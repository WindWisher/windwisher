#!/usr/bin/env bash

set -euo pipefail

ANTIGRAVITY_APP_SUPPORT="${HOME}/Library/Application Support/Antigravity"
ANTIGRAVITY_GLOBAL_STORAGE="${ANTIGRAVITY_APP_SUPPORT}/User/globalStorage"
ANTIGRAVITY_GEMINI_ROOT="${HOME}/.gemini/antigravity"
BACKUP_ROOT="${HOME}/Backups/antigravity-conversations"
MAX_BACKUPS="${ANTIGRAVITY_BACKUP_RETENTION:-10}"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
TARGET_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
LATEST_LINK="${BACKUP_ROOT}/latest"

if [[ ! "${MAX_BACKUPS}" =~ ^[1-9][0-9]*$ ]]; then
  echo "ANTIGRAVITY_BACKUP_RETENTION must be a positive integer." >&2
  exit 1
fi

remove_snapshot() {
  local snapshot="$1"

  if [[ ! -d "${snapshot}" || -L "${snapshot}" ||
      "${snapshot}" != "${BACKUP_ROOT}"/20[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9] ]]; then
    echo "Refusing to remove unexpected backup path: ${snapshot}" >&2
    return 1
  fi

  xattr -cr "${snapshot}" 2>/dev/null || true
  chmod -RN "${snapshot}" 2>/dev/null || true
  chmod -R u+rwX "${snapshot}" 2>/dev/null || true
  find "${snapshot}" -depth -delete
}

prune_backups() {
  local keep="$1"
  local snapshots=()
  local delete_count
  local index

  shopt -s nullglob
  snapshots=("${BACKUP_ROOT}"/20[0-9][0-9][0-9][0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9])
  shopt -u nullglob

  delete_count=$((${#snapshots[@]} - keep))
  if ((delete_count <= 0)); then
    return
  fi

  for ((index = 0; index < delete_count; index++)); do
    echo "Removing old backup: ${snapshots[index]}"
    remove_snapshot "${snapshots[index]}"
  done
}

cleanup_on_exit() {
  local status=$?

  trap - EXIT
  if ((status != 0)) && [[ -d "${TARGET_DIR}" ]]; then
    echo "Removing incomplete backup: ${TARGET_DIR}" >&2
    remove_snapshot "${TARGET_DIR}" || true
  fi
  prune_backups "${MAX_BACKUPS}" || true
  exit "${status}"
}

mkdir -p "${BACKUP_ROOT}"
# Leave room for the snapshot being created, even if the disk is already tight.
prune_backups "$((MAX_BACKUPS - 1))"
trap cleanup_on_exit EXIT
mkdir -p "${TARGET_DIR}"

copy_if_exists() {
  local source="$1"
  local target="$2"

  if [[ -e "${source}" ]]; then
    mkdir -p "$(dirname "${target}")"
    cp -R "${source}" "${target}"
  fi
}

echo "Creating backup in: ${TARGET_DIR}"

copy_if_exists \
  "${ANTIGRAVITY_GLOBAL_STORAGE}/state.vscdb" \
  "${TARGET_DIR}/globalStorage/state.vscdb"
copy_if_exists \
  "${ANTIGRAVITY_GLOBAL_STORAGE}/state.vscdb.backup" \
  "${TARGET_DIR}/globalStorage/state.vscdb.backup"
copy_if_exists \
  "${ANTIGRAVITY_GLOBAL_STORAGE}/storage.json" \
  "${TARGET_DIR}/globalStorage/storage.json"
copy_if_exists \
  "${ANTIGRAVITY_GEMINI_ROOT}" \
  "${TARGET_DIR}/gemini-antigravity"

python3 - <<'PY' "${ANTIGRAVITY_GEMINI_ROOT}" "${TARGET_DIR}/consistency_report.txt"
from pathlib import Path
import sys

root = Path(sys.argv[1])
report_path = Path(sys.argv[2])

conversations = {p.stem for p in (root / "conversations").glob("*.pb")}
annotations = {p.stem for p in (root / "annotations").glob("*.pbtxt")}
brain_dirs = {
    p.name for p in (root / "brain").iterdir()
    if p.is_dir() and p.name != "tempmediaStorage"
}

lines = [
    f"gemini root: {root}",
    f"conversation files: {len(conversations)}",
    f"annotation files: {len(annotations)}",
    f"brain dirs: {len(brain_dirs)}",
    "",
    "missing annotations:",
]

missing_annotations = sorted(conversations - annotations)
if missing_annotations:
    lines.extend(missing_annotations)
else:
    lines.append("(none)")

lines.extend(["", "missing brain dirs:"])
missing_brain = sorted(conversations - brain_dirs)
if missing_brain:
    lines.extend(missing_brain)
else:
    lines.append("(none)")

lines.extend(["", "brain dirs without conversation file:"])
orphan_brain = sorted(brain_dirs - conversations)
if orphan_brain:
    lines.extend(orphan_brain)
else:
    lines.append("(none)")

report_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

rm -f "${LATEST_LINK}"
ln -s "${TARGET_DIR}" "${LATEST_LINK}"

prune_backups "${MAX_BACKUPS}"

echo "Backup completed."
echo "Latest snapshot: ${LATEST_LINK}"
echo "Consistency report: ${TARGET_DIR}/consistency_report.txt"
echo "Retention: latest ${MAX_BACKUPS} snapshots"
