import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse } from "../_shared/http.ts";

type LiveStationConfig = {
  provider: "METEOPILES" | "WINDGURU_STATION" | "WEATHERCLOUD";
  stationKey: string;
  stationId: string;
  stationName: string;
};

type LiveObservation = {
  station_provider: string;
  station_key: string;
  station_id: string;
  station_name: string;
  observed_at: string;
  source_fetched_at: string;
  wind_knots: number | null;
  wind_min_knots: number | null;
  gust_knots: number | null;
  wind_direction_deg: number | null;
  temp_c: number | null;
  pressure_hpa: number | null;
  humidity_pct: number | null;
  rain_mm: number | null;
  raw_payload: Record<string, unknown>;
};

const collectorSecret = Deno.env.get("SPOT_LIVE_COLLECTOR_SECRET") ??
  Deno.env.get("LIVE_WIND_RECORDER_SECRET") ??
  "";
const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

const stations: LiveStationConfig[] = [
  {
    provider: "WINDGURU_STATION",
    stationKey: "windguru-station:51",
    stationId: "51",
    stationName: "DK Piles Meteo",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:3711662418",
    stationId: "3711662418",
    stationName: "Weathercloud ElPaquebote",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:5629095484",
    stationId: "5629095484",
    stationName: "Weathercloud Platja de les Deveses",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:5411085804",
    stationId: "5411085804",
    stationName: "Weathercloud Perellobeach",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:4026174225",
    stationId: "4026174225",
    stationName: "Weathercloud YT60234",
  },
];

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "method-not-allowed" }, { status: 405 });
  }
  if (!collectorSecret) {
    return jsonResponse(
      { error: "missing-collector-secret" },
      { status: 500 },
    );
  }
  if (
    (request.headers.get("authorization") ?? "") !== `Bearer ${collectorSecret}`
  ) {
    return jsonResponse({ error: "unauthorized" }, { status: 401 });
  }
  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse(
      { error: "missing-supabase-service-role-key" },
      { status: 500 },
    );
  }

  const diagnostics: Record<string, unknown>[] = [];
  const observations: LiveObservation[] = [];

  for (const station of stations) {
    try {
      const observation = await fetchStationObservation(station);
      if (observation == null) {
        diagnostics.push({
          stationKey: station.stationKey,
          status: "missing-observation",
        });
        continue;
      }
      observations.push(observation);
      diagnostics.push({
        stationKey: station.stationKey,
        status: "collected",
        observedAt: observation.observed_at,
        windKnots: observation.wind_knots,
      });
    } catch (error) {
      diagnostics.push({
        stationKey: station.stationKey,
        status: "failed",
        error: error instanceof Error ? error.message : String(error),
      });
    }
  }

  let insertedOrUpdated = 0;
  if (observations.length > 0) {
    const { error } = await supabase
      .from("spot_live_observations")
      .upsert(observations, { onConflict: "station_key,observed_at" });
    if (error) {
      return jsonResponse(
        {
          error: "upsert-failed",
          message: error.message,
          diagnostics,
        },
        { status: 500 },
      );
    }
    insertedOrUpdated = observations.length;
  }

  const { data: pruned, error: pruneError } = await supabase.rpc(
    "prune_spot_live_observations",
    { retention: "72 hours" },
  );
  if (pruneError) {
    diagnostics.push({
      status: "prune-failed",
      error: pruneError.message,
    });
  }

  return jsonResponse({
    ok: true,
    collected: observations.length,
    insertedOrUpdated,
    pruned: pruned ?? 0,
    diagnostics,
  });
});

async function fetchStationObservation(
  station: LiveStationConfig,
): Promise<LiveObservation | null> {
  switch (station.provider) {
    case "METEOPILES":
      return await fetchMeteopilesObservation(station);
    case "WINDGURU_STATION":
      return await fetchWindguruStationObservation(station);
    case "WEATHERCLOUD":
      return await fetchWeathercloudObservation(station);
  }
}

