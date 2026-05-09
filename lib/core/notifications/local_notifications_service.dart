import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/config/env/local_env_store.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:windwisher/core/notifications/direct_message_notification_event.dart';
import 'package:windwisher/core/notifications/spot_chat_notification_event.dart';
import 'package:windwisher/core/notifications/spot_alarm_cycle_runtime_service.dart';
import 'package:windwisher/core/notifications/spot_alarm_notification_event.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

@pragma('vm:entry-point')
Future<void> notificationTapBackground(NotificationResponse response) async {
  try {
    await ensureNotificationBackgroundDependenciesInitialized();
    await LocalNotificationsService.instance
        .handleBackgroundNotificationResponse(response);
  } catch (error, stackTrace) {
    debugPrint(
      'LocalNotificationsService: background notification response failed: $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }
}

Future<void> ensureNotificationBackgroundDependenciesInitialized() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStoragePaths.ensureInitialized();
  await LocalEnvStore.initialize();
  final url = EnvConfig.supabaseUrl.trim();
  final anonKey = EnvConfig.supabaseAnonKey.trim();
  if (url.isEmpty || anonKey.isEmpty || _isSupabaseInitialized()) {
    return;
  }
  try {
    await Supabase.initialize(url: url, anonKey: anonKey);
  } catch (_) {
    // Another isolate/process may have initialized Supabase between the check
    // and the call. If a client is available afterwards, this is harmless.
    if (!_isSupabaseInitialized()) {
      rethrow;
    }
  }
}

bool _isSupabaseInitialized() {
  try {
    Supabase.instance.client;
    return true;
  } catch (_) {
    return false;
  }
}

class LocalNotificationsService {
  LocalNotificationsService._();

  static const String _alarmChannelId = 'spot_alarms_v2';
  static const String _directMessageChannelId = 'direct_messages_v1';
  static const String _spotChatChannelId = 'spot_chat_v1';
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

  static final AndroidNotificationChannel _spotChatChannel =
      const AndroidNotificationChannel(
        _spotChatChannelId,
        'Chat de spots',
        description: 'Notificaciones locales del chat publico de cada spot.',
        importance: Importance.high,
      );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final StreamController<DirectMessageNotificationEvent>
  _directMessageOpenController =
      StreamController<DirectMessageNotificationEvent>.broadcast();
  final StreamController<SpotChatNotificationEvent> _spotChatOpenController =
      StreamController<SpotChatNotificationEvent>.broadcast();
  final StreamController<SpotAlarmNotificationEvent> _spotAlarmOpenController =
      StreamController<SpotAlarmNotificationEvent>.broadcast();
  DirectMessageNotificationEvent? _pendingDirectMessageOpen;
  SpotChatNotificationEvent? _pendingSpotChatOpen;
  SpotAlarmNotificationEvent? _pendingSpotAlarmOpen;
  final Map<int, Timer> _foregroundAlarmRepeatTimers = <int, Timer>{};
  Future<void>? _initializing;
  bool _initialized = false;
  bool _timezoneInitialized = false;

  Stream<DirectMessageNotificationEvent> get directMessageOpenStream =>
      _directMessageOpenController.stream;

  Stream<SpotChatNotificationEvent> get spotChatOpenStream =>
      _spotChatOpenController.stream;

  Stream<SpotAlarmNotificationEvent> get spotAlarmOpenStream =>
      _spotAlarmOpenController.stream;

  DirectMessageNotificationEvent? consumePendingDirectMessageOpen() {
    final pending = _pendingDirectMessageOpen;
    _pendingDirectMessageOpen = null;
    return pending;
  }

  SpotChatNotificationEvent? consumePendingSpotChatOpen() {
    final pending = _pendingSpotChatOpen;
    _pendingSpotChatOpen = null;
    return pending;
  }

  SpotAlarmNotificationEvent? consumePendingSpotAlarmOpen() {
    final pending = _pendingSpotAlarmOpen;
    _pendingSpotAlarmOpen = null;
    return pending;
  }

  Future<void> initialize() {
    if (_initialized) {
      return Future<void>.value();
    }
    final pendingInitialization = _initializing;
    if (pendingInitialization != null) {
      return pendingInitialization;
    }
    final initialization = _initialize();
    _initializing = initialization;
    return initialization.whenComplete(() {
      _initializing = null;
    });
  }

  Future<void> _initialize() async {
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
    await androidPlugin?.createNotificationChannel(_spotChatChannel);
    _initialized = true;
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    final launchResponse = launchDetails?.notificationResponse;
    if (launchResponse != null) {
      await _handleNotificationResponse(launchResponse);
    }
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

  Future<void> showSpotChatMessage({
    required String spotName,
    required String spotArea,
    required String messageId,
    required String senderName,
    required String body,
  }) async {
    await initialize();
    final safeSenderName = senderName.trim().isEmpty
        ? 'Chat del spot'
        : senderName.trim();
    final safeBody = body.trim().isEmpty
        ? 'Hay un mensaje nuevo en $spotName.'
        : body.trim();
    final payload = jsonEncode(<String, String>{
      'type': 'spot_chat',
      'spotName': spotName,
      'spotArea': spotArea,
      'messageId': messageId,
    });
    await _plugin.show(
      id: _notificationIdForSpotChat(spotName, spotArea, messageId),
      title: safeSenderName,
      body: safeBody,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _spotChatChannelId,
          'Chat de spots',
          channelDescription:
              'Notificaciones locales del chat publico de cada spot.',
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
    int occurrenceIndex = 0,
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
      occurrenceIndex: occurrenceIndex,
    );
    if (scheduleRemainingRepeats && occurrenceIndex + 1 < maxRepeats) {
      await _scheduleRemainingRepeats(
        alarmId: alarmId,
        cycleId: cycleId,
        title: title,
        body: body,
        repeatWindow: repeatWindow,
        maxRepeats: maxRepeats,
        completedOccurrences: occurrenceIndex + 1,
      );
    }
  }

  Future<void> scheduleAlarmCycleFromRemotePush({
    required String alarmId,
    required String title,
    required String body,
    required AlarmRepeatWindow repeatWindow,
    required int maxRepeats,
    int occurrenceIndex = 0,
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
        occurrenceIndex: occurrenceIndex,
      );
    }
    debugPrint(
      'LocalNotificationsService: remote spot alarm cycle started alarmId=$alarmId maxRepeats=$maxRepeats includeImmediate=$includeImmediateNotification',
    );
  }

  Future<void> handleRemoteSpotAlarmPushOpen({
    required String alarmId,
    required String title,
    required String body,
    required AlarmRepeatWindow repeatWindow,
    required int maxRepeats,
    required int occurrenceIndex,
  }) async {
    await initialize();
    await cancelAlarmCycle(alarmId: alarmId, maxRepeats: maxRepeats);
    final cycleId = SpotAlarmCycleRuntimeService.instance.startCycle(
      alarmId: alarmId,
      maxRepeats: maxRepeats,
      repeatWindowName: repeatWindow.name,
    );
    final hasNextRepeat = await _scheduleNextLocalAlarmRepeatIfAvailable(
      alarmId: alarmId,
      cycleId: cycleId,
      title: title,
      body: body,
      repeatWindowRaw: repeatWindow.name,
      occurrenceIndex: occurrenceIndex,
      maxRepeats: maxRepeats,
    );
    final event = SpotAlarmNotificationEvent(alarmId: alarmId);
    _pendingSpotAlarmOpen = event;
    _spotAlarmOpenController.add(event);
    unawaited(
      hasNextRepeat
          ? _syncSnoozedAlarmAfterLocalSchedule(alarmId)
          : _finalizeAlarmAfterLastNotification(
              alarmId: alarmId,
              cycleId: cycleId,
              maxRepeats: maxRepeats,
              source: 'remote-open',
            ),
    );
    debugPrint(
      'LocalNotificationsService: remote spot alarm push opened alarmId=$alarmId hasNextRepeat=$hasNextRepeat',
    );
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
    var hash = 0x811c9dc5;
    final raw = '$alarmId:$occurrenceIndex';
    for (final unit in raw.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  int _notificationIdForSpotChat(
    String spotName,
    String spotArea,
    String messageId,
  ) {
    var hash = 0x811c9dc5;
    final raw = 'spot_chat:$spotName:$spotArea:$messageId';
    for (final unit in raw.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash & 0x7fffffff;
  }

  Future<void> cancelAlarmCycle({
    required String alarmId,
    required int maxRepeats,
  }) async {
    await initialize();
    for (var index = 0; index < maxRepeats; index += 1) {
      final notificationId = notificationIdForAlarm(alarmId, index);
      _foregroundAlarmRepeatTimers.remove(notificationId)?.cancel();
      await _plugin.cancel(id: notificationId);
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

  Future<void> _scheduleSnoozedAlarmReminder({
    required String alarmId,
    required String cycleId,
    required String title,
    required String body,
    required AlarmRepeatWindow repeatWindow,
    required int maxRepeats,
    required int occurrenceIndex,
  }) async {
    final repeatDuration = _repeatWindowDuration(repeatWindow);
    final notificationId = notificationIdForAlarm(alarmId, occurrenceIndex);
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
    final when = DateTime.now().add(repeatDuration);
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _alarmChannelId,
        'Alarmas de spots',
        channelDescription:
            'Alertas locales cuando el live cumple una alarma guardada.',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
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
    );

    await _scheduleAlarmReminderNotification(
      notificationId: notificationId,
      alarmId: alarmId,
      occurrenceIndex: occurrenceIndex,
      title: title,
      body: body,
      when: when,
      details: details,
      payload: payload,
    );
    _foregroundAlarmRepeatTimers.remove(notificationId)?.cancel();
    _foregroundAlarmRepeatTimers[notificationId] = Timer(repeatDuration, () {
      _foregroundAlarmRepeatTimers.remove(notificationId);
      unawaited(
        _showAlarmNotification(
              notificationId: notificationId,
              alarmId: alarmId,
              cycleId: cycleId,
              title: title,
              body: body,
              repeatWindow: repeatWindow,
              maxRepeats: maxRepeats,
              occurrenceIndex: occurrenceIndex,
            )
            .then((_) {
              debugPrint(
                'LocalNotificationsService: foreground fallback alarm reminder shown alarmId=$alarmId occurrence=$occurrenceIndex',
              );
            })
            .catchError((Object error, StackTrace stackTrace) {
              debugPrint(
                'LocalNotificationsService: foreground fallback alarm reminder failed alarmId=$alarmId error=$error',
              );
              debugPrintStack(stackTrace: stackTrace);
            }),
      );
    });
  }

  Future<void> _scheduleAlarmReminderNotification({
    required int notificationId,
    required String alarmId,
    required int occurrenceIndex,
    required String title,
    required String body,
    required DateTime when,
    required NotificationDetails details,
    required String payload,
  }) async {
    final scheduledDate = tz.TZDateTime.from(when.toUtc(), tz.UTC);
    for (final mode in const <AndroidScheduleMode>[
      AndroidScheduleMode.alarmClock,
      AndroidScheduleMode.exactAllowWhileIdle,
      AndroidScheduleMode.inexactAllowWhileIdle,
    ]) {
      try {
        await _plugin.zonedSchedule(
          id: notificationId,
          title: title,
          body: body,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: mode,
          payload: payload,
        );
        debugPrint(
          'LocalNotificationsService: snoozed alarm reminder scheduled alarmId=$alarmId occurrence=$occurrenceIndex when=${when.toUtc().toIso8601String()} mode=${mode.name}',
        );
        return;
      } on PlatformException catch (error, stackTrace) {
        debugPrint(
          'LocalNotificationsService: snooze schedule failed alarmId=$alarmId occurrence=$occurrenceIndex mode=${mode.name}; trying fallback. $error',
        );
        debugPrintStack(stackTrace: stackTrace);
      }
    }
    throw StateError(
      'No se pudo programar la repeticion local de la alarma $alarmId.',
    );
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
    await ensureNotificationBackgroundDependenciesInitialized();
    await initialize();
    await _handleNotificationResponse(response);
  }

  Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      debugPrint(
        'LocalNotificationsService: notification response without payload action=${response.actionId} id=${response.id}',
      );
      return;
    }
    debugPrint(
      'LocalNotificationsService: notification response action=${response.actionId} id=${response.id} payload=$payload',
    );
    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(payload) as Map<String, dynamic>;
    } catch (error) {
      debugPrint(
        'LocalNotificationsService: notification payload decode failed: $error',
      );
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
    if (decoded['type'] == 'spot_chat') {
      final spotName = decoded['spotName'] as String?;
      final spotArea = decoded['spotArea'] as String?;
      final messageId = decoded['messageId'] as String?;
      if (spotName != null &&
          spotName.isNotEmpty &&
          spotArea != null &&
          spotArea.isNotEmpty &&
          messageId != null &&
          messageId.isNotEmpty) {
        final event = SpotChatNotificationEvent(
          spotName: spotName,
          spotArea: spotArea,
          messageId: messageId,
        );
        _pendingSpotChatOpen = event;
        _spotChatOpenController.add(event);
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
    debugPrint(
      'LocalNotificationsService: parsed spot alarm response alarmId=$alarmId cycleId=$cycleId occurrence=$occurrenceIndex maxRepeats=$maxRepeats action=${response.actionId}',
    );
    final actionId = response.actionId;
    final isCurrentCycle = SpotAlarmCycleRuntimeService.instance.isCurrentCycle(
      alarmId: alarmId,
      cycleId: cycleId,
    );
    if (!isCurrentCycle) {
      debugPrint(
        'LocalNotificationsService: spot alarm response uses a stale or missing local cycle; continuing from notification payload alarmId=$alarmId cycleId=$cycleId action=$actionId',
      );
    }
    if (actionId == null || actionId.isEmpty) {
      await _cancelNotificationResponse(
        response: response,
        alarmId: alarmId,
        occurrenceIndex: occurrenceIndex,
      );
      final hasNextRepeat = await _scheduleNextLocalAlarmRepeatIfAvailable(
        alarmId: alarmId,
        cycleId: cycleId,
        title: title,
        body: body,
        repeatWindowRaw: repeatWindowRaw,
        occurrenceIndex: occurrenceIndex,
        maxRepeats: maxRepeats,
      );
      final event = SpotAlarmNotificationEvent(alarmId: alarmId);
      _pendingSpotAlarmOpen = event;
      _spotAlarmOpenController.add(event);
      unawaited(
        hasNextRepeat
            ? _syncSnoozedAlarmAfterLocalSchedule(alarmId)
            : _finalizeAlarmAfterLastNotification(
                alarmId: alarmId,
                cycleId: cycleId,
                maxRepeats: maxRepeats,
                source: 'open',
              ),
      );
      debugPrint(
        'LocalNotificationsService: spot alarm notification opened; snooze queued alarmId=$alarmId',
      );
      return;
    }
    if (actionId == _snoozeActionId) {
      await _snoozeAlarmFromNotificationResponse(
        response: response,
        alarmId: alarmId,
        cycleId: cycleId,
        title: title,
        body: body,
        repeatWindowRaw: repeatWindowRaw,
        occurrenceIndex: occurrenceIndex,
        maxRepeats: maxRepeats,
      );
    } else if (actionId == _stopActionId) {
      await _cancelAlarmActionNotification(
        response: response,
        alarmId: alarmId,
        occurrenceIndex: occurrenceIndex,
        maxRepeats: maxRepeats,
      );
      await SpotAlarmCatalog.instance.stopAlarmUntilConditionsReset(alarmId);
      SpotAlarmCycleRuntimeService.instance.stopCycle(
        alarmId: alarmId,
        cycleId: cycleId,
      );
      await cancelAlarmCycle(alarmId: alarmId, maxRepeats: maxRepeats);
      debugPrint(
        'LocalNotificationsService: spot alarm stopped alarmId=$alarmId occurrence=$occurrenceIndex',
      );
    }
  }

  Future<bool> _scheduleNextLocalAlarmRepeatIfAvailable({
    required String alarmId,
    required String cycleId,
    required String title,
    required String body,
    required String repeatWindowRaw,
    required int occurrenceIndex,
    required int maxRepeats,
  }) async {
    if (occurrenceIndex + 1 >= maxRepeats) {
      await cancelAlarmCycle(alarmId: alarmId, maxRepeats: maxRepeats);
      return false;
    }
    await cancelAlarmCycle(alarmId: alarmId, maxRepeats: maxRepeats);
    await _scheduleSnoozedAlarmReminder(
      alarmId: alarmId,
      cycleId: cycleId,
      title: title,
      body: body,
      repeatWindow: _repeatWindowFromName(repeatWindowRaw),
      maxRepeats: maxRepeats,
      occurrenceIndex: occurrenceIndex + 1,
    );
    return true;
  }

  Future<void> _syncSnoozedAlarmAfterLocalSchedule(String alarmId) async {
    try {
      await SpotAlarmCatalog.instance.snoozeAlarm(alarmId);
      debugPrint(
        'LocalNotificationsService: spot alarm snooze synced after local schedule alarmId=$alarmId',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'LocalNotificationsService: spot alarm snooze sync after local schedule failed alarmId=$alarmId error=$error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _finalizeAlarmAfterLastNotification({
    required String alarmId,
    required String cycleId,
    required int maxRepeats,
    required String source,
  }) async {
    try {
      await SpotAlarmCatalog.instance.stopAlarmUntilConditionsReset(alarmId);
      SpotAlarmCycleRuntimeService.instance.stopCycle(
        alarmId: alarmId,
        cycleId: cycleId,
      );
      await cancelAlarmCycle(alarmId: alarmId, maxRepeats: maxRepeats);
      debugPrint(
        'LocalNotificationsService: spot alarm finalized after last $source alarmId=$alarmId maxRepeats=$maxRepeats',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'LocalNotificationsService: spot alarm finalize after last $source failed alarmId=$alarmId error=$error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _snoozeAlarmFromNotificationResponse({
    required NotificationResponse response,
    required String alarmId,
    required String cycleId,
    required String title,
    required String body,
    required String repeatWindowRaw,
    required int occurrenceIndex,
    required int maxRepeats,
  }) async {
    await _cancelAlarmActionNotification(
      response: response,
      alarmId: alarmId,
      occurrenceIndex: occurrenceIndex,
      maxRepeats: maxRepeats,
    );
    final hasNextRepeat = await _scheduleNextLocalAlarmRepeatIfAvailable(
      alarmId: alarmId,
      cycleId: cycleId,
      title: title,
      body: body,
      repeatWindowRaw: repeatWindowRaw,
      occurrenceIndex: occurrenceIndex,
      maxRepeats: maxRepeats,
    );
    if (!hasNextRepeat) {
      await _finalizeAlarmAfterLastNotification(
        alarmId: alarmId,
        cycleId: cycleId,
        maxRepeats: maxRepeats,
        source: 'snooze',
      );
      return;
    }
    await SpotAlarmCatalog.instance.snoozeAlarm(alarmId);
    debugPrint(
      'LocalNotificationsService: spot alarm snoozed alarmId=$alarmId occurrence=$occurrenceIndex maxRepeats=$maxRepeats',
    );
  }

  Future<void> _cancelAlarmActionNotification({
    required NotificationResponse response,
    required String alarmId,
    required int occurrenceIndex,
    required int maxRepeats,
  }) async {
    await _cancelNotificationResponse(
      response: response,
      alarmId: alarmId,
      occurrenceIndex: occurrenceIndex,
    );
    for (var index = 0; index < maxRepeats; index += 1) {
      await _plugin.cancel(id: notificationIdForAlarm(alarmId, index));
    }
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
