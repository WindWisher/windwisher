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
  directions: string[];
  repeat_window: string;
  max_repeats: number;
  trigger_count: number;
  last_triggered_at: string | null;
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

  for (const alarm of alarmRows) {
    evaluated += 1;
    if (alarm.station_provider !== "AEMET") {
      unsupported += 1;
      await logDelivery(alarm, "skipped", "unsupported-provider", null);
      logged += 1;
      continue;
    }

    if (!aemetApiKey) {
      await logDelivery(alarm, "skipped", "missing-aemet-api-key", null);
      logged += 1;
      continue;
    }

    const observation = await fetchAemetStationObservation(alarm.station_key);
    if (!observation) {
      await logDelivery(alarm, "skipped", "missing-observation", null);
      logged += 1;
      continue;
    }

    const evaluation = evaluateAlarm(alarm, observation);
    if (!evaluation.active) {
      if (alarm.trigger_count !== 0 || alarm.last_triggered_at != null) {
        await resetTriggerState(alarm);
      }
      continue;
    }
    active += 1;

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

    await logDelivery(
      alarm,
      "ready",
      "push-provider-not-implemented",
      {
        ...evaluation.payload,
        pushSubscriptions: subscriptions.map((subscription) => ({
          platform: subscription.platform,
          provider: subscription.provider,
        })),
      },
    );
    await updateTriggerState(alarm, alarm.trigger_count + 1, now);
    logged += 1;
  }

  return jsonResponse({
    ok: true,
    evaluated,
    active,
    logged,
    unsupported,
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
    return { active: false, payload: null };
  }
  const hour = observation.observedAt.getHours();
  const timeMatches = isHourInRange(hour, alarm.start_hour, alarm.end_hour);
  const windMatches =
    observation.windKnots >= alarm.wind_range_start &&
    observation.windKnots <= alarm.wind_range_end;
  const directionMatches =
    observation.windDirectionBucket != null &&
    alarm.directions.includes(observation.windDirectionBucket);
  return {
    active: timeMatches && windMatches && directionMatches,
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

function isHourInRange(hour: number, startHour: number, endHour: number) {
  if (startHour === endHour) {
    return true;
  }
  if (startHour < endHour) {
    return hour >= startHour && hour < endHour;
  }
  return hour >= startHour || hour < endHour;
}

function canRepeat(alarm: AlarmRow, now: Date) {
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
