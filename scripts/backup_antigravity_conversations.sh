#!/usr/bin/env bash

set -euo pipefail

ANTIGRAVITY_APP_SUPPORT="${HOME}/Library/Application Support/Antigravity"
ANTIGRAVITY_GLOBAL_STORAGE="${ANTIGRAVITY_APP_SUPPORT}/User/globalStorage"
ANTIGRAVITY_GEMINI_ROOT="${HOME}/.gemini/antigravity"
BACKUP_ROOT="${HOME}/Backups/antigravity-conversations"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
TARGET_DIR="${BACKUP_ROOT}/${TIMESTAMP}"
LATEST_LINK="${BACKUP_ROOT}/latest"

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

echo "Backup completed."
echo "Latest snapshot: ${LATEST_LINK}"
echo "Consistency report: ${TARGET_DIR}/consistency_report.txt"
