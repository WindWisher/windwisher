#!/usr/bin/env bash

set -euo pipefail

RECOVERY_ROOT="${HOME}/Recovered/antigravity-conversations"
SOURCE_ROOT="${HOME}/.gemini/antigravity"
TIMESTAMP="$(date +"%Y%m%d-%H%M%S")"
TARGET_DIR="${RECOVERY_ROOT}/${TIMESTAMP}"
LATEST_LINK="${RECOVERY_ROOT}/latest"

mkdir -p "${TARGET_DIR}"

python3 - <<'PY' "${SOURCE_ROOT}" "${TARGET_DIR}"
from __future__ import annotations

import json
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

source_root = Path(sys.argv[1])
target_dir = Path(sys.argv[2])

conversations_dir = source_root / "conversations"
brain_dir = source_root / "brain"
annotations_dir = source_root / "annotations"

artifact_names = [
    "task.md",
    "walkthrough.md",
    "implementation_plan.md",
    "improvements_proposal.md",
]

metadata_names = [f"{name}.metadata.json" for name in artifact_names]


def format_timestamp(seconds: int | None, nanos: int | None) -> str | None:
    if seconds is None:
        return None
    nanos = nanos or 0
    dt = datetime.fromtimestamp(seconds + nanos / 1_000_000_000, tz=timezone.utc)
    return dt.isoformat()


def parse_annotation(path: Path) -> str | None:
    if not path.exists():
        return None
    text = path.read_text(encoding="utf-8", errors="replace")
    seconds = None
    nanos = None
    for token in text.replace("{", " ").replace("}", " ").split():
        if token.startswith("seconds:"):
            try:
                seconds = int(token.split(":", 1)[1])
            except ValueError:
                pass
        if token.startswith("nanos:"):
            try:
                nanos = int(token.split(":", 1)[1])
            except ValueError:
                pass
    return format_timestamp(seconds, nanos)


def load_json(path: Path) -> dict | None:
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except json.JSONDecodeError:
        return None


index_rows = []

for pb_path in sorted(conversations_dir.glob("*.pb")):
    conv_id = pb_path.stem
    dest = target_dir / conv_id
    dest.mkdir(parents=True, exist_ok=True)

    brain_path = brain_dir / conv_id
    annotation_path = annotations_dir / f"{conv_id}.pbtxt"

    info: dict[str, object] = {
        "id": conv_id,
        "conversation_file": str(pb_path),
        "conversation_size_bytes": pb_path.stat().st_size,
        "brain_dir_exists": brain_path.is_dir(),
        "annotation_exists": annotation_path.exists(),
        "last_user_view_time": parse_annotation(annotation_path),
        "artifacts": [],
        "metadata_files": [],
    }

    summaries: list[str] = []
    updated_ats: list[str] = []

    shutil.copy2(pb_path, dest / pb_path.name)

    if annotation_path.exists():
      shutil.copy2(annotation_path, dest / annotation_path.name)

    if brain_path.is_dir():
        for name in artifact_names:
            src = brain_path / name
            if src.exists():
                shutil.copy2(src, dest / name)
                info["artifacts"].append(name)

        for name in metadata_names:
            src = brain_path / name
            payload = load_json(src)
            if src.exists():
                shutil.copy2(src, dest / name)
                info["metadata_files"].append(name)
            if payload:
                summary = payload.get("summary")
                updated_at = payload.get("updatedAt")
                if isinstance(summary, str) and summary not in summaries:
                    summaries.append(summary)
                if isinstance(updated_at, str) and updated_at not in updated_ats:
                    updated_ats.append(updated_at)

        media_files = []
        for child in sorted(brain_path.iterdir()):
            if child.is_file() and child.suffix.lower() in {
                ".png", ".jpg", ".jpeg", ".webp", ".gif"
            }:
                media_files.append(child.name)
                shutil.copy2(child, dest / child.name)
        info["media_files"] = media_files

    info["summaries"] = summaries
    info["updated_at_candidates"] = updated_ats

    preferred_summary = summaries[0] if summaries else "(no summary found)"
    preferred_updated = updated_ats[0] if updated_ats else "(unknown)"
    info["preferred_summary"] = preferred_summary
    info["preferred_updated_at"] = preferred_updated

    readme_lines = [
        f"ID: {conv_id}",
        f"Summary: {preferred_summary}",
        f"Updated At: {preferred_updated}",
        f"Last User View Time: {info['last_user_view_time'] or '(unknown)'}",
        f"Conversation File: {pb_path}",
        f"Brain Directory: {brain_path if brain_path.is_dir() else '(missing)'}",
        f"Annotation File: {annotation_path if annotation_path.exists() else '(missing)'}",
        "",
        "Recovered files:",
    ]

    for name in info["artifacts"]:
        readme_lines.append(f"- {name}")
    for name in info["metadata_files"]:
        readme_lines.append(f"- {name}")
    for name in info.get("media_files", []):
        readme_lines.append(f"- {name}")
    readme_lines.append(f"- {pb_path.name}")
    if annotation_path.exists():
        readme_lines.append(f"- {annotation_path.name}")

    (dest / "README.txt").write_text("\n".join(readme_lines) + "\n", encoding="utf-8")
    (dest / "recovery_info.json").write_text(
        json.dumps(info, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    index_rows.append(
        {
            "id": conv_id,
            "summary": preferred_summary,
            "updated_at": preferred_updated,
            "last_user_view_time": info["last_user_view_time"] or "",
            "artifacts": ",".join(info["artifacts"]),
            "annotation_exists": str(info["annotation_exists"]).lower(),
            "brain_dir_exists": str(info["brain_dir_exists"]).lower(),
        }
    )

index_rows.sort(key=lambda row: (row["updated_at"], row["last_user_view_time"], row["id"]))

index_lines = [
    "# Recovered Antigravity Conversations",
    "",
    f"Source root: {source_root}",
    f"Recovered at: {datetime.now(timezone.utc).isoformat()}",
    "",
]

for row in reversed(index_rows):
    index_lines.extend(
        [
            f"## {row['id']}",
            f"- Summary: {row['summary']}",
            f"- Updated At: {row['updated_at'] or '(unknown)'}",
            f"- Last User View Time: {row['last_user_view_time'] or '(unknown)'}",
            f"- Artifacts: {row['artifacts'] or '(none)'}",
            f"- Brain Dir Exists: {row['brain_dir_exists']}",
            f"- Annotation Exists: {row['annotation_exists']}",
            "",
        ]
    )

(target_dir / "INDEX.md").write_text("\n".join(index_lines), encoding="utf-8")
(target_dir / "index.json").write_text(
    json.dumps(index_rows, indent=2, ensure_ascii=False) + "\n",
    encoding="utf-8",
)
PY

rm -f "${LATEST_LINK}"
ln -s "${TARGET_DIR}" "${LATEST_LINK}"

echo "Recovery completed."
echo "Recovered conversations: ${TARGET_DIR}"
echo "Latest symlink: ${LATEST_LINK}"
echo "Index: ${TARGET_DIR}/INDEX.md"
