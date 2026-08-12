# Jump algorithm validation

## Goal

Develop an independent WindWisher jump algorithm using synchronized sensor
measurements and externally reported jumps as reference labels. WOO, SurfR and
SurfR on Garmin are comparators, not implementations to copy.

## Current evidence

### WOO

- The Android app receives resolved jump values from the WOO ecosystem.
- Existing local captures include per-jump `Air`, `QhData` and `RawDataStatic`.
- The current experimental Big Air model was fitted to 39 jumps across two
  sessions. Its low error on those sessions is not evidence of general 90%+
  equivalence because training and validation data are not independent.

### SurfR Android

- Sensor input uses accelerometer and gyroscope data at a requested 100 Hz.
- The native code rotates acceleration into a world frame, integrates vertical
  acceleration into velocity and position, corrects drift and uses a state
  machine plus sanity filters to accept jumps.
- Distinct processing modes exist for board, chest, watch and Garmin inputs.

### SurfR Garmin

- The Connect IQ app reports a 100 Hz sample rate and calibration offset/gain
  values in its FIT session metadata.
- It stores resolved jump height, airtime, distance, GPS endpoints and a compact
  jump chart in FIT developer fields.
- The FIT activity contains approximately one record per second, not the raw
  100 Hz inertial stream. The watch therefore performs the high-rate processing
  before writing the activity.

## Validation protocol

1. Record the same session concurrently with WOO, SurfR/Garmin and a
   WindWisher-owned 100 Hz inertial logger.
2. Synchronize clocks before entering the water and create several deliberate
   calibration events at the beginning and end of the session.
3. Preserve raw accelerometer, gyroscope, GPS and monotonic timestamps without
   resampling or vendor-derived values.
4. Normalize each provider's reported jumps with `tools/jump_lab`.
5. Split sessions by day: fit parameters on training sessions and report final
   metrics only on unseen validation sessions.
6. Measure detection precision/recall/F1 separately from height, airtime and
   distance errors. Never replace these metrics with a single similarity score.
7. Test mounting positions independently: board, wrist and phone/chest signals
   require different calibration and may require different models.

## Proposed WindWisher pipeline

1. Validate sample cadence and calibrate sensor bias/scale.
2. Estimate orientation from gyroscope and accelerometer data.
3. Transform acceleration into earth coordinates and remove gravity.
4. Detect takeoff and landing with a state machine that includes hysteresis.
5. Correct velocity and position drift over each candidate jump window.
6. Estimate height from corrected vertical displacement and use GPS only for
   horizontal distance and consistency checks.
7. Reject implausible candidates using explicit, testable quality rules.
8. Emit a confidence/quality value alongside every accepted jump.

Runtime integration should begin only after the independent validation set has
acceptable detection and error metrics for each supported mounting position.
