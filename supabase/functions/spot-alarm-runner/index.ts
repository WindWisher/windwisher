import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse } from "../_shared/http.ts";

type AlarmRow = {
  id: string;
  user_id: string;
  spot_key: string;
  spot_name: string;
  spot_area: string;
  station_provider: string;
  station_key: string;
  station_name: string;
  wind_range_start: number;
  wind_range_end: number;
  start_hour: number;
  end_hour: number;
  start_minute: number;
  end_minute: number;
  directions: string[];
  repeat_window: string;
  max_repeats: number;
  trigger_count: number;
  last_triggered_at: string | null;
  snoozed_until: string | null;
  stopped_until_reset: boolean;
};

const MAX_OBSERVATION_AGE_MINUTES = 80;

type PushSubscriptionRow = {
  user_id: string;
  device_token: string;
  platform: string;
  provider: string;
  enabled: boolean;
};

type PushFailure = {
  reason: string;
  disableToken: boolean;
};

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const anonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
const aemetApiKey = Deno.env.get("AEMET_OPENDATA_API_KEY") ?? "";
const runnerSecret = Deno.env.get("SPOT_ALARM_RUNNER_SECRET") ?? "";
const firebaseServiceAccountJson =
  Deno.env.get("FIREBASE_SERVICE_ACCOUNT_JSON") ?? "";

const supabase = createClient(supabaseUrl, anonKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "method-not-allowed" }, { status: 405 });
  }
  if (!runnerSecret) {
    return jsonResponse(
      { error: "missing-runner-secret" },
      { status: 500 },
    );
  }
  if (
    (request.headers.get("authorization") ?? "") !== `Bearer ${runnerSecret}`
  ) {
    return jsonResponse({ error: "unauthorized" }, { status: 401 });
  }
  if (!supabaseUrl || !anonKey) {
    return jsonResponse(
      { error: "missing-supabase-anon-key" },
      { status: 500 },
    );
  }

  const alarmRows = await loadAlarmRows();
  const pushSubscriptions = await loadPushSubscriptions();
  const pushByUserId = new Map<string, PushSubscriptionRow[]>();
  for (const subscription of pushSubscriptions) {
    const list = pushByUserId.get(subscription.user_id) ?? [];
    list.push(subscription);
    pushByUserId.set(subscription.user_id, list);
  }

  let evaluated = 0;
  let active = 0;
  let logged = 0;
  let unsupported = 0;
  const diagnostics: Record<string, unknown>[] = [];

  for (const alarm of alarmRows) {
    evaluated += 1;
    if (!supportsStationProvider(alarm.station_provider)) {
      unsupported += 1;
      diagnostics.push({
        alarmId: alarm.id,
        stationProvider: alarm.station_provider,
        status: "unsupported-provider",
      });
      await logDelivery(alarm, "skipped", "unsupported-provider", null);
      logged += 1;
      continue;
    }
    if (alarm.station_provider === "AEMET" && !aemetApiKey) {
      diagnostics.push({
        alarmId: alarm.id,
        stationProvider: alarm.station_provider,
        status: "missing-aemet-api-key",
      });
      await logDelivery(alarm, "skipped", "missing-aemet-api-key", null);
      logged += 1;
      continue;
    }

    const observation = await fetchObservationForAlarm(alarm);
    if (!observation) {
      diagnostics.push({
        alarmId: alarm.id,
        stationKey: alarm.station_key,
        status: "missing-observation",
      });
      await logDelivery(alarm, "skipped", "missing-observation", null);
      logged += 1;
      continue;
    }

    const evaluation = evaluateAlarm(alarm, observation);
    diagnostics.push({
      alarmId: alarm.id,
      stationKey: alarm.station_key,
      stationName: alarm.station_name,
      active: evaluation.active,
      reason: evaluation.reason,
      observedAt: observation.observedAt?.toISOString(),
      observedWindKnots: observation.windKnots,
      observedDirection: observation.windDirectionBucket,
      expectedWindStart: alarm.wind_range_start,
      expectedWindEnd: alarm.wind_range_end,
      expectedDirections: alarm.directions,
      expectedStartHour: alarm.start_hour,
      expectedStartMinute: alarm.start_minute,
      expectedEndHour: alarm.end_hour,
      expectedEndMinute: alarm.end_minute,
    });
    if (!evaluation.active) {
      if (
        alarm.trigger_count !== 0 ||
        alarm.last_triggered_at != null ||
        alarm.snoozed_until != null ||
        alarm.stopped_until_reset
      ) {
        await resetTriggerState(alarm);
      }
      continue;
    }
    active += 1;

    const subscriptions = pushByUserId.get(alarm.user_id) ?? [];
    if (subscriptions.length == 0) {
      await logDelivery(
        alarm,
        "ready",
        "no-push-subscription",
        evaluation.payload,
      );
      logged += 1;
      continue;
    }

    const now = new Date();
    const snoozedUntil = alarm.snoozed_until
      ? new Date(alarm.snoozed_until)
      : null;
    if (snoozedUntil != null && snoozedUntil.getTime() > now.getTime()) {
      await logDelivery(
        alarm,
        "skipped",
        "snoozed-until-next-repeat",
        evaluation.payload,
      );
      logged += 1;
      continue;
    }

    if (alarm.stopped_until_reset) {
      await logDelivery(
        alarm,
        "skipped",
        "stopped-until-conditions-reset",
        evaluation.payload,
      );
      logged += 1;
      continue;
    }

    if (alarm.trigger_count >= alarm.max_repeats) {
      await logDelivery(
        alarm,
        "skipped",
        "max-repeats-reached-for-current-active-window",
        evaluation.payload,
      );
      logged += 1;
      continue;
    }

    if (!firebaseServiceAccountJson.trim()) {
      await logDelivery(
        alarm,
        "skipped",
        "missing-firebase-service-account-json",
        evaluation.payload,
      );
      logged += 1;
      continue;
    }

    const firebase = parseFirebaseServiceAccount(firebaseServiceAccountJson);
    if (!firebase) {
      await logDelivery(
        alarm,
        "skipped",
        "invalid-firebase-service-account-json",
        evaluation.payload,
      );
      logged += 1;
      continue;
    }

    const delivery = await sendAlarmPushes({
      firebase,
      alarm,
      title: `Alarma activa · ${alarm.station_name}`,
      body:
        `${alarm.spot_name}: ${formatKnots(evaluation.payload?.windKnots)} · ` +
        `${String(evaluation.payload?.direction ?? "-")}`,
      payload: evaluation.payload,
      subscriptions,
    });

    await logDelivery(
      alarm,
      delivery.sent > 0 ? "sent" : "failed",
      delivery.reason,
      {
        ...evaluation.payload,
        sent: delivery.sent,
        failed: delivery.failed,
      },
    );

    if (delivery.sent > 0) {
      await updateTriggerState(alarm, alarm.trigger_count + 1, now);
    }
    logged += 1;
  }

  return jsonResponse({
    ok: true,
    evaluated,
    active,
    logged,
    unsupported,
    diagnostics,
  });
});

