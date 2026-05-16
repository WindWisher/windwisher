// deno-lint-ignore-file no-explicit-any
import { createClient } from "jsr:@supabase/supabase-js@2";
import { NetCDFReader } from "npm:netcdfjs@3.0.0";
import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, readJson } from "../_shared/http.ts";

type NearbyRequest = {
  spotKey?: string;
  spotName?: string;
  latitude?: number;
  longitude?: number;
  radiusKm?: number;
  maxResults?: number;
  offset?: number;
  forceRefresh?: boolean;
};

type MaritimeObservationRow = {
  spot_key: string;
  spot_name: string;
  provider: "MADIS_MARITIME";
  platform_id: string;
  platform_type: string | null;
  platform_name: string | null;
  station_key: string;
  latitude: number;
  longitude: number;
  distance_km: number;
  observed_at: string;
  source_fetched_at: string;
  source_file: string;
  wind_speed_ms: number | null;
  wind_speed_knots: number | null;
  wind_dir_deg: number | null;
  gust_ms: number | null;
  gust_knots: number | null;
  air_temp_c: number | null;
  pressure_hpa: number | null;
  humidity_pct: number | null;
  sea_surface_temp_c: number | null;
  wave_height_m: number | null;
  wave_period_s: number | null;
  quality: string | null;
  raw_payload: Record<string, unknown>;
};

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

const provider = "MADIS_MARITIME" as const;
const cacheFreshMinutes = 15;
const maxRadiusKm = 50;
const defaultRadiusKm = 10;
const defaultMaxResults = 10;

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return jsonResponse({ error: "method-not-allowed" }, { status: 405 });
  }
  if (!supabaseUrl || !serviceRoleKey) {
    return jsonResponse(
      { error: "missing-supabase-service-role-key" },
      { status: 500 },
    );
  }

  try {
    const body = await readJson<NearbyRequest>(request);
    const spotName = (body.spotName ?? "").trim();
    const spotKey = normalizeSpotKey(body.spotKey || spotName);
    const latitude = readFiniteNumber(body.latitude);
    const longitude = readFiniteNumber(body.longitude);
    if (!spotName || !spotKey || latitude == null || longitude == null) {
      return jsonResponse({ error: "invalid-spot" }, { status: 400 });
    }

    const radiusKm = clamp(
      readFiniteNumber(body.radiusKm) ?? defaultRadiusKm,
      1,
      maxRadiusKm,
    );
    const maxResults = Math.trunc(
      clamp(readFiniteNumber(body.maxResults) ?? defaultMaxResults, 1, 30),
    );
    const offset = Math.trunc(
      clamp(readFiniteNumber(body.offset) ?? 0, 0, 300),
    );

    if (!body.forceRefresh) {
      const cached = await fetchCachedRows(
        spotKey,
        radiusKm,
        maxResults,
        offset,
      );
      if (cached.total > 0) {
        return jsonResponse({
          ok: true,
          source: "cache",
          total: cached.total,
          offset,
          limit: maxResults,
          hasMore: offset + cached.rows.length < cached.total,
          observations: cached.rows,
        });
      }
    }

    const result = await collectNearbyMadisRows({
      spotKey,
      spotName,
      latitude,
      longitude,
      radiusKm,
      maxResults,
      offset,
    });

    if (result.allRows.length > 0) {
      const { error } = await supabase
        .from("spot_maritime_observations")
        .upsert(result.allRows, {
          onConflict: "spot_key,provider,platform_id,observed_at",
        });
      if (error) {
        return jsonResponse(
          { error: "upsert-failed", message: error.message },
          { status: 500 },
        );
      }
    }

    await supabase.rpc("prune_spot_maritime_observations", {
      retention: "72 hours",
    });

    return jsonResponse({
      ok: true,
      source: "madis",
      sourceFile: result.sourceFile,
      total: result.total,
      offset,
      limit: maxResults,
      hasMore: offset + result.rows.length < result.total,
      observations: result.rows,
    });
  } catch (error) {
    return jsonResponse(
      {
        error: "madis-maritime-nearby-failed",
        message: error instanceof Error ? error.message : String(error),
      },
      { status: 500 },
    );
  }
});

async function fetchCachedRows(
  spotKey: string,
  radiusKm: number,
  maxResults: number,
  offset: number,
): Promise<{ rows: MaritimeObservationRow[]; total: number }> {
  const freshSince = new Date(
    Date.now() - cacheFreshMinutes * 60 * 1000,
  ).toISOString();
  const { data, error, count } = await supabase
    .from("spot_maritime_observations")
    .select("*")
    .eq("spot_key", spotKey)
    .lte("distance_km", radiusKm)
    .gte("source_fetched_at", freshSince)
    .order("distance_km", { ascending: true })
    .range(offset, offset + maxResults - 1);
  if (error) {
    throw error;
  }
  const { count: exactCount, error: countError } = await supabase
    .from("spot_maritime_observations")
    .select("id", { count: "exact", head: true })
    .eq("spot_key", spotKey)
    .lte("distance_km", radiusKm)
    .gte("source_fetched_at", freshSince);
  if (countError) {
    throw countError;
  }
  return {
    rows: (data ?? []) as MaritimeObservationRow[],
    total: exactCount ?? count ?? data?.length ?? 0,
  };
}

