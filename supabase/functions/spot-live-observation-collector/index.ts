import { createClient } from "jsr:@supabase/supabase-js@2";
import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse } from "../_shared/http.ts";

type LiveStationConfig = {
  provider:
    | "METEOPILES"
    | "WINDGURU_STATION"
    | "WEATHERCLOUD"
    | "WUNDERGROUND"
    | "XUSS";
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

const olivaXeloWuDiagnosticSamples: Record<
  string,
  { stationKey: string; stationName: string }
> = {
  "weathercloud:0444100906": {
    stationKey: "diagnostic:oliva-xelo-sampled-5m",
    stationName: "Diagnostic Oliva Xelo sampled 5m",
  },
  "wunderground:IOLIVA107": {
    stationKey: "diagnostic:oliva-wu107-sampled-5m",
    stationName: "Diagnostic Oliva WU IOLIVA107 sampled 5m",
  },
};

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
    provider: "XUSS",
    stationKey: "xuss:denia",
    stationId: "denia",
    stationName: "Xuss Denia Joan Chabas",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:5629095484",
    stationId: "5629095484",
    stationName: "Weathercloud Platja de les Deveses",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IDNIA15",
    stationId: "IDNIA15",
    stationName: "WU Les Marines IDNIA15",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IELSPO7",
    stationId: "IELSPO7",
    stationName: "WU Els Poblets IELSPO7",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IELSPO8",
    stationId: "IELSPO8",
    stationName: "WU Mira-rosa IELSPO8",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IELVER21",
    stationId: "IELVER21",
    stationName: "WU El Verger IELVER21",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IELSPO5",
    stationId: "IELSPO5",
    stationName: "WU Els Poblets IELSPO5",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IELSPO14",
    stationId: "IELSPO14",
    stationName: "WU Mira-rosa IELSPO14",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IDNIA157",
    stationId: "IDNIA157",
    stationName: "WU Les Marines IDNIA157",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IDNIA70",
    stationId: "IDNIA70",
    stationName: "WU Les Marines IDNIA70",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IDNIA123",
    stationId: "IDNIA123",
    stationName: "WU Les Marines IDNIA123",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IDNIA121",
    stationId: "IDNIA121",
    stationName: "WU Denia IDNIA121",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IDNIA35",
    stationId: "IDNIA35",
    stationName: "WU Denia IDNIA35",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IDNIA142",
    stationId: "IDNIA142",
    stationName: "WU Denia IDNIA142",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IDNIA140",
    stationId: "IDNIA140",
    stationName: "WU Rotes IDNIA140",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IDNIA129",
    stationId: "IDNIA129",
    stationName: "WU Deveses IDNIA129",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IOLIVA49",
    stationId: "IOLIVA49",
    stationName: "WU Platja d'Oliva IOLIVA49",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:ICALP39",
    stationId: "ICALP39",
    stationName: "WU Calp San Gabriel ICALP39",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:ICALP32",
    stationId: "ICALP32",
    stationName: "WU Calp ICALP32",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:5819243918",
    stationId: "5819243918",
    stationName: "Weathercloud Calpe",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:4026174225",
    stationId: "4026174225",
    stationName: "Weathercloud YT60234",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:0444100906",
    stationId: "0444100906",
    stationName: "Weathercloud Xelo",
  },
  {
    provider: "WUNDERGROUND",
    stationKey: "wunderground:IOLIVA107",
    stationId: "IOLIVA107",
    stationName: "WU Oliva IOLIVA107",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:9778698522",
    stationId: "9778698522",
    stationName: "Weathercloud IOLIVA24",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:6074243991",
    stationId: "6074243991",
    stationName: "Weathercloud vj",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:5676427857",
    stationId: "5676427857",
    stationName: "Weathercloud Simyo Station",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:4447233755",
    stationId: "4447233755",
    stationName: "Weathercloud WS GANDIA GRAU",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:8448335204",
    stationId: "8448335204",
    stationName: "Weathercloud KGC & Windsports",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:1097806057",
    stationId: "1097806057",
    stationName: "Weathercloud Ricardo H",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:4227028590",
    stationId: "4227028590",
    stationName: "Weathercloud Piscina MB",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:8722640612",
    stationId: "8722640612",
    stationName: "Weathercloud Cullera Edificio Dosel",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:3117140332",
    stationId: "3117140332",
    stationName: "Weathercloud Cullera Faro",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:9767745419",
    stationId: "9767745419",
    stationName: "Weathercloud CulMeteo",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:2487023427",
    stationId: "2487023427",
    stationName: "Weathercloud Sagan",
  },
  {
    provider: "WEATHERCLOUD",
    stationKey: "weathercloud:1503665819",
    stationId: "1503665819",
    stationName: "Weathercloud Cullera-Ibiza",
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
  const diagnosticObservedAt = collectionSlotDate().toISOString();

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
      const diagnosticSample = diagnosticSampleObservation(
        observation,
        diagnosticObservedAt,
      );
      if (diagnosticSample != null) {
        observations.push(diagnosticSample);
      }
      diagnostics.push({
        stationKey: station.stationKey,
        status: "collected",
        observedAt: observation.observed_at,
        windKnots: observation.wind_knots,
        diagnosticObservedAt: diagnosticSample?.observed_at,
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
    case "WUNDERGROUND":
      return await fetchWundergroundObservation(station);
    case "XUSS":
      return await fetchXussDeniaObservation(station);
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
    wind_knots: mpsToKnots(
      weathercloudFreshPairNumber(stats, "wspdavg_current"),
    ),
    wind_min_knots: null,
    gust_knots: mpsToKnots(
      weathercloudFreshPairNumber(stats, "wspdhi_current"),
    ),
    wind_direction_deg: roundNullable(
      weathercloudFreshPairNumber(stats, "wdiravg_current", false),
    ),
    temp_c: weathercloudFreshPairNumber(stats, "temp_current"),
    pressure_hpa: roundNullable(
      weathercloudFreshPairNumber(stats, "bar_current"),
    ),
    humidity_pct: roundNullable(
      weathercloudFreshPairNumber(stats, "hum_current"),
    ),
    rain_mm: weathercloudFreshPairNumber(stats, "rain_day_total"),
    raw_payload: stats,
  });
}

