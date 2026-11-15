# BT4 and SurfR handoff

## Fresh recovered NV4 replay

Parsed the preserved preflight-20260911 BAK/TXT with the existing strict parser
and invoked compareArchivedCapture without modifying the sibling repository.
All 200 samples were processed. Baseline, sustained segmentation and persistent
impulse variants each produced zero confirmed and two rejected candidates.
The flight-bearing candidate reports takeoff peak 25.93137 m/s^2 (~2.644 g),
landing peak 30.13692 m/s^2 and JUMP_IMPULSE_LOW_G_ENVELOPE_MISSING, alongside
ARM_MOTION_PATTERN. These are diagnostic reason codes, not independent labels.
The three methods again do not recover this operator-reported positive.

The generic inspect-garmin CLI rejected temporal reference alignment with
"Operator counts do not establish event timing". The strict parse plus
archived comparison supports count-only evidence and was used instead; no
timestamp was fabricated and no parser/reference guard was bypassed.

This identifies the same unresolved evidence gate, not a new repaired detector.
Do not claim exact candidate-to-physical-hop timing or reproduce historical
negative traces from the synthetic waveform. Further study must add a genuinely
new discriminant, not retry these rejected variants or lower the scalar gate.

## Current evidence reviewed

Read sibling Watch BT4_DIAGNOSTIC_CAPTURE.md, MINIMAL_REGRESSION_RECOVERY.md
and the existing source/fixtures without modifying the Watch project.
The three WV trials are complete; no fourth trial or automatic repeat is
justified by the prior bounded study. No capture or installation was started.

The existing 2350 mg counterfactual recovers a candidate on DIAG_01 but also
accepts a preserved synthetic brisk-walking counterexample. The current report
explicitly distinguishes that synthetic regression from a sample-exact replay
of the historic physical AT2 failure. Do not claim the latter was reproduced.
Hardware negative evidence remains insufficient for promotion; M6 stays NO_GO.

## Fresh verification on 2026-11-15

Ran node --test on takeoff-evidence.test.mjs, archived-regression.test.mjs,
surfr-reference.test.mjs and woo-surfr-reference.test.mjs: 14 passed, 0 failed.
This validates tested software semantics, not improved physical performance or
the installed watch binary. No full-suite/build/hardware claim is made.

## SurfR contribution and next discriminative question

SurfR Android has mounting-specific candidate routes and multi-window drift
checks. That supports investigating temporal sequence/context rather than
lowering one acceleration threshold. It does not validate SurfR thresholds
for WindWisher or fix the Garmin gyro artifacts. Keep gyro quality-only under
the existing Watch findings until its input validity is independently resolved.

Before proposing a feature, inspect complete available DIAG_01/WV and recovered
NV4 motion vectors with their reference limitations. Existing timing/impulse,
segmentation and periodic-background experiments already reject several simple
repairs; do not repeat them as new findings. A new feature must add observable
information and preserve the constructed counterexample, not merely separate
synthetic from real capture geometry.

The new November WOO/SurfR event is useful for provider-result comparison and
WOO raw interpretation, but lacks a simultaneous WindWisher wrist capture.
It cannot validate a new wrist classifier or justify reopening physical trials.
