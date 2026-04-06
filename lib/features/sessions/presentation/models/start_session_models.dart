import 'package:flutter/material.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

enum SessionCapturePhase { ready, recording, finished, syncing, synced }

enum SessionMediaSelection { none, camera, gallery }

enum SessionCaptureControlAction {
  showMessage,
  startRecording,
  confirmStopRecording,
  showSaveDialog,
  resetToReady,
  none,
}

class SessionCaptureControlDecision {
  const SessionCaptureControlDecision({
    required this.action,
    this.message,
  });

  final SessionCaptureControlAction action;
  final String? message;
}

enum SessionLocationAccessAction { startCapture, showMessage }

class SessionLocationAccessDecision {
  const SessionLocationAccessDecision({
    required this.action,
    this.message,
  });

  final SessionLocationAccessAction action;
  final String? message;
}

enum SessionStopCaptureAction { discardAndReset, markFinished }

class SessionStopCaptureDecision {
  const SessionStopCaptureDecision({
    required this.action,
    this.message,
  });

  final SessionStopCaptureAction action;
  final String? message;
}

class StartSessionPageData {
  const StartSessionPageData({required this.description});

  final String description;
}

class StartSessionPanelData {
  const StartSessionPanelData({
    required this.captureStatusText,
    this.importHintText,
  });

  final String captureStatusText;
  final String? importHintText;
}

class SessionGearSetupOptionData {
  const SessionGearSetupOptionData({
    required this.id,
    required this.name,
    required this.detailLines,
  });

  final String id;
  final String name;
  final List<String> detailLines;
}

class SessionUploadDialogData {
  const SessionUploadDialogData({
    required this.title,
    required this.submitLabel,
    required this.showSpotField,
    required this.spotOptions,
    required this.initialSpot,
    required this.notesLabel,
    required this.initialNotes,
    required this.initialMediaSelection,
    required this.initialSessionPhotoLocalPath,
    required this.gearSetupOptions,
    required this.initialGearSetupId,
  });

  final String title;
  final String submitLabel;
  final bool showSpotField;
  final List<String> spotOptions;
  final String initialSpot;
  final String notesLabel;
  final String initialNotes;
  final SessionMediaSelection initialMediaSelection;
  final String? initialSessionPhotoLocalPath;
  final List<SessionGearSetupOptionData> gearSetupOptions;
  final String? initialGearSetupId;
}

class SessionUploadDialogResult {
  const SessionUploadDialogResult({
    required this.spot,
    required this.notes,
    required this.mediaSelection,
    required this.sessionPhotoLocalPath,
    required this.gearSetupId,
    required this.gearSetupName,
  });

  final String spot;
  final String notes;
  final SessionMediaSelection mediaSelection;
  final String? sessionPhotoLocalPath;
  final String? gearSetupId;
  final String? gearSetupName;
}

