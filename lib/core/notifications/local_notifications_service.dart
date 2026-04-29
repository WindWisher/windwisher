import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:windwisher/core/notifications/direct_message_notification_event.dart';
import 'package:windwisher/core/notifications/spot_alarm_cycle_runtime_service.dart';
import 'package:windwisher/core/notifications/spot_alarm_notification_event.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  await LocalNotificationsService.instance.handleBackgroundNotificationResponse(
    response,
  );
}

class LocalNotificationsService {
  LocalNotificationsService._();

  static const String _alarmChannelId = 'spot_alarms_v2';
  static const String _directMessageChannelId = 'direct_messages_v1';
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

  static final AndroidNotificationChannel _directMessageChannel =
      const AndroidNotificationChannel(
        _directMessageChannelId,
        'Mensajes directos',
        description: 'Notificaciones locales de chats directos entre usuarios.',
        importance: Importance.high,
      );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<DirectMessageNotificationEvent>
  _directMessageOpenController =
      StreamController<DirectMessageNotificationEvent>.broadcast();
  final StreamController<SpotAlarmNotificationEvent> _spotAlarmOpenController =
      StreamController<SpotAlarmNotificationEvent>.broadcast();
  DirectMessageNotificationEvent? _pendingDirectMessageOpen;
  SpotAlarmNotificationEvent? _pendingSpotAlarmOpen;
  bool _initialized = false;
  bool _timezoneInitialized = false;

  Stream<DirectMessageNotificationEvent> get directMessageOpenStream =>
      _directMessageOpenController.stream;

  Stream<SpotAlarmNotificationEvent> get spotAlarmOpenStream =>
      _spotAlarmOpenController.stream;

  DirectMessageNotificationEvent? consumePendingDirectMessageOpen() {
    final pending = _pendingDirectMessageOpen;
    _pendingDirectMessageOpen = null;
    return pending;
  }