async function collectNearbyMadisRows(params: {
  spotKey: string;
  spotName: string;
  latitude: number;
  longitude: number;
  radiusKm: number;
  maxResults: number;
  offset: number;
}): Promise<{
  rows: MaritimeObservationRow[];
  allRows: MaritimeObservationRow[];
  total: number;
  sourceFile: string;
}> {
  const { arrayBuffer, sourceFile } = await fetchLatestMadisFile();
  const reader = new NetCDFReader(arrayBuffer);
  const latitudes = readVariable(reader, "latitude");
  const longitudes = readVariable(reader, "longitude");
  const timeObs = readVariable(reader, "timeObs");
  if (!latitudes || !longitudes || !timeObs) {
    throw new Error("missing-required-madis-variables");
  }

  const windSpeed = readVariable(reader, "windSpeed");
  const windDir = readVariable(reader, "windDir");
  const windGust = readVariable(reader, "windGust");
  const temperature = readVariable(reader, "temperature");
  const seaLevelPress = readVariable(reader, "seaLevelPress");
  const relHumidity = readVariable(reader, "relHumidity") ??
    readVariable(reader, "rh");
  const seaSurfaceTemp = readVariable(reader, "seaSurfaceTemp");
  const waveHeight = readVariable(reader, "waveHeight");
  const wavePeriod = readVariable(reader, "wavePeriod");
  const platformType = readVariable(reader, "dataPlatformType");
  const stationNames = readStringVariable(reader, "stationName");
  const stationIds = readStringVariable(reader, "stationId");

  const rows: MaritimeObservationRow[] = [];
  const fetchedAt = new Date().toISOString();
  const count = Math.min(latitudes.length, longitudes.length, timeObs.length);

  for (let index = 0; index < count; index += 1) {
    const latitude = readValue(latitudes, index);
    const longitude = normalizeLongitude(readValue(longitudes, index));
    const observedAt = parseMadisTime(readValue(timeObs, index));
    if (latitude == null || longitude == null || observedAt == null) {
      continue;
    }
    const distanceKm = haversineKm(
      params.latitude,
      params.longitude,
      latitude,
      longitude,
    );
    if (distanceKm > params.radiusKm) {
      continue;
    }

    const platformId = sanitizePlatformId(
      stationIds[index] || stationNames[index] || `madis-${index}`,
    );
    const stationKey = `madis-maritime:${platformId}`;
    const windSpeedMs = readValue(windSpeed, index);
    const windGustMs = readValue(windGust, index);
    const airTempK = readValue(temperature, index);
    const pressurePa = readValue(seaLevelPress, index);
    const sstK = readValue(seaSurfaceTemp, index);

    rows.push({
      spot_key: params.spotKey,
      spot_name: params.spotName,
      provider,
      platform_id: platformId,
      platform_type: platformTypeLabel(readValue(platformType, index)),
      platform_name: stationNames[index] || null,
      station_key: stationKey,
      latitude,
      longitude,
      distance_km: Number(distanceKm.toFixed(3)),
      observed_at: observedAt.toISOString(),
      source_fetched_at: fetchedAt,
      source_file: sourceFile,
      wind_speed_ms: windSpeedMs,
      wind_speed_knots: msToKnots(windSpeedMs),
      wind_dir_deg: readValue(windDir, index),
      gust_ms: windGustMs,
      gust_knots: msToKnots(windGustMs),
      air_temp_c: kelvinToC(airTempK),
      pressure_hpa: pressurePa == null ? null : pressurePa / 100,
      humidity_pct: readValue(relHumidity, index),
      sea_surface_temp_c: kelvinToC(sstK),
      wave_height_m: readValue(waveHeight, index),
      wave_period_s: readValue(wavePeriod, index),
      quality: "raw-madis-qc-available",
      raw_payload: {
        sourceFile,
        madisIndex: index,
      },
    });
  }

  rows.sort((a, b) => {
    const distance = a.distance_km - b.distance_km;
    if (distance !== 0) return distance;
    return Date.parse(b.observed_at) - Date.parse(a.observed_at);
  });

  const latestByPlatform = new Map<string, MaritimeObservationRow>();
  for (const row of rows) {
    const existing = latestByPlatform.get(row.platform_id);
    if (
      !existing ||
      Date.parse(row.observed_at) > Date.parse(existing.observed_at)
    ) {
      latestByPlatform.set(row.platform_id, row);
    }
  }

  return {
    rows: [...latestByPlatform.values()].slice(
      params.offset,
      params.offset + params.maxResults,
    ),
    allRows: [...latestByPlatform.values()],
    total: latestByPlatform.size,
    sourceFile,
  };
}