async function loadAlarmRows(): Promise<AlarmRow[]> {
  const { data, error } = await supabase
    .rpc("get_backend_spot_alarm_runner_alarms");
  if (error) {
    throw error;
  }
  return (data ?? []) as AlarmRow[];
}

type FirebaseServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

function parseFirebaseServiceAccount(
  raw: string,
): FirebaseServiceAccount | null {
  try {
    const parsed = JSON.parse(raw) as Partial<FirebaseServiceAccount>;
    if (
      typeof parsed.project_id !== "string" ||
      typeof parsed.client_email !== "string" ||
      typeof parsed.private_key !== "string" ||
      !parsed.project_id.trim() ||
      !parsed.client_email.trim() ||
      !parsed.private_key.trim()
    ) {
      return null;
    }
    return {
      project_id: parsed.project_id.trim(),
      client_email: parsed.client_email.trim(),
      private_key: parsed.private_key,
    };
  } catch (_) {
    return null;
  }
}

async function sendAlarmPushes({
  firebase,
  alarm,
  title,
  body,
  payload,
  subscriptions,
}: {
  firebase: FirebaseServiceAccount;
  alarm: AlarmRow;
  title: string;
  body: string;
  payload: Record<string, unknown> | null;
  subscriptions: PushSubscriptionRow[];
}) {
  const accessToken = await getFirebaseAccessToken(firebase);
  let sent = 0;
  let failed = 0;
  const failureReasons: string[] = [];
  for (const subscription of subscriptions) {
    if (subscription.user_id !== alarm.user_id) {
      failed += 1;
      failureReasons.push("push-subscription-user-mismatch");
      continue;
    }
    if (subscription.provider !== "fcm") {
      failed += 1;
      failureReasons.push("unsupported-push-provider");
      continue;
    }
    const response = await fetch(
      `https://fcm.googleapis.com/v1/projects/${firebase.project_id}/messages:send`,
      {
        method: "POST",
        headers: {
          authorization: `Bearer ${accessToken}`,
          "content-type": "application/json; charset=utf-8",
        },
        body: JSON.stringify({
          message: {
            token: subscription.device_token,
            data: {
              type: "spot_alarm",
              alarmId: alarm.id,
              spotKey: alarm.spot_key,
              stationKey: alarm.station_key,
              stationProvider: alarm.station_provider,
              repeatWindow: alarm.repeat_window,
              maxRepeats: String(alarm.max_repeats),
              occurrenceIndex: String(alarm.trigger_count),
              title,
              body,
            },
            android: {
              priority: "high",
            },
            apns: {
              headers: {
                "apns-priority": "10",
                "apns-push-type": "alert",
              },
              payload: {
                aps: {
                  alert: {
                    title,
                    body,
                  },
                  category: "spot_alarm_actions",
                  "interruption-level": "time-sensitive",
                  sound: "default",
                },
              },
            },
          },
        }),
      },
    );
    if (response.ok) {
      sent += 1;
    } else {
      failed += 1;
      const responseText = await response.text();
      const failure = classifyPushFailure(response.status, responseText);
      failureReasons.push(failure.reason);
      if (failure.disableToken) {
        await disableInvalidPushSubscription(subscription);
      }
    }
  }
  return {
    sent,
    failed,
    reason: sent > 0
      ? (failed > 0 ? "partial-push-delivery" : "push-delivered")
      : (failureReasons[0] ?? "push-send-failed"),
    payload,
  };
}