  SpotAlarmNotificationEvent? consumePendingSpotAlarmOpen() {
    final pending = _pendingSpotAlarmOpen;
    _pendingSpotAlarmOpen = null;
    return pending;
  }

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initializeTimezone();

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
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_alarmChannel);
    await androidPlugin?.createNotificationChannel(_directMessageChannel);
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
    try {
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (_) {
      // Best effort: if Android does not expose exact alarm permission on this device,
      // keep standard notifications working and fall back later when scheduling.
    }

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

  Future<void> showDirectMessage({
    required String threadId,
    required String messageId,
    required String senderName,
    required String body,
  }) async {
    await initialize();
    final safeSenderName = senderName.trim().isEmpty
        ? 'Nuevo mensaje'
        : senderName.trim();
    final safeBody = body.trim().isEmpty
        ? 'Tienes un mensaje nuevo.'
        : body.trim();
    final payload = jsonEncode(<String, String>{
      'type': 'direct_message',
      'threadId': threadId,
      'messageId': messageId,
    });
    await _plugin.show(
      id: threadId.hashCode & 0x7fffffff,
      title: safeSenderName,
      body: safeBody,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _directMessageChannelId,
          'Mensajes directos',
          channelDescription:
              'Notificaciones locales de chats directos entre usuarios.',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.message,
        ),
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active,
        ),
        macOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.active,
        ),
      ),
      payload: payload,
    );
  }

  Future<void> showSpotAlarm({
    required String alarmId,
    required String title,
    required String body,
    required AlarmRepeatWindow repeatWindow,
    required int maxRepeats,
    bool scheduleRemainingRepeats = true,
  }) async {
    await initialize();
    await cancelAlarmCycle(alarmId: alarmId, maxRepeats: maxRepeats);
    final cycleId = SpotAlarmCycleRuntimeService.instance.startCycle(
      alarmId: alarmId,
      maxRepeats: maxRepeats,
      repeatWindowName: repeatWindow.name,
    );
    await _showAlarmNotification(
      notificationId: notificationIdForAlarm(alarmId, 0),
      alarmId: alarmId,
      cycleId: cycleId,
      title: title,
      body: body,
      repeatWindow: repeatWindow,
      maxRepeats: maxRepeats,
      occurrenceIndex: 0,
    );
    if (scheduleRemainingRepeats && maxRepeats > 1) {
      await _scheduleRemainingRepeats(
        alarmId: alarmId,
        cycleId: cycleId,
        title: title,
        body: body,
        repeatWindow: repeatWindow,
        maxRepeats: maxRepeats,
        completedOccurrences: 1,
      );
    }
  }

  Future<void> scheduleAlarmCycleFromRemotePush({
    required String alarmId,
    required String title,
    required String body,
    required AlarmRepeatWindow repeatWindow,
    required int maxRepeats,
    bool includeImmediateNotification = false,
  }) async {
    await initialize();
    await cancelAlarmCycle(alarmId: alarmId, maxRepeats: maxRepeats);
    final cycleId = SpotAlarmCycleRuntimeService.instance.startCycle(
      alarmId: alarmId,
      maxRepeats: maxRepeats,
      repeatWindowName: repeatWindow.name,
    );
    if (includeImmediateNotification) {
      await _showAlarmNotification(
        notificationId: notificationIdForAlarm(alarmId, 0),
        alarmId: alarmId,
        cycleId: cycleId,
        title: title,
        body: body,
        repeatWindow: repeatWindow,
        maxRepeats: maxRepeats,
        occurrenceIndex: 0,
      );
    }
    if (maxRepeats > 1) {
      await _scheduleRemainingRepeats(
        alarmId: alarmId,
        cycleId: cycleId,
        title: title,
        body: body,
        repeatWindow: repeatWindow,
        maxRepeats: maxRepeats,
        completedOccurrences: 1,
      );
    }
  }

  Future<void> _showAlarmNotification({
    required int notificationId,
    required String alarmId,
    required String cycleId,
    required String title,
    required String body,
    required AlarmRepeatWindow repeatWindow,
    required int maxRepeats,
    required int occurrenceIndex,
  }) async {
    final payload = jsonEncode(<String, String>{
      'type': 'spot_alarm',
      'alarmId': alarmId,
      'cycleId': cycleId,
      'title': title,
      'body': body,
      'repeatWindow': repeatWindow.name,
      'maxRepeats': '$maxRepeats',
      'occurrenceIndex': '$occurrenceIndex',
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
          autoCancel: true,
          ongoing: false,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          vibrationPattern: Int64List.fromList(<int>[0, 900, 300, 900]),
          actions: <AndroidNotificationAction>[
            AndroidNotificationAction(
              _snoozeActionId,
              'Posponer',
              showsUserInterface: false,
              cancelNotification: true,
            ),
            AndroidNotificationAction(
              _stopActionId,
              'Parar',
              showsUserInterface: false,
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

  int notificationIdForAlarm(String alarmId, int occurrenceIndex) {
    return ((alarmId.hashCode & 0x7fffffff) + occurrenceIndex) & 0x7fffffff;
  }

  Future<void> cancelAlarmCycle({
    required String alarmId,
    required int maxRepeats,
  }) async {
    await initialize();
    for (var index = 0; index < maxRepeats; index += 1) {
      await _plugin.cancel(id: notificationIdForAlarm(alarmId, index));
    }
  }

  Future<void> _scheduleRemainingRepeats({
    required String alarmId,
    required String cycleId,
    required String title,
    required String body,
    required AlarmRepeatWindow repeatWindow,
    required int maxRepeats,
    required int completedOccurrences,
  }) async {
    final remainingCount = maxRepeats - completedOccurrences;
    if (remainingCount <= 0) {
      return;
    }
    final repeatDuration = _repeatWindowDuration(repeatWindow);
    for (var offset = 1; offset <= remainingCount; offset += 1) {
      final occurrenceIndex = completedOccurrences + offset - 1;
      final payload = jsonEncode(<String, String>{
        'type': 'spot_alarm',
        'alarmId': alarmId,
        'cycleId': cycleId,
        'title': title,
        'body': body,
        'repeatWindow': repeatWindow.name,
        'maxRepeats': '$maxRepeats',
        'occurrenceIndex': '$occurrenceIndex',
      });
      final when = DateTime.now().add(repeatDuration * offset);
      try {
        await _plugin.zonedSchedule(
          id: notificationIdForAlarm(alarmId, occurrenceIndex),
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(when.toUtc(), tz.UTC),
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
              autoCancel: true,
              ongoing: false,
              audioAttributesUsage: AudioAttributesUsage.alarm,
              vibrationPattern: Int64List.fromList(<int>[0, 900, 300, 900]),
              actions: <AndroidNotificationAction>[
                AndroidNotificationAction(
                  _snoozeActionId,
                  'Posponer',
                  showsUserInterface: false,
                  cancelNotification: true,
                ),
                AndroidNotificationAction(
                  _stopActionId,
                  'Parar',
                  showsUserInterface: false,
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
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } on PlatformException catch (error, stackTrace) {
        debugPrint(
          'LocalNotificationsService: exact schedule failed for alarm repeat; falling back to inexactAllowWhileIdle. $error',
        );
        debugPrintStack(stackTrace: stackTrace);
        await _plugin.zonedSchedule(
          id: notificationIdForAlarm(alarmId, occurrenceIndex),
          title: title,
          body: body,
          scheduledDate: tz.TZDateTime.from(when.toUtc(), tz.UTC),
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
              autoCancel: true,
              ongoing: false,
              audioAttributesUsage: AudioAttributesUsage.alarm,
              vibrationPattern: Int64List.fromList(<int>[0, 900, 300, 900]),
              actions: <AndroidNotificationAction>[
                AndroidNotificationAction(
                  _snoozeActionId,
                  'Posponer',
                  showsUserInterface: false,
                  cancelNotification: true,
                ),
                AndroidNotificationAction(
                  _stopActionId,
                  'Parar',
                  showsUserInterface: false,
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
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: payload,
        );
      }
    }
  }

  Duration _repeatWindowDuration(AlarmRepeatWindow window) {
    switch (window) {
      case AlarmRepeatWindow.min1:
        return const Duration(minutes: 1);
      case AlarmRepeatWindow.min5:
        return const Duration(minutes: 5);
      case AlarmRepeatWindow.min10:
        return const Duration(minutes: 10);
      case AlarmRepeatWindow.min15:
        return const Duration(minutes: 15);
      case AlarmRepeatWindow.min30:
        return const Duration(minutes: 30);
    }
  }

  AlarmRepeatWindow _repeatWindowFromName(String raw) {
    return AlarmRepeatWindow.values.firstWhere(
      (value) => value.name == raw,
      orElse: () => AlarmRepeatWindow.min10,
    );
  }

  void _initializeTimezone() {
    if (_timezoneInitialized) {
      return;
    }
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
    _timezoneInitialized = true;
  }

  Future<void> handleBackgroundNotificationResponse(
    NotificationResponse response,
  ) async {
    await initialize();
    await _handleNotificationResponse(response);
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
    if (decoded['type'] == 'direct_message') {
      final threadId = decoded['threadId'] as String?;
      final messageId = decoded['messageId'] as String?;
      if (threadId != null &&
          threadId.isNotEmpty &&
          messageId != null &&
          messageId.isNotEmpty) {
        final event = DirectMessageNotificationEvent(
          threadId: threadId,
          messageId: messageId,
        );
        _pendingDirectMessageOpen = event;
        _directMessageOpenController.add(event);
      }
      return;
    }
    if (decoded['type'] != 'spot_alarm') {
      return;
    }
    final alarmId = decoded['alarmId'] as String?;
    final cycleId = decoded['cycleId'] as String?;
    final repeatWindowRaw = decoded['repeatWindow'] as String?;
    final title = (decoded['title'] as String?)?.trim().isNotEmpty == true
        ? (decoded['title'] as String).trim()
        : 'Alarma de spot';
    final body = (decoded['body'] as String?)?.trim().isNotEmpty == true
        ? (decoded['body'] as String).trim()
        : 'La alarma sigue activa.';
    final maxRepeats = int.tryParse(decoded['maxRepeats'] as String? ?? '');
    final occurrenceIndex = int.tryParse(
      decoded['occurrenceIndex'] as String? ?? '',
    );
    if (alarmId == null ||
        alarmId.isEmpty ||
        cycleId == null ||
        cycleId.isEmpty ||
        repeatWindowRaw == null ||
        maxRepeats == null ||
        occurrenceIndex == null) {
      return;
    }
    if (!SpotAlarmCycleRuntimeService.instance.isCurrentCycle(
      alarmId: alarmId,
      cycleId: cycleId,
    )) {
      await _cancelNotificationResponse(
        response: response,
        alarmId: alarmId,
        occurrenceIndex: occurrenceIndex,
      );
      return;
    }
    final actionId = response.actionId;
    if (actionId == null || actionId.isEmpty) {
      await _cancelNotificationResponse(
        response: response,
        alarmId: alarmId,
        occurrenceIndex: occurrenceIndex,
      );
      final event = SpotAlarmNotificationEvent(alarmId: alarmId);
      _pendingSpotAlarmOpen = event;
      _spotAlarmOpenController.add(event);
      return;
    }
    if (actionId == _snoozeActionId) {
      await _cancelNotificationResponse(
        response: response,
        alarmId: alarmId,
        occurrenceIndex: occurrenceIndex,
      );
      SpotAlarmCatalog.instance.snoozeAlarm(alarmId);
      await cancelAlarmCycle(alarmId: alarmId, maxRepeats: maxRepeats);
      await _scheduleRemainingRepeats(
        alarmId: alarmId,
        cycleId: cycleId,
        title: title,
        body: body,
        repeatWindow: _repeatWindowFromName(repeatWindowRaw),
        maxRepeats: maxRepeats,
        completedOccurrences: occurrenceIndex + 1,
      );
    } else if (actionId == _stopActionId) {
      await _cancelNotificationResponse(
        response: response,
        alarmId: alarmId,
        occurrenceIndex: occurrenceIndex,
      );
      SpotAlarmCatalog.instance.stopAlarmUntilConditionsReset(alarmId);
      SpotAlarmCycleRuntimeService.instance.stopCycle(
        alarmId: alarmId,
        cycleId: cycleId,
      );
      await cancelAlarmCycle(alarmId: alarmId, maxRepeats: maxRepeats);
    }
    await _cancelNotificationResponse(
      response: response,
      alarmId: alarmId,
      occurrenceIndex: occurrenceIndex,
    );
  }

  Future<void> _cancelNotificationResponse({
    required NotificationResponse response,
    required String alarmId,
    required int occurrenceIndex,
  }) async {
    final responseId = response.id;
    if (responseId != null) {
      await _plugin.cancel(id: responseId);
    }
    await _plugin.cancel(id: notificationIdForAlarm(alarmId, occurrenceIndex));
  }

  @visibleForTesting
  FlutterLocalNotificationsPlugin get plugin => _plugin;
}
