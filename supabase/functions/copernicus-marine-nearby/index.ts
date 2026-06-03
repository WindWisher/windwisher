// deno-lint-ignore-file no-explicit-any
import { createClient } from "jsr:@supabase/supabase-js@2";
import initSqlJs from "npm:sql.js@1.12.0";
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

type CopernicusSqliteRow = {
  variable: string;
  platform_id: string;
  platform_type: string;
  time: number;
  longitude: number;
  latitude: number;
  elevation: number | null;
  pressure: number | null;
  value: number;
  value_qc: number | null;
};

type MaritimeObservationRow = {
  spot_key: string;
  spot_name: string;
  provider: "COPERNICUS_MARINE";
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

type CopernicusPlatformObservation = {
  platformId: string;
  platformType: string | null;
  institution: string | null;
  latitude: number;
  longitude: number;
  distanceKm: number;
  observedAt: string;
  values: Map<string, { value: number; observedAt: string }>;
};

const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
const copernicusUsername = Deno.env.get("COPERNICUSMARINE_SERVICE_USERNAME") ??
  "";
const copernicusPassword = Deno.env.get("COPERNICUSMARINE_SERVICE_PASSWORD") ??
  "";
const supabase = createClient(supabaseUrl, serviceRoleKey, {
  auth: { persistSession: false, autoRefreshToken: false },
});

const provider = "COPERNICUS_MARINE" as const;
const datasetId = "cmems_obs-ins_med_phybgcwav_mynrt_na_irr";
const productId = "INSITU_MED_PHYBGCWAV_DISCRETE_MYNRT_013_035";
const stacMetadataUrl =
  "https://s3.waw3-1.cloudferro.com/mdl-metadata/metadata/INSITU_MED_PHYBGCWAV_DISCRETE_MYNRT_013_035/cmems_obs-ins_med_phybgcwav_mynrt_na_irr_202311--ext--latest/dataset.stac.json";
const cacheFreshMinutes = 30;
const defaultRadiusKm = 10;
const maxRadiusKm = 50;
const defaultMaxResults = 10;
const variables = [
  "WSPD",
  "WDIR",
  "GSPD",
  "GDIR",
  "DRYT",
  "RELH",
  "ATMS",
  "VHM0",
  "VAVT",
  "TEMP",
];
const sqlPromise = initSqlJs();

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
  if (!copernicusUsername || !copernicusPassword) {
    return jsonResponse(
      { error: "missing-copernicus-credentials" },
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
          provider,
          total: cached.total,
          offset,
          limit: maxResults,
          hasMore: offset + cached.rows.length < cached.total,
          observations: cached.rows,
        });
      }
    }

    const result = await collectNearbyCopernicusRows({
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
      source: "copernicus",
      provider,
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
        error: "copernicus-marine-nearby-failed",
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
  const { data, error } = await supabase
    .from("spot_maritime_observations")
    .select("*")
    .eq("spot_key", spotKey)
    .eq("provider", provider)
    .lte("distance_km", radiusKm)
    .gte("source_fetched_at", freshSince)
    .order("distance_km", { ascending: true })
    .order("observed_at", { ascending: false });
  if (error) throw error;
  const latestRows = latestObservationRowsByPlatform(
    ((data ?? []) as MaritimeObservationRow[]),
  );
  return {
    rows: latestRows.slice(offset, offset + maxResults),
    total: latestRows.length,
  };
}

async function collectNearbyCopernicusRows(params: {
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
  const bbox = boundingBox(params.latitude, params.longitude, params.radiusKm);
  const now = new Date();
  const start = new Date(now.getTime() - 72 * 60 * 60 * 1000);
  const parsedRows = await fetchCopernicusRows({
    minLongitude: bbox.minLongitude,
    maxLongitude: bbox.maxLongitude,
    minLatitude: bbox.minLatitude,
    maxLatitude: bbox.maxLatitude,
    start,
    end: now,
  });
  const fetchedAt = new Date().toISOString();
  const byPlatformAndObservedAt = new Map<string, CopernicusPlatformObservation>();

  for (const row of parsedRows) {
    const platformId = sanitizePlatformId(row.platform_id);
    const observedAt = new Date(row.time * 1000);
    const observedAtIso = observedAt.toISOString();
    const latitude = row.latitude;
    const longitude = row.longitude;
    const value = row.value;
    if (
      !platformId || !observedAt || latitude == null || longitude == null ||
      value == null || !isUsableQuality(row.value_qc)
    ) {
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
    const groupKey = `${platformId}|${observedAtIso}`;
    const existing = byPlatformAndObservedAt.get(groupKey);
    if (!existing) {
      byPlatformAndObservedAt.set(groupKey, {
        platformId,
        platformType: row.platform_type || null,
        institution: null,
        latitude,
        longitude,
        distanceKm,
        observedAt: observedAtIso,
        values: new Map([
          [row.variable, { value, observedAt: observedAtIso }],
        ]),
      });
      continue;
    }
    const existingVariable = existing.values.get(row.variable);
    if (!existingVariable) {
      existing.values.set(row.variable, {
        value,
        observedAt: observedAtIso,
      });
    }
  }

  const allRows = [...byPlatformAndObservedAt.values()]
    .map((platform) => toObservationRow(params, platform, fetchedAt))
    .sort((a, b) => {
      const distanceDelta = a.distance_km - b.distance_km;
      if (distanceDelta !== 0) return distanceDelta;
      return Date.parse(b.observed_at) - Date.parse(a.observed_at);
    });
  const latestRows = latestObservationRowsByPlatform(allRows);

  return {
    rows: latestRows.slice(params.offset, params.offset + params.maxResults),
    allRows,
    total: latestRows.length,
    sourceFile: `${datasetId}:${start.toISOString()}/${now.toISOString()}`,
  };
}

function latestObservationRowsByPlatform(
  rows: MaritimeObservationRow[],
): MaritimeObservationRow[] {
  const byPlatform = new Map<string, MaritimeObservationRow>();
  for (const row of rows) {
    const existing = byPlatform.get(row.platform_id);
    if (
      !existing ||
      Date.parse(row.observed_at) > Date.parse(existing.observed_at)
    ) {
      byPlatform.set(row.platform_id, row);
    }
  }
  return [...byPlatform.values()].sort((a, b) => a.distance_km - b.distance_km);
}

async function fetchCopernicusRows(params: {
  minLongitude: number;
  maxLongitude: number;
  minLatitude: number;
  maxLatitude: number;
  start: Date;
  end: Date;
}): Promise<CopernicusSqliteRow[]> {
  const stac = await fetchJson(stacMetadataUrl);
  const asset = stac.assets?.timeChunked;
  const baseUrl = asset?.href;
  if (!baseUrl || !asset.viewDims) {
    throw new Error("invalid-copernicus-stac");
  }
  const rows: CopernicusSqliteRow[] = [];
  for (const variable of variables) {
    const chunkNames = getChunkNames(asset, variable, params);
    for (const chunkName of chunkNames) {
      const chunkRows = await fetchSqliteRows(
        `${baseUrl}/${variable}/${chunkName}.sqlite`,
        variable,
        params,
      );
      rows.push(...chunkRows);
    }
  }
  return rows;
}

async function fetchSqliteRows(
  url: string,
  variable: string,
  params: {
    minLongitude: number;
    maxLongitude: number;
    minLatitude: number;
    maxLatitude: number;
    start: Date;
    end: Date;
  },
): Promise<CopernicusSqliteRow[]> {
  const response = await fetch(url, {
    headers: { "user-agent": "WindWisher/1.0" },
  });
  if (response.status === 403 || response.status === 404) {
    return [];
  }
  if (!response.ok) {
    const body = await response.text();
    throw new Error(
      `copernicus-sqlite-${response.status}:${body.slice(0, 120)}`,
    );
  }
  const SQL = await sqlPromise;
  const db = new SQL.Database(new Uint8Array(await response.arrayBuffer()));
  try {
    const startSeconds = Math.floor(params.start.getTime() / 1000);
    const endSeconds = Math.floor(params.end.getTime() / 1000);
    const statement = db.prepare(`
      select platform_id, platform_type, time, longitude, latitude, elevation,
             pressure, value, value_qc
      from data
      where time >= :startSeconds
        and time <= :endSeconds
        and longitude >= :minLongitude
        and longitude <= :maxLongitude
        and latitude >= :minLatitude
        and latitude <= :maxLatitude
        and elevation >= -10
        and elevation <= 10
    `);
    statement.bind({
      ":startSeconds": startSeconds,
      ":endSeconds": endSeconds,
      ":minLongitude": params.minLongitude,
      ":maxLongitude": params.maxLongitude,
      ":minLatitude": params.minLatitude,
      ":maxLatitude": params.maxLatitude,
    });
    const rows: CopernicusSqliteRow[] = [];
    while (statement.step()) {
      const row = statement.getAsObject() as Record<string, unknown>;
      rows.push({
        variable,
        platform_id: String(row.platform_id ?? ""),
        platform_type: String(row.platform_type ?? ""),
        time: Number(row.time),
        longitude: Number(row.longitude),
        latitude: Number(row.latitude),
        elevation: readFiniteNumber(row.elevation),
        pressure: readFiniteNumber(row.pressure),
        value: Number(row.value),
        value_qc: readFiniteNumber(row.value_qc),
      });
    }
    statement.free();
    return rows;
  } finally {
    db.close();
  }
}

function getChunkNames(
  asset: any,
  variable: string,
  params: {
    start: Date;
    end: Date;
  },
): string[] {
  const dims = asset.viewDims ?? {};
  const ranges: Record<string, [number, number]> = {};
  for (const coordinateId of ["time", "elevation", "longitude", "latitude"]) {
    const dim = dims[coordinateId];
    const chunkLen = readChunkValue(dim?.chunkLen, variable);
    if (!chunkLen) {
      ranges[coordinateId] = [0, 0];
      continue;
    }
    const min = coordinateId === "time"
      ? Math.floor(params.start.getTime() / 1000)
      : coordinateId === "elevation"
      ? -10
      : undefined;
    const max = coordinateId === "time"
      ? Math.floor(params.end.getTime() / 1000)
      : coordinateId === "elevation"
      ? 10
      : undefined;
    if (min == null || max == null) {
      ranges[coordinateId] = [0, 0];
      continue;
    }
    ranges[coordinateId] = [
      chunkIndex(min, chunkLen, dim, variable),
      chunkIndex(max, chunkLen, dim, variable),
    ];
  }
  const names: string[] = [];
  for (let time = ranges.time[0]; time <= ranges.time[1]; time += 1) {
    for (
      let elevation = ranges.elevation[0];
      elevation <= ranges.elevation[1];
      elevation += 1
    ) {
      for (
        let longitude = ranges.longitude[0];
        longitude <= ranges.longitude[1];
        longitude += 1
      ) {
        for (
          let latitude = ranges.latitude[0];
          latitude <= ranges.latitude[1];
          latitude += 1
        ) {
          names.push(`${time}.${elevation}.${longitude}.${latitude}`);
        }
      }
    }
  }
  return names;
}

function chunkIndex(
  value: number,
  chunkLength: number,
  dim: any,
  variable: string,
): number {
  const reference = Number(dim.chunkRefCoord ?? 0);
  const chunkType = dim.chunkType ?? "default";
  if (chunkType === "symmetricGeometric") {
    const factor = Number(
      readChunkValue(dim.chunkGeometricFactor, variable) ?? 1,
    );
    const absolute = Math.abs(value - reference);
    if (absolute < chunkLength) return 0;
    const index = factor === 1
      ? Math.floor(absolute / chunkLength)
      : Math.ceil(Math.log(absolute / chunkLength) / Math.log(factor));
    return value < reference ? -index : index;
  }
  return Math.floor((value - reference) / chunkLength);
}

function readChunkValue(value: unknown, variable: string): number | null {
  if (value == null) return null;
  if (typeof value === "number") return Number.isFinite(value) ? value : null;
  if (typeof value === "object") {
    const item = (value as Record<string, unknown>)[variable];
    return readFiniteNumber(item);
  }
  return readFiniteNumber(value);
}

async function fetchJson(url: string): Promise<any> {
  const response = await fetch(url, {
    headers: { "user-agent": "WindWisher/1.0" },
  });
  if (!response.ok) {
    throw new Error(`copernicus-metadata-${response.status}`);
  }
  return await response.json();
}

function toObservationRow(
  params: {
    spotKey: string;
    spotName: string;
  },
  platform: {
    platformId: string;
    platformType: string | null;
    institution: string | null;
    latitude: number;
    longitude: number;
    distanceKm: number;
    observedAt: string;
    values: Map<string, { value: number; observedAt: string }>;
  },
  fetchedAt: string,
): MaritimeObservationRow {
  const windSpeedMs = readPlatformValue(platform.values, "WSPD");
  const gustMs = readPlatformValue(platform.values, "GSPD");
  return {
    spot_key: params.spotKey,
    spot_name: params.spotName,
    provider,
    platform_id: platform.platformId,
    platform_type: platform.platformType,
    platform_name: platform.platformId,
    station_key: `copernicus-marine:${platform.platformId}`,
    latitude: platform.latitude,
    longitude: platform.longitude,
    distance_km: Number(platform.distanceKm.toFixed(3)),
    observed_at: platform.observedAt,
    source_fetched_at: fetchedAt,
    source_file: productId,
    wind_speed_ms: windSpeedMs,
    wind_speed_knots: msToKnots(windSpeedMs),
    wind_dir_deg: readPlatformValue(platform.values, "WDIR"),
    gust_ms: gustMs,
    gust_knots: msToKnots(gustMs),
    air_temp_c: readPlatformValue(platform.values, "DRYT"),
    pressure_hpa: readPlatformValue(platform.values, "ATMS"),
    humidity_pct: readPlatformValue(platform.values, "RELH"),
    sea_surface_temp_c: readPlatformValue(platform.values, "TEMP"),
    wave_height_m: readPlatformValue(platform.values, "VHM0"),
    wave_period_s: readPlatformValue(platform.values, "VAVT"),
    quality: "copernicus-qc-1-2",
    raw_payload: {
      datasetId,
      productId,
      variables: Object.fromEntries(
        [...platform.values.entries()].map(([key, item]) => [
          key,
          item.value,
        ]),
      ),
      variableObservedAt: Object.fromEntries(
        [...platform.values.entries()].map(([key, item]) => [
          key,
          item.observedAt,
        ]),
      ),
      institution: platform.institution,
      platformType: platform.platformType,
    },
  };
}

function readPlatformValue(
  values: Map<string, { value: number; observedAt: string }>,
  key: string,
): number | null {
  return values.get(key)?.value ?? null;
}

function boundingBox(
  latitude: number,
  longitude: number,
  radiusKm: number,
): {
  minLatitude: number;
  maxLatitude: number;
  minLongitude: number;
  maxLongitude: number;
} {
  const latDelta = radiusKm / 111.32;
  const lonDelta = radiusKm / (111.32 * Math.cos(toRadians(latitude)));
  return {
    minLatitude: clamp(latitude - latDelta, -90, 90),
    maxLatitude: clamp(latitude + latDelta, -90, 90),
    minLongitude: longitude - lonDelta,
    maxLongitude: longitude + lonDelta,
  };
}

function isUsableQuality(value: number | null): boolean {
  return value == null || value === 1 || value === 2;
}

function msToKnots(value: number | null): number | null {
  return value == null ? null : value * 1.9438444924406;
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

function parseDate(value: string): Date | null {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? null : date;
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