function classifyPushFailure(
  status: number,
  responseText: string,
): PushFailure {
  const trimmed = responseText.slice(0, 180);
  const raw = `fcm-${status}:${trimmed}`;
  if (
    responseText.includes('"errorCode": "UNREGISTERED"') ||
    responseText.includes("UNREGISTERED")
  ) {
    return {
      reason: `fcm-${status}:UNREGISTERED`,
      disableToken: true,
    };
  }
  return {
    reason: raw,
    disableToken: false,
  };
}

async function disableInvalidPushSubscription(
  subscription: PushSubscriptionRow,
) {
  const { error } = await supabase.rpc("disable_backend_push_subscription", {
    target_user_id: subscription.user_id,
    target_device_token: subscription.device_token,
  });
  if (error) {
    console.error("disable-invalid-push-subscription-failed", {
      userId: subscription.user_id,
      platform: subscription.platform,
      provider: subscription.provider,
      error: error.message,
    });
  }
}

async function getFirebaseAccessToken(
  serviceAccount: FirebaseServiceAccount,
) {
  const now = Math.floor(Date.now() / 1000);
  const header = {
    alg: "RS256",
    typ: "JWT",
  };
  const claimSet = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };
  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedClaimSet = base64UrlEncode(JSON.stringify(claimSet));
  const unsignedJwt = `${encodedHeader}.${encodedClaimSet}`;
  const signature = await signJwt(unsignedJwt, serviceAccount.private_key);
  const assertion = `${unsignedJwt}.${signature}`;

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: {
      "content-type": "application/x-www-form-urlencoded",
    },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });
  if (!response.ok) {
    throw new Error(`firebase-token-request-failed:${response.status}`);
  }
  const data = await response.json() as { access_token?: string };
  if (!data.access_token) {
    throw new Error("missing-firebase-access-token");
  }
  return data.access_token;
}

async function signJwt(unsignedJwt: string, privateKeyPem: string) {
  const pemContents = privateKeyPem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replaceAll(/\s+/g, "");
  const keyBytes = Uint8Array.from(
    atob(pemContents),
    (char) => char.charCodeAt(0),
  );
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    keyBytes.buffer,
    {
      name: "RSASSA-PKCS1-v1_5",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    cryptoKey,
    new TextEncoder().encode(unsignedJwt),
  );
  return base64UrlEncodeBytes(new Uint8Array(signature));
}

function base64UrlEncode(value: string) {
  return base64UrlEncodeBytes(new TextEncoder().encode(value));
}

function base64UrlEncodeBytes(bytes: Uint8Array) {
  let binary = "";
  for (const byte of bytes) {
    binary += String.fromCharCode(byte);
  }
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll(
    "=",
    "",
  );
}

function formatKnots(raw: unknown) {
  if (typeof raw !== "number" || !Number.isFinite(raw)) {
    return "-";
  }
  return `${raw.toFixed(1)} kt`;
}

async function loadPushSubscriptions(): Promise<PushSubscriptionRow[]> {
  const { data, error } = await supabase
    .rpc("get_backend_push_subscriptions");
  if (error) {
    throw error;
  }
  return (data ?? []) as PushSubscriptionRow[];
}

async function logDelivery(
  alarm: AlarmRow,
  status: string,
  reason: string,
  payload: Record<string, unknown> | null,
) {
  const { error: rpcError } = await supabase.rpc(
    "log_backend_spot_alarm_delivery",
    {
      target_alarm_id: alarm.id,
      target_station_provider: alarm.station_provider,
      target_station_key: alarm.station_key,
      delivery_status: status,
      delivery_reason: reason,
      delivery_payload: payload,
    },
  );
  if (rpcError) {
    throw rpcError;
  }
}