async function fetchMeteopilesObservation(
  station: LiveStationConfig,
): Promise<LiveObservation | null> {
  const response = await fetch(
    "http://www.meteopiles.es/wflash/Data/wflash.txt",
    { headers: { "user-agent": "WindWisher/1.0" } },
  );
  if (!response.ok) {
    throw new Error(`meteopiles-http-${response.status}`);
  }
  const text = new TextDecoder("iso-8859-1").decode(
    await response.arrayBuffer(),
  );
  const values = text.trim().split(",");
  if (values.length < 26 || !values[0].startsWith("F=")) {
    return null;
  }

  const observedAt = parseVwsTimestamp(readString(values, 0)) ??
    parseTodayTime(readString(values, 1));
  if (observedAt == null) {
    return null;
  }
  if (isStale(observedAt)) {
    return null;
  }

  return baseObservation(station, observedAt, {
    wind_knots: mphToKnots(readNumber(values, 4)),
    wind_min_knots: null,
    gust_knots: mphToKnots(readNumber(values, 5)),
    wind_direction_deg: roundNullable(readNumber(values, 3)),
    temp_c: fahrenheitToCelsius(readNumber(values, 9)),
    pressure_hpa: roundNullable(inHgToHpa(readNumber(values, 25))),
    humidity_pct: roundNullable(readNumber(values, 7)),
    rain_mm: inchesToMm(readNumber(values, 11)),
    raw_payload: { source: "wflash", values },
  });
}

async function fetchWindguruStationObservation(
  station: LiveStationConfig,
): Promise<LiveObservation | null> {
  const url = new URL("https://www.windguru.cz/int/iapi.php");
  url.searchParams.set("callback", "windwisher");
  url.searchParams.set("q", "station_data_current");
  url.searchParams.set("id_station", station.stationId);
  url.searchParams.set("date_format", "Y-m-d H:i:s T");

  const response = await fetch(url, {
    headers: {
      referer: "https://www.dkpiles.com/meteo.html",
      "user-agent": "WindWisher/1.0",
    },
  });
  if (!response.ok) {
    throw new Error(`windguru-http-${response.status}`);
  }
  const raw = (await response.text()).trim();
  const json = decodeJsonp(raw, "windwisher");
  const data = JSON.parse(json) as Record<string, unknown>;
  if (data.return === "error") {
    throw new Error(String(data.message ?? "windguru-error"));
  }

  const unixTime = readObjectNumber(data, "unixtime");
  if (unixTime == null) {
    return null;
  }
  const observedAt = new Date(unixTime * 1000);

  return baseObservation(station, observedAt, {
    wind_knots: readObjectNumber(data, "wind_avg"),
    wind_min_knots: readObjectNumber(data, "wind_min"),
    gust_knots: readObjectNumber(data, "wind_max"),
    wind_direction_deg: roundNullable(readObjectNumber(data, "wind_direction")),
    temp_c: readObjectNumber(data, "temperature"),
    pressure_hpa: roundNullable(readObjectNumber(data, "mslp")),
    humidity_pct: roundNullable(readObjectNumber(data, "rh")),
    rain_mm: null,
    raw_payload: data,
  });
}

async function fetchWeathercloudObservation(
  station: LiveStationConfig,
): Promise<LiveObservation | null> {
  const stats = await fetchWeathercloudStats(station.stationId);
  const observedAt = weathercloudObservedAt(stats);
  if (observedAt == null || isStale(observedAt)) {
    return null;
  }

  return baseObservation(station, observedAt, {
    wind_knots: mpsToKnots(weathercloudPairNumber(stats.wspdavg_current)),
    wind_min_knots: null,
    gust_knots: mpsToKnots(weathercloudPairNumber(stats.wspdhi_current)),
    wind_direction_deg: roundNullable(
      weathercloudPairNumber(stats.wdiravg_current),
    ),
    temp_c: weathercloudPairNumber(stats.temp_current),
    pressure_hpa: roundNullable(weathercloudPairNumber(stats.bar_current)),
    humidity_pct: roundNullable(weathercloudPairNumber(stats.hum_current)),
    rain_mm: weathercloudPairNumber(stats.rain_day_total),
    raw_payload: stats,
  });
}

