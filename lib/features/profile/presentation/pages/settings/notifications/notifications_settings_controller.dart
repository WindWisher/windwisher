import 'package:windwisher/core/notifications/firebase_push_messaging_service.dart';
import 'package:windwisher/core/notifications/local_notifications_service.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';

class NotificationsSettingsToggleResult {
  const NotificationsSettingsToggleResult({
    required this.enabled,
    required this.status,
    required this.message,
  });

  final bool enabled;
  final PushSubscriptionSyncStatus status;
  final String message;
}

class NotificationsSettingsController {
  const NotificationsSettingsController._();

  static String pushStatusLabel(PushSubscriptionSyncStatus status) {
    switch (status) {
      case PushSubscriptionSyncStatus.synced:
        return 'sincronizado';
      case PushSubscriptionSyncStatus.disabled:
        return 'desactivado';
      case PushSubscriptionSyncStatus.unauthenticated:
        return 'sin sesion';
      case PushSubscriptionSyncStatus.providerNotConfigured:
        return 'provider no configurado';
      case PushSubscriptionSyncStatus.missingDeviceToken:
        return 'sin token';
    }
  }

  static String obfuscatedToken(String token) {
    if (token.length <= 12) {
      return token;
    }
    return '${token.substring(0, 6)}...${token.substring(token.length - 6)}';
  }

  static Future<NotificationsSettingsToggleResult> setEnabled(
    bool newValue, {
    required String? pushInitError,
  }) async {
    if (newValue) {
      final permissionsGranted =
          await LocalNotificationsService.instance.ensurePermissions();
      if (!permissionsGranted) {
        return const NotificationsSettingsToggleResult(
          enabled: false,
          status: PushSubscriptionSyncStatus.disabled,
          message:
              'El sistema no ha concedido permisos de notificacion en este dispositivo.',
        );
      }
      await FirebasePushMessagingService.instance.refreshDeviceRegistration();
    }

    final status = await PushNotificationSubscriptionService.instance.setEnabled(
      newValue,
    );

    return NotificationsSettingsToggleResult(
      enabled: newValue,
      status: status,
      message: _messageForStatus(status, pushInitError: pushInitError),
    );
  }

  static String _messageForStatus(
    PushSubscriptionSyncStatus status, {
    required String? pushInitError,
  }) {
    switch (status) {
      case PushSubscriptionSyncStatus.synced:
        return 'Suscripcion push del dispositivo sincronizada.';
      case PushSubscriptionSyncStatus.disabled:
        return 'Notificaciones desactivadas en este dispositivo.';
      case PushSubscriptionSyncStatus.unauthenticated:
        return 'Inicia sesion para sincronizar alarmas push entre dispositivos.';
      case PushSubscriptionSyncStatus.providerNotConfigured:
        return pushInitError == null || pushInitError.isEmpty
            ? 'Push remotas pendientes de configurar en la app. De momento solo estan listas las notificaciones locales.'
            : 'No se ha podido inicializar el push remoto: $pushInitError';
      case PushSubscriptionSyncStatus.missingDeviceToken:
        return 'Proveedor push listo, pero este dispositivo aun no tiene token registrado.';
    }
  }
}
