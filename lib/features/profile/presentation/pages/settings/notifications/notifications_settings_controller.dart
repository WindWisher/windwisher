import 'package:windwisher/core/notifications/firebase_push_messaging_service.dart';
import 'package:windwisher/core/notifications/local_notifications_service.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/core/notifications/push_notification_preferences.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/notifications/notification_permission_service.dart';

class NotificationsSettingsToggleResult {
  const NotificationsSettingsToggleResult({
    required this.enabled,
    required this.status,
    required this.permissionState,
    required this.message,
  });

  final bool enabled;
  final PushSubscriptionSyncStatus status;
  final NotificationPermissionState permissionState;
  final String message;
}

class NotificationsSettingsController {
  const NotificationsSettingsController._();

  static const permissionService = NotificationPermissionService();

  static Future<NotificationsSettingsToggleResult> setEnabled(
    bool newValue, {
    required String? pushInitError,
  }) async {
    var permissionState = await permissionService.currentState();
    if (newValue) {
      if (permissionState != NotificationPermissionState.granted) {
        permissionState = await permissionService.request();
      }
      if (permissionState != NotificationPermissionState.granted) {
        final status = await PushNotificationSubscriptionService.instance
            .setEnabled(false);
        return NotificationsSettingsToggleResult(
          enabled: false,
          status: status,
          permissionState: permissionState,
          message:
              permissionState == NotificationPermissionState.permanentlyDenied
              ? 'Las notificaciones estan bloqueadas. Puedes habilitarlas desde los ajustes del dispositivo.'
              : 'Necesitamos tu permiso para enviarte alarmas y mensajes.',
        );
      }
      await FirebasePushMessagingService.instance.refreshDeviceRegistration();
    } else {
      await LocalNotificationsService.instance.cancelAllNotifications();
    }

    final status = await PushNotificationSubscriptionService.instance
        .setEnabled(newValue);

    return NotificationsSettingsToggleResult(
      enabled: newValue,
      status: status,
      permissionState: permissionState,
      message: _messageForStatus(status, pushInitError: pushInitError),
    );
  }

  static Future<PushSubscriptionSyncStatus> setCategoryEnabled(
    PushNotificationCategory category,
    bool enabled,
  ) async {
    final status = await PushNotificationSubscriptionService.instance
        .setCategoryEnabled(category, enabled);
    if (!enabled) {
      switch (category) {
        case PushNotificationCategory.spotAlarms:
          await LocalNotificationsService.instance
              .cancelSpotAlarmNotifications();
        case PushNotificationCategory.directMessages:
          await LocalNotificationsService.instance
              .cancelDirectMessageNotifications();
        case PushNotificationCategory.spotChatMentions:
          await LocalNotificationsService.instance
              .cancelSpotChatNotifications();
      }
    }
    return status;
  }

  static String _messageForStatus(
    PushSubscriptionSyncStatus status, {
    required String? pushInitError,
  }) {
    switch (status) {
      case PushSubscriptionSyncStatus.synced:
        return 'Notificaciones activadas en este dispositivo.';
      case PushSubscriptionSyncStatus.disabled:
        return 'Notificaciones desactivadas en este dispositivo.';
      case PushSubscriptionSyncStatus.unauthenticated:
        return 'Inicia sesion para recibir notificaciones.';
      case PushSubscriptionSyncStatus.providerNotConfigured:
        return pushInitError == null || pushInitError.isEmpty
            ? 'El servicio de notificaciones no esta disponible ahora mismo.'
            : 'No se ha podido conectar el servicio de notificaciones.';
      case PushSubscriptionSyncStatus.missingDeviceToken:
        return 'Estamos terminando de registrar este dispositivo.';
    }
  }
}
