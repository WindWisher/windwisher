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

type PushSubscriptionRow = {
  user_id: string;
  device_token: string;
  platform: string;
  provider: string;
  enabled: boolean;
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
  if ((request.headers.get("authorization") ?? "") !== `Bearer ${runnerSecret}`) {
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
    if (alarm.station_provider !== "AEMET") {
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

    if (!aemetApiKey) {
      diagnostics.push({
        alarmId: alarm.id,
        stationProvider: alarm.station_provider,
        status: "missing-aemet-api-key",
      });
      await logDelivery(alarm, "skipped", "missing-aemet-api-key", null);
      logged += 1;
      continue;
    }

    const observation = await fetchAemetStationObservation(alarm.station_key);
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

    if (alarm.stopped_until_reset) {
      continue;
    }

    const subscriptions = pushByUserId.get(alarm.user_id) ?? [];
    if (subscriptions.length == 0) {
      await logDelivery(alarm, "ready", "no-push-subscription", evaluation.payload);
      logged += 1;
      continue;
    }

    if (alarm.trigger_count >= alarm.max_repeats) {
      await logDelivery(alarm, "skipped", "max-repeats-reached", evaluation.payload);
      logged += 1;
      continue;
    }

    const now = new Date();
    if (!canRepeat(alarm, now)) {
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

function parseFirebaseServiceAccount(raw: string): FirebaseServiceAccount | null {
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
  for (const subscription of subscriptions) {
    if (subscription.provider !== "fcm") {
      failed += 1;
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
            notification: {
              title,
              body,
            },
            data: {
              type: "spot_alarm",
              alarmId: alarm.id,
              spotKey: alarm.spot_key,
              stationKey: alarm.station_key,
              stationProvider: alarm.station_provider,
            },
            android: {
              priority: "high",
              notification: {
                channel_id: "spot_alarms_v2",
                sound: "default",
                default_sound: true,
                default_vibrate_timings: true,
                notification_priority: "PRIORITY_MAX",
              },
            },
            apns: {
              headers: {
                "apns-priority": "10",
                "apns-push-type": "alert",
              },
              payload: {
                aps: {
                  sound: "default",
                  badge: 1,
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
    }
  }
  return {
    sent,
    failed,
    reason: sent > 0
      ? (failed > 0 ? "partial-push-delivery" : "push-delivered")
      : "push-send-failed",
    payload,
  };
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
  const keyBytes = Uint8Array.from(atob(pemContents), (char) => char.charCodeAt(0));
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
  return btoa(binary).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
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
  const { error: rpcError } = await supabase.rpc("log_backend_spot_alarm_delivery", {
    target_alarm_id: alarm.id,
    target_station_provider: alarm.station_provider,
    target_station_key: alarm.station_key,
    delivery_status: status,
    delivery_reason: reason,
    delivery_payload: payload,
  });
  if (rpcError) {
    throw rpcError;
  }
}

async function resetTriggerState(alarm: AlarmRow) {
  const { error } = await supabase.rpc("update_backend_spot_alarm_trigger_state", {
    target_alarm_id: alarm.id,
    reset_trigger_state: true,
  });
  if (error) {
    throw error;
  }
}

async function updateTriggerState(
  alarm: AlarmRow,
  nextTriggerCount: number,
  nextLastTriggeredAt: Date,
) {
  const { error } = await supabase.rpc("update_backend_spot_alarm_trigger_state", {
    target_alarm_id: alarm.id,
    next_trigger_count: nextTriggerCount,
    next_last_triggered_at: nextLastTriggeredAt.toISOString(),
    reset_trigger_state: false,
  });
  if (error) {
    throw error;
  }
}

async function fetchAemetStationObservation(stationId: string) {
  const envelope = await fetchJsonObject(
    `https://opendata.aemet.es/opendata/api/observacion/convencional/datos/estacion/${encodeURIComponent(stationId)}/?api_key=${aemetApiKey}`,
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

function evaluateAlarm(
  alarm: AlarmRow,
  observation: {
    observedAt: Date | null;
    windKnots: number | null;
    windDirectionBucket: string | null;
  },
) {
  if (!observation.observedAt || observation.windKnots == null) {
    return { active: false, payload: null, reason: "missing-wind-or-time" };
  }
  const totalMinutes =
    (observation.observedAt.getHours() * 60) + observation.observedAt.getMinutes();
  const timeMatches = isMinuteInRange(
    totalMinutes,
    alarm.start_hour,
    alarm.start_minute,
    alarm.end_hour,
    alarm.end_minute,
  );
  const windMatches =
    observation.windKnots >= alarm.wind_range_start &&
    observation.windKnots <= alarm.wind_range_end;
  const directionMatches =
    observation.windDirectionBucket != null &&
    alarm.directions.includes(observation.windDirectionBucket);
  const active = timeMatches && windMatches && directionMatches;
  const reason = active
    ? "active"
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
      observedAt: observation.observedAt.toISOString(),
      windKnots: observation.windKnots,
      direction: observation.windDirectionBucket,
    },
  };
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

function canRepeat(alarm: AlarmRow, now: Date) {
  if (alarm.snoozed_until) {
    const snoozedUntil = parseDate(alarm.snoozed_until);
    if (snoozedUntil && now.getTime() < snoozedUntil.getTime()) {
      return false;
    }
  }
  if (!alarm.last_triggered_at) {
    return true;
  }
  const lastTriggeredAt = parseDate(alarm.last_triggered_at);
  if (!lastTriggeredAt) {
    return true;
  }
  return now.getTime() - lastTriggeredAt.getTime() >= repeatWindowMs(alarm.repeat_window);
}

function repeatWindowMs(raw: string) {
  switch (raw) {
    case "min5":
      return 5 * 60 * 1000;
    case "min10":
      return 10 * 60 * 1000;
    case "min15":
      return 15 * 60 * 1000;
    case "min30":
      return 30 * 60 * 1000;
    default:
      return 10 * 60 * 1000;
  }
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

async function fetchJsonObject(url: string): Promise<Record<string, unknown>> {
  const response = await fetch(url, {
    headers: { accept: "application/json" },
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

function readDatosUrl(envelope: Record<string, unknown>): string {
  const raw = envelope.datos;
  if (typeof raw !== "string" || !raw.trim()) {
    throw new Error("missing-datos-url");
  }
  return raw;
}
