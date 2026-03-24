import { corsHeaders } from "../_shared/cors.ts";
import { jsonResponse, readJson } from "../_shared/http.ts";

type BeachForecastRequest = {
  action: "aemet-beach-forecast";
  beachCode: string;
};

type MunicipalForecastRequest = {
  action: "aemet-municipal-forecast";
  municipalityCode: string;
};

type CoastalForecastRequest = {
  action: "aemet-coastal-forecast";
  coastalCode: string;
};

type StationObservationRequest = {
  action: "aemet-station-observation";
  stationId: string;
};

type LatestObservationRequest = {
  action: "aemet-observations-latest";
};

type MeteoblueForecastPackageRequest = {
  action: "meteoblue-forecast-package";
  lat: number;
  lon: number;
  name: string;
};

type MeteosourcePointForecastRequest = {
  action: "meteosource-point-forecast";
  lat: number;
  lon: number;
  sections: string;
};

type MeteostatPointHourlyRequest = {
  action: "meteostat-point-hourly";
  lat: number;
  lon: number;
  start: string;
  end: string;
};

type MeteostatPointDailyRequest = {
  action: "meteostat-point-daily";
  lat: number;
  lon: number;
  start: string;
  end: string;
};

type OpenMeteoPointForecastRequest = {
  action: "open-meteo-point-forecast";
  lat: number;
  lon: number;
  model: string;
};

type OpenMeteoPointMarineRequest = {
  action: "open-meteo-point-marine";
  lat: number;
  lon: number;
};

type AvametDailyHistoryRequest = {
  action: "avamet-daily-history";
  stationId: string;
};

type AvametIntradayHistoryRequest = {
  action: "avamet-intraday-history";
  stationId: string;
};

type AvametObservationRequest = {
  action: "avamet-observation";
  stationId: string;
};

type AiguaBlancaLatestRequest = {
  action: "aigua-blanca-latest";
};

type OpenMeteoWeatherGridRequest = {
  action: "open-meteo-weather-grid";
  latitudes: string;
  longitudes: string;
  model: string;
};

type OpenMeteoMarineGridRequest = {
  action: "open-meteo-marine-grid";
  latitudes: string;
  longitudes: string;
};

type InforatgePageRequest = {
  action: "inforatge-page";
  url: string;
};

type InforatgeGraphRequest = {
  action: "inforatge-graph";
  url: string;
  formData: Record<string, string>;
};

type ForecastProxyRequest =
  | MunicipalForecastRequest
  | BeachForecastRequest
  | CoastalForecastRequest
  | StationObservationRequest
  | LatestObservationRequest
  | MeteoblueForecastPackageRequest
  | MeteosourcePointForecastRequest
  | MeteostatPointHourlyRequest
  | MeteostatPointDailyRequest
  | OpenMeteoPointForecastRequest
  | OpenMeteoPointMarineRequest
  | AvametDailyHistoryRequest
  | AvametIntradayHistoryRequest
  | AvametObservationRequest
  | AiguaBlancaLatestRequest
  | OpenMeteoWeatherGridRequest
  | OpenMeteoMarineGridRequest
  | InforatgePageRequest
  | InforatgeGraphRequest;

const aemetApiKey = Deno.env.get("AEMET_OPENDATA_API_KEY") ?? "";
const meteoblueApiKey = Deno.env.get("METEOBLUE_API_KEY") ?? "";
const meteosourceApiKey = Deno.env.get("METEOSOURCE_API_KEY") ?? "";
const meteostatRapidApiKey =
  Deno.env.get("METEOSTAT_API_KEY") ??
  Deno.env.get("METEOSTAT_RAPIDAPI_KEY") ??
  "";
