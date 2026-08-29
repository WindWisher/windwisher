import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/notifications/notification_permission_service.dart';
import 'package:windwisher/features/profile/presentation/pages/settings/notifications/notifications_settings_section.dart';

void main() {
  testWidgets('shows an active device without exposing technical data', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        enabled: true,
        permission: NotificationPermissionState.granted,
        syncStatus: PushSubscriptionSyncStatus.synced,
      ),
    );

    expect(find.text('Activas'), findsOneWidget);
    expect(
      find.text('Este dispositivo esta preparado para recibir avisos.'),
      findsNothing,
    );
    expect(find.textContaining('Token:'), findsNothing);
    expect(find.textContaining('provider'), findsNothing);
  });

  testWidgets('offers system settings when permission is blocked', (
    tester,
  ) async {
    var openedSettings = false;
    await tester.pumpWidget(
      _testApp(
        enabled: false,
        permission: NotificationPermissionState.permanentlyDenied,
        syncStatus: PushSubscriptionSyncStatus.disabled,
        onOpenSystemSettings: () => openedSettings = true,
      ),
    );

    expect(find.text('Bloqueadas por el sistema'), findsOneWidget);
    expect(
      find.textContaining('Habilita el permiso en los ajustes'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('open_notification_settings')));
    expect(openedSettings, isTrue);
  });

  testWidgets('offers retry while device registration is pending', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      _testApp(
        enabled: true,
        permission: NotificationPermissionState.granted,
        syncStatus: PushSubscriptionSyncStatus.missingDeviceToken,
        onRetry: () => retried = true,
      ),
    );

    expect(find.text('Registro pendiente'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('retry_notification_registration')),
    );
    expect(retried, isTrue);
  });

  testWidgets('disables the switch on unsupported platforms', (tester) async {
    await tester.pumpWidget(
      _testApp(
        enabled: false,
        permission: NotificationPermissionState.unsupported,
        syncStatus: PushSubscriptionSyncStatus.providerNotConfigured,
      ),
    );

    final toggle = tester.widget<SwitchListTile>(
      find.byKey(const ValueKey('notifications_enabled_switch')),
    );
    expect(toggle.onChanged, isNull);
    expect(find.text('No disponibles'), findsOneWidget);
  });

  testWidgets('expands category controls and updates one preference', (
    tester,
  ) async {
    bool? alarmsEnabled;
    await tester.pumpWidget(
      _testApp(
        enabled: true,
        permission: NotificationPermissionState.granted,
        syncStatus: PushSubscriptionSyncStatus.synced,
        onSpotAlarmsChanged: (value) => alarmsEnabled = value,
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('notification_categories_expansion')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Alarmas de viento'), findsOneWidget);
    expect(find.text('Mensajes directos'), findsOneWidget);
    expect(find.text('Menciones en chats de spots'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('spot_alarms_notification_toggle')),
    );
    expect(alarmsEnabled, isFalse);
  });

  testWidgets('keeps category controls read-only while master is disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        enabled: false,
        permission: NotificationPermissionState.granted,
        syncStatus: PushSubscriptionSyncStatus.disabled,
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('notification_categories_expansion')),
    );
    await tester.pumpAndSettle();

    final toggle = tester.widget<SwitchListTile>(
      find.descendant(
        of: find.byKey(const ValueKey('direct_messages_notification_toggle')),
        matching: find.byType(SwitchListTile),
      ),
    );
    expect(toggle.value, isTrue);
    expect(toggle.onChanged, isNull);
  });
}

Widget _testApp({
  required bool enabled,
  required NotificationPermissionState permission,
  required PushSubscriptionSyncStatus syncStatus,
  VoidCallback? onOpenSystemSettings,
  VoidCallback? onRetry,
  ValueChanged<bool>? onSpotAlarmsChanged,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: NotificationsSettingsSection(
          notificationsEnabled: enabled,
          permissionState: permission,
          syncStatus: syncStatus,
          remoteProviderConfigured: true,
          isBusy: false,
          onNotificationsChanged: (_) {},
          spotAlarmsEnabled: true,
          directMessagesEnabled: true,
          spotChatMentionsEnabled: true,
          onSpotAlarmsChanged: onSpotAlarmsChanged ?? (_) {},
          onDirectMessagesChanged: (_) {},
          onSpotChatMentionsChanged: (_) {},
          onOpenSystemSettings: onOpenSystemSettings ?? () {},
          onRetry: onRetry ?? () {},
        ),
      ),
    ),
  );
}
