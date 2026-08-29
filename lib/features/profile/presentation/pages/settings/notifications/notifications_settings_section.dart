import 'package:flutter/material.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/notifications/notification_permission_service.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/widgets/settings_section_card.dart';

class NotificationsSettingsSection extends StatelessWidget {
  const NotificationsSettingsSection({
    super.key,
    required this.notificationsEnabled,
    required this.permissionState,
    required this.syncStatus,
    required this.remoteProviderConfigured,
    required this.isBusy,
    required this.onNotificationsChanged,
    required this.spotAlarmsEnabled,
    required this.directMessagesEnabled,
    required this.spotChatMentionsEnabled,
    required this.onSpotAlarmsChanged,
    required this.onDirectMessagesChanged,
    required this.onSpotChatMentionsChanged,
    required this.onOpenSystemSettings,
    required this.onRetry,
  });

  final bool notificationsEnabled;
  final NotificationPermissionState permissionState;
  final PushSubscriptionSyncStatus syncStatus;
  final bool remoteProviderConfigured;
  final bool isBusy;
  final ValueChanged<bool> onNotificationsChanged;
  final bool spotAlarmsEnabled;
  final bool directMessagesEnabled;
  final bool spotChatMentionsEnabled;
  final ValueChanged<bool> onSpotAlarmsChanged;
  final ValueChanged<bool> onDirectMessagesChanged;
  final ValueChanged<bool> onSpotChatMentionsChanged;
  final VoidCallback onOpenSystemSettings;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final presentation = NotificationStatusPresentation.resolve(
      enabled: notificationsEnabled,
      permissionState: permissionState,
      syncStatus: syncStatus,
      remoteProviderConfigured: remoteProviderConfigured,
    );
    final colors = Theme.of(context).colorScheme;

    return SettingsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_outlined, color: colors.primary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Notificaciones',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _StatusBadge(presentation: presentation),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SwitchListTile(
            key: const ValueKey('notifications_enabled_switch'),
            contentPadding: EdgeInsets.zero,
            title: const Text('Avisos en este dispositivo'),
            subtitle: const Text(
              'Alarmas de viento, mensajes y actividad importante.',
            ),
            value: notificationsEnabled,
            onChanged:
                isBusy ||
                    permissionState == NotificationPermissionState.unsupported
                ? null
                : onNotificationsChanged,
          ),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: const ValueKey('notification_categories_expansion'),
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              leading: const Icon(Icons.tune),
              title: const Text('Personalizar avisos'),
              subtitle: const Text('Elige que notificaciones quieres recibir.'),
              children: [
                _NotificationCategoryTile(
                  key: const ValueKey('spot_alarms_notification_toggle'),
                  icon: Icons.air,
                  title: 'Alarmas de viento',
                  subtitle: 'Avisos cuando se cumplan tus condiciones.',
                  value: spotAlarmsEnabled,
                  onChanged: _categoryCallback(onSpotAlarmsChanged),
                ),
                _NotificationCategoryTile(
                  key: const ValueKey('direct_messages_notification_toggle'),
                  icon: Icons.forum_outlined,
                  title: 'Mensajes directos',
                  subtitle: 'Nuevos mensajes privados de otros usuarios.',
                  value: directMessagesEnabled,
                  onChanged: _categoryCallback(onDirectMessagesChanged),
                ),
                _NotificationCategoryTile(
                  key: const ValueKey('spot_mentions_notification_toggle'),
                  icon: Icons.alternate_email,
                  title: 'Menciones en chats de spots',
                  subtitle: 'Avisos cuando alguien te mencione en un spot.',
                  value: spotChatMentionsEnabled,
                  onChanged: _categoryCallback(onSpotChatMentionsChanged),
                ),
              ],
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: isBusy || presentation.showDetails
                ? Container(
                    key: ValueKey(presentation.title),
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: presentation.color(colors).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isBusy)
                          const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            presentation.icon,
                            size: 20,
                            color: presentation.color(colors),
                          ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            isBusy
                                ? 'Actualizando la configuracion...'
                                : presentation.description,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(
                    key: ValueKey('notification_status_details_hidden'),
                  ),
          ),
          if (presentation.showOpenSettings || presentation.showRetry) ...[
            const SizedBox(height: AppSpacing.xs),
            Align(
              alignment: Alignment.centerRight,
              child: presentation.showOpenSettings
                  ? TextButton.icon(
                      key: const ValueKey('open_notification_settings'),
                      onPressed: isBusy ? null : onOpenSystemSettings,
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('Abrir ajustes del dispositivo'),
                    )
                  : TextButton.icon(
                      key: const ValueKey('retry_notification_registration'),
                      onPressed: isBusy ? null : onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
            ),
          ],
        ],
      ),
    );
  }

  ValueChanged<bool>? _categoryCallback(ValueChanged<bool> callback) {
    if (isBusy || !notificationsEnabled) {
      return null;
    }
    return callback;
  }
}