async function resetTriggerState(alarm: AlarmRow) {
  const { error } = await supabase.rpc(
    "update_backend_spot_alarm_trigger_state",
    {
      target_alarm_id: alarm.id,
      reset_trigger_state: true,
    },
  );
  if (error) {
    throw error;
  }
}

async function updateTriggerState(
  alarm: AlarmRow,
  nextTriggerCount: number,
  nextLastTriggeredAt: Date,
) {
  const { error } = await supabase.rpc(
    "update_backend_spot_alarm_trigger_state",
    {
      target_alarm_id: alarm.id,
      next_trigger_count: nextTriggerCount,
      next_last_triggered_at: nextLastTriggeredAt.toISOString(),
      reset_trigger_state: false,
    },
  );
  if (error) {
    throw error;
  }
}

async function fetchObservationForAlarm(alarm: AlarmRow) {
  switch (alarm.station_provider) {
    case "AEMET":
      return await fetchAemetStationObservation(alarm.station_key);
    case "AIGUABLANCA":
      return await fetchAiguaBlancaObservation();
    case "INFORATGE":
      return await fetchInforatgeObservation(alarm.station_key);
    case "AVAMET":
      return await fetchAvametObservation(alarm.station_key);
    case "WINDGURU_STATION":
      return await fetchWindguruStationObservation(alarm.station_key);
    case "WUNDERGROUND":
      return await fetchWundergroundObservation(alarm.station_key);
    case "METEOCLIMATIC":
      return await fetchMeteoclimaticObservation(alarm.station_key);
    case "PUERTOS":
    case "PORTUS":
      return await fetchPortusObservation(alarm.station_key);
    default:
      return null;
  }
}

function supportsStationProvider(provider: string) {
  return provider === "AEMET" ||
    provider === "AIGUABLANCA" ||
    provider === "INFORATGE" ||
    provider === "AVAMET" ||
    provider === "WINDGURU_STATION" ||
    provider === "WUNDERGROUND" ||
    provider === "METEOCLIMATIC" ||
    provider === "PUERTOS" ||
    provider === "PORTUS";
}

async function fetchAemetStationObservation(stationId: string) {
  const envelope = await fetchJsonObject(
    `https://opendata.aemet.es/opendata/api/observacion/convencional/datos/estacion/${
      encodeURIComponent(stationId)
    }/?api_key=${aemetApiKey}`,
  );
  const dataUrl = readDatosUrl(envelope);
  const data = await fetchJsonArray(dataUrl);
  const latest = data.at(-1) as Record<string, unknown> | undefined;
  if (!latest) {
    return null;
  }
  return {
    observedAt: parseDate(latest.fint),
    windKnots: parseKnots(latest.vv),
    windDirectionBucket: directionBucket(latest.dv),
  };
}

async function fetchAiguaBlancaObservation() {
  const payload = await fetchJsonObject(
    "https://meteo.feedket.com/api/endpoints/latest.php",
    { "X-API-KEY": "GDFH85DF-GD75D65-SFSEF5" },
  );
  const latest = asRecord(payload.latest);
  if (!latest) {
    return null;
  }
  return {
    observedAt: parseDateWithUtcSuffix(latest.created_at),
    windKnots: parseNumber(latest.wind_speed_kt),
    windDirectionBucket: directionBucket(latest.wind_dir),
  };
}

async function fetchInforatgeObservation(stationKey: string) {
  const stationId = extractStationId(stationKey);
  const liveUrl = inforatgeLiveUrlForStation(stationId);
  const body = await fetchText(liveUrl);
  const updatedMatch = body.match(
    /<h2>(\d{1,2}:\d{2}:\d{2})<br>(.*?)<\/h2>/is,
  );
  const windMatch = body.match(
    /velocitat i direcci&oacute; del vent<\/div>\s*<div class="blocValor">(\d+(?:,\d+)?)<span class="vPetit">\s*([^<]+)<\/span><\/div>\s*<div class="blocUnitats">km\/h<\/div>/is,
  );
  if (!updatedMatch || !windMatch) {
    return null;
  }
  const observedAt = parseInforatgeObservedAt(updatedMatch[1], updatedMatch[2]);
  const windKmh = parseNumber(windMatch[1]);
  if (!observedAt || windKmh == null) {
    return null;
  }
  return {
    observedAt,
    windKnots: Number((windKmh * 0.539957).toFixed(2)),
    windDirectionBucket: directionBucket(cardinalToDegrees(windMatch[2])),
    observedTotalMinutesLocal: localTotalMinutesFromDate(observedAt),
  };
}