async function fetchWeathercloudStats(deviceId: string) {
  const pageUrl = `https://app.weathercloud.net/d${
    encodeURIComponent(deviceId)
  }`;
  const pageResponse = await fetch(pageUrl, {
    headers: weathercloudHeaders(),
  });
  if (!pageResponse.ok) {
    throw new Error(`weathercloud-page-http-${pageResponse.status}`);
  }
  const cookie = (pageResponse.headers.get("set-cookie") ?? "")
    .split(";")[0];
  const page = await pageResponse.text();
  const token = page.match(/WEATHERCLOUD_CSRF_TOKEN:"([^"]+)"/)?.[1];
  if (!token) {
    throw new Error("weathercloud-token-not-found");
  }
  const statsUrl = new URL("https://app.weathercloud.net/device/stats");
  statsUrl.searchParams.set("code", deviceId);
  statsUrl.searchParams.set("WEATHERCLOUD_CSRF_TOKEN", token);
  return await fetchJsonObject(statsUrl.toString(), {
    ...weathercloudHeaders(),
    accept: "application/json, text/javascript, */*; q=0.01",
    cookie,
    referer: pageUrl,
    "x-requested-with": "XMLHttpRequest",
  });
}

function weathercloudHeaders(): Record<string, string> {
  return {
    "accept-language": "es-ES,es;q=0.9,en;q=0.8",
    "user-agent": "Mozilla/5.0 WindWisher/1.0",
  };
}

function weathercloudObservedAt(stats: Record<string, unknown>) {
  const epoch = readObjectNumber(stats, "last_update");
  return epoch == null ? null : new Date(epoch * 1000);
}

function weathercloudPairNumber(value: unknown): number | null {
  if (!Array.isArray(value) || value.length < 2) {
    return null;
  }
  const numberValue = Number(value[1]);
  return Number.isFinite(numberValue) ? numberValue : null;
}

async function fetchMeteoclimaticObservation(
  station: LiveStationConfig,
): Promise<LiveObservation | null> {
  const response = await fetch(
    `https://www.meteoclimatic.net/feed/rss/${
      encodeURIComponent(station.stationId)
    }`,
    { headers: meteoclimaticRequestHeaders() },
  );
  if (!response.ok) {
    throw new Error(`meteoclimatic-http-${response.status}`);
  }
  const body = new TextDecoder("iso-8859-1").decode(
    await response.arrayBuffer(),
  );
  const dataMatch = body.match(
    /\[\[<([A-Z0-9]+);\(([^)]*)\);\(([^)]*)\);\(([^)]*)\);\(([^)]*)\);\(([^)]*)\);([^>]*)>\]\]/s,
  );
  if (!dataMatch) {
    return null;
  }

  const temperature = splitMeteoclimaticTuple(dataMatch[2]);
  const humidity = splitMeteoclimaticTuple(dataMatch[3]);
  const pressure = splitMeteoclimaticTuple(dataMatch[4]);
  const wind = splitMeteoclimaticTuple(dataMatch[5]);
  const rain = splitMeteoclimaticTuple(dataMatch[6]);
  const observedAt = parseMeteoclimaticObservedAt(body);
  const windKmh = parseMeteoclimaticNumber(wind[0]);
  if (observedAt == null || windKmh == null) {
    return null;
  }

  return baseObservation(station, observedAt, {
    wind_knots: kmhToKnots(windKmh),
    wind_min_knots: null,
    gust_knots: kmhToKnots(parseMeteoclimaticNumber(wind[1])),
    wind_direction_deg: roundNullable(parseMeteoclimaticNumber(wind[2])),
    temp_c: parseMeteoclimaticNumber(temperature[0]),
    pressure_hpa: roundNullable(parseMeteoclimaticNumber(pressure[0])),
    humidity_pct: roundNullable(parseMeteoclimaticNumber(humidity[0])),
    rain_mm: parseMeteoclimaticNumber(rain[0]),
    raw_payload: {
      source: "meteoclimatic-rss",
      stationId: dataMatch[1],
      stationName: decodeHtmlText(dataMatch[7]),
      pubDate: observedAt.toISOString(),
    },
  });
}

function baseObservation(
  station: LiveStationConfig,
  observedAt: Date,
  values: Omit<
    LiveObservation,
    | "station_provider"
    | "station_key"
    | "station_id"
    | "station_name"
    | "observed_at"
    | "source_fetched_at"
  >,
): LiveObservation {
  return {
    station_provider: station.provider,
    station_key: station.stationKey,
    station_id: station.stationId,
    station_name: station.stationName,
    observed_at: observedAt.toISOString(),
    source_fetched_at: new Date().toISOString(),
    ...values,
  };
}