class _NotificationCategoryTile extends StatelessWidget {
  const _NotificationCategoryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.only(left: AppSpacing.sm),
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

enum NotificationStatusTone { success, neutral, warning, error }

class NotificationStatusPresentation {
  const NotificationStatusPresentation({
    required this.title,
    required this.description,
    required this.icon,
    required this.tone,
    this.showOpenSettings = false,
    this.showRetry = false,
    this.showDetails = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final NotificationStatusTone tone;
  final bool showOpenSettings;
  final bool showRetry;
  final bool showDetails;

  static NotificationStatusPresentation resolve({
    required bool enabled,
    required NotificationPermissionState permissionState,
    required PushSubscriptionSyncStatus syncStatus,
    required bool remoteProviderConfigured,
  }) {
    if (permissionState == NotificationPermissionState.unsupported) {
      return const NotificationStatusPresentation(
        title: 'No disponibles',
        description:
            'Las notificaciones push no estan disponibles en esta version.',
        icon: Icons.info_outline,
        tone: NotificationStatusTone.neutral,
        showDetails: true,
      );
    }
    if (permissionState == NotificationPermissionState.permanentlyDenied ||
        permissionState == NotificationPermissionState.restricted) {
      return const NotificationStatusPresentation(
        title: 'Bloqueadas por el sistema',
        description:
            'Habilita el permiso en los ajustes del dispositivo para recibir avisos.',
        icon: Icons.notifications_off_outlined,
        tone: NotificationStatusTone.error,
        showOpenSettings: true,
        showDetails: true,
      );
    }
    if (!enabled) {
      return NotificationStatusPresentation(
        title: permissionState == NotificationPermissionState.denied
            ? 'Permiso pendiente'
            : 'Desactivadas',
        description: permissionState == NotificationPermissionState.denied
            ? 'Activa el interruptor cuando quieras conceder el permiso.'
            : 'No enviaremos avisos a este dispositivo.',
        icon: Icons.notifications_none,
        tone: NotificationStatusTone.neutral,
      );
    }
    if (permissionState == NotificationPermissionState.unknown) {
      return const NotificationStatusPresentation(
        title: 'Comprobando permiso',
        description: 'Estamos revisando la configuracion del dispositivo.',
        icon: Icons.hourglass_top,
        tone: NotificationStatusTone.neutral,
        showDetails: true,
      );
    }
    if (permissionState != NotificationPermissionState.granted) {
      return const NotificationStatusPresentation(
        title: 'Permiso necesario',
        description: 'Concede el permiso para poder recibir avisos.',
        icon: Icons.notification_important_outlined,
        tone: NotificationStatusTone.warning,
        showDetails: true,
      );
    }
    if (!remoteProviderConfigured ||
        syncStatus == PushSubscriptionSyncStatus.providerNotConfigured) {
      return const NotificationStatusPresentation(
        title: 'Servicio no disponible',
        description:
            'No hemos podido conectar el servicio. Puedes intentarlo de nuevo.',
        icon: Icons.cloud_off_outlined,
        tone: NotificationStatusTone.warning,
        showRetry: true,
        showDetails: true,
      );
    }
    if (syncStatus == PushSubscriptionSyncStatus.missingDeviceToken) {
      return const NotificationStatusPresentation(
        title: 'Registro pendiente',
        description: 'Estamos terminando de registrar este dispositivo.',
        icon: Icons.sync,
        tone: NotificationStatusTone.warning,
        showRetry: true,
        showDetails: true,
      );
    }
    if (syncStatus == PushSubscriptionSyncStatus.unauthenticated) {
      return const NotificationStatusPresentation(
        title: 'Sesion necesaria',
        description: 'Inicia sesion para recibir tus alarmas y mensajes.',
        icon: Icons.person_outline,
        tone: NotificationStatusTone.warning,
        showDetails: true,
      );
    }
    return const NotificationStatusPresentation(
      title: 'Activas',
      description: 'Este dispositivo esta preparado para recibir avisos.',
      icon: Icons.check_circle_outline,
      tone: NotificationStatusTone.success,
    );
  }

  Color color(ColorScheme colors) {
    switch (tone) {
      case NotificationStatusTone.success:
        return Colors.green.shade700;
      case NotificationStatusTone.neutral:
        return colors.onSurfaceVariant;
      case NotificationStatusTone.warning:
        return Colors.orange.shade800;
      case NotificationStatusTone.error:
        return colors.error;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.presentation});

  final NotificationStatusPresentation presentation;

  @override
  Widget build(BuildContext context) {
    final color = presentation.color(Theme.of(context).colorScheme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        presentation.title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
