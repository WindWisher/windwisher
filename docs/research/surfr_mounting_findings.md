# SurfR mounting-specific findings

Static observations from local Android JADX output v1017. These observations
are not proof of Garmin Connect IQ parity or validated WindWisher behavior.

| Stage | Board | Chest | Watch / Garmin-related modes |
| --- | --- | --- | --- |
| Sensor ingestion | Shared calibration, orientation and time handling | Shared entrypoints | Shared entrypoints for the inspected Android paths |
| Candidate routing | C3732r.m6237a | C3698G.m6183f | Non-Board route; additional mode branches exist |
| Initial settings | Separate initialization in C3709S.m6198h | Non-Board initialization | WatchLQ/Garmin/GarminLight have additional grouped choices |
| Reprocessing | Board-related branches exist | Explicit chest branch in RunnableC3695D around line 962 | Explicit WatchLQ/Garmin branch around line 1059 |
| Alternate input | Not established here | Not established here | GarminLight routes an additional input through C3721g.m6208d; semantics remain to trace |

Sources: EnumC3707P, C3709S.m6192b/m6198h, C3721g.m6209e and
RunnableC3695D.run. Obfuscated temporary meanings and threshold units are not
universally established. Do not label a chest branch as arm rejection or a
Garmin branch as barometric without tracing its inputs.

## WindWisher implications

Keep source, physical placement and selected processing strategy separate.
board_imu/body_imu remain coarse compatibility metadata, not sufficient
algorithm identifiers. Existing placement classification now respects explicit
chest/wrist/body rather than inferring board from the SurfR provider name.

The inspected Garmin envelope converter currently enumerates position,
heartRate and pressure. It does not establish an accepted accelerometer/gyro
stream. This is a receiver-contract observation, not a complete audit of the
external Watch producer. Before wrist jump processing, verify producer sensor
acquisition/export and extend the transport deliberately with validation and
versioning; do not fabricate inertial data from GPS or the SurfR 1 Hz FIT.

Priorities: trace Board boundaries for board data, Chest-specific conditions
for phone/chest, and Watch/Garmin motion handling for wrist. Collect and evaluate
each position separately on held-out sessions. Preserve the confirmed shared
WOO/SurfR jump as a cross-device result comparison only.