class SessionDeviceSelectorItemData {
  const SessionDeviceSelectorItemData({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

class SessionDetectedCompatibleDeviceData {
  const SessionDetectedCompatibleDeviceData({
    required this.id,
    required this.defaultName,
    required this.kind,
    required this.status,
    required this.sensorSummary,
    required this.family,
    required this.placement,
    required this.connectionState,
    required this.manufacturer,
    required this.model,
    required this.physicalSensorKeys,
    required this.isSessionEligible,
    this.firmwareVersion,
    String? customName,
  }) : customName = customName ?? defaultName;

  final String id;
  final String defaultName;
  final String kind;
  final String status;
  final String sensorSummary;
  final String family;
  final String placement;
  final String connectionState;
  final String manufacturer;
  final String model;
  final String? firmwareVersion;
  final List<String> physicalSensorKeys;
  final bool isSessionEligible;
  final String customName;

  bool get hasBarometer => physicalSensorKeys.contains('barometer');
  bool get hasAltimeter => physicalSensorKeys.contains('altimeter');

  SessionDetectedCompatibleDeviceData copyWith({String? customName}) {
    return SessionDetectedCompatibleDeviceData(
      id: id,
      defaultName: defaultName,
      kind: kind,
      status: status,
      sensorSummary: sensorSummary,
      family: family,
      placement: placement,
      connectionState: connectionState,
      manufacturer: manufacturer,
      model: model,
      firmwareVersion: firmwareVersion,
      physicalSensorKeys: physicalSensorKeys,
      isSessionEligible: isSessionEligible,
      customName: customName ?? this.customName,
    );
  }
}

class SessionCaptureSample {
  const SessionCaptureSample({
    required this.latitude,
    required this.longitude,
    required this.speedKnots,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;
  final double speedKnots;
  final DateTime timestamp;
}

class SessionSyncedPendingItemData {
  const SessionSyncedPendingItemData({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final String id;
  final String title;
  final String subtitle;
}

class SessionImportedPendingResult {
  const SessionImportedPendingResult({
    required this.title,
    required this.fileName,
    required this.fileExtension,
    required this.endedAt,
    required this.duration,
    required this.summary,
    required this.jumpHistory,
  });

  final String title;
  final String fileName;
  final String fileExtension;
  final DateTime endedAt;
  final Duration duration;
  final String summary;
  final List<SessionJumpRecord> jumpHistory;
}

class SessionSelectedDeviceCardData {
  const SessionSelectedDeviceCardData({
    required this.name,
    required this.kind,
    required this.capabilitiesIcon,
    required this.statusLabel,
    required this.statusColor,
    required this.availabilityLabel,
    required this.sensorCountLabel,
    required this.isPhoneDeviceSelected,
  });

  final String name;
  final String kind;
  final IconData capabilitiesIcon;
  final String statusLabel;
  final Color statusColor;
  final String availabilityLabel;
  final String sensorCountLabel;
  final bool isPhoneDeviceSelected;
}

class SessionCaptureStatusCardData {
  const SessionCaptureStatusCardData({
    required this.statusText,
    required this.stepProgress,
    required this.elapsedLabel,
    required this.gpsLabel,
    required this.gpsBackgroundColor,
    required this.gpsForegroundColor,
    required this.gpsIcon,
    required this.autoPauseLabel,
    required this.autoPauseBackgroundColor,
    required this.autoPauseForegroundColor,
    required this.autoPauseIcon,
    required this.currentSpeedLabel,
    required this.maxSpeedLabel,
    required this.activeLabel,
    required this.pausedLabel,
    required this.saveReadinessLabel,
    required this.saveReadinessBackgroundColor,
    required this.saveReadinessForegroundColor,
    required this.saveReadinessIcon,
    required this.actionLabel,
    required this.actionIcon,
    required this.actionEnabled,
  });

  final String statusText;
  final double stepProgress;
  final String elapsedLabel;
  final String gpsLabel;
  final Color gpsBackgroundColor;
  final Color gpsForegroundColor;
  final IconData gpsIcon;
  final String autoPauseLabel;
  final Color autoPauseBackgroundColor;
  final Color autoPauseForegroundColor;
  final IconData autoPauseIcon;
  final String currentSpeedLabel;
  final String maxSpeedLabel;
  final String activeLabel;
  final String pausedLabel;
  final String saveReadinessLabel;
  final Color saveReadinessBackgroundColor;
  final Color saveReadinessForegroundColor;
  final IconData saveReadinessIcon;
  final String actionLabel;
  final IconData actionIcon;
  final bool actionEnabled;
}

class SessionStopRecordingDialogData {
  const SessionStopRecordingDialogData({
    required this.title,
    required this.primaryMessage,
    required this.secondaryMessage,
    required this.requirementsMessage,
    required this.gpsWarningMessage,
    required this.lossWarningMessage,
    required this.confirmLabel,
  });

  final String title;
  final String primaryMessage;
  final String secondaryMessage;
  final String? requirementsMessage;
  final String? gpsWarningMessage;
  final String lossWarningMessage;
  final String confirmLabel;
}

class SessionCapturePresentationInput {
  const SessionCapturePresentationInput({
    required this.phase,
    required this.hasSelectedDevice,
    required this.isPhoneDeviceSelected,
    required this.isAutoPaused,
    required this.isAutoPausePending,
    required this.autoPauseRemainingSeconds,
    required this.elapsedLabel,
    required this.currentSpeedLabel,
    required this.maxSpeedLabel,
    required this.activeLabel,
    required this.pausedLabel,
    required this.lastGpsAccuracyMeters,
    required this.hasEnoughRecordedTrackForSave,
    required this.saveReadinessSatisfiedRuleCount,
  });

  final SessionCapturePhase phase;
  final bool hasSelectedDevice;
  final bool isPhoneDeviceSelected;
  final bool isAutoPaused;
  final bool isAutoPausePending;
  final int autoPauseRemainingSeconds;
  final String elapsedLabel;
  final String currentSpeedLabel;
  final String maxSpeedLabel;
  final String activeLabel;
  final String pausedLabel;
  final double? lastGpsAccuracyMeters;
  final bool hasEnoughRecordedTrackForSave;
  final int saveReadinessSatisfiedRuleCount;
}

class SessionRecentMotionActivityInput {
  const SessionRecentMotionActivityInput({
    required this.now,
    required this.lastAccelerationEventAt,
    required this.lastRotationEventAt,
    required this.window,
  });

  final DateTime now;
  final DateTime? lastAccelerationEventAt;
  final DateTime? lastRotationEventAt;
  final Duration window;
}

class SessionMotionEventCooldownInput {
  const SessionMotionEventCooldownInput({
    required this.now,
    required this.lastEventAt,
    required this.cooldown,
  });

  final DateTime now;
  final DateTime? lastEventAt;
  final Duration cooldown;
}

class SessionAutoPauseEvaluationInput {
  const SessionAutoPauseEvaluationInput({
    required this.isAutoPaused,
    required this.delta,
    required this.speedKnots,
    required this.hasRecentMotionActivity,
    required this.lowSpeedCandidateDuration,
    required this.resumeCandidateDuration,
    required this.autoPausedDuration,
    required this.autoPauseCount,
    required this.autoPauseSpeedKnots,
    required this.autoResumeSpeedKnots,
    required this.autoPauseDelay,
    required this.autoResumeDelay,
  });

  final bool isAutoPaused;
  final Duration delta;
  final double speedKnots;
  final bool hasRecentMotionActivity;
  final Duration lowSpeedCandidateDuration;
  final Duration resumeCandidateDuration;
  final Duration autoPausedDuration;
  final int autoPauseCount;
  final double autoPauseSpeedKnots;
  final double autoResumeSpeedKnots;
  final Duration autoPauseDelay;
  final Duration autoResumeDelay;
}

class SessionAutoPauseEvaluationResult {
  const SessionAutoPauseEvaluationResult({
    required this.isAutoPaused,
    required this.lowSpeedCandidateDuration,
    required this.resumeCandidateDuration,
    required this.autoPausedDuration,
    required this.autoPauseCount,
  });

  final bool isAutoPaused;
  final Duration lowSpeedCandidateDuration;
  final Duration resumeCandidateDuration;
  final Duration autoPausedDuration;
  final int autoPauseCount;
}

class SessionCaptureTrackStepEvaluationInput {
  const SessionCaptureTrackStepEvaluationInput({
    required this.accuracyMeters,
    required this.maxAccuracyMeters,
    required this.previous,
    required this.current,
    required this.maxPlausibleSpeedKnots,
  });

  final double accuracyMeters;
  final double maxAccuracyMeters;
  final SessionCaptureSample? previous;
  final SessionCaptureSample current;
  final double maxPlausibleSpeedKnots;
}

class SessionCaptureTrackStepEvaluationResult {
  const SessionCaptureTrackStepEvaluationResult({
    required this.isUsablePosition,
    required this.isPlausibleStep,
    required this.legMeters,
    required this.delta,
  });

  final bool isUsablePosition;
  final bool isPlausibleStep;
  final double? legMeters;
  final Duration? delta;
}

class SessionCaptureTrackAccumulationInput {
  const SessionCaptureTrackAccumulationInput({
    required this.legMeters,
    required this.delta,
    required this.speedKnots,
    required this.isAutoPaused,
    required this.currentDistanceMeters,
    required this.currentMovingDuration,
    required this.currentMaxSpeedKnots,
    required this.movingMinSpeedKnots,
  });

  final double? legMeters;
  final Duration? delta;
  final double speedKnots;
  final bool isAutoPaused;
  final double currentDistanceMeters;
  final Duration currentMovingDuration;
  final double currentMaxSpeedKnots;
  final double movingMinSpeedKnots;
}

class SessionCaptureTrackAccumulationResult {
  const SessionCaptureTrackAccumulationResult({
    required this.distanceMeters,
    required this.movingDuration,
    required this.maxSpeedKnots,
  });

  final double distanceMeters;
  final Duration movingDuration;
  final double maxSpeedKnots;
}

class SessionCaptureSpeedResolutionInput {
  const SessionCaptureSpeedResolutionInput({
    required this.rawSpeedMetersPerSecond,
    required this.positionLatitude,
    required this.positionLongitude,
    required this.positionTimestamp,
    required this.previous,
  });

  final double rawSpeedMetersPerSecond;
  final double positionLatitude;
  final double positionLongitude;
  final DateTime positionTimestamp;
  final SessionCaptureSample? previous;
}

class SessionAccelerationEvaluationInput {
  const SessionAccelerationEvaluationInput({
    required this.x,
    required this.y,
    required this.z,
    required this.recentAccelerationGs,
    required this.currentMaxAccelerationG,
    required this.accelerationPeakConfirmationRatio,
    required this.accelerationPeakRequiredMatches,
    required this.accelerationEventThresholdG,
    required this.currentTrackSpeedKnots,
    required this.motionEventMinSpeedKnots,
    required this.canRegisterMotionEvent,
  });

  final double x;
  final double y;
  final double z;
  final List<double> recentAccelerationGs;
  final double currentMaxAccelerationG;
  final double accelerationPeakConfirmationRatio;
  final int accelerationPeakRequiredMatches;
  final double accelerationEventThresholdG;
  final double currentTrackSpeedKnots;
  final double motionEventMinSpeedKnots;
  final bool canRegisterMotionEvent;
}

class SessionAccelerationEvaluationResult {
  const SessionAccelerationEvaluationResult({
    required this.accelerationG,
    required this.updatedRecentAccelerationGs,
    required this.updatedMaxAccelerationG,
    required this.shouldRegisterMotionEvent,
    required this.shouldRefreshUi,
  });

  final double accelerationG;
  final List<double> updatedRecentAccelerationGs;
  final double updatedMaxAccelerationG;
  final bool shouldRegisterMotionEvent;
  final bool shouldRefreshUi;
}

class SessionApplyAccelerationEvaluationInput {
  const SessionApplyAccelerationEvaluationInput({
    required this.evaluation,
    required this.accelerationPeakWindowSize,
    required this.currentAccelerationEventCount,
    required this.now,
  });

  final SessionAccelerationEvaluationResult evaluation;
  final int accelerationPeakWindowSize;
  final int currentAccelerationEventCount;
  final DateTime now;
}

class SessionApplyAccelerationEvaluationResult {
  const SessionApplyAccelerationEvaluationResult({
    required this.updatedRecentAccelerationGs,
    required this.updatedMaxAccelerationG,
    required this.updatedAccelerationEventCount,
    required this.updatedLastAccelerationEventAt,
    required this.shouldRefreshUi,
    required this.detectedAccelerationG,
  });

  final List<double> updatedRecentAccelerationGs;
  final double updatedMaxAccelerationG;
  final int updatedAccelerationEventCount;
  final DateTime? updatedLastAccelerationEventAt;
  final bool shouldRefreshUi;
  final double? detectedAccelerationG;
}

class SessionRotationEvaluationInput {
  const SessionRotationEvaluationInput({
    required this.x,
    required this.y,
    required this.z,
    required this.currentMaxRotationDegPerSec,
    required this.rotationEventThresholdDegPerSec,
    required this.currentTrackSpeedKnots,
    required this.motionEventMinSpeedKnots,
    required this.canRegisterMotionEvent,
  });

  final double x;
  final double y;
  final double z;
  final double currentMaxRotationDegPerSec;
  final double rotationEventThresholdDegPerSec;
  final double currentTrackSpeedKnots;
  final double motionEventMinSpeedKnots;
  final bool canRegisterMotionEvent;
}

class SessionRotationEvaluationResult {
  const SessionRotationEvaluationResult({
    required this.rotationDegPerSec,
    required this.updatedMaxRotationDegPerSec,
    required this.shouldRegisterMotionEvent,
    required this.shouldRefreshUi,
  });

  final double rotationDegPerSec;
  final double updatedMaxRotationDegPerSec;
  final bool shouldRegisterMotionEvent;
  final bool shouldRefreshUi;
}

class SessionApplyRotationEvaluationInput {
  const SessionApplyRotationEvaluationInput({
    required this.evaluation,
    required this.currentRotationEventCount,
    required this.now,
  });

  final SessionRotationEvaluationResult evaluation;
  final int currentRotationEventCount;
  final DateTime now;
}

class SessionApplyRotationEvaluationResult {
  const SessionApplyRotationEvaluationResult({
    required this.updatedMaxRotationDegPerSec,
    required this.updatedRotationEventCount,
    required this.updatedLastRotationEventAt,
    required this.shouldRefreshUi,
    required this.detectedRotationDegPerSec,
  });

  final double updatedMaxRotationDegPerSec;
  final int updatedRotationEventCount;
  final DateTime? updatedLastRotationEventAt;
  final bool shouldRefreshUi;
  final double? detectedRotationDegPerSec;
}

class SessionPendingJumpCandidate {
  const SessionPendingJumpCandidate({
    required this.startedAt,
    required this.takeoffSpeedKnots,
    required this.maxManeuverG,
    required this.maxRotationDegPerSec,
  });

  final DateTime startedAt;
  final double takeoffSpeedKnots;
  final double maxManeuverG;
  final double maxRotationDegPerSec;

  SessionPendingJumpCandidate copyWith({
    DateTime? startedAt,
    double? takeoffSpeedKnots,
    double? maxManeuverG,
    double? maxRotationDegPerSec,
  }) {
    return SessionPendingJumpCandidate(
      startedAt: startedAt ?? this.startedAt,
      takeoffSpeedKnots: takeoffSpeedKnots ?? this.takeoffSpeedKnots,
      maxManeuverG: maxManeuverG ?? this.maxManeuverG,
      maxRotationDegPerSec: maxRotationDegPerSec ?? this.maxRotationDegPerSec,
    );
  }
}

class SessionJumpCandidateStartInput {
  const SessionJumpCandidateStartInput({
    required this.pendingCandidate,
    required this.lastJumpRecordedAt,
    required this.now,
    required this.currentSpeedKnots,
    required this.accelerationG,
    required this.rotationDegPerSec,
    required this.jumpMinTakeoffSpeedKnots,
    required this.jumpMinManeuverG,
    required this.jumpMinManeuverRotationDegPerSec,
    required this.jumpCooldown,
  });

  final SessionPendingJumpCandidate? pendingCandidate;
  final DateTime? lastJumpRecordedAt;
  final DateTime now;
  final double currentSpeedKnots;
  final double? accelerationG;
  final double? rotationDegPerSec;
  final double jumpMinTakeoffSpeedKnots;
  final double jumpMinManeuverG;
  final double jumpMinManeuverRotationDegPerSec;
  final Duration jumpCooldown;
}

class SessionJumpCandidateExpirationInput {
  const SessionJumpCandidateExpirationInput({
    required this.pendingCandidate,
    required this.now,
    required this.jumpMaxAirTime,
  });

  final SessionPendingJumpCandidate? pendingCandidate;
  final DateTime now;
  final Duration jumpMaxAirTime;
}

class SessionJumpCandidateFinalizeInput {
  const SessionJumpCandidateFinalizeInput({
    required this.pendingCandidate,
    required this.recordingStartedAt,
    required this.landedAt,
    required this.landingG,
    required this.landingSpeedKnots,
    required this.nextJumpIndex,
    required this.jumpMinAirTime,
    required this.jumpMinManeuverG,
    required this.jumpMinManeuverRotationDegPerSec,
  });

  final SessionPendingJumpCandidate? pendingCandidate;
  final DateTime? recordingStartedAt;
  final DateTime landedAt;
  final double landingG;
  final double landingSpeedKnots;
  final int nextJumpIndex;
  final Duration jumpMinAirTime;
  final double jumpMinManeuverG;
  final double jumpMinManeuverRotationDegPerSec;
}

class SessionJumpCandidateFinalizeResult {
  const SessionJumpCandidateFinalizeResult({
    required this.recordedJump,
    required this.lastJumpRecordedAt,
  });

  final SessionJumpRecord? recordedJump;
  final DateTime? lastJumpRecordedAt;
}

class SessionInertialJumpAccelerationUpdateInput {
  const SessionInertialJumpAccelerationUpdateInput({
    required this.pendingCandidate,
    required this.lastJumpRecordedAt,
    required this.now,
    required this.currentSpeedKnots,
    required this.accelerationG,
    required this.jumpMinTakeoffSpeedKnots,
    required this.jumpMinManeuverG,
    required this.jumpMinManeuverRotationDegPerSec,
    required this.jumpCooldown,
    required this.jumpMinAirTime,
    required this.jumpMaxAirTime,
    required this.jumpLandingThresholdG,
    required this.jumpLandingMinSpeedKnots,
  });

  final SessionPendingJumpCandidate? pendingCandidate;
  final DateTime? lastJumpRecordedAt;
  final DateTime now;
  final double currentSpeedKnots;
  final double accelerationG;
  final double jumpMinTakeoffSpeedKnots;
  final double jumpMinManeuverG;
  final double jumpMinManeuverRotationDegPerSec;
  final Duration jumpCooldown;
  final Duration jumpMinAirTime;
  final Duration jumpMaxAirTime;
  final double jumpLandingThresholdG;
  final double jumpLandingMinSpeedKnots;
}

class SessionInertialJumpRotationUpdateInput {
  const SessionInertialJumpRotationUpdateInput({
    required this.pendingCandidate,
    required this.lastJumpRecordedAt,
    required this.now,
    required this.currentSpeedKnots,
    required this.rotationDegPerSec,
    required this.jumpMinTakeoffSpeedKnots,
    required this.jumpMinManeuverG,
    required this.jumpMinManeuverRotationDegPerSec,
    required this.jumpCooldown,
    required this.jumpMaxAirTime,
  });

  final SessionPendingJumpCandidate? pendingCandidate;
  final DateTime? lastJumpRecordedAt;
  final DateTime now;
  final double currentSpeedKnots;
  final double rotationDegPerSec;
  final double jumpMinTakeoffSpeedKnots;
  final double jumpMinManeuverG;
  final double jumpMinManeuverRotationDegPerSec;
  final Duration jumpCooldown;
  final Duration jumpMaxAirTime;
}

class SessionInertialJumpUpdateResult {
  const SessionInertialJumpUpdateResult({
    required this.pendingCandidate,
    required this.shouldFinalize,
    required this.landedAt,
    required this.landingG,
    required this.landingSpeedKnots,
  });

  final SessionPendingJumpCandidate? pendingCandidate;
  final bool shouldFinalize;
  final DateTime? landedAt;
  final double? landingG;
  final double? landingSpeedKnots;
}

class SessionJumpDetectionAccelerationInput {
  const SessionJumpDetectionAccelerationInput({
    required this.jumpDetectionMode,
    required this.pendingCandidate,
    required this.lastJumpRecordedAt,
    required this.now,
    required this.currentSpeedKnots,
    required this.accelerationG,
    required this.jumpMinTakeoffSpeedKnots,
    required this.jumpMinManeuverG,
    required this.jumpMinManeuverRotationDegPerSec,
    required this.jumpCooldown,
    required this.jumpMinAirTime,
    required this.jumpMaxAirTime,
    required this.jumpLandingThresholdG,
    required this.jumpLandingMinSpeedKnots,
  });

  final String jumpDetectionMode;
  final SessionPendingJumpCandidate? pendingCandidate;
  final DateTime? lastJumpRecordedAt;
  final DateTime now;
  final double currentSpeedKnots;
  final double accelerationG;
  final double jumpMinTakeoffSpeedKnots;
  final double jumpMinManeuverG;
  final double jumpMinManeuverRotationDegPerSec;
  final Duration jumpCooldown;
  final Duration jumpMinAirTime;
  final Duration jumpMaxAirTime;
  final double jumpLandingThresholdG;
  final double jumpLandingMinSpeedKnots;
}

class SessionJumpDetectionRotationInput {
  const SessionJumpDetectionRotationInput({
    required this.jumpDetectionMode,
    required this.pendingCandidate,
    required this.lastJumpRecordedAt,
    required this.now,
    required this.currentSpeedKnots,
    required this.rotationDegPerSec,
    required this.jumpMinTakeoffSpeedKnots,
    required this.jumpMinManeuverG,
    required this.jumpMinManeuverRotationDegPerSec,
    required this.jumpCooldown,
    required this.jumpMaxAirTime,
  });

  final String jumpDetectionMode;
  final SessionPendingJumpCandidate? pendingCandidate;
  final DateTime? lastJumpRecordedAt;
  final DateTime now;
  final double currentSpeedKnots;
  final double rotationDegPerSec;
  final double jumpMinTakeoffSpeedKnots;
  final double jumpMinManeuverG;
  final double jumpMinManeuverRotationDegPerSec;
  final Duration jumpCooldown;
  final Duration jumpMaxAirTime;
}

class SessionApplyJumpFinalizeInput {
  const SessionApplyJumpFinalizeInput({
    required this.pendingCandidate,
    required this.recordingStartedAt,
    required this.landedAt,
    required this.landingG,
    required this.landingSpeedKnots,
    required this.nextJumpIndex,
    required this.jumpMinAirTime,
    required this.jumpMinManeuverG,
    required this.jumpMinManeuverRotationDegPerSec,
    required this.currentJumpHistory,
  });

  final SessionPendingJumpCandidate? pendingCandidate;
  final DateTime? recordingStartedAt;
  final DateTime landedAt;
  final double landingG;
  final double landingSpeedKnots;
  final int nextJumpIndex;
  final Duration jumpMinAirTime;
  final double jumpMinManeuverG;
  final double jumpMinManeuverRotationDegPerSec;
  final List<SessionJumpRecord> currentJumpHistory;
}

class SessionApplyJumpFinalizeResult {
  const SessionApplyJumpFinalizeResult({
    required this.updatedJumpHistory,
    required this.lastJumpRecordedAt,
    required this.pendingCandidate,
  });

  final List<SessionJumpRecord> updatedJumpHistory;
  final DateTime? lastJumpRecordedAt;
  final SessionPendingJumpCandidate? pendingCandidate;
}

class SessionTrackDerivedMetricsInput {
  const SessionTrackDerivedMetricsInput({
    required this.samples,
    required this.recordingDistanceMeters,
    required this.recordingMaxSpeedKnots,
    required this.rawPositionCount,
    required this.rejectedAccuracyCount,
    required this.rejectedPlausibilityCount,
  });

  final List<SessionCaptureSample> samples;
  final double recordingDistanceMeters;
  final double recordingMaxSpeedKnots;
  final int rawPositionCount;
  final int rejectedAccuracyCount;
  final int rejectedPlausibilityCount;
}

class SessionTrackDerivedMetricsResult {
  const SessionTrackDerivedMetricsResult({
    required this.netDisplacementKm,
    required this.coverageAreaKm2,
    required this.maxDistanceFromStartKm,
    required this.timeInRiskZone,
    required this.sweetspotPercent,
    required this.directionalStabilityPercent,
    required this.routeEfficiencyPercent,
    required this.averageSampleIntervalSeconds,
    required this.lostSamplesPercent,
    required this.datasetHealthPercent,
  });

  final double netDisplacementKm;
  final double coverageAreaKm2;
  final double maxDistanceFromStartKm;
  final Duration timeInRiskZone;
  final double sweetspotPercent;
  final double directionalStabilityPercent;
  final double routeEfficiencyPercent;
  final double averageSampleIntervalSeconds;
  final double lostSamplesPercent;
  final double datasetHealthPercent;
}

class SessionTrackTransitionSummary {
  const SessionTrackTransitionSummary({
    required this.count,
    required this.qualityPercent,
    required this.avgSpeedLossKnots,
    required this.avgRecoverySeconds,
  });

  const SessionTrackTransitionSummary.empty()
    : count = 0,
      qualityPercent = 0,
      avgSpeedLossKnots = 0,
      avgRecoverySeconds = 0;

  final int count;
  final double qualityPercent;
  final double avgSpeedLossKnots;
  final double avgRecoverySeconds;
}

class StartSessionSaveConfigData {
  const StartSessionSaveConfigData({
    required this.spot,
    required this.notes,
    required this.sessionMediaLabel,
    this.sessionPhotoLocalPath,
    this.gearSetupId,
    this.gearSetupName,
  });

  final String spot;
  final String notes;
  final String sessionMediaLabel;
  final String? sessionPhotoLocalPath;
  final String? gearSetupId;
  final String? gearSetupName;
}

class SessionRecordedMetricsSummaryInput {
  const SessionRecordedMetricsSummaryInput({
    required this.samples,
    required this.timelineKnots,
    required this.jumpHistory,
    required this.duration,
    required this.autoPausedDuration,
    required this.movingDuration,
    required this.recordingDistanceMeters,
    required this.recordingMaxSpeedKnots,
    required this.rawPositionCount,
    required this.rejectedAccuracyCount,
    required this.rejectedPlausibilityCount,
    required this.lastGpsAccuracyMeters,
    required this.accelerationEventCount,
    required this.rotationEventCount,
    required this.autoPauseCount,
    required this.movingAverageMinSpeedKnots,
  });

  final List<SessionCaptureSample> samples;
  final List<double> timelineKnots;
  final List<SessionJumpRecord> jumpHistory;
  final Duration duration;
  final Duration autoPausedDuration;
  final Duration movingDuration;
  final double recordingDistanceMeters;
  final double recordingMaxSpeedKnots;
  final int rawPositionCount;
  final int rejectedAccuracyCount;
  final int rejectedPlausibilityCount;
  final double? lastGpsAccuracyMeters;
  final int accelerationEventCount;
  final int rotationEventCount;
  final int autoPauseCount;
  final double movingAverageMinSpeedKnots;
}

class SessionRecordedMetricsSummaryResult {
  const SessionRecordedMetricsSummaryResult({
    required this.distanceKm,
    required this.avgSpeedKnots,
    required this.movingAvgSpeedKnots,
    required this.planingMinutes,
    required this.jumpsCount,
    required this.maxJumpHeightMeters,
    required this.maxHangtimeSeconds,
    required this.measuredValues,
  });

  final double distanceKm;
  final double avgSpeedKnots;
  final double movingAvgSpeedKnots;
  final int? planingMinutes;
  final int jumpsCount;
  final double? maxJumpHeightMeters;
  final double? maxHangtimeSeconds;
  final Map<String, String> measuredValues;
}

class RecordedSessionBuilderInput {
  const RecordedSessionBuilderInput({
    required this.id,
    required this.title,
    required this.deviceName,
    required this.deviceKind,
    required this.deviceSensorKeys,
    required this.jumpDetectionMode,
    required this.endedAt,
    required this.duration,
    required this.config,
    required this.distanceKm,
    required this.maxSpeedKnots,
    required this.avgSpeedKnots,
    required this.movingAvgSpeedKnots,
    required this.planingMinutes,
    required this.recordedPointCount,
    required this.autoPauseCount,
    required this.accelerationEventCount,
    required this.rotationEventCount,
    required this.maxRotationDegPerSec,
    required this.jumpsCount,
    required this.maxJumpHeightMeters,
    required this.maxHangtimeSeconds,
    required this.jumpHistory,
    required this.timelineKnots,
    required this.routePoints,
    required this.eventPointCount,
    required this.eventMaxSpeedKnots,
    required this.measuredValues,
  });

  final String id;
  final String title;
  final String deviceName;
  final String deviceKind;
  final List<String> deviceSensorKeys;
  final String jumpDetectionMode;
  final DateTime endedAt;
  final Duration duration;
  final StartSessionSaveConfigData config;
  final double? distanceKm;
  final double? maxSpeedKnots;
  final double? avgSpeedKnots;
  final double? movingAvgSpeedKnots;
  final int? planingMinutes;
  final int recordedPointCount;
  final int autoPauseCount;
  final int accelerationEventCount;
  final int rotationEventCount;
  final double? maxRotationDegPerSec;
  final int? jumpsCount;
  final double? maxJumpHeightMeters;
  final double? maxHangtimeSeconds;
  final List<SessionJumpRecord> jumpHistory;
  final List<double> timelineKnots;
  final List<SessionTrackPoint> routePoints;
  final int eventPointCount;
  final double eventMaxSpeedKnots;
  final Map<String, String> measuredValues;
}

class ImportedRecordedSessionBuilderInput {
  const ImportedRecordedSessionBuilderInput({
    required this.id,
    required this.deviceName,
    required this.deviceKind,
    required this.imported,
    required this.config,
  });

  final String id;
  final String deviceName;
  final String deviceKind;
  final SessionImportedPendingResult imported;
  final StartSessionSaveConfigData config;
}

class EditedRecordedSessionBuilderInput {
  const EditedRecordedSessionBuilderInput({
    required this.baseSession,
    required this.notes,
    required this.mediaSelection,
    required this.sessionPhotoLocalPath,
    required this.gearSetupId,
    required this.gearSetupName,
    required this.sessionMediaLabel,
  });

  final RecordedSession baseSession;
  final String notes;
  final SessionMediaSelection mediaSelection;
  final String? sessionPhotoLocalPath;
  final String? gearSetupId;
  final String? gearSetupName;
  final String sessionMediaLabel;
}
