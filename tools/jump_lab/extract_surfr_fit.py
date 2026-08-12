#!/usr/bin/env python3
"""Normalize jump results written by the SurfR Garmin Connect IQ app."""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

try:
    import fitdecode
except ImportError as exc:  # pragma: no cover - exercised by the CLI environment
    raise SystemExit(
        "Missing fitdecode. Install tools/jump_lab/requirements.txt in a venv."
    ) from exc


SURFR_APPLICATION_ID = "6cf9f6ba-1541-417d-9494-01fbc90e5f5d"


def _message_values(frame: Any) -> dict[str, Any]:
    return {field.name: field.value for field in frame.fields}


def _as_numbers(value: Any, length: int) -> tuple[float, ...] | None:
    if not isinstance(value, (tuple, list)) or len(value) < length:
        return None
    try:
        return tuple(float(entry) for entry in value)
    except (TypeError, ValueError):
        return None


def _unix_seconds_to_datetime(value: int) -> datetime:
    return datetime.fromtimestamp(value, tz=timezone.utc)


def _json_value(value: Any) -> Any:
    if isinstance(value, datetime):
        return value.isoformat()
    if isinstance(value, tuple):
        return [_json_value(entry) for entry in value]
    if isinstance(value, list):
        return [_json_value(entry) for entry in value]
    return value


def extract(path: Path) -> dict[str, Any]:
    session: dict[str, Any] | None = None
    app_version: int | None = None
    app_id: str | None = None
    raw_jumps: dict[tuple[Any, ...], dict[str, Any]] = {}

    with fitdecode.FitReader(path) as fit:
        for frame in fit:
            if not isinstance(frame, fitdecode.records.FitDataMessage):
                continue
            values = _message_values(frame)
            if frame.name == "developer_data_id":
                raw_id = values.get("application_id")
                if isinstance(raw_id, (tuple, list)) and len(raw_id) == 16:
                    hex_id = "".join(f"{int(entry):02x}" for entry in raw_id)
                    app_id = (
                        f"{hex_id[:8]}-{hex_id[8:12]}-{hex_id[12:16]}-"
                        f"{hex_id[16:20]}-{hex_id[20:]}"
                    )
                app_version = values.get("application_version")
            elif frame.name == "session":
                session = values
            elif frame.name == "record":
                jump = _as_numbers(values.get("jump"), 4)
                timestamps = values.get("timestamps")
                if jump is None or not any(jump):
                    continue
                if not isinstance(timestamps, (tuple, list)) or len(timestamps) < 3:
                    continue
                timestamp_key = tuple(int(entry) for entry in timestamps[:3])
                if not any(timestamp_key):
                    continue
                # SurfR repeats the latest jump payload in subsequent FIT records.
                key = timestamp_key + tuple(round(entry, 6) for entry in jump)
                raw_jumps.setdefault(
                    key,
                    {
                        "jump": jump,
                        "timestamps": timestamp_key,
                        "approachspeed": values.get("approachspeed"),
                        "approachheading": values.get("approachheading"),
                        "gps": values.get("gps"),
                        "jumpchart": values.get("jumpchart"),
                    },
                )

    if session is None:
        raise ValueError("FIT file does not contain a session message")
    if app_id != SURFR_APPLICATION_ID:
        raise ValueError(
            f"Unexpected Connect IQ application id: {app_id or 'missing'}"
        )

    started_at = session.get("start_time")
    if not isinstance(started_at, datetime):
        raise ValueError("FIT session does not contain a valid start_time")

    start_unix_seconds = int(started_at.timestamp())
    jumps: list[dict[str, Any]] = []
    ordered = sorted(raw_jumps.values(), key=lambda item: item["timestamps"])
    for index, raw in enumerate(ordered, start=1):
        jump = raw["jump"]
        takeoff_raw, _, landing_raw = raw["timestamps"]
        jumps.append(
            {
                "id": f"surfr-{index:04d}",
                "event_time_s": float(takeoff_raw - start_unix_seconds),
                "takeoff_time_s": float(takeoff_raw - start_unix_seconds),
                "landing_time_s": float(landing_raw - start_unix_seconds),
                "height_m": jump[0],
                "airtime_s": jump[1],
                "distance_m": jump[2],
                "raw": {
                    "jump_tuple": list(jump),
                    "timestamps_unix_epoch": list(raw["timestamps"]),
                    "takeoff_at": _unix_seconds_to_datetime(takeoff_raw).isoformat(),
                    "landing_at": _unix_seconds_to_datetime(landing_raw).isoformat(),
                    "approach_speed_tuple": _json_value(raw["approachspeed"]),
                    "approach_heading_tuple": _json_value(raw["approachheading"]),
                    "gps_tuple": _json_value(raw["gps"]),
                    "jump_chart": _json_value(raw["jumpchart"]),
                    "unmapped_jump_value_4": jump[3],
                },
            }
        )

    expected_count = session.get("jumpcount")
    if isinstance(expected_count, int) and expected_count != len(jumps):
        raise ValueError(
            f"Deduplicated {len(jumps)} jumps, but FIT session reports {expected_count}"
        )

    metadata_keys = (
        "maxheight",
        "jumpcount",
        "avgheight",
        "totalheight",
        "minh",
        "dualprocessing",
        "surfrai",
        "syncissue",
        "calibration_offsetx",
        "calibration_offsety",
        "calibration_offsetz",
        "calibration_gainx",
        "calibration_gainy",
        "calibration_gainz",
    )
    return {
        "schema_version": 1,
        "session": {
            "id": path.stem,
            "source": "surfr_garmin",
            "source_version": str(app_version) if app_version is not None else None,
            "source_application_id": app_id,
            "started_at": started_at.isoformat(),
            "sample_rate_hz": session.get("samplerate"),
            "metadata": {
                key: _json_value(session.get(key)) for key in metadata_keys
            },
        },
        "jumps": jumps,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("fit", type=Path, help="SurfR Garmin FIT activity")
    parser.add_argument("--out", type=Path, required=True, help="Output JSON")
    args = parser.parse_args()

    payload = extract(args.fit)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(
        json.dumps(payload, indent=2, ensure_ascii=True) + "\n",
        encoding="utf-8",
    )
    print(
        f"Extracted {len(payload['jumps'])} jumps from {args.fit} -> {args.out}"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
