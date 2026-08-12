#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${1:-$ROOT_DIR/local.env.json}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing environment file: $ENV_FILE" >&2
  exit 1
fi

for command in curl jq; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing required command: $command" >&2
    exit 1
  fi
done

SUPABASE_URL="$(jq -r '.SUPABASE_URL // empty' "$ENV_FILE")"
ANON_KEY="$(jq -r '.SUPABASE_ANON_KEY // empty' "$ENV_FILE")"
SERVICE_KEY="$(jq -r '.SUPABASE_SERVICE_ROLE_KEY // empty' "$ENV_FILE")"

if [[ -z "$SUPABASE_URL" || -z "$ANON_KEY" || -z "$SERVICE_KEY" ]]; then
  echo "Supabase URL, anon key or service role key is missing" >&2
  exit 1
fi

RUN_ID="$(date +%s)-$$"
PASSWORD="WindWisher-${RUN_ID}-Aa1!"
USER_A_EMAIL="units-a-${RUN_ID}@example.invalid"
USER_B_EMAIL="units-b-${RUN_ID}@example.invalid"
USER_A_ID=""
USER_B_ID=""

delete_user() {
  local user_id="$1"
  if [[ -n "$user_id" ]]; then
    curl --silent --show-error --fail \
      --request DELETE \
      "$SUPABASE_URL/auth/v1/admin/users/$user_id" \
      --header "apikey: $SERVICE_KEY" \
      --header "Authorization: Bearer $SERVICE_KEY" \
      >/dev/null
  fi
}

cleanup() {
  delete_user "$USER_A_ID" || true
  delete_user "$USER_B_ID" || true
}
trap cleanup EXIT

create_user() {
  local email="$1"
  local payload
  payload="$(
    jq --null-input \
      --arg email "$email" \
      --arg password "$PASSWORD" \
      '{email: $email, password: $password, email_confirm: true}'
  )"
  curl --silent --show-error --fail \
    --request POST \
    "$SUPABASE_URL/auth/v1/admin/users" \
    --header "apikey: $SERVICE_KEY" \
    --header "Authorization: Bearer $SERVICE_KEY" \
    --header "Content-Type: application/json" \
    --data "$payload"
}

sign_in() {
  local email="$1"
  local payload
  payload="$(
    jq --null-input \
      --arg email "$email" \
      --arg password "$PASSWORD" \
      '{email: $email, password: $password}'
  )"
  curl --silent --show-error --fail \
    --request POST \
    "$SUPABASE_URL/auth/v1/token?grant_type=password" \
    --header "apikey: $ANON_KEY" \
    --header "Content-Type: application/json" \
    --data "$payload" \
    | jq -r '.access_token'
}

USER_A_ID="$(create_user "$USER_A_EMAIL" | jq -r '.id')"
USER_B_ID="$(create_user "$USER_B_EMAIL" | jq -r '.id')"

TOKEN_A_PHONE="$(sign_in "$USER_A_EMAIL")"
TOKEN_A_WEB="$(sign_in "$USER_A_EMAIL")"
TOKEN_B="$(sign_in "$USER_B_EMAIL")"

PREFERENCES_PAYLOAD="$(
  jq --null-input \
    --arg userId "$USER_A_ID" \
    '{
      user_id: $userId,
      wind_speed_unit: "milesPerHour",
      distance_unit: "nauticalMiles",
      temperature_unit: "fahrenheit",
      height_unit: "feet"
    }'
)"

curl --silent --show-error --fail \
  --request POST \
  "$SUPABASE_URL/rest/v1/user_unit_preferences?on_conflict=user_id" \
  --header "apikey: $ANON_KEY" \
  --header "Authorization: Bearer $TOKEN_A_PHONE" \
  --header "Content-Type: application/json" \
  --header "Prefer: resolution=merge-duplicates,return=minimal" \
  --data "$PREFERENCES_PAYLOAD" \
  >/dev/null

SAME_USER_VALUES="$(
  curl --silent --show-error --fail \
    "$SUPABASE_URL/rest/v1/user_unit_preferences?select=wind_speed_unit,distance_unit,temperature_unit,height_unit" \
    --header "apikey: $ANON_KEY" \
    --header "Authorization: Bearer $TOKEN_A_WEB"
)"

jq --exit-status '
  length == 1 and
  .[0].wind_speed_unit == "milesPerHour" and
  .[0].distance_unit == "nauticalMiles" and
  .[0].temperature_unit == "fahrenheit" and
  .[0].height_unit == "feet"
' <<<"$SAME_USER_VALUES" >/dev/null

OTHER_USER_VALUES="$(
  curl --silent --show-error --fail \
    "$SUPABASE_URL/rest/v1/user_unit_preferences?select=user_id" \
    --header "apikey: $ANON_KEY" \
    --header "Authorization: Bearer $TOKEN_B"
)"

jq --exit-status 'length == 0' <<<"$OTHER_USER_VALUES" >/dev/null

echo "same_user_cross_session=ok"
echo "different_user_isolation=ok"
echo "temporary_users_cleanup=scheduled"
