import 'package:flutter/material.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class StartSessionPresentationMapper {
  const StartSessionPresentationMapper._();

  static const StartSessionPageData pageData = StartSessionPageData(
    description:
        'Elige el dispositivo con el que quieres grabar y prepara la sesion.',
  );

  static StartSessionPanelData buildPanelData({
    required String captureStatusText,
    String? importHintText,
  }) {
    return StartSessionPanelData(
      captureStatusText: captureStatusText,
      importHintText: importHintText,
    );
  }

  static SessionCaptureControlDecision resolveCaptureControlDecision({
    required SessionCapturePhase phase,
    required bool hasSelectedDevice,
    required bool isPhoneDeviceSelected,
  }) {
    switch (phase) {
      case SessionCapturePhase.ready:
        if (!hasSelectedDevice) {
          return const SessionCaptureControlDecision(
            action: SessionCaptureControlAction.showMessage,
            message: 'Selecciona un dispositivo primero.',
          );
        }
        if (!isPhoneDeviceSelected) {
          return const SessionCaptureControlDecision(
            action: SessionCaptureControlAction.showMessage,
            message: 'Este dispositivo aun no puede grabar sesiones.',
          );
        }
        return const SessionCaptureControlDecision(
          action: SessionCaptureControlAction.startRecording,
        );
      case SessionCapturePhase.recording:
        return const SessionCaptureControlDecision(
          action: SessionCaptureControlAction.confirmStopRecording,
        );
      case SessionCapturePhase.finished:
        return const SessionCaptureControlDecision(
          action: SessionCaptureControlAction.showSaveDialog,
        );
      case SessionCapturePhase.synced:
        return const SessionCaptureControlDecision(
          action: SessionCaptureControlAction.resetToReady,
        );
      case SessionCapturePhase.syncing:
        return const SessionCaptureControlDecision(
          action: SessionCaptureControlAction.none,
        );
    }
  }

  static SessionStopCaptureDecision resolveStopCaptureDecision({
    required bool hasEnoughRecordedTrackForSave,
  }) {
    if (!hasEnoughRecordedTrackForSave) {
      return const SessionStopCaptureDecision(
        action: SessionStopCaptureAction.discardAndReset,
        message:
            'No hemos podido registrar suficiente track GPS. Necesitamos 2 puntos válidos, 1 minuto y 20 metros.',
      );
    }

    return const SessionStopCaptureDecision(
      action: SessionStopCaptureAction.markFinished,
    );
  }

  static String buildCaptureStatusText(SessionCapturePresentationInput input) {
    switch (input.phase) {
      case SessionCapturePhase.ready:
        if (!input.hasSelectedDevice) {
          return 'Selecciona un dispositivo para empezar.';
        }
        return input.isPhoneDeviceSelected
            ? 'Listo para grabar con el telefono.'
            : 'Este dispositivo aun no puede grabar sesiones.';
      case SessionCapturePhase.recording:
        if (input.isAutoPaused) {
          return 'Sesion en pausa automatica. Esperando movimiento.';
        }
        if (input.isAutoPausePending) {
          return 'Auto-pausa pendiente por baja actividad.';
        }
        return 'Grabando recorrido y velocidad por GPS.';
      case SessionCapturePhase.finished:
        return 'Sesion finalizada. Revisa los datos y guardala.';
      case SessionCapturePhase.syncing:
        return 'Guardando sesion...';
      case SessionCapturePhase.synced:
        return 'Sesion guardada.';
    }
  }

  static List<SessionDeviceSelectorItemData> buildDeviceSelectorItems({
    required List<LinkedDevice> devices,
  }) {
    return devices
        .map(
          (device) => SessionDeviceSelectorItemData(
            id: device.id,
            label: '${device.name} · ${device.kind}',
          ),
        )
        .toList(growable: false);
  }

  static SessionSelectedDeviceCardData buildSelectedDeviceCardData({
    required LinkedDevice selectedDevice,
    required IconData capabilitiesIcon,
    required String statusLabel,
    required Color statusColor,
    required String availabilityLabel,
    required String sensorCountLabel,
    required bool isPhoneDeviceSelected,
  }) {
    return SessionSelectedDeviceCardData(
      name: selectedDevice.name,
      kind: selectedDevice.kind,
      capabilitiesIcon: capabilitiesIcon,
      statusLabel: statusLabel,
      statusColor: statusColor,
      availabilityLabel: availabilityLabel,
      sensorCountLabel: sensorCountLabel,
      isPhoneDeviceSelected: isPhoneDeviceSelected,
    );
  }

  static SessionCaptureStatusCardData buildCaptureStatusCardData({
    required SessionCapturePresentationInput input,
    required ColorScheme colorScheme,
  }) {
    final isRecording = input.phase == SessionCapturePhase.recording;
    final isRecordingOrFinished =
        input.phase == SessionCapturePhase.recording ||
        input.phase == SessionCapturePhase.finished;
    final autoPauseLabel = !isRecording
        ? 'Auto-pausa lista'
        : input.isAutoPaused
        ? 'Auto-pausa ON'
        : input.isAutoPausePending
        ? 'Auto-pausa pendiente · ${input.autoPauseRemainingSeconds}s'
        : 'Auto-pausa OFF';
    final autoPauseBackgroundColor = !isRecording
        ? colorScheme.surfaceContainerHighest
        : input.isAutoPaused
        ? const Color(0x1F1565C0)
        : input.isAutoPausePending
        ? const Color(0x1FF57C00)
        : colorScheme.surfaceContainerHighest;
    final autoPauseForegroundColor = !isRecording
        ? colorScheme.onSurfaceVariant
        : input.isAutoPaused
        ? const Color(0xFF1565C0)
        : input.isAutoPausePending
        ? const Color(0xFFEF6C00)
        : colorScheme.onSurfaceVariant;
    final autoPauseIcon = input.isAutoPaused
        ? Icons.pause_circle_filled_rounded
        : input.isAutoPausePending
        ? Icons.hourglass_bottom_rounded
        : Icons.play_circle_outline_rounded;
    final saveReadinessLabel = !isRecordingOrFinished
        ? 'Guardado pendiente'
        : input.hasEnoughRecordedTrackForSave
        ? 'Guardable · 3/3'
        : 'Guardable · ${input.saveReadinessSatisfiedRuleCount}/3';
    final saveReadinessBackgroundColor = !isRecordingOrFinished
        ? colorScheme.surfaceContainerHighest
        : input.hasEnoughRecordedTrackForSave
        ? const Color(0x1F2E7D32)
        : input.saveReadinessSatisfiedRuleCount > 0
        ? const Color(0x1FFF8F00)
        : colorScheme.surfaceContainerHighest;
    final saveReadinessForegroundColor = !isRecordingOrFinished
        ? colorScheme.onSurfaceVariant
        : input.hasEnoughRecordedTrackForSave
        ? const Color(0xFF2E7D32)
        : input.saveReadinessSatisfiedRuleCount > 0
        ? const Color(0xFFEF6C00)
        : colorScheme.onSurfaceVariant;
    final saveReadinessIcon = !isRecordingOrFinished
        ? Icons.save_outlined
        : input.hasEnoughRecordedTrackForSave
        ? Icons.check_circle_rounded
        : input.saveReadinessSatisfiedRuleCount > 0
        ? Icons.timelapse_rounded
        : Icons.hourglass_empty_rounded;
    final actionLabel = switch (input.phase) {
      SessionCapturePhase.ready => 'Iniciar sesion',
      SessionCapturePhase.recording => 'Detener sesion',
      SessionCapturePhase.finished => 'Guardar sesion',
      SessionCapturePhase.syncing => 'Guardando...',
      SessionCapturePhase.synced => 'Nueva sesion',
    };
    final actionIcon = switch (input.phase) {
      SessionCapturePhase.ready => Icons.play_circle_fill_rounded,
      SessionCapturePhase.recording => Icons.stop_circle_rounded,
      SessionCapturePhase.finished => Icons.sync_rounded,
      SessionCapturePhase.syncing => Icons.sync,
      SessionCapturePhase.synced => Icons.replay_rounded,
    };
    return SessionCaptureStatusCardData(
      statusText: buildCaptureStatusText(input),
      stepProgress:
          (switch (input.phase) {
                SessionCapturePhase.ready => 0,
                SessionCapturePhase.recording => 1,
                SessionCapturePhase.finished => 2,
                SessionCapturePhase.syncing => 3,
                SessionCapturePhase.synced => 4,
              } +
              1) /
          5,
      elapsedLabel: input.elapsedLabel,
      lastJumpLabel: input.lastJumpLabel,
      autoPauseLabel: autoPauseLabel,
      autoPauseBackgroundColor: autoPauseBackgroundColor,
      autoPauseForegroundColor: autoPauseForegroundColor,
      autoPauseIcon: autoPauseIcon,
      currentSpeedLabel: input.currentSpeedLabel,
      maxSpeedLabel: input.maxSpeedLabel,
      activeLabel: input.activeLabel,
      pausedLabel: input.pausedLabel,
      saveReadinessLabel: saveReadinessLabel,
      saveReadinessBackgroundColor: saveReadinessBackgroundColor,
      saveReadinessForegroundColor: saveReadinessForegroundColor,
      saveReadinessIcon: saveReadinessIcon,
      actionLabel: actionLabel,
      actionIcon: actionIcon,
      actionEnabled: input.phase != SessionCapturePhase.syncing,
    );
  }
}