function inforatgeLiveUrlForStation(stationId: string) {
  if (stationId === "46181e01") {
    return "https://inforatge.com/meteo-oliva";
  }
  if (stationId === "46105e02") {
    return "https://inforatge.com/meteo-cullera";
  }
  return "https://inforatge.com/meteo-oliva-02";
}

async function fetchAvametObservation(stationKey: string) {
  const stationId = extractStationId(stationKey);
  const body = await fetchText(
    `https://www.avamet.org/mxo_i.php?id=${stationId}`,
  );
  const normalized = body
    .replaceAll("&nbsp;", " ")
    .replaceAll("&#160;", " ")
    .replaceAll("&deg;", "°")
    .replaceAll(/<[^>]+>/g, " ")
    .replaceAll(/\s+/g, " ")
    .trim();
  const observedAtMatch = normalized.match(
    /(\d{2}-\d{2}-\d{4})\s+(\d{2}:\d{2})/,
  );
  const windMatch = normalized.match(
    /Vent[^0-9]*([0-9\.,]+)\s*km\/h\s*([A-Z]{1,3})/i,
  );
  if (!windMatch) {
    return null;
  }
  const observedAt = observedAtMatch
    ? parseDdMmYyyyHm(observedAtMatch[1], observedAtMatch[2])
    : null;
  const windKmh = parseNumber(windMatch[1]);
  if (windKmh == null) {
    return null;
  }
  return {
    observedAt,
    windKnots: Number((windKmh * 0.539957).toFixed(2)),
    windDirectionBucket: directionBucket(cardinalToDegrees(windMatch[2])),
    observedTotalMinutesLocal: localTotalMinutesFromDate(observedAt),
  };
}

async function fetchPortusObservation(stationKey: string) {
  const stationId = extractStationId(stationKey);
  const payload = await fetchPortusJson(
    `https://portus.puertos.es/portussvr/api/lastData/station/${
      encodeURIComponent(stationId)
    }?locale=es`,
    ["WIND", "AIR_TEMP", "AIR_PRESURE"],
  );
  const record = asRecord(payload);
  if (!record) {
    return null;
  }
  const observedAt = parsePortusDate(record.fecha);
  const rawData = Array.isArray(record.datos) ? record.datos : [];
  let windMps: number | null = null;
  let windDeg: number | null = null;
  for (const item of rawData) {
    const entry = asRecord(item);
    if (!entry) {
      continue;
    }
    const param = typeof entry.paramEseoo === "string"
      ? entry.paramEseoo
      : null;
    const value = scaledPortusValue(entry);
    if (param === "WindSpeed") {
      windMps = value;
    } else if (param === "WindDir") {
      windDeg = value;
    }
  }
  if (windMps == null) {
    return null;
  }
  return {
    observedAt,
    windKnots: Number((windMps * 1.9438444924406).toFixed(2)),
    windDirectionBucket: directionBucket(windDeg),
    observedTotalMinutesLocal: localTotalMinutesFromDate(observedAt),
  };
}

async function fetchWindguruStationObservation(stationKey: string) {
  const stationId = extractStationId(stationKey);
  const url = new URL("https://www.windguru.cz/int/iapi.php");
  url.searchParams.set("callback", "windwisher");
  url.searchParams.set("q", "station_data_current");
  url.searchParams.set("id_station", stationId);
  url.searchParams.set("date_format", "Y-m-d H:i:s T");

  const response = await fetch(url, {
    headers: {
      accept: "application/javascript,text/javascript,*/*",
      referer: "https://www.dkpiles.com/meteo.html",
      "user-agent": "WindWisher/1.0",
    },
  });
  if (!response.ok) {
    throw new Error(`windguru-request-failed:${response.status}`);
  }
  const raw = (await response.text()).trim();
  const data = asRecord(JSON.parse(decodeJsonp(raw, "windwisher")));
  if (!data || data.return === "error") {
    return null;
  }

  const unixTime = parseNumber(data.unixtime);
  const windKnots = parseNumber(data.wind_avg);
  if (unixTime == null || windKnots == null) {
    return null;
  }
  const observedAt = new Date(unixTime * 1000);
  return {
    observedAt,
    windKnots,
    windDirectionBucket: directionBucket(data.wind_direction),
    observedTotalMinutesLocal: localTotalMinutesFromDate(observedAt),
  };
}

