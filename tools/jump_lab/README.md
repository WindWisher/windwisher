# WindWisher Jump Lab

This directory contains clean-room research tools for comparing jump results
reported by external devices with algorithms developed for WindWisher.

The tools do not contain vendor code or activate a jump algorithm in the app.
Captured APKs, FIT files and normalized session data must stay under `tmp/` or
`.tmp/`, which are ignored by Git.

## Normalized session format

Each JSON file contains session metadata and a `jumps` array. Jump timestamps
are seconds from the session start. A producer may omit values it cannot
support, but it must not infer or fabricate them.

```json
{
  "schema_version": 1,
  "session": {
    "id": "session-id",
    "source": "surfr_garmin",
    "source_version": "37",
    "started_at": "2026-08-08T15:37:19+00:00",
    "sample_rate_hz": 100
  },
  "jumps": [
    {
      "id": "surfr-0001",
      "event_time_s": 34.0,
      "takeoff_time_s": 34.0,
      "landing_time_s": 37.0,
      "height_m": 2.24,
      "airtime_s": 2.99,
      "distance_m": 20.72
    }
  ]
}
```

## SurfR Garmin FIT import

Install the isolated dependency and convert a FIT activity:

```bash
python3 -m venv .tmp/jump-lab-venv
.tmp/jump-lab-venv/bin/pip install -r tools/jump_lab/requirements.txt
.tmp/jump-lab-venv/bin/python tools/jump_lab/extract_surfr_fit.py \
  .tmp/garmin_surfr/2026-08-08.fit \
  --out .tmp/jump_lab/surfr-2026-08-08.json
```

The importer keeps unknown SurfR tuple values under `raw`. It only labels the
first three values because the FIT data and session totals support them as
height, airtime and distance.

## Compare a WindWisher candidate

```bash
python3 tools/jump_lab/evaluate.py \
  --reference .tmp/jump_lab/surfr-2026-08-08.json \
  --candidate .tmp/jump_lab/windwisher-2026-08-08.json \
  --max-time-delta 2.0
```

The report includes precision, recall, F1, timestamp error, MAE/RMSE and the
percentage of matched jumps within explicit tolerances. It deliberately does
not produce an ambiguous single "similarity" percentage.
