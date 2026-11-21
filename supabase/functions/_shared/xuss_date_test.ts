import { parseXussDateParts } from "./xuss_date.ts";

for (const month of ["November", "noviembre", "NOV", "nov"]) {
  Deno.test(`Xuss parses full and abbreviated month ${month}`, () => {
    const result = parseXussDateParts(
      `Ultima grabación a: 08:42 Data: 21 ${month} 2026`,
    );
    if (
      JSON.stringify(result) !==
        JSON.stringify({ year: 2026, month: 11, day: 21, hour: 8, minute: 42 })
    ) {
      throw new Error("Unexpected Xuss date parts");
    }
  });
}
for (
  const date of ["31 November 2026", "21 unknown 2026", "29 February 2026"]
) {
  Deno.test(`Xuss rejects invalid date ${date}`, () => {
    if (
      parseXussDateParts(`Ultima grabacion a: 08:42 Data: ${date}`) !== null
    ) {
      throw new Error("Invalid calendar date accepted");
    }
  });
}
for (const time of ["24:42", "08:60"]) {
  Deno.test(`Xuss rejects invalid time ${time}`, () => {
    if (
      parseXussDateParts(
        `Ultima grabacion a: ${time} Data: 21 November 2026`,
      ) !== null
    ) {
      throw new Error("Invalid clock time accepted");
    }
  });
}
