# Watch project continuity audit

Read-only review of sibling `../WindWisher Watch`. No Watch source was changed,
no binary installed and no hardware capture started in this audit.

## Three separate paths already exist

1. `platforms/garmin/session-engine`: product session journal and phone transport.
   FRAME_POSITION/HEART_RATE/PRESSURE and lifecycle/quality records are accepted;
   SeTransferProducer validates the same bounded list. This agrees with the
   Flutter converter; missing raw IMU there is a contract boundary, not proof
   the Watch project has no inertial acquisition.
2. `platforms/garmin/source/MotionProbe.mc`: sensor laboratory with accelerometer
   and gyro registration, per-sample timestamps and timing diagnostics.
3. `platforms/garmin/jump-research`: isolated bounded IMU capture and experimental
   detector, with host replay, decision snapshots and physical trial reports.

## Existing evidence to preserve

`docs/jump-engine/M5_4B_FINDINGS.md` reports experimental-0.5 phase-scoped
features, host/device parity on one diagnostic capture and an unresolved
discrimination problem: lowering a threshold recovers a candidate but revives
a brisk-walking false positive. It explicitly retains M6 NO_GO.

`GYRO_HARDWARE_FINDINGS.md` reports implausible motion-dependent watch gyro
values and GYRO_ROLE=QUALITY_ONLY. This is distinct from the coherent WOO raw
gyro and cannot inherit WOO's calibration or be a wrist boundary dependency.

`GARMIN_RESEARCH_CAPTURE.md` describes bounded capture/export and forbids
full-session raw IMU in that research app. Preserve that scope; do not propose
unbounded logging or schema expansion as an already agreed next step.

## Corrected next step

Continue from the Watch project's current diagnostic/parity findings. Use
SurfR mode analysis to formulate testable physical hypotheses, not to copy
thresholds or overwrite the existing detector. First inspect current
BT4_DIAGNOSTIC_CAPTURE.md, hardware artifacts and source guards before any
new capture, algorithm tuning or transport extension. These reports describe
prior verification, not tests rerun during this audit.

The sibling worktree has pending session-transfer changes; leave them intact.
