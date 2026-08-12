#!/usr/bin/env python3
"""Compare normalized WindWisher jump output with a reference session."""

from __future__ import annotations

import argparse
import json
import math
from pathlib import Path
from statistics import mean
from typing import Any


METRICS = ("height_m", "airtime_s", "distance_m")


def _load(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if payload.get("schema_version") != 1 or not isinstance(payload.get("jumps"), list):
        raise ValueError(f"Unsupported normalized session: {path}")
    return payload


def _event_time(jump: dict[str, Any]) -> float:
    value = jump.get("event_time_s", jump.get("takeoff_time_s"))
    if not isinstance(value, (int, float)):
        raise ValueError(f"Jump {jump.get('id', '<unknown>')} has no event time")
    return float(value)


def _match(
    references: list[dict[str, Any]],
    candidates: list[dict[str, Any]],
    max_delta: float,
) -> list[tuple[dict[str, Any], dict[str, Any], float]]:
    possible: list[tuple[float, int, int]] = []
    for reference_index, reference in enumerate(references):
        for candidate_index, candidate in enumerate(candidates):
            delta = abs(_event_time(reference) - _event_time(candidate))
            if delta <= max_delta:
                possible.append((delta, reference_index, candidate_index))

    matched_references: set[int] = set()
    matched_candidates: set[int] = set()
    matches: list[tuple[dict[str, Any], dict[str, Any], float]] = []
    for delta, reference_index, candidate_index in sorted(possible):
        if reference_index in matched_references or candidate_index in matched_candidates:
            continue
        matched_references.add(reference_index)
        matched_candidates.add(candidate_index)
        matches.append((references[reference_index], candidates[candidate_index], delta))
    return sorted(matches, key=lambda entry: _event_time(entry[0]))


def _percentile(values: list[float], percentile: float) -> float | None:
    if not values:
        return None
    ordered = sorted(values)
    index = (len(ordered) - 1) * percentile
    lower = math.floor(index)
    upper = math.ceil(index)
    if lower == upper:
        return ordered[lower]
    return ordered[lower] + (ordered[upper] - ordered[lower]) * (index - lower)


def _metric_summary(
    matches: list[tuple[dict[str, Any], dict[str, Any], float]],
    key: str,
    tolerance: float,
) -> dict[str, Any]:
    errors: list[float] = []
    signed_errors: list[float] = []
    for reference, candidate, _ in matches:
        expected = reference.get(key)
        actual = candidate.get(key)
        if not isinstance(expected, (int, float)) or not isinstance(actual, (int, float)):
            continue
        signed = float(actual) - float(expected)
        signed_errors.append(signed)
        errors.append(abs(signed))
    return {
        "compared": len(errors),
        "mae": mean(errors) if errors else None,
        "rmse": math.sqrt(mean([error * error for error in signed_errors]))
        if signed_errors
        else None,
        "bias": mean(signed_errors) if signed_errors else None,
        "p95_absolute_error": _percentile(errors, 0.95),
        "within_tolerance": sum(error <= tolerance for error in errors),
        "within_tolerance_ratio": (
            sum(error <= tolerance for error in errors) / len(errors)
            if errors
            else None
        ),
        "tolerance": tolerance,
    }


def evaluate(
    reference: dict[str, Any],
    candidate: dict[str, Any],
    max_time_delta: float,
    tolerances: dict[str, float],
) -> dict[str, Any]:
    references = reference["jumps"]
    candidates = candidate["jumps"]
    matches = _match(references, candidates, max_time_delta)
    true_positives = len(matches)
    precision = true_positives / len(candidates) if candidates else 0.0
    recall = true_positives / len(references) if references else 0.0
    f1 = 2 * precision * recall / (precision + recall) if precision + recall else 0.0
    time_errors = [entry[2] for entry in matches]
    return {
        "reference_source": reference.get("session", {}).get("source"),
        "candidate_source": candidate.get("session", {}).get("source"),
        "reference_jumps": len(references),
        "candidate_jumps": len(candidates),
        "matched_jumps": true_positives,
        "false_positives": len(candidates) - true_positives,
        "false_negatives": len(references) - true_positives,
        "precision": precision,
        "recall": recall,
        "f1": f1,
        "time": {
            "max_match_delta_s": max_time_delta,
            "mae_s": mean(time_errors) if time_errors else None,
            "p95_s": _percentile(time_errors, 0.95),
        },
        "metrics": {
            key: _metric_summary(matches, key, tolerances[key]) for key in METRICS
        },
        "matches": [
            {
                "reference_id": reference_jump.get("id"),
                "candidate_id": candidate_jump.get("id"),
                "time_delta_s": delta,
            }
            for reference_jump, candidate_jump, delta in matches
        ],
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--reference", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--max-time-delta", type=float, default=2.0)
    parser.add_argument("--height-tolerance", type=float, default=0.25)
    parser.add_argument("--airtime-tolerance", type=float, default=0.25)
    parser.add_argument("--distance-tolerance", type=float, default=3.0)
    parser.add_argument("--out", type=Path)
    args = parser.parse_args()

    report = evaluate(
        _load(args.reference),
        _load(args.candidate),
        args.max_time_delta,
        {
            "height_m": args.height_tolerance,
            "airtime_s": args.airtime_tolerance,
            "distance_m": args.distance_tolerance,
        },
    )
    rendered = json.dumps(report, indent=2, ensure_ascii=True) + "\n"
    if args.out:
        args.out.parent.mkdir(parents=True, exist_ok=True)
        args.out.write_text(rendered, encoding="utf-8")
    print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