async function fetchLatestMadisFile(): Promise<{
  arrayBuffer: ArrayBuffer;
  sourceFile: string;
}> {
  const now = new Date();
  for (let offset = 0; offset < 8; offset += 1) {
    const candidate = new Date(now.getTime() - offset * 60 * 60 * 1000);
    const sourceFile = formatMadisFile(candidate);
    const url =
      `https://madis-data.ncep.noaa.gov/madisPublic/data/point/maritime/netcdf/${sourceFile}`;
    const response = await fetch(url, {
      headers: { "user-agent": "WindWisher/1.0" },
    });
    if (!response.ok) {
      continue;
    }
    const compressed = await response.arrayBuffer();
    const stream = new Blob([compressed]).stream().pipeThrough(
      new DecompressionStream("gzip"),
    );
    const decompressed = await new Response(stream).arrayBuffer();
    return { arrayBuffer: decompressed, sourceFile };
  }
  throw new Error("no-recent-madis-maritime-file");
}

function formatMadisFile(date: Date): string {
  const yyyy = date.getUTCFullYear().toString().padStart(4, "0");
  const mm = (date.getUTCMonth() + 1).toString().padStart(2, "0");
  const dd = date.getUTCDate().toString().padStart(2, "0");
  const hh = date.getUTCHours().toString().padStart(2, "0");
  return `${yyyy}${mm}${dd}_${hh}00.gz`;
}

function readVariable(reader: NetCDFReader, name: string): any[] | null {
  try {
    const data = reader.getDataVariable(name);
    return Array.from(data as Iterable<unknown>);
  } catch (_) {
    return null;
  }
}

function readStringVariable(reader: NetCDFReader, name: string): string[] {
  try {
    const variable = reader.variables.find((item) => item.name === name);
    const data = reader.getDataVariable(name) as any;
    if (!variable) return [];
    const dimensionRef = variable.dimensions[1];
    const recordLength = typeof dimensionRef === "number"
      ? reader.dimensions[dimensionRef]?.size
      : reader.dimensions.find((dimension) => dimension.name === dimensionRef)
        ?.size;
    const values = Array.from(data as Iterable<unknown>);
    if (!recordLength || recordLength <= 0) {
      return values.map((value) => String(value ?? "").trim());
    }
    const output: string[] = [];
    for (let index = 0; index < values.length; index += recordLength) {
      const chars = values.slice(index, index + recordLength).map((value) => {
        if (typeof value === "number") return String.fromCharCode(value);
        return String(value ?? "");
      });
      output.push(chars.join("").replace(/\0/g, "").trim());
    }
    return output;
  } catch (_) {
    return [];
  }
}

function readValue(values: any[] | null, index: number): number | null {
  if (!values || index < 0 || index >= values.length) return null;
  const value = Number(values[index]);
  if (!Number.isFinite(value)) return null;
  if (Math.abs(value) > 1e20 || value <= -9998) return null;
  return value;
}

function parseMadisTime(value: number | null): Date | null {
  if (value == null) return null;
  const millis = value > 1e12 ? value : value * 1000;
  const date = new Date(millis);
  if (Number.isNaN(date.getTime())) return null;
  return date;
}

function normalizeLongitude(value: number | null): number | null {
  if (value == null) return null;
  if (value > 180) return value - 360;
  return value;
}

function msToKnots(value: number | null): number | null {
  return value == null ? null : value * 1.9438444924406;
}

function kelvinToC(value: number | null): number | null {
  return value == null ? null : value - 273.15;
}

function platformTypeLabel(value: number | null): string | null {
  if (value == null) return null;
  if (value === 0) return "moving";
  if (value === 1) return "stationary";
  return `type-${Math.trunc(value)}`;
}

function sanitizePlatformId(value: string): string {
  return value.trim().replace(/\s+/g, "-").replace(/[^A-Za-z0-9:_-]/g, "");
}

function normalizeSpotKey(value: string): string {
  return value.trim().toLowerCase().replace(/\s+/g, "-").replace(
    /[^a-z0-9:_-]/g,
    "",
  );
}

function readFiniteNumber(value: unknown): number | null {
  const number = Number(value);
  return Number.isFinite(number) ? number : null;
}

function clamp(value: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, value));
}

function haversineKm(
  latitudeA: number,
  longitudeA: number,
  latitudeB: number,
  longitudeB: number,
): number {
  const radiusKm = 6371;
  const dLat = toRadians(latitudeB - latitudeA);
  const dLon = toRadians(longitudeB - longitudeA);
  const lat1 = toRadians(latitudeA);
  const lat2 = toRadians(latitudeB);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLon / 2) ** 2;
  return radiusKm * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
}

function toRadians(value: number): number {
  return value * Math.PI / 180;
}
