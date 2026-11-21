import {
  meteoclimaticUrl,
  normalizeInforatgeUrl,
  portusWindRequest,
} from "./live_upstream_request.ts";

function rejects(action: () => unknown) {
  try {
    action();
  } catch {
    return;
  }
  throw new Error("Unsafe upstream request accepted");
}

Deno.test("Meteoclimatic only accepts station codes", () => {
  if (
    meteoclimaticUrl("ESPVA4600000046420A") !==
      "https://www.meteoclimatic.net/feed/rss/ESPVA4600000046420A"
  ) {
    throw new Error("Incorrect station URL");
  }
  for (const id of ["../admin", "https://example.com", "A?x=y", null, ""]) {
    rejects(() => meteoclimaticUrl(id));
  }
});
Deno.test("Portus requests pin upstream, operation and parameter bodies", () => {
  const current = portusWindRequest("current", 123);
  if (
    !current.url.endsWith("/lastData/station/123?locale=es") ||
    current.body !== '["WIND","AIR_TEMP","AIR_PRESURE"]' ||
    portusWindRequest("history", 123).body !== "[42,40,43]" ||
    portusWindRequest("stations", null).body !== null
  ) {
    throw new Error("Incorrect Portus request");
  }
  for (const id of [-1, 0, 1.5, "../admin", null, Infinity]) {
    rejects(() => portusWindRequest("current", id));
  }
  rejects(() => portusWindRequest("delete", 123));
});
Deno.test("Inforatge only accepts the exact HTTPS provider hosts", () => {
  for (
    const url of [
      "/meteo-oliva",
      "//inforatge.com/meteo-cullera/estacio",
      "https://www.inforatge.com/meteo-oliva",
    ]
  ) {
    normalizeInforatgeUrl(url);
  }
  for (
    const url of [
      "https://evilinforatge.com",
      "http://inforatge.com",
      "file://inforatge.com",
      "https://inforatge.com:444",
      "https://user:pass@inforatge.com",
      "//127.0.0.1/internal",
    ]
  ) {
    rejects(() => normalizeInforatgeUrl(url));
  }
});