async function fetchWundergroundObservation(
  station: LiveStationConfig,
): Promise<LiveObservation | null> {
  const apiKey = await fetchWundergroundApiKey(station.stationId);
  const url = new URL("https://api.weather.com/v2/pws/observations/current");
  url.searchParams.set("stationId", station.stationId);
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
  const latest = readRecord(observations[0]);
  if (latest == null) {
    return null;
  }
  const metric = readRecord(latest.metric);
  if (metric == null) {
    return null;
  }
  const observedAt = parseWundergroundObservedAt(latest);
  const windKmh = readUnknownNumber(metric.windSpeed);
  if (observedAt == null || windKmh == null || isStale(observedAt)) {
    return null;
  }

  return baseObservation(station, observedAt, {
    wind_knots: kmhToKnots(windKmh),
    wind_min_knots: null,
    gust_knots: kmhToKnots(readUnknownNumber(metric.windGust)),
    wind_direction_deg: roundNullable(readUnknownNumber(latest.winddir)),
    temp_c: readUnknownNumber(metric.temp),
    pressure_hpa: roundNullable(readUnknownNumber(metric.pressure)),
    humidity_pct: roundNullable(readUnknownNumber(latest.humidity)),
    rain_mm: readUnknownNumber(metric.precipTotal),
    raw_payload: latest,
  });
}