const meteostatRapidApiHost =
  Deno.env.get("METEOSTAT_API_HOST") ??
  Deno.env.get("METEOSTAT_RAPIDAPI_HOST") ??
  "meteostat.p.rapidapi.com";

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse(
      { error: "method-not-allowed" },
      { status: 405 },
    );
  }

  const requiresAemet =
    request.method === "POST";

  // Action-specific secret validation happens per branch.
  if (!requiresAemet) {
    return jsonResponse(
      { error: "method-not-allowed" },
      { status: 405 },
    );
  }

  try {
    const payload = await readJson<ForecastProxyRequest>(request);

    switch (payload.action) {
      case "aemet-municipal-forecast":
      case "aemet-beach-forecast":
      case "aemet-coastal-forecast":
      case "aemet-station-observation":
      case "aemet-observations-latest":
        if (!aemetApiKey) {
          return jsonResponse(
            {
              error: "missing-aemet-api-key",
              message: "Set AEMET_OPENDATA_API_KEY in Supabase secrets.",
            },
            { status: 500 },
          );
        }
        break;
      case "meteoblue-forecast-package":
        if (!meteoblueApiKey) {
          return jsonResponse(
            {
              error: "missing-meteoblue-api-key",
              message: "Set METEOBLUE_API_KEY in Supabase secrets.",
            },
            { status: 500 },
          );
        }
        break;
      case "meteosource-point-forecast":
        if (!meteosourceApiKey) {
          return jsonResponse(
            {
              error: "missing-meteosource-api-key",
              message: "Set METEOSOURCE_API_KEY in Supabase secrets.",
            },
            { status: 500 },
          );
        }
        break;
      case "meteostat-point-hourly":
      case "meteostat-point-daily":
        if (!meteostatRapidApiKey) {
          return jsonResponse(
            {
              error: "missing-meteostat-rapidapi-key",
              message:
                "Set METEOSTAT_API_KEY in Supabase secrets.",
            },
            { status: 500 },
          );
        }
        break;
      default:
        break;
    }

    switch (payload.action) {
      case "aemet-municipal-forecast":
        return jsonResponse(await fetchAemetMunicipalForecast(payload.municipalityCode));
      case "aemet-beach-forecast":
        return jsonResponse(await fetchAemetBeachForecast(payload.beachCode));
      case "aemet-coastal-forecast":
        return jsonResponse(await fetchAemetCoastalForecast(payload.coastalCode));
      case "aemet-station-observation":
        return jsonResponse(await fetchAemetStationObservation(payload.stationId));
      case "aemet-observations-latest":
        return jsonResponse(await fetchAemetLatestObservations());
      case "meteoblue-forecast-package":
        return jsonResponse(
          await fetchMeteoblueForecastPackage(payload.lat, payload.lon, payload.name),
        );
      case "meteosource-point-forecast":
        return jsonResponse(
          await fetchMeteosourcePointForecast(
            payload.lat,
            payload.lon,
            payload.sections,
          ),
        );
      case "meteostat-point-hourly":
        return jsonResponse(
          await fetchMeteostatPointHourly(
            payload.lat,
            payload.lon,
            payload.start,
            payload.end,
          ),
        );
      case "meteostat-point-daily":
        return jsonResponse(
          await fetchMeteostatPointDaily(
            payload.lat,
            payload.lon,
            payload.start,
            payload.end,
          ),
        );
      case "open-meteo-point-forecast":
        return jsonResponse(
          await fetchOpenMeteoPointForecast(payload.lat, payload.lon, payload.model),
        );
      case "open-meteo-point-marine":
        return jsonResponse(
          await fetchOpenMeteoPointMarine(payload.lat, payload.lon),
        );
      case "avamet-daily-history":
        return jsonResponse(await fetchAvametDailyHistory(payload.stationId));
      case "avamet-intraday-history":
        return jsonResponse(await fetchAvametIntradayHistory(payload.stationId));
      case "avamet-observation":
        return jsonResponse(await fetchAvametObservation(payload.stationId));
      case "aigua-blanca-latest":
        return jsonResponse(await fetchAiguaBlancaLatest());
      case "open-meteo-weather-grid":
        return jsonResponse(
          await fetchOpenMeteoWeatherGrid(
            payload.latitudes,
            payload.longitudes,
            payload.model,
          ),
        );
      case "open-meteo-marine-grid":
        return jsonResponse(
          await fetchOpenMeteoMarineGrid(payload.latitudes, payload.longitudes),
        );
      case "inforatge-page":
        return jsonResponse(await fetchInforatgePage(payload.url));
      case "inforatge-graph":
        return jsonResponse(await fetchInforatgeGraph(payload.url, payload.formData));
      default:
        return jsonResponse({ error: "unsupported-action" }, { status: 400 });
    }
  } catch (error) {
    return jsonResponse(
      {
        error: "forecast-proxy-failed",
        message: error instanceof Error ? error.message : String(error),
      },
      { status: 500 },
    );
  }
});

