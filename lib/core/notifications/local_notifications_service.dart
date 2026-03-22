import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  LocalNotificationsService._();

  static final LocalNotificationsService instance =
      LocalNotificationsService._();

  static const AndroidNotificationChannel _alarmChannel =
      AndroidNotificationChannel(
        'spot_alarms',
        'Alarmas de spots',
        description:
            'Alertas locales cuando el live cumple una alarma guardada.',
        importance: Importance.high,
      );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_alarmChannel);
    _initialized = true;
  }

  Future<bool> ensurePermissions() async {
    await initialize();

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidGranted = await androidPlugin
        ?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosGranted = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final macPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    final macGranted = await macPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    final grantedValues = <bool?>[
      androidGranted,
      iosGranted,
      macGranted,
    ].whereType<bool>().toList(growable: false);
    if (grantedValues.isEmpty) {
      return true;
    }
    return grantedValues.any((value) => value);
  }

  Future<void> showSpotAlarm({
    required int notificationId,
    required String title,
    required String body,
  }) async {
    await initialize();
    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'spot_alarms',
          'Alarmas de spots',
          channelDescription:
              'Alertas locales cuando el live cumple una alarma guardada.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
        macOS: DarwinNotificationDetails(),
      ),
    );
  }

  int notificationIdForAlarm(String alarmId) {
    return alarmId.hashCode & 0x7fffffff;
  }

  @visibleForTesting
  FlutterLocalNotificationsPlugin get plugin => _plugin;
}