function decodeJsonp(raw: string, callback: string): string {
  const prefix = `${callback}(`;
  if (raw.startsWith(prefix) && raw.endsWith(");")) {
    return raw.slice(prefix.length, -2);
  }
  return raw;
}

function parseTodayTime(label: string | null): Date | null {
  if (label == null) {
    return null;
  }
  const parts = label.split(":").map((part) => Number.parseInt(part, 10));
  if (parts.length < 2 || parts.some((part) => Number.isNaN(part))) {
    return null;
  }
  const madridNow = datePartsInTimeZone(new Date(), "Europe/Madrid");
  const observed = zonedDateTimeToUtc({
    timeZone: "Europe/Madrid",
    year: madridNow.year,
    month: madridNow.month,
    day: madridNow.day,
    hour: parts[0],
    minute: parts[1],
    second: parts[2] ?? 0,
  });
  if (observed.getTime() - Date.now() > 30 * 60 * 1000) {
    observed.setUTCDate(observed.getUTCDate() - 1);
  }
  return observed;
}

function parseVwsTimestamp(raw: string | null): Date | null {
  if (raw == null || !raw.startsWith("F=")) {
    return null;
  }
  const seconds = Number.parseInt(raw.slice(2), 10);
  if (!Number.isFinite(seconds)) {
    return null;
  }
  return new Date(Date.UTC(1900, 0, 1, 0, 0, 0) + seconds * 1000);
}

function isStale(observedAt: Date): boolean {
  return Date.now() - observedAt.getTime() > 2 * 60 * 60 * 1000;
}

function zonedDateTimeToUtc({
  timeZone,
  year,
  month,
  day,
  hour,
  minute,
  second,
}: {
  timeZone: string;
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
}): Date {
  const utcGuess = new Date(
    Date.UTC(year, month - 1, day, hour, minute, second),
  );
  const offsetMs = timeZoneOffsetMs(timeZone, utcGuess);
  return new Date(utcGuess.getTime() - offsetMs);
}

function timeZoneOffsetMs(timeZone: string, date: Date): number {
  const parts = datePartsInTimeZone(date, timeZone);
  const zonedAsUtc = Date.UTC(
    parts.year,
    parts.month - 1,
    parts.day,
    parts.hour,
    parts.minute,
    parts.second,
  );
  return zonedAsUtc - date.getTime();
}

function datePartsInTimeZone(date: Date, timeZone: string) {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone,
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    second: "2-digit",
    hour12: false,
  }).formatToParts(date);
  const values = Object.fromEntries(
    parts
      .filter((part) => part.type !== "literal")
      .map((part) => [part.type, Number.parseInt(part.value, 10)]),
  );
  return {
    year: values.year,
    month: values.month,
    day: values.day,
    hour: values.hour,
    minute: values.minute,
    second: values.second,
  };
}

function readString(values: string[], index: number): string | null {
  const value = values[index]?.trim();
  return value ? value : null;
}

function readNumber(values: string[], index: number): number | null {
  const value = Number.parseFloat(readString(values, index) ?? "");
  return Number.isFinite(value) ? value : null;
}

function readObjectNumber(
  data: Record<string, unknown>,
  key: string,
): number | null {
  const value = data[key];
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string") {
    const parsed = Number.parseFloat(value);
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function roundNullable(value: number | null): number | null {
  return value == null ? null : Math.round(value);
}

function mphToKnots(value: number | null): number | null {
  return value == null ? null : value * 0.868976242;
}

function fahrenheitToCelsius(value: number | null): number | null {
  return value == null ? null : (value - 32) * 5 / 9;
}

function inHgToHpa(value: number | null): number | null {
  return value == null ? null : value * 33.8638866667;
}

function inchesToMm(value: number | null): number | null {
  return value == null ? null : value * 25.4;
}

function kmhToKnots(value: number | null): number | null {
  return value == null ? null : value * 0.539957;
}

function mpsToKnots(value: number | null): number | null {
  return value == null ? null : value * 1.9438444924406;
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

function decodeHtmlText(value: string | undefined) {
  return (value ?? "")
    .replaceAll("&amp;", "&")
    .replaceAll("&nbsp;", " ")
    .replaceAll("&#243;", "o")
    .replaceAll("&oacute;", "o")
    .trim();
}