async function fetchAemetBeachForecast(beachCode: string) {
  if (!beachCode.trim()) {
    throw new Error("missing-beach-code");
  }

  const envelope = await fetchJsonObject(
    `https://opendata.aemet.es/opendata/api/prediccion/especifica/playa/${encodeURIComponent(beachCode)}/?api_key=${aemetApiKey}`,
  );
  const dataUrl = readDatosUrl(envelope);
  const data = await fetchJsonArray(dataUrl);
  return {
    provider: "AEMET",
    action: "aemet-beach-forecast",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchAvametDailyHistory(stationId: string) {
  if (!stationId.trim()) {
    throw new Error("missing-station-id");
  }
  const data = await fetchText(
    `https://www.avamet.org/mx-dia.php?id=${encodeURIComponent(stationId)}`,
  );
  return {
    provider: "AVAMET",
    action: "avamet-daily-history",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchAvametIntradayHistory(stationId: string) {
  if (!stationId.trim()) {
    throw new Error("missing-station-id");
  }
  const data = await fetchText(
    `https://www.avamet.org/mxo_i.php?id=${encodeURIComponent(stationId)}`,
  );
  return {
    provider: "AVAMET",
    action: "avamet-intraday-history",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchAvametObservation(stationId: string) {
  if (!stationId.trim()) {
    throw new Error("missing-station-id");
  }
  const data = await fetchText(
    `https://www.avamet.org/mxo_i.php?id=${encodeURIComponent(stationId)}`,
  );
  return {
    provider: "AVAMET",
    action: "avamet-observation",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchAiguaBlancaLatest() {
  const response = await fetch("https://meteo.feedket.com/api/endpoints/latest.php", {
    headers: {
      "X-API-KEY": "GDFH85DF-GD75D65-SFSEF5",
      "content-type": "application/json",
    },
  });
  if (!response.ok) {
    throw new Error(`aigua-blanca-upstream-http-${response.status}`);
  }
  const data = await response.json();
  if (!isRecord(data)) {
    throw new Error("invalid-aigua-blanca-json-object");
  }
  return {
    provider: "AiguaBlanca",
    action: "aigua-blanca-latest",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchOpenMeteoPointForecast(
  lat: number,
  lon: number,
  model: string,
) {
  if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
    throw new Error("invalid-location");
  }
  const normalizedModel = (() => {
    switch (model) {
      case "Best match":
        return "";
      case "ICON":
        return "icon_seamless";
      case "ECMWF":
        return "ecmwf_ifs025";
      case "AROME Seamless":
        return "meteofrance_arome_seamless";
      case "AROME France":
        return "meteofrance_arome_france";
      case "ARPEGE Europe":
        return "meteofrance_arpege_europe";
      case "ARPEGE Seamless":
        return "meteofrance_seamless";
      case "ARPEGE World":
        return "meteofrance_arpege_world";
      default:
        return "gfs_seamless";
    }
  })();
  const modelsQuery = normalizedModel ? `&models=${normalizedModel}` : "";
  const response = await fetch(
    `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&hourly=temperature_2m,pressure_msl,cloud_cover,precipitation,wind_speed_10m,wind_direction_10m,wind_gusts_10m&forecast_days=16${modelsQuery}&timezone=auto`,
  );
  if (!response.ok) {
    throw new Error(`open-meteo-point-forecast-upstream-http-${response.status}`);
  }
  const data = await response.json();
  if (!isRecord(data)) {
    throw new Error("invalid-open-meteo-point-forecast-json");
  }
  return {
    provider: "OpenMeteo",
    action: "open-meteo-point-forecast",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchOpenMeteoPointMarine(lat: number, lon: number) {
  if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
    throw new Error("invalid-location");
  }
  const response = await fetch(
    `https://marine-api.open-meteo.com/v1/marine?latitude=${lat}&longitude=${lon}&hourly=wave_height,sea_surface_temperature&forecast_days=16&timezone=auto`,
  );
  if (!response.ok) {
    throw new Error(`open-meteo-point-marine-upstream-http-${response.status}`);
  }
  const data = await response.json();
  if (!isRecord(data)) {
    throw new Error("invalid-open-meteo-point-marine-json");
  }
  return {
    provider: "OpenMeteo",
    action: "open-meteo-point-marine",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchOpenMeteoWeatherGrid(
  latitudes: string,
  longitudes: string,
  model: string,
) {
  if (!latitudes.trim() || !longitudes.trim()) {
    throw new Error("missing-grid-coordinates");
  }
  const normalizedModel = (() => {
    switch (model) {
      case "Best match":
        return "";
      case "ICON":
        return "icon_seamless";
      case "ECMWF":
        return "ecmwf_ifs025";
      case "AROME Seamless":
        return "meteofrance_arome_seamless";
      case "AROME France":
        return "meteofrance_arome_france";
      case "ARPEGE Europe":
        return "meteofrance_arpege_europe";
      case "ARPEGE Seamless":
        return "meteofrance_seamless";
      case "ARPEGE World":
        return "meteofrance_arpege_world";
      default:
        return "gfs_seamless";
    }
  })();
  const modelsQuery = normalizedModel ? `&models=${normalizedModel}` : "";
  const response = await fetch(
    `https://api.open-meteo.com/v1/forecast?latitude=${latitudes}&longitude=${longitudes}&hourly=wind_speed_10m,wind_direction_10m,wind_gusts_10m&forecast_days=16${modelsQuery}&timezone=auto`,
  );
  if (!response.ok) {
    throw new Error(`open-meteo-weather-upstream-http-${response.status}`);
  }
  const data = await response.json();
  return {
    provider: "OpenMeteo",
    action: "open-meteo-weather-grid",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchOpenMeteoMarineGrid(latitudes: string, longitudes: string) {
  if (!latitudes.trim() || !longitudes.trim()) {
    throw new Error("missing-grid-coordinates");
  }
  const response = await fetch(
    `https://marine-api.open-meteo.com/v1/marine?latitude=${latitudes}&longitude=${longitudes}&hourly=wave_height&forecast_days=16&timezone=auto`,
  );
  if (!response.ok) {
    throw new Error(`open-meteo-marine-upstream-http-${response.status}`);
  }
  const data = await response.json();
  return {
    provider: "OpenMeteo",
    action: "open-meteo-marine-grid",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchInforatgePage(url: string) {
  const safeUrl = normalizeInforatgeUrl(url);
  const data = await fetchText(safeUrl);
  return {
    provider: "Inforatge",
    action: "inforatge-page",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchInforatgeGraph(
  url: string,
  formData: Record<string, string>,
) {
  const safeUrl = normalizeInforatgeUrl(url);
  const body = new URLSearchParams(formData).toString();
  const response = await fetch(safeUrl, {
    method: "POST",
    headers: {
      "content-type": "application/x-www-form-urlencoded; charset=utf-8",
      "user-agent": "WindWisher/1.0",
    },
    body,
  });
  if (!response.ok) {
    throw new Error(`inforatge-graph-upstream-http-${response.status}`);
  }
  const data = await response.text();
  return {
    provider: "Inforatge",
    action: "inforatge-graph",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchAemetMunicipalForecast(municipalityCode: string) {
  if (!municipalityCode.trim()) {
    throw new Error("missing-municipality-code");
  }

  const envelope = await fetchJsonObject(
    `https://opendata.aemet.es/opendata/api/prediccion/especifica/municipio/horaria/${encodeURIComponent(municipalityCode)}/?api_key=${aemetApiKey}`,
  );
  const dataUrl = readDatosUrl(envelope);
  const data = await fetchJsonArray(dataUrl);
  return {
    provider: "AEMET",
    action: "aemet-municipal-forecast",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchAemetCoastalForecast(coastalCode: string) {
  if (!coastalCode.trim()) {
    throw new Error("missing-coastal-code");
  }

  const envelope = await fetchJsonObject(
    `https://opendata.aemet.es/opendata/api/prediccion/maritima/costera/costa/${encodeURIComponent(coastalCode)}/?api_key=${aemetApiKey}`,
  );
  const dataUrl = readDatosUrl(envelope);
  const data = await fetchJsonArray(dataUrl);
  return {
    provider: "AEMET",
    action: "aemet-coastal-forecast",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchAemetStationObservation(stationId: string) {
  if (!stationId.trim()) {
    throw new Error("missing-station-id");
  }

  const envelope = await fetchJsonObject(
    `https://opendata.aemet.es/opendata/api/observacion/convencional/datos/estacion/${encodeURIComponent(stationId)}/?api_key=${aemetApiKey}`,
  );
  const dataUrl = readDatosUrl(envelope);
  const data = await fetchJsonArray(dataUrl);
  return {
    provider: "AEMET",
    action: "aemet-station-observation",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchAemetLatestObservations() {
  const envelope = await fetchJsonObject(
    `https://opendata.aemet.es/opendata/api/observacion/convencional/todas/?api_key=${aemetApiKey}`,
  );
  const dataUrl = readDatosUrl(envelope);
  const data = await fetchJsonArray(dataUrl);
  return {
    provider: "AEMET",
    action: "aemet-observations-latest",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchMeteoblueForecastPackage(
  lat: number,
  lon: number,
  name: string,
) {
  if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
    throw new Error("invalid-location");
  }

  const encodedName = encodeURIComponent(name || "spot");
  const response = await fetch(
    `https://my.meteoblue.com/packages/basic-15min_basic-day_current_clouds-15min_sea-1h_air-15min_wind-1h?lat=${lat}&lon=${lon}&tz=utc&format=json&windspeed=kn&winddirection=degree&forecast_days=7&name=${encodedName}&apikey=${meteoblueApiKey}`,
  );
  if (!response.ok) {
    throw new Error(`meteoblue-upstream-http-${response.status}`);
  }
  const data = await response.json();
  if (!isRecord(data)) {
    throw new Error("invalid-meteoblue-json-object");
  }
  return {
    provider: "Meteoblue",
    action: "meteoblue-forecast-package",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchMeteosourcePointForecast(
  lat: number,
  lon: number,
  sections: string,
) {
  if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
    throw new Error("invalid-location");
  }
  const safeSections = sections.trim() || "hourly";
  const response = await fetch(
    `https://www.meteosource.com/api/v1/free/point?lat=${lat}&lon=${lon}&sections=${encodeURIComponent(safeSections)}&timezone=UTC&language=en&units=metric&key=${meteosourceApiKey}`,
  );
  if (!response.ok) {
    throw new Error(`meteosource-upstream-http-${response.status}`);
  }
  const data = await response.json();
  if (!isRecord(data)) {
    throw new Error("invalid-meteosource-json-object");
  }
  return {
    provider: "Meteosource",
    action: "meteosource-point-forecast",
    requestedAt: new Date().toISOString(),
    data,
  };
}

async function fetchMeteostatPointHourly(
  lat: number,
  lon: number,
  start: string,
  end: string,
) {
  return fetchMeteostatPointSeries("hourly", lat, lon, start, end);
}

async function fetchMeteostatPointDaily(
  lat: number,
  lon: number,
  start: string,
  end: string,
) {
  return fetchMeteostatPointSeries("daily", lat, lon, start, end);
}

async function fetchMeteostatPointSeries(
  mode: "hourly" | "daily",
  lat: number,
  lon: number,
  start: string,
  end: string,
) {
  if (!Number.isFinite(lat) || !Number.isFinite(lon)) {
    throw new Error("invalid-location");
  }
  if (!start.trim() || !end.trim()) {
    throw new Error("invalid-date-range");
  }
  const tzPart = mode === "hourly" ? "&tz=UTC" : "";
  const response = await fetch(
    `https://${meteostatRapidApiHost}/point/${mode}?lat=${lat}&lon=${lon}&start=${encodeURIComponent(start)}&end=${encodeURIComponent(end)}${tzPart}&units=metric&model=true`,
    {
      headers: {
        "x-rapidapi-host": meteostatRapidApiHost,
        "x-rapidapi-key": meteostatRapidApiKey,
      },
    },
  );
  if (!response.ok) {
    throw new Error(`meteostat-upstream-http-${response.status}`);
  }
  const data = await response.json();
  if (!isRecord(data)) {
    throw new Error("invalid-meteostat-json-object");
  }
  return {
    provider: "Meteostat",
    action: `meteostat-point-${mode}`,
    requestedAt: new Date().toISOString(),
    data,
  };
}

function readDatosUrl(envelope: Record<string, unknown>): string {
  const dataUrl = envelope["datos"];
  if (typeof dataUrl !== "string" || !dataUrl.trim()) {
    throw new Error("missing-datos-url");
  }
  return dataUrl;
}

async function fetchJsonObject(url: string): Promise<Record<string, unknown>> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`upstream-http-${response.status}`);
  }
  const payload = await response.json();
  if (!isRecord(payload)) {
    throw new Error("invalid-json-object");
  }
  return payload;
}

async function fetchJsonArray(url: string): Promise<unknown[]> {
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`upstream-http-${response.status}`);
  }
  const payload = await response.json();
  if (!Array.isArray(payload)) {
    throw new Error("invalid-json-array");
  }
  return payload;
}

async function fetchText(url: string): Promise<string> {
  const response = await fetch(url, {
    headers: {
      "user-agent": "WindWisher/1.0",
    },
  });
  if (!response.ok) {
    throw new Error(`upstream-http-${response.status}`);
  }
  return await response.text();
}

function normalizeInforatgeUrl(url: string): string {
  if (!url.trim()) {
    throw new Error("missing-inforatge-url");
  }
  const normalized = url.startsWith("//")
    ? `https:${url}`
    : url.startsWith("/")
    ? `https://inforatge.com${url}`
    : url;
  const parsed = new URL(normalized);
  if (!parsed.hostname.endsWith("inforatge.com")) {
    throw new Error("invalid-inforatge-host");
  }
  return parsed.toString();
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
