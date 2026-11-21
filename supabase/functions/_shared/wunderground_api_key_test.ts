import {
  extractWundergroundApiKey,
  readWundergroundResponse,
} from "./wunderground_api_key.ts";

const cases = JSON.parse(
  await Deno.readTextFile(
    new URL(
      "../../../test/fixtures/wunderground_api_key_cases.json",
      import.meta.url,
    ),
  ),
) as { name: string; html: string; expected: string | null }[];

for (const item of cases) {
  Deno.test(item.name, () => {
    if (extractWundergroundApiKey(item.html) !== item.expected) {
      throw new Error(`Extraction mismatch: ${item.name}`);
    }
  });
}

Deno.test("HTTP 204 is no observations, not a JSON or authorization error", async () => {
  const payload = await readWundergroundResponse(
    new Response(null, { status: 204 }),
  );
  if (Object.keys(payload).length !== 0) {
    throw new Error("Expected empty payload");
  }
});

Deno.test("HTTP 401 remains an error without exposing the response or key", async () => {
  try {
    await readWundergroundResponse(
      new Response("private upstream details", { status: 401 }),
    );
  } catch (error) {
    if (error instanceof Error && error.message === "wunderground-http-401") {
      return;
    }
    throw error;
  }
  throw new Error("Expected authorization error");
});

Deno.test("valid observation objects are preserved", async () => {
  const payload = await readWundergroundResponse(
    Response.json({ observations: [{ stationID: "SYNTHETIC" }] }),
  );
  if (
    !Array.isArray(payload.observations) || payload.observations.length !== 1
  ) throw new Error("Observation lost");
});
