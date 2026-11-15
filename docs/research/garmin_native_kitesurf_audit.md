# Native Garmin Kitesurf FIT audit

Read-only MTP copy of activity 2026-05-14-15-49-24.fit to ignored
`.tmp/garmin_native_audit/`. Complete FIT parsed with CRC checking set to RAISE;
no CRC exception. Session identifies sport_profile_name=Kitesurf,
sport=kitesurfing, sub_sport=generic. Zero developer_data_id messages were
observed, distinguishing it from the inspected SurfR FIT. This does not prove
that every record originated in a specific internal firmware algorithm.

Observed session elapsed time is 3821.702 s and total distance 10352.31 m.
1556 record messages contain distance, enhanced_speed, enhanced_altitude,
heart_rate, GPS coordinates, temperature and timestamps, plus unknown fields.
These supplied Garmin metrics can be preserved/imported rather than recomputed
from raw sensors in WindWisher.

No recognized per-jump height/airtime fields or named jump messages were found
in this inspection. The decoder has unknown native fields/messages, so this
is not proof that no firmware version/device can record jump information.
Altitude is elevation, not per-jump height; do not relabel it as jump height.

Next integration can target the existing standard Garmin FIT metrics, while
jump computation remains a separately sourced/validated capability. Importing
completed activities and reading live Connect IQ Activity.Info are distinct
paths; this file inspection verifies the former data availability only.
No watch files were modified, deleted, recorded or uploaded.
