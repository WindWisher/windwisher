import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

class LocalNotificationsService {
  LocalNotificationsService._();

  static const String _alarmChannelId = 'spot_alarms_v2';
  static const String _alarmCategoryId = 'spot_alarm_actions';
  static const String _stopActionId = 'stop_alarm';
  static const String _snoozeActionId = 'snooze_alarm';

  static final LocalNotificationsService instance =
      LocalNotificationsService._();

  static final AndroidNotificationChannel _alarmChannel =
      AndroidNotificationChannel(
        _alarmChannelId,
        'Alarmas de spots',
        description:
            'Alertas locales cuando el live cumple una alarma guardada.',
        importance: Importance.max,
        enableVibration: true,
        vibrationPattern: Int64List.fromList(<int>[0, 900, 300, 900]),
        audioAttributesUsage: AudioAttributesUsage.alarm,
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
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          _alarmCategoryId,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(_snoozeActionId, 'Posponer'),
            DarwinNotificationAction.plain(
              _stopActionId,
              'Parar',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
          ],
        ),
      ],
    );

    await _plugin.initialize(
        settings: InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_alarmChannel);
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchResponse = launchDetails?.notificationResponse;
    if (launchResponse != null) {
      await _handleNotificationResponse(launchResponse);
    }
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
    required String alarmId,
    required String title,
    required String body,
  }) async {
    await initialize();
    final payload = jsonEncode(<String, String>{
      'type': 'spot_alarm',
      'alarmId': alarmId,
    });
    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _alarmChannelId,
          'Alarmas de spots',
          channelDescription:
              'Alertas locales cuando el live cumple una alarma guardada.',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          autoCancel: false,
          ongoing: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          vibrationPattern: Int64List.fromList(<int>[0, 900, 300, 900]),
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              _snoozeActionId,
              'Posponer',
              showsUserInterface: true,
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              _stopActionId,
              'Parar',
              showsUserInterface: true,
              cancelNotification: true,
            ),
          ],
        ),
        iOS: const DarwinNotificationDetails(
          categoryIdentifier: _alarmCategoryId,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
        macOS: const DarwinNotificationDetails(
          categoryIdentifier: _alarmCategoryId,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      payload: payload,
    );
  }

  int notificationIdForAlarm(String alarmId) {
    return alarmId.hashCode & 0x7fffffff;
  }

  Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(payload) as Map<String, dynamic>;
    } catch (_) {
      return;
    }
    if (decoded['type'] != 'spot_alarm') {
      return;
    }
    final alarmId = decoded['alarmId'] as String?;
    if (alarmId == null || alarmId.isEmpty) {
      return;
    }
    final actionId = response.actionId;
    if (actionId == _snoozeActionId) {
      SpotAlarmCatalog.instance.snoozeAlarm(alarmId);
    } else if (actionId == _stopActionId) {
      SpotAlarmCatalog.instance.stopAlarmUntilConditionsReset(alarmId);
    }
    final notificationId = response.id;
    if (notificationId != null) {
      await _plugin.cancel(id: notificationId);
    }
  }

  @visibleForTesting
  FlutterLocalNotificationsPlugin get plugin => _plugin;
}
