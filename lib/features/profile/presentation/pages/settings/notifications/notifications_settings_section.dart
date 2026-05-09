import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';

class NotificationsSettingsSection extends StatelessWidget {
  const NotificationsSettingsSection({
    super.key,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.remoteProviderConfigured,
    required this.pushInitError,
    required this.pushStatusLabel,
    required this.pushTokenLabel,
  });

  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final bool remoteProviderConfigured;
  final String? pushInitError;
  final String pushStatusLabel;
  final String pushTokenLabel;

  @override
  Widget build(BuildContext context) {
    return SettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notificaciones',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Activar notificaciones'),
            value: notificationsEnabled,
            onChanged: onNotificationsChanged,
          ),
          if (!remoteProviderConfigured)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Push remoto no disponible en este dispositivo o build.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  if (pushInitError != null && pushInitError!.isNotEmpty)
                    Text(
                      'Detalle: $pushInitError',
                      style: const TextStyle(color: Colors.grey),
                    ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado push: $pushStatusLabel',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    pushTokenLabel,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
