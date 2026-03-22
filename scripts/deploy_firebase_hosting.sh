#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [[ ! -f "local.env.json" ]]; then
  echo "Missing local.env.json in project root" >&2
  exit 1
fi

flutter build web

ruby -rjson <<'RUBY'
src = JSON.parse(File.read("local.env.json"))
safe = {
  "SUPABASE_URL" => src["SUPABASE_URL"],
  "SUPABASE_ANON_KEY" => src["SUPABASE_ANON_KEY"],
  "AEMET_OPENDATA_API_KEY" => "",
  "METEOBLUE_API_KEY" => "",
  "METEOSOURCE_API_KEY" => "",
  "METEOSTAT_RAPIDAPI_KEY" => "",
  "METEOSTAT_RAPIDAPI_HOST" => src["METEOSTAT_RAPIDAPI_HOST"] || "meteostat.p.rapidapi.com"
}

File.write("build/web/assets/local.env.json", JSON.pretty_generate(safe))
RUBY

firebase deploy --only hosting