async function fetchWundergroundObservation(stationKey: string) {
  const stationId = extractStationId(stationKey);
  const apiKey = await fetchWundergroundApiKey(stationId);
  const url = new URL("https://api.weather.com/v2/pws/observations/current");
  url.searchParams.set("stationId", stationId);
  url.searchParams.set("numericPrecision", "decimal");
  url.searchParams.set("format", "json");
  url.searchParams.set("units", "m");
  url.searchParams.set("apiKey", apiKey);

  const payload = await fetchJsonObject(url.toString(), {
    referer: "https://www.wunderground.com/",
    "user-agent": "WindWisher/1.0",
  });
  const observations = Array.isArray(payload.observations)
    ? payload.observations
    : [];
  const latest = asRecord(observations[0]);
  if (!latest) {
    return null;
  }
  const metric = asRecord(latest.metric);
  if (!metric) {
    return null;
  }
  const windKmh = parseNumber(metric.windSpeed);
  if (windKmh == null) {
    return null;
  }
  return {
    observedAt: parseWundergroundObservedAt(latest),
    windKnots: Number((windKmh * 0.539957).toFixed(2)),
    windDirectionBucket: directionBucket(latest.winddir),
  };
}

async function fetchMeteoclimaticObservation(stationKey: string) {
  const stationId = extractStationId(stationKey);
  const body = await fetchText(
    `https://www.meteoclimatic.net/feed/rss/${encodeURIComponent(stationId)}`,
    meteoclimaticRequestHeaders(),
  );
  const dataMatch = body.match(
    /\[\[<([A-Z0-9]+);\(([^)]*)\);\(([^)]*)\);\(([^)]*)\);\(([^)]*)\);\(([^)]*)\);([^>]*)>\]\]/s,
  );
  if (!dataMatch) {
    return null;
  }
  const wind = splitMeteoclimaticTuple(dataMatch[5]);
  const windKmh = parseMeteoclimaticNumber(wind[0]);
  if (windKmh == null) {
    return null;
  }
  return {
    observedAt: parseMeteoclimaticObservedAt(body),
    windKnots: Number((windKmh * 0.539957).toFixed(2)),
    windDirectionBucket: directionBucket(parseMeteoclimaticNumber(wind[2])),
  };
}

function splitMeteoclimaticTuple(tuple: string | undefined) {
  return tuple?.split(";").map((value) => value.trim()) ?? [];
}

function parseMeteoclimaticNumber(value: string | undefined) {
  if (!value) {
    return null;
  }
  const parsed = Number(value.replace(",", "."));
  return Number.isFinite(parsed) ? parsed : null;
}

function parseMeteoclimaticObservedAt(body: string) {
  const pubDate = body.match(/<pubDate>([^<]+)<\/pubDate>/)?.[1]?.trim();
  if (!pubDate) {
    return null;
  }
  const observedAt = new Date(pubDate);
  return Number.isNaN(observedAt.getTime()) ? null : observedAt;
}

async function fetchWundergroundApiKey(stationId: string) {
  const dashboard = await fetchText(
    `https://www.wunderground.com/dashboard/pws/${
      encodeURIComponent(stationId)
    }`,
  );
  const match = dashboard.match(/apiKey=([A-Za-z0-9]+)/);
  const apiKey = match?.[1];
  if (!apiKey) {
    throw new Error("wunderground-api-key-not-found");
  }
  return apiKey;
}

function evaluateAlarm(
  alarm: AlarmRow,
  observation: {
    observedAt: Date | null;
    windKnots: number | null;
    windDirectionBucket: string | null;
    observedTotalMinutesLocal?: number | null;
  },
) {
  if (observation.windKnots == null) {
    return { active: false, payload: null, reason: "missing-wind-or-time" };
  }
  const now = new Date();
  const totalMinutes = madridTotalMinutes(now);
  const observationAgeMinutes = observation.observedAt == null
    ? null
    : Math.max(
      0,
      Math.floor((now.getTime() - observation.observedAt.getTime()) / 60000),
    );
  const freshEnough = observationAgeMinutes == null ||
    observationAgeMinutes <= MAX_OBSERVATION_AGE_MINUTES;
  const timeMatches = isMinuteInRange(
    totalMinutes,
    alarm.start_hour,
    alarm.start_minute,
    alarm.end_hour,
    alarm.end_minute,
  );
  const windMatches = observation.windKnots >= alarm.wind_range_start &&
    observation.windKnots <= alarm.wind_range_end;
  const directionMatches = observation.windDirectionBucket != null &&
    alarm.directions.includes(observation.windDirectionBucket);
  const active = freshEnough && timeMatches && windMatches && directionMatches;
  const reason = active
    ? "active"
    : !freshEnough
    ? "stale-observation"
    : !timeMatches
    ? "time-mismatch"
    : !windMatches
    ? "wind-mismatch"
    : "direction-mismatch";
  return {
    active,
    reason,
    payload: {
      spotKey: alarm.spot_key,
      spotName: alarm.spot_name,
      stationKey: alarm.station_key,
      stationName: alarm.station_name,
      observedAt: observation.observedAt?.toISOString() ?? null,
      observedAgeMinutes: observationAgeMinutes,
      windKnots: observation.windKnots,
      direction: observation.windDirectionBucket,
    },
  };
}

