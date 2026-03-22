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

type ForecastProxyRequest =
  | MunicipalForecastRequest
  | BeachForecastRequest
  | CoastalForecastRequest
  | StationObservationRequest
  | LatestObservationRequest
  | MeteoblueForecastPackageRequest
  | MeteosourcePointForecastRequest
  | MeteostatPointHourlyRequest
  | MeteostatPointDailyRequest;

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

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}
