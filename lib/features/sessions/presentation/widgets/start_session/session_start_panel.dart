import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_capture_status_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_device_selector_field.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_file_import_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_selected_device_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_synced_pending_card.dart';

class SessionStartPanel extends StatelessWidget {
  const SessionStartPanel({
    super.key,
    required this.data,
    required this.devices,
    required this.selectedDeviceId,
    required this.onDeviceChanged,
    required this.selectedDeviceCard,
    required this.syncedPendingCard,
    required this.captureStatusCard,
    required this.onImportPressed,
  });

  final StartSessionPanelData data;
  final List<SessionDeviceSelectorItemData> devices;
  final String? selectedDeviceId;
  final ValueChanged<String> onDeviceChanged;
  final SessionSelectedDeviceCard? selectedDeviceCard;
  final SessionSyncedPendingCard? syncedPendingCard;
  final SessionCaptureStatusCard captureStatusCard;
  final VoidCallback onImportPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Dispositivos vinculados',
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        if (devices.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('No hay dispositivos vinculados todavia.'),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SessionDeviceSelectorField(
                selectedDeviceId: selectedDeviceId,
                devices: devices,
                onChanged: onDeviceChanged,
              ),
              if (selectedDeviceCard != null) ...[
                const SizedBox(height: AppSpacing.xs),
                selectedDeviceCard!,
              ],
              if (syncedPendingCard != null) ...[
                const SizedBox(height: AppSpacing.xs),
                syncedPendingCard!,
              ],
            ],
          ),
        const SizedBox(height: AppSpacing.sm),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Captura de sesion',
                  style: textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  data.captureStatusText,
                  style: textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                captureStatusCard,
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SessionFileImportCard(
          onImportPressed: onImportPressed,
          hintText: data.importHintText,
        ),
      ],
    );
  }
}