function madridTotalMinutes(value: Date) {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: "Europe/Madrid",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).formatToParts(value);
  const hour = Number(parts.find((part) => part.type === "hour")?.value ?? "0");
  const minute = Number(
    parts.find((part) => part.type === "minute")?.value ?? "0",
  );
  return (hour * 60) + minute;
}

function localTotalMinutesFromDate(value: Date | null) {
  if (!value) {
    return null;
  }
  return (value.getHours() * 60) + value.getMinutes();
}

function isMinuteInRange(
  totalMinutes: number,
  startHour: number,
  startMinute: number,
  endHour: number,
  endMinute: number,
) {
  const startTotal = (startHour * 60) + startMinute;
  const endTotal = (endHour * 60) + endMinute;
  if (startTotal === endTotal) {
    return true;
  }
  if (startTotal < endTotal) {
    return totalMinutes >= startTotal && totalMinutes < endTotal;
  }
  return totalMinutes >= startTotal || totalMinutes < endTotal;
}

function directionBucket(raw: unknown): string | null {
  const numeric = parseNumber(raw);
  if (numeric == null) {
    return null;
  }
  const normalized = ((numeric % 360) + 360) % 360;
  if (normalized < 23 || normalized >= 338) return "N";
  if (normalized < 68) return "NE";
  if (normalized < 113) return "E";
  if (normalized < 158) return "SE";
  if (normalized < 203) return "S";
  if (normalized < 248) return "SW";
  if (normalized < 293) return "W";
  return "NW";
}

function parseKnots(raw: unknown): number | null {
  const numeric = parseNumber(raw);
  if (numeric == null) {
    return null;
  }
  return Number((numeric * 0.539957).toFixed(2));
}

function parseNumber(raw: unknown): number | null {
  if (typeof raw === "number" && Number.isFinite(raw)) {
    return raw;
  }
  if (typeof raw !== "string") {
    return null;
  }
  const normalized = raw.replace(",", ".").trim();
  if (!normalized) {
    return null;
  }
  const numeric = Number(normalized);
  return Number.isFinite(numeric) ? numeric : null;
}

function parseDate(raw: unknown): Date | null {
  if (typeof raw !== "string" || !raw.trim()) {
    return null;
  }
  const parsed = new Date(raw);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function parsePortusDate(raw: unknown): Date | null {
  if (typeof raw !== "string" || !raw.trim()) {
    return null;
  }
  const match = raw.trim().match(
    /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/,
  );
  if (!match) {
    return null;
  }
  const year = Number(match[1]);
  const month = Number(match[2]);
  const day = Number(match[3]);
  const hour = Number(match[4]);
  const minute = Number(match[5]);
  const second = Number(match[6]);
  if (
    !Number.isFinite(year) ||
    !Number.isFinite(month) ||
    !Number.isFinite(day) ||
    !Number.isFinite(hour) ||
    !Number.isFinite(minute) ||
    !Number.isFinite(second)
  ) {
    return null;
  }
  return new Date(year, month - 1, day, hour, minute, second);
}

function parseWundergroundObservedAt(
  observation: Record<string, unknown>,
): Date | null {
  const epoch = parseNumber(observation.epoch);
  if (epoch != null) {
    return new Date(epoch * 1000);
  }
  return parseDate(observation.obsTimeUtc);
}

function scaledPortusValue(entry: Record<string, unknown>): number | null {
  const value = parseNumber(entry.valor);
  const factor = parseNumber(entry.factor);
  if (value == null || factor == null || factor === 0) {
    return null;
  }
  return value / factor;
}

function decodeJsonp(raw: string, callback: string): string {
  const prefix = `${callback}(`;
  if (raw.startsWith(prefix) && raw.endsWith(");")) {
    return raw.slice(prefix.length, -2);
  }
  return raw;
}

async function fetchJsonObject(
  url: string,
  headers: Record<string, string> = {},
): Promise<Record<string, unknown>> {
  const response = await fetch(url, {
    headers: { accept: "application/json", ...headers },
  });
  if (!response.ok) {
    throw new Error(`request-failed:${response.status}`);
  }
  return await response.json() as Record<string, unknown>;
}

async function fetchJsonArray(url: string): Promise<unknown[]> {
  const response = await fetch(url, {
    headers: { accept: "application/json" },
  });
  if (!response.ok) {
    throw new Error(`request-failed:${response.status}`);
  }
  return await response.json() as unknown[];
}

async function fetchPortusJson(url: string, body: unknown): Promise<unknown> {
  const response = await fetch(url, {
    method: "POST",
    headers: {
      accept: "application/json",
      "content-type": "application/json",
    },
    body: JSON.stringify(body),
  });
  if (!response.ok) {
    throw new Error(`portus-request-failed:${response.status}`);
  }
  return await response.json();
}

async function fetchText(
  url: string,
  headers: Record<string, string> = {
    accept: "text/html,application/xhtml+xml",
    "user-agent": "WindWisher/1.0",
  },
): Promise<string> {
  const response = await fetch(url, {
    headers,
  });
  if (!response.ok) {
    throw new Error(`request-failed:${response.status}`);
  }
  return await response.text();
}

function meteoclimaticRequestHeaders() {
  return {
    "accept":
      "application/rss+xml, application/xml;q=0.9, text/xml;q=0.8, */*;q=0.7",
    "accept-language": "es-ES,es;q=0.9,en;q=0.8",
    "cache-control": "no-cache",
    "pragma": "no-cache",
    "referer": "https://www.meteoclimatic.net/",
    "user-agent":
      "Mozilla/5.0 (compatible; WindWisher/1.0; +https://windwisher.app)",
  };
}

function asRecord(value: unknown): Record<string, unknown> | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }
  return value as Record<string, unknown>;
}

