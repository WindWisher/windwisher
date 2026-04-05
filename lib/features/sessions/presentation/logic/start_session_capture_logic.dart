import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class StartSessionCaptureLogic {
  const StartSessionCaptureLogic._();

  static String activeJumpDetectionModeForDeviceKind(String? deviceKind) {
    final resolvedDeviceKind = deviceKind ?? 'Dispositivo Android';
    return SessionInsightData.jumpDetectionModeForSensors(
      SessionInsightData.physicalSensorsForDeviceKind(resolvedDeviceKind),
    );
  }

  static bool canRegisterMotionEvent(SessionMotionEventCooldownInput input) {
    final lastEventAt = input.lastEventAt;
    if (lastEventAt == null) {
      return true;
    }
    return input.now.difference(lastEventAt) >= input.cooldown;
  }

  static bool hasRecentMotionActivity(SessionRecentMotionActivityInput input) {
    final lastMotionAt =
        <DateTime?>[
          input.lastAccelerationEventAt,
          input.lastRotationEventAt,
        ].whereType<DateTime>().fold<DateTime?>(
          null,
          (latest, value) =>
              latest == null || value.isAfter(latest) ? value : latest,
        );
    if (lastMotionAt == null) {
      return false;
    }
    return input.now.difference(lastMotionAt) < input.window;
  }

  static double resolveSpeedKnots(SessionCaptureSpeedResolutionInput input) {
    const metersPerSecondToKnots = 1.943844;
    final raw = input.rawSpeedMetersPerSecond;
    if (raw.isFinite && raw > 0) {
      return raw * metersPerSecondToKnots;
    }

    final previous = input.previous;
    if (previous == null) {
      return 0;
    }

    final delta = input.positionTimestamp.difference(previous.timestamp);
    if (delta.inMilliseconds <= 0) {
      return 0;
    }

    final distance = Geolocator.distanceBetween(
      previous.latitude,
      previous.longitude,
      input.positionLatitude,
      input.positionLongitude,
    );
    final metersPerSecond = distance / (delta.inMilliseconds / 1000);
    if (!metersPerSecond.isFinite || metersPerSecond <= 0) {
      return 0;
    }
    return metersPerSecond * metersPerSecondToKnots;
  }

  static SessionAccelerationEvaluationResult evaluateAcceleration(
    SessionAccelerationEvaluationInput input,
  ) {
    const gravityMetersPerSecond2 = 9.80665;
    final metersPerSecond2 = math.sqrt(
      input.x * input.x + input.y * input.y + input.z * input.z,
    );
    final accelerationG = metersPerSecond2 / gravityMetersPerSecond2;
    if (!accelerationG.isFinite) {
      return SessionAccelerationEvaluationResult(
        accelerationG: accelerationG,
        updatedRecentAccelerationGs: List<double>.from(
          input.recentAccelerationGs,
        ),
        updatedMaxAccelerationG: input.currentMaxAccelerationG,
        shouldRegisterMotionEvent: false,
        shouldRefreshUi: false,
      );
    }

    final updatedRecentAccelerationGs = List<double>.from(
      input.recentAccelerationGs,
    )..add(accelerationG);
    final confirmationThreshold =
        accelerationG * input.accelerationPeakConfirmationRatio;
    final confirmationMatches = updatedRecentAccelerationGs
        .where((value) => value >= confirmationThreshold)
        .length;
    final hasConfirmedPeak =
        confirmationMatches >= input.accelerationPeakRequiredMatches;
    final updatedMaxAccelerationG =
        hasConfirmedPeak && accelerationG > input.currentMaxAccelerationG
        ? accelerationG
        : input.currentMaxAccelerationG;
    final shouldRegisterMotionEvent =
        accelerationG >= input.accelerationEventThresholdG &&
        input.currentTrackSpeedKnots >= input.motionEventMinSpeedKnots &&
        input.canRegisterMotionEvent;

    return SessionAccelerationEvaluationResult(
      accelerationG: accelerationG,
      updatedRecentAccelerationGs: updatedRecentAccelerationGs,
      updatedMaxAccelerationG: updatedMaxAccelerationG,
      shouldRegisterMotionEvent: shouldRegisterMotionEvent,
      shouldRefreshUi:
          updatedMaxAccelerationG != input.currentMaxAccelerationG ||
          shouldRegisterMotionEvent,
    );
  }

  static SessionApplyAccelerationEvaluationResult applyAccelerationEvaluation(
    SessionApplyAccelerationEvaluationInput input,
  ) {
    final evaluation = input.evaluation;
    var updatedRecentAccelerationGs = List<double>.from(
      evaluation.updatedRecentAccelerationGs,
    );
    if (updatedRecentAccelerationGs.length > input.accelerationPeakWindowSize) {
      updatedRecentAccelerationGs = updatedRecentAccelerationGs.sublist(
        updatedRecentAccelerationGs.length - input.accelerationPeakWindowSize,
      );
    }

    final didRegisterMotionEvent = evaluation.shouldRegisterMotionEvent;
    final updatedAccelerationEventCount = didRegisterMotionEvent
        ? input.currentAccelerationEventCount + 1
        : input.currentAccelerationEventCount;

    return SessionApplyAccelerationEvaluationResult(
      updatedRecentAccelerationGs: updatedRecentAccelerationGs,
      updatedMaxAccelerationG: evaluation.updatedMaxAccelerationG,
      updatedAccelerationEventCount: updatedAccelerationEventCount,
      updatedLastAccelerationEventAt: didRegisterMotionEvent ? input.now : null,
      shouldRefreshUi: evaluation.shouldRefreshUi || didRegisterMotionEvent,
      detectedAccelerationG: evaluation.accelerationG.isFinite
          ? evaluation.accelerationG
          : null,
    );
  }

  static SessionRotationEvaluationResult evaluateRotation(
    SessionRotationEvaluationInput input,
  ) {
    const radiansToDegrees = 57.295779513;
    final rotationDegPerSec =
        math.sqrt(input.x * input.x + input.y * input.y + input.z * input.z) *
        radiansToDegrees;
    if (!rotationDegPerSec.isFinite) {
      return SessionRotationEvaluationResult(
        rotationDegPerSec: rotationDegPerSec,
        updatedMaxRotationDegPerSec: input.currentMaxRotationDegPerSec,
        shouldRegisterMotionEvent: false,
        shouldRefreshUi: false,
      );
    }

    final updatedMaxRotationDegPerSec =
        rotationDegPerSec > input.currentMaxRotationDegPerSec
        ? rotationDegPerSec
        : input.currentMaxRotationDegPerSec;
    final shouldRegisterMotionEvent =
        rotationDegPerSec >= input.rotationEventThresholdDegPerSec &&
        input.currentTrackSpeedKnots >= input.motionEventMinSpeedKnots &&
        input.canRegisterMotionEvent;

    return SessionRotationEvaluationResult(
      rotationDegPerSec: rotationDegPerSec,
      updatedMaxRotationDegPerSec: updatedMaxRotationDegPerSec,
      shouldRegisterMotionEvent: shouldRegisterMotionEvent,
      shouldRefreshUi:
          updatedMaxRotationDegPerSec != input.currentMaxRotationDegPerSec ||
          shouldRegisterMotionEvent,
    );
  }

  static SessionApplyRotationEvaluationResult applyRotationEvaluation(
    SessionApplyRotationEvaluationInput input,
  ) {
    final evaluation = input.evaluation;
    final didRegisterMotionEvent = evaluation.shouldRegisterMotionEvent;
    final updatedRotationEventCount = didRegisterMotionEvent
        ? input.currentRotationEventCount + 1
        : input.currentRotationEventCount;

    return SessionApplyRotationEvaluationResult(
      updatedMaxRotationDegPerSec: evaluation.updatedMaxRotationDegPerSec,
      updatedRotationEventCount: updatedRotationEventCount,
      updatedLastRotationEventAt: didRegisterMotionEvent ? input.now : null,
      shouldRefreshUi: evaluation.shouldRefreshUi || didRegisterMotionEvent,
      detectedRotationDegPerSec: evaluation.rotationDegPerSec.isFinite
          ? evaluation.rotationDegPerSec
          : null,
    );
  }

  static SessionPendingJumpCandidate? expireJumpCandidate(
    SessionJumpCandidateExpirationInput input,
  ) {
    final candidate = input.pendingCandidate;
    if (candidate == null) {
      return null;
    }
    if (input.now.difference(candidate.startedAt) > input.jumpMaxAirTime) {
      return null;
    }
    return candidate;
  }

  static SessionPendingJumpCandidate? maybeStartJumpCandidate(
    SessionJumpCandidateStartInput input,
  ) {
    if (input.pendingCandidate != null ||
        input.currentSpeedKnots < input.jumpMinTakeoffSpeedKnots) {
      return input.pendingCandidate;
    }
    if (input.lastJumpRecordedAt != null &&
        input.now.difference(input.lastJumpRecordedAt!) < input.jumpCooldown) {
      return null;
    }

    final hasAccelerationTrigger =
        input.accelerationG != null &&
        input.accelerationG! >= input.jumpMinManeuverG;
    final hasRotationTrigger =
        input.rotationDegPerSec != null &&
        input.rotationDegPerSec! >= input.jumpMinManeuverRotationDegPerSec;
    if (!hasAccelerationTrigger && !hasRotationTrigger) {
      return null;
    }

    return SessionPendingJumpCandidate(
      startedAt: input.now,
      takeoffSpeedKnots: input.currentSpeedKnots,
      maxManeuverG: input.accelerationG ?? 0,
      maxRotationDegPerSec: input.rotationDegPerSec ?? 0,
    );
  }

  static SessionJumpCandidateFinalizeResult finalizeJumpCandidate(
    SessionJumpCandidateFinalizeInput input,
  ) {
    final candidate = input.pendingCandidate;
    final startedAt = input.recordingStartedAt;
    if (candidate == null || startedAt == null) {
      return const SessionJumpCandidateFinalizeResult(
        recordedJump: null,
        lastJumpRecordedAt: null,
      );
    }

    final hangtime = input.landedAt.difference(candidate.startedAt);
    final hangtimeSeconds = hangtime.inMilliseconds / 1000;
    if (hangtimeSeconds < (input.jumpMinAirTime.inMilliseconds / 1000)) {
      return const SessionJumpCandidateFinalizeResult(
        recordedJump: null,
        lastJumpRecordedAt: null,
      );
    }

    const gravityMetersPerSecond2 = 9.80665;
    final estimatedHeightMeters =
        gravityMetersPerSecond2 * hangtimeSeconds * hangtimeSeconds / 8;
    final estimatedFallSpeedMetersPerSecond =
        gravityMetersPerSecond2 * hangtimeSeconds / 2;

    return SessionJumpCandidateFinalizeResult(
      recordedJump: SessionJumpRecord(
        index: input.nextJumpIndex,
        heightMeters: estimatedHeightMeters,
        hangtimeSeconds: hangtimeSeconds,
        maneuverG: candidate.maxManeuverG > 0 ? candidate.maxManeuverG : null,
        maneuverRotationDegPerSec: candidate.maxRotationDegPerSec > 0
            ? candidate.maxRotationDegPerSec
            : null,
        fallSpeedMetersPerSecond: estimatedFallSpeedMetersPerSecond,
        takeoffSpeedKnots: candidate.takeoffSpeedKnots,
        landingSpeedKnots: input.landingSpeedKnots,
        landingG: input.landingG,
        recordedAt: candidate.startedAt.difference(startedAt),
      ),
      lastJumpRecordedAt: input.landedAt,
    );
  }

  static SessionApplyJumpFinalizeResult applyJumpFinalize(
    SessionApplyJumpFinalizeInput input,
  ) {
    final result = finalizeJumpCandidate(
      SessionJumpCandidateFinalizeInput(
        pendingCandidate: input.pendingCandidate,
        recordingStartedAt: input.recordingStartedAt,
        landedAt: input.landedAt,
        landingG: input.landingG,
        landingSpeedKnots: input.landingSpeedKnots,
        nextJumpIndex: input.nextJumpIndex,
        jumpMinAirTime: input.jumpMinAirTime,
      ),
    );

    final updatedJumpHistory = List<SessionJumpRecord>.from(
      input.currentJumpHistory,
    );
    final recordedJump = result.recordedJump;
    if (recordedJump != null) {
      updatedJumpHistory.add(recordedJump);
    }

    return SessionApplyJumpFinalizeResult(
      updatedJumpHistory: updatedJumpHistory,
      lastJumpRecordedAt: result.lastJumpRecordedAt,
      pendingCandidate: null,
    );
  }

  static SessionInertialJumpUpdateResult updateInertialJumpFromAcceleration(
    SessionInertialJumpAccelerationUpdateInput input,
  ) {
    final expiredCandidate = expireJumpCandidate(
      SessionJumpCandidateExpirationInput(
        pendingCandidate: input.pendingCandidate,
        now: input.now,
        jumpMaxAirTime: input.jumpMaxAirTime,
      ),
    );
    final startedCandidate = maybeStartJumpCandidate(
      SessionJumpCandidateStartInput(
        pendingCandidate: expiredCandidate,
        lastJumpRecordedAt: input.lastJumpRecordedAt,
        now: input.now,
        currentSpeedKnots: input.currentSpeedKnots,
        accelerationG: input.accelerationG,
        rotationDegPerSec: null,
        jumpMinTakeoffSpeedKnots: input.jumpMinTakeoffSpeedKnots,
        jumpMinManeuverG: input.jumpMinManeuverG,
        jumpMinManeuverRotationDegPerSec:
            input.jumpMinManeuverRotationDegPerSec,
        jumpCooldown: input.jumpCooldown,
      ),
    );
    if (startedCandidate == null) {
      return const SessionInertialJumpUpdateResult(
        pendingCandidate: null,
        shouldFinalize: false,
        landedAt: null,
        landingG: null,
        landingSpeedKnots: null,
      );
    }

    final updatedCandidate = startedCandidate.copyWith(
      maxManeuverG: math.max(startedCandidate.maxManeuverG, input.accelerationG),
    );
    final airborneTime = input.now.difference(updatedCandidate.startedAt);
    final shouldFinalize =
        airborneTime >= input.jumpMinAirTime &&
        airborneTime <= input.jumpMaxAirTime &&
        input.accelerationG >= input.jumpLandingThresholdG &&
        input.currentSpeedKnots >= input.jumpLandingMinSpeedKnots;

    return SessionInertialJumpUpdateResult(
      pendingCandidate: updatedCandidate,
      shouldFinalize: shouldFinalize,
      landedAt: shouldFinalize ? input.now : null,
      landingG: shouldFinalize ? input.accelerationG : null,
      landingSpeedKnots: shouldFinalize ? input.currentSpeedKnots : null,
    );
  }

  static SessionInertialJumpUpdateResult updateJumpDetectionFromAcceleration(
    SessionJumpDetectionAccelerationInput input,
  ) {
    switch (input.jumpDetectionMode) {
      case 'barometric':
        // Ruta provisional hasta que conectemos deteccion real por altitud relativa.
        return updateInertialJumpFromAcceleration(
          SessionInertialJumpAccelerationUpdateInput(
            pendingCandidate: input.pendingCandidate,
            lastJumpRecordedAt: input.lastJumpRecordedAt,
            now: input.now,
            currentSpeedKnots: input.currentSpeedKnots,
            accelerationG: input.accelerationG,
            jumpMinTakeoffSpeedKnots: input.jumpMinTakeoffSpeedKnots,
            jumpMinManeuverG: input.jumpMinManeuverG,
            jumpMinManeuverRotationDegPerSec:
                input.jumpMinManeuverRotationDegPerSec,
            jumpCooldown: input.jumpCooldown,
            jumpMinAirTime: input.jumpMinAirTime,
            jumpMaxAirTime: input.jumpMaxAirTime,
            jumpLandingThresholdG: input.jumpLandingThresholdG,
            jumpLandingMinSpeedKnots: input.jumpLandingMinSpeedKnots,
          ),
        );
      case 'inertial_fallback':
        return updateInertialJumpFromAcceleration(
          SessionInertialJumpAccelerationUpdateInput(
            pendingCandidate: input.pendingCandidate,
            lastJumpRecordedAt: input.lastJumpRecordedAt,
            now: input.now,
            currentSpeedKnots: input.currentSpeedKnots,
            accelerationG: input.accelerationG,
            jumpMinTakeoffSpeedKnots: input.jumpMinTakeoffSpeedKnots,
            jumpMinManeuverG: input.jumpMinManeuverG,
            jumpMinManeuverRotationDegPerSec:
                input.jumpMinManeuverRotationDegPerSec,
            jumpCooldown: input.jumpCooldown,
            jumpMinAirTime: input.jumpMinAirTime,
            jumpMaxAirTime: input.jumpMaxAirTime,
            jumpLandingThresholdG: input.jumpLandingThresholdG,
            jumpLandingMinSpeedKnots: input.jumpLandingMinSpeedKnots,
          ),
        );
    }
    return const SessionInertialJumpUpdateResult(
      pendingCandidate: null,
      shouldFinalize: false,
      landedAt: null,
      landingG: null,
      landingSpeedKnots: null,
    );
  }

  static SessionInertialJumpUpdateResult updateInertialJumpFromRotation(
    SessionInertialJumpRotationUpdateInput input,
  ) {
    final expiredCandidate = expireJumpCandidate(
      SessionJumpCandidateExpirationInput(
        pendingCandidate: input.pendingCandidate,
        now: input.now,
        jumpMaxAirTime: input.jumpMaxAirTime,
      ),
    );
    final startedCandidate = maybeStartJumpCandidate(
      SessionJumpCandidateStartInput(
        pendingCandidate: expiredCandidate,
        lastJumpRecordedAt: input.lastJumpRecordedAt,
        now: input.now,
        currentSpeedKnots: input.currentSpeedKnots,
        accelerationG: null,
        rotationDegPerSec: input.rotationDegPerSec,
        jumpMinTakeoffSpeedKnots: input.jumpMinTakeoffSpeedKnots,
        jumpMinManeuverG: input.jumpMinManeuverG,
        jumpMinManeuverRotationDegPerSec:
            input.jumpMinManeuverRotationDegPerSec,
        jumpCooldown: input.jumpCooldown,
      ),
    );
    if (startedCandidate == null) {
      return const SessionInertialJumpUpdateResult(
        pendingCandidate: null,
        shouldFinalize: false,
        landedAt: null,
        landingG: null,
        landingSpeedKnots: null,
      );
    }

    return SessionInertialJumpUpdateResult(
      pendingCandidate: startedCandidate.copyWith(
        maxRotationDegPerSec: math.max(
          startedCandidate.maxRotationDegPerSec,
          input.rotationDegPerSec,
        ),
      ),
      shouldFinalize: false,
      landedAt: null,
      landingG: null,
      landingSpeedKnots: null,
    );
  }

  static SessionInertialJumpUpdateResult updateJumpDetectionFromRotation(
    SessionJumpDetectionRotationInput input,
  ) {
    switch (input.jumpDetectionMode) {
      case 'barometric':
        // Ruta provisional hasta que conectemos perfil vertical barometrico real.
        return updateInertialJumpFromRotation(
          SessionInertialJumpRotationUpdateInput(
            pendingCandidate: input.pendingCandidate,
            lastJumpRecordedAt: input.lastJumpRecordedAt,
            now: input.now,
            currentSpeedKnots: input.currentSpeedKnots,
            rotationDegPerSec: input.rotationDegPerSec,
            jumpMinTakeoffSpeedKnots: input.jumpMinTakeoffSpeedKnots,
            jumpMinManeuverG: input.jumpMinManeuverG,
            jumpMinManeuverRotationDegPerSec:
                input.jumpMinManeuverRotationDegPerSec,
            jumpCooldown: input.jumpCooldown,
            jumpMaxAirTime: input.jumpMaxAirTime,
          ),
        );
      case 'inertial_fallback':
        return updateInertialJumpFromRotation(
          SessionInertialJumpRotationUpdateInput(
            pendingCandidate: input.pendingCandidate,
            lastJumpRecordedAt: input.lastJumpRecordedAt,
            now: input.now,
            currentSpeedKnots: input.currentSpeedKnots,
            rotationDegPerSec: input.rotationDegPerSec,
            jumpMinTakeoffSpeedKnots: input.jumpMinTakeoffSpeedKnots,
            jumpMinManeuverG: input.jumpMinManeuverG,
            jumpMinManeuverRotationDegPerSec:
                input.jumpMinManeuverRotationDegPerSec,
            jumpCooldown: input.jumpCooldown,
            jumpMaxAirTime: input.jumpMaxAirTime,
          ),
        );
    }
    return const SessionInertialJumpUpdateResult(
      pendingCandidate: null,
      shouldFinalize: false,
      landedAt: null,
      landingG: null,
      landingSpeedKnots: null,
    );
  }

  static SessionCaptureTrackStepEvaluationResult evaluateTrackStep(
    SessionCaptureTrackStepEvaluationInput input,
  ) {
    final isUsablePosition =
        input.accuracyMeters.isFinite &&
        input.accuracyMeters > 0 &&
        input.accuracyMeters <= input.maxAccuracyMeters &&
        input.current.latitude.isFinite &&
        input.current.longitude.isFinite &&
        input.current.timestamp.isAfter(DateTime.fromMillisecondsSinceEpoch(0));
    if (!isUsablePosition) {
      return const SessionCaptureTrackStepEvaluationResult(
        isUsablePosition: false,
        isPlausibleStep: false,
        legMeters: null,
        delta: null,
      );
    }

    if (input.previous == null) {
      return const SessionCaptureTrackStepEvaluationResult(
        isUsablePosition: true,
        isPlausibleStep: true,
        legMeters: null,
        delta: null,
      );
    }

    final delta = input.current.timestamp.difference(input.previous!.timestamp);
    if (delta.inMilliseconds <= 0) {
      return const SessionCaptureTrackStepEvaluationResult(
        isUsablePosition: true,
        isPlausibleStep: false,
        legMeters: null,
        delta: null,
      );
    }

    final legMeters = Geolocator.distanceBetween(
      input.previous!.latitude,
      input.previous!.longitude,
      input.current.latitude,
      input.current.longitude,
    );
    if (!legMeters.isFinite || legMeters < 0) {
      return const SessionCaptureTrackStepEvaluationResult(
        isUsablePosition: true,
        isPlausibleStep: false,
        legMeters: null,
        delta: null,
      );
    }

    final metersPerSecond = legMeters / (delta.inMilliseconds / 1000);
    if (!metersPerSecond.isFinite) {
      return const SessionCaptureTrackStepEvaluationResult(
        isUsablePosition: true,
        isPlausibleStep: false,
        legMeters: null,
        delta: null,
      );
    }

    final knots = metersPerSecond * 1.943844;
    return SessionCaptureTrackStepEvaluationResult(
      isUsablePosition: true,
      isPlausibleStep: knots <= input.maxPlausibleSpeedKnots,
      legMeters: legMeters,
      delta: delta,
    );
  }

  static SessionCaptureTrackAccumulationResult accumulateTrackStep(
    SessionCaptureTrackAccumulationInput input,
  ) {
    var distanceMeters = input.currentDistanceMeters;
    if (input.legMeters != null &&
        input.legMeters!.isFinite &&
        input.legMeters! > 0) {
      distanceMeters += input.legMeters!;
    }

    var movingDuration = input.currentMovingDuration;
    final delta = input.delta;
    if (delta != null &&
        !delta.isNegative &&
        delta.inSeconds > 0 &&
        !input.isAutoPaused &&
        input.speedKnots >= input.movingMinSpeedKnots) {
      movingDuration += delta;
    }

    final maxSpeedKnots = input.speedKnots > input.currentMaxSpeedKnots
        ? input.speedKnots
        : input.currentMaxSpeedKnots;

    return SessionCaptureTrackAccumulationResult(
      distanceMeters: distanceMeters,
      movingDuration: movingDuration,
      maxSpeedKnots: maxSpeedKnots,
    );
  }

  static SessionAutoPauseEvaluationResult evaluateAutoPause(
    SessionAutoPauseEvaluationInput input,
  ) {
    if (input.isAutoPaused) {
      if (input.speedKnots >= input.autoResumeSpeedKnots) {
        final resumeCandidateDuration =
            input.resumeCandidateDuration + input.delta;
        if (resumeCandidateDuration >= input.autoResumeDelay) {
          return SessionAutoPauseEvaluationResult(
            isAutoPaused: false,
            lowSpeedCandidateDuration: Duration.zero,
            resumeCandidateDuration: Duration.zero,
            autoPausedDuration: input.autoPausedDuration,
            autoPauseCount: input.autoPauseCount,
          );
        }
        return SessionAutoPauseEvaluationResult(
          isAutoPaused: true,
          lowSpeedCandidateDuration: input.lowSpeedCandidateDuration,
          resumeCandidateDuration: resumeCandidateDuration,
          autoPausedDuration: input.autoPausedDuration,
          autoPauseCount: input.autoPauseCount,
        );
      }

      return SessionAutoPauseEvaluationResult(
        isAutoPaused: true,
        lowSpeedCandidateDuration: input.lowSpeedCandidateDuration,
        resumeCandidateDuration: Duration.zero,
        autoPausedDuration: input.autoPausedDuration + input.delta,
        autoPauseCount: input.autoPauseCount,
      );
    }

    final hasLowSpeed = input.speedKnots <= input.autoPauseSpeedKnots;
    final hasNoRecentMotion = !input.hasRecentMotionActivity;
    if (hasLowSpeed && hasNoRecentMotion) {
      final lowSpeedCandidateDuration =
          input.lowSpeedCandidateDuration + input.delta;
      if (lowSpeedCandidateDuration >= input.autoPauseDelay) {
        return SessionAutoPauseEvaluationResult(
          isAutoPaused: true,
          lowSpeedCandidateDuration: Duration.zero,
          resumeCandidateDuration: Duration.zero,
          autoPausedDuration:
              input.autoPausedDuration + lowSpeedCandidateDuration,
          autoPauseCount: input.autoPauseCount + 1,
        );
      }

      return SessionAutoPauseEvaluationResult(
        isAutoPaused: false,
        lowSpeedCandidateDuration: lowSpeedCandidateDuration,
        resumeCandidateDuration: Duration.zero,
        autoPausedDuration: input.autoPausedDuration,
        autoPauseCount: input.autoPauseCount,
      );
    }

    return SessionAutoPauseEvaluationResult(
      isAutoPaused: false,
      lowSpeedCandidateDuration: Duration.zero,
      resumeCandidateDuration: Duration.zero,
      autoPausedDuration: input.autoPausedDuration,
      autoPauseCount: input.autoPauseCount,
    );
  }
}
