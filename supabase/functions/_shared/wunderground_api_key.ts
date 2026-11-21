/** Only use weather configuration or explicit PWS API URLs, never ad keys. */
export function extractWundergroundApiKey(dashboard: string): string | null {
  const configKeys = new Set<string>();
  for (
    const match of dashboard.matchAll(
      /\b(?:const|let|var)\s+data\s*=\s*(\{.*?\})\s*;/gs,
    )
  ) {
    try {
      const config = JSON.parse(match[1]);
      if (
        config == null || typeof config !== "object" ||
        !["https://api.weather.com", "https://api.weather.com/"].includes(
          config.API_URL,
        )
      ) continue;
      if (
        typeof config.API_KEY === "string" &&
        /^[A-Za-z0-9_-]+$/.test(config.API_KEY)
      ) {
        configKeys.add(config.API_KEY);
      }
    } catch {
      // Do not evaluate executable JavaScript to recover a credential.
    }
  }
  if (configKeys.size > 0) {
    return configKeys.size === 1 ? [...configKeys][0] : null;
  }
  const legacyKeys = new Set<string>();
  const normalized = dashboard.replaceAll("\\/", "/").replaceAll("&amp;", "&");
  for (const match of normalized.matchAll(/https:\/\/[^\s"'<>]+/g)) {
    try {
      const url = new URL(match[0]);
      if (
        url.hostname !== "api.weather.com" || url.username || url.password ||
        (url.port && url.port !== "443") ||
        !url.pathname.startsWith("/v2/pws/observations/")
      ) continue;
      const keys = url.searchParams.getAll("apiKey");
      if (keys.length === 1 && /^[A-Za-z0-9_-]+$/.test(keys[0])) {
        legacyKeys.add(keys[0]);
      }
    } catch {
      // Malformed URLs cannot supply a key.
    }
  }
  return legacyKeys.size === 1 ? [...legacyKeys][0] : null;
}

export async function readWundergroundResponse(
  response: Response,
): Promise<Record<string, unknown>> {
  if (!response.ok) throw new Error(`wunderground-http-${response.status}`);
  if (response.status === 204) return {};
  const payload: unknown = await response.json();
  if (
    payload == null || typeof payload !== "object" || Array.isArray(payload)
  ) {
    throw new Error("wunderground-invalid-response");
  }
  return payload as Record<string, unknown>;
}
