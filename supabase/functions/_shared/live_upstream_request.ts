// These public proxy operations never accept an arbitrary upstream URL or body.
export function meteoclimaticUrl(stationId: unknown): string {
  if (typeof stationId !== "string" || !/^[A-Z0-9]{5,40}$/.test(stationId)) {
    throw new Error("invalid-meteoclimatic-station-id");
  }
  return `https://www.meteoclimatic.net/feed/rss/${stationId}`;
}

export function portusWindRequest(operation: unknown, stationId: unknown): {
  url: string;
  body: string | null;
} {
  const base = "https://portus.puertos.es/portussvr/api";
  if (operation === "stations") {
    return { url: `${base}/estaciones/rt/WIND?locale=es`, body: null };
  }
  if (
    typeof stationId !== "number" || !Number.isSafeInteger(stationId) ||
    stationId <= 0
  ) {
    throw new Error("invalid-portus-station-id");
  }
  switch (operation) {
    case "current":
      return {
        url: `${base}/lastData/station/${stationId}?locale=es`,
        body: JSON.stringify(["WIND", "AIR_TEMP", "AIR_PRESURE"]),
      };
    case "history":
      return {
        url: `${base}/RTData/station/${stationId}?locale=es`,
        body: JSON.stringify([42, 40, 43]),
      };
    default:
      throw new Error("invalid-portus-operation");
  }
}

export function normalizeInforatgeUrl(url: string): string {
  const parsed = new URL(url, "https://inforatge.com");
  if (
    parsed.protocol !== "https:" ||
    !["inforatge.com", "www.inforatge.com"].includes(parsed.hostname) ||
    parsed.port !== "" || parsed.username !== "" || parsed.password !== ""
  ) {
    throw new Error("invalid-inforatge-url");
  }
  return parsed.toString();
}
