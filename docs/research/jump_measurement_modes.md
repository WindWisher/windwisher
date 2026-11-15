# Jump measurement scope

## User requirements

## Project ownership confirmed by the user

Own-watch acquisition, calibration, jump detection, height/airtime calculation
and on-watch quality handling belong to the sibling project
`/Users/raulmartinez/Documents/Proyectos/Antigravity/WindWisher Watch`.
Continue implementation there using its existing experimental engine and
validation gates. Do not create a second wrist calculation engine in Flutter.

WindWisher mobile owns receiving, validating, storing and presenting session
results, plus its phone/device adapters. Watch-to-mobile result contracts must
be coordinated explicitly; research exports are not production contracts.
WOO/SurfR analysis supplies evidence, not automatically approved code or
calibration for the Watch engine. Phone-mounted processing remains a separate
mobile concern, validated for board/chest independently.

WindWisher must support WOO on the board, a phone on the board, a phone on
the rider's chest and a watch on the wrist, including the user's Garmin app.
Device source and mounting position are separate dimensions. A common session
format must not imply a common calibration or a validated universal detector.

| Input | Placement | Processing investigation | Current evidence |
| --- | --- | --- | --- |
| WOO | board | Firmware results plus raw-window reconstruction | BLE captures, one operator-confirmed shared SurfR event; firmware unavailable |
| Phone | board | Board-specific motion and impact handling | SurfR Android Board follows a separate detector route |
| Phone | chest | Rider motion and mounting calibration | SurfR Android Chest mode and shared non-Board processing entrypoint |
| Watch, including Garmin | wrist | Arm-motion rejection and wrist calibration | SurfR Android Watch/Garmin modes; actual Garmin FIT has results, not identified high-rate raw IMU |

Android Garmin-mode presence does not establish parity with SurfR Connect IQ.
WOO firmware reconstruction remains a research objective; comparing vendor
results and developing WindWisher's own pipeline are distinct deliverables.

## Existing WindWisher representation

linked_device.dart and start_session_models.dart preserve placement. Session
detail additionally has mountType, measurementMode and measurementConfidence.
inferMeasurementMode currently groups inputs as board_imu or body_imu; that
coarse grouping must not be used as the sole selector for chest versus wrist
algorithms. These fields establish metadata, not validated sensor processing.

## Next analysis and integration gates

The sibling Watch project already has isolated IMU research and physical trial
history. Read [watch_project_continuity.md](watch_project_continuity.md) before
proposing new sensor capture or treating product export limits as absent capture.

Verified static differences and the current Garmin input limitation are in
[surfr_mounting_findings.md](surfr_mounting_findings.md).

Trace SurfR Board, Chest and Watch/Garmin routes separately and document shared
and differing stages. Verify what the user's Garmin producer actually exports
before extending its canonical schema or assuming raw IMU availability.
Use explicit source, placement, sensor cadence, calibration and algorithm
version in research reports; preserve unknown placement rather than guess.
Validate each mounting position on held-out sessions. The shared ~2.7 m jump
anchors an event comparison, not cross-mount equivalence or calibrated height.
Do not activate experimental WOO regressions as a production detector.