async function fetchWundergroundApiKey(stationId: string) {
  const dashboardUrl = `https://www.wunderground.com/dashboard/pws/${
    encodeURIComponent(stationId)
  }`;
  const response = await fetch(dashboardUrl, {
    headers: {
      accept: "text/html,application/xhtml+xml,*/*",
      referer: "https://www.wunderground.com/",
      "user-agent": "WindWisher/1.0",
    },
  });
  if (!response.ok) {
    throw new Error(`wunderground-dashboard-http-${response.status}`);
  }
  const dashboard = await response.text();
  const apiKey = dashboard.match(/apiKey=([A-Za-z0-9]+)/)?.[1];
  if (!apiKey) {
    throw new Error("wunderground-api-key-not-found");
  }
  return apiKey;
}

async function fetchXussDeniaObservation(
  station: LiveStationConfig,
): Promise<LiveObservation | null> {
  const response = await fetch("http://www.xuss.es/Meteo/Denia.php", {
    headers: {
      "user-agent": "WindWisher/1.0",
      accept: "text/html,*/*",
    },
  });
  if (!response.ok) {
    throw new Error(`xuss-http-${response.status}`);
  }
  const body = new TextDecoder("iso-8859-1").decode(
    await response.arrayBuffer(),
  );
  const observedAt = parseXussObservedAt(body);
  const wind = parseXussKmhKts(body, "Velocidad media del viento");
  if (observedAt == null || wind?.knots == null || isStale(observedAt)) {
    return null;
  }

  return baseObservation(station, observedAt, {
    wind_knots: wind.knots,
    wind_min_knots: null,
    gust_knots: parseXussKmhKts(body, "ráfagas maxima")?.knots ?? null,
    wind_direction_deg: roundNullable(
      parseXussDegrees(body, "Direcci[oó]n del viento"),
    ),
    temp_c: parseXussNumberAfter(body, String.raw`Temperatura actual.*?<b>`),
    pressure_hpa: roundNullable(
      parseXussNumberAfter(body, String.raw`Bar[oó]metro.*?>`),
    ),
    humidity_pct: roundNullable(
      parseXussNumberAfter(body, String.raw`Humedad\s*</td>\s*<td>`),
    ),
    rain_mm: parseXussNumberAfter(
      body,
      String.raw`Lluvia.*?\(desde medianoche\).*?>`,
    ),
    raw_payload: {
      source: "xuss-denia-html",
      observedAtLabel: parseXussObservedAtLabel(body),
    },
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

function weathercloudFreshPairNumber(
  stats: Record<string, unknown>,
  key: string,
  allowNegative = true,
): number | null {
  const value = stats[key];
  if (!Array.isArray(value) || value.length < 2) {
    return weathercloudPairNumber(value);
  }
  const pairEpoch = Number(value[0]);
  const lastUpdateEpoch = readObjectNumber(stats, "last_update");
  const numberValue = weathercloudPairNumber(value);
  if (numberValue == null) {
    return null;
  }
  if (!allowNegative && numberValue < 0) {
    return null;
  }
  if (
    Number.isFinite(pairEpoch) &&
    lastUpdateEpoch != null &&
    pairEpoch < lastUpdateEpoch
  ) {
    return null;
  }
  return numberValue;
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

function collectionSlotDate(now = new Date()): Date {
  const slot = new Date(now);
  const minute = slot.getUTCMinutes();
  slot.setUTCMinutes(minute - (minute % 5), 0, 0);
  return slot;
}

function diagnosticSampleObservation(
  observation: LiveObservation,
  diagnosticObservedAt: string,
): LiveObservation | null {
  const diagnostic = olivaXeloWuDiagnosticSamples[observation.station_key];
  if (diagnostic == null) {
    return null;
  }
  return {
    ...observation,
    station_provider: `${observation.station_provider}_DIAGNOSTIC`,
    station_key: diagnostic.stationKey,
    station_name: diagnostic.stationName,
    observed_at: diagnosticObservedAt,
    raw_payload: {
      diagnostic: "oliva-xelo-vs-wu-sampled-5m",
      sourceStationProvider: observation.station_provider,
      sourceStationKey: observation.station_key,
      sourceObservedAt: observation.observed_at,
      sourceRawPayload: observation.raw_payload,
    },
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
  return readUnknownNumber(value);
}

function readUnknownNumber(value: unknown): number | null {
  if (typeof value === "number" && Number.isFinite(value)) {
    return value;
  }
  if (typeof value === "string") {
    const parsed = Number.parseFloat(value);
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function readRecord(value: unknown): Record<string, unknown> | null {
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    return null;
  }
  return value as Record<string, unknown>;
}

function parseWundergroundObservedAt(
  observation: Record<string, unknown>,
): Date | null {
  const epoch = readUnknownNumber(observation.epoch);
  if (epoch != null) {
    return new Date(epoch * 1000);
  }
  const utc = typeof observation.obsTimeUtc === "string"
    ? observation.obsTimeUtc
    : null;
  if (utc == null) {
    return null;
  }
  const parsed = new Date(utc);
  return Number.isNaN(parsed.getTime()) ? null : parsed;
}

function parseXussObservedAt(body: string): Date | null {
  const match = body.match(
    /Ultima grabaci[oó]n a:\s*(\d{1,2}):(\d{2}).*?Data:\s*(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})/is,
  );
  if (!match) {
    return null;
  }
  const hour = Number(match[1]);
  const minute = Number(match[2]);
  const day = Number(match[3]);
  const month = parseXussMonth(match[4]);
  const year = Number(match[5]);
  if (
    !Number.isFinite(hour) ||
    !Number.isFinite(minute) ||
    !Number.isFinite(day) ||
    month == null ||
    !Number.isFinite(year)
  ) {
    return null;
  }
  return zonedDateTimeToUtc({
    timeZone: "Europe/Madrid",
    year,
    month,
    day,
    hour,
    minute,
    second: 0,
  });
}

function parseXussObservedAtLabel(body: string): string | null {
  return body.match(/Ultima grabaci[oó]n a:\s*([^<]+)/i)?.[1]?.trim() ?? null;
}

function parseXussKmhKts(
  body: string,
  labelPattern: string,
): { kmh: number | null; knots: number | null } | null {
  const match = body.match(
    new RegExp(
      `${labelPattern}.*?<td[^>]*>\\s*([0-9.,]+)\\s*kmh\\s*\\(([0-9.,]+)\\s*kts\\)`,
      "is",
    ),
  );
  if (!match) {
    return null;
  }
  return {
    kmh: parseXussNumber(match[1]),
    knots: parseXussNumber(match[2]),
  };
}

function parseXussDegrees(body: string, labelPattern: string): number | null {
  const match = body.match(
    new RegExp(`${labelPattern}.*?<td[^>]*>.*?\\(([0-9.,]+)&deg;\\)`, "is"),
  );
  return parseXussNumber(match?.[1]);
}

function parseXussNumberAfter(
  body: string,
  prefixPattern: string,
): number | null {
  const match = body.match(new RegExp(`${prefixPattern}\\s*([0-9.,]+)`, "is"));
  return parseXussNumber(match?.[1]);
}

function parseXussNumber(raw: string | undefined): number | null {
  if (!raw) {
    return null;
  }
  const parsed = Number(raw.replace(",", "."));
  return Number.isFinite(parsed) ? parsed : null;
}

function parseXussMonth(raw: string | undefined): number | null {
  switch (raw?.toLowerCase()) {
    case "jan":
    case "ene":
      return 1;
    case "feb":
      return 2;
    case "mar":
      return 3;
    case "apr":
    case "abr":
      return 4;
    case "may":
      return 5;
    case "jun":
      return 6;
    case "jul":
      return 7;
    case "aug":
    case "ago":
      return 8;
    case "sep":
      return 9;
    case "oct":
      return 10;
    case "nov":
      return 11;
    case "dec":
    case "dic":
      return 12;
    default:
      return null;
  }
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
