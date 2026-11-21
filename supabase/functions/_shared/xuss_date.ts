export function parseXussDateParts(body: string): {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
} | null {
  const match = body.match(
    /Ultima grabaci[oó]n a:\s*(\d{1,2}):(\d{2}).*?Data:\s*(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})/is,
  );
  if (!match) return null;
  const aliases = [
    ["jan", "ene", "january", "enero"],
    ["feb", "february", "febrero"],
    ["mar", "march", "marzo"],
    ["apr", "abr", "april", "abril"],
    ["may", "mayo"],
    ["jun", "june", "junio"],
    ["jul", "july", "julio"],
    ["aug", "ago", "august", "agosto"],
    ["sep", "sept", "september", "septiembre"],
    ["oct", "october", "octubre"],
    ["nov", "november", "noviembre"],
    ["dec", "dic", "december", "diciembre"],
  ];
  const hour = Number(match[1]);
  const minute = Number(match[2]);
  const day = Number(match[3]);
  const month =
    aliases.findIndex((names) => names.includes(match[4].toLowerCase())) + 1;
  const year = Number(match[5]);
  const calendar = new Date(Date.UTC(year, month - 1, day));
  if (
    month === 0 || hour > 23 || minute > 59 ||
    calendar.getUTCFullYear() !== year ||
    calendar.getUTCMonth() + 1 !== month || calendar.getUTCDate() !== day
  ) {
    return null;
  }
  return { year, month, day, hour, minute };
}