function extractStationId(stationKey: string) {
  const parts = stationKey.split(":");
  return parts.length > 1 ? parts[parts.length - 1] : stationKey;
}

function parseDateWithUtcSuffix(raw: unknown) {
  if (typeof raw !== "string" || !raw.trim()) {
    return null;
  }
  const normalized = `${raw.trim().replace(" ", "T")}Z`;
  return parseDate(normalized);
}

function parseDdMmYyyyHm(datePart: string, timePart: string) {
  const [day, month, year] = datePart.split("-").map((value) => Number(value));
  const [hour, minute] = timePart.split(":").map((value) => Number(value));
  if (
    !Number.isFinite(day) || !Number.isFinite(month) ||
    !Number.isFinite(year) ||
    !Number.isFinite(hour) || !Number.isFinite(minute)
  ) {
    return null;
  }
  return new Date(year, month - 1, day, hour, minute);
}

function parseInforatgeObservedAt(timeValue: string, dateValue: string) {
  const timeMatch = timeValue.trim().match(/^(\d{1,2}):(\d{2}):(\d{2})$/);
  const dateMatch = dateValue.replaceAll("\n", " ").trim().match(
    /(\d{1,2}) de ([a-zA-Z&;]+) de (\d{4})/i,
  );
  if (!timeMatch || !dateMatch) {
    return null;
  }
  const day = Number(dateMatch[1]);
  const month = monthFromCatalan(dateMatch[2]);
  const year = Number(dateMatch[3]);
  const hour = Number(timeMatch[1]);
  const minute = Number(timeMatch[2]);
  const second = Number(timeMatch[3]);
  if (
    month == null ||
    !Number.isFinite(day) ||
    !Number.isFinite(year) ||
    !Number.isFinite(hour) ||
    !Number.isFinite(minute) ||
    !Number.isFinite(second)
  ) {
    return null;
  }
  return new Date(year, month - 1, day, hour, minute, second);
}

function monthFromCatalan(value: string) {
  const normalized = value
    .toLowerCase()
    .replaceAll("&ccedil;", "c")
    .replaceAll("ç", "c")
    .trim();
  switch (normalized) {
    case "gener":
      return 1;
    case "febrer":
      return 2;
    case "marc":
      return 3;
    case "abril":
      return 4;
    case "maig":
      return 5;
    case "juny":
      return 6;
    case "juliol":
      return 7;
    case "agost":
      return 8;
    case "setembre":
      return 9;
    case "octubre":
      return 10;
    case "novembre":
      return 11;
    case "desembre":
      return 12;
    default:
      return null;
  }
}

function cardinalToDegrees(raw: string) {
  const normalized = raw.trim().toUpperCase();
  const degrees: Record<string, number> = {
    N: 0,
    NNE: 23,
    NE: 45,
    ENE: 68,
    E: 90,
    ESE: 113,
    SE: 135,
    SSE: 158,
    S: 180,
    SSO: 203,
    SSW: 203,
    SO: 225,
    SW: 225,
    OSO: 248,
    WSW: 248,
    O: 270,
    W: 270,
    ONO: 293,
    WNW: 293,
    NO: 315,
    NW: 315,
    NNO: 338,
    NNW: 338,
  };
  return degrees[normalized] ?? null;
}

function readDatosUrl(envelope: Record<string, unknown>): string {
  const raw = envelope.datos;
  if (typeof raw !== "string" || !raw.trim()) {
    throw new Error("missing-datos-url");
  }
  return raw;
}
