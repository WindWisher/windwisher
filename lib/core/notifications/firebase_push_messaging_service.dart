import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:windwisher/firebase_options.dart';
import 'package:windwisher/core/notifications/direct_message_notification_event.dart';
import 'package:windwisher/core/notifications/local_notifications_service.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/core/notifications/spot_chat_notification_event.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await ensureNotificationBackgroundDependenciesInitialized();
    await _ensureFirebaseInitializedIfNeeded();
    await LocalNotificationsService.instance.initialize();
    await PushNotificationSubscriptionService.instance.initialize();
    final pushPreferences = PushNotificationSubscriptionService.instance;
    if (!pushPreferences.enabled) {
      return;
    }
    if (message.data['type'] == 'direct_message' &&
        pushPreferences.directMessagesEnabled &&
        (message.notification == null ||
            ((message.notification?.title?.trim().isEmpty ?? true) &&
                (message.notification?.body?.trim().isEmpty ?? true)))) {
      final threadId = message.data['threadId']?.trim();
      final messageId = message.data['messageId']?.trim();
      if (threadId != null &&
          threadId.isNotEmpty &&
          messageId != null &&
          messageId.isNotEmpty) {
        await LocalNotificationsService.instance.showDirectMessage(
          threadId: threadId,
          messageId: messageId,
          senderName:
              message.data['senderDisplayName']?.trim().isNotEmpty == true
              ? message.data['senderDisplayName']!.trim()
              : 'Nuevo mensaje',
          body: message.data['preview']?.trim().isNotEmpty == true
              ? message.data['preview']!.trim()
              : 'Tienes un mensaje nuevo.',
        );
      }
      return;
    }
    if (message.data['type'] == 'spot_chat' &&
        pushPreferences.spotChatMentionsEnabled &&
        (message.notification == null ||
            ((message.notification?.title?.trim().isEmpty ?? true) &&
                (message.notification?.body?.trim().isEmpty ?? true)))) {
      final spotName = message.data['spotName']?.trim();
      final spotArea = message.data['spotArea']?.trim();
      final messageId = message.data['messageId']?.trim();
      if (spotName != null &&
          spotName.isNotEmpty &&
          spotArea != null &&
          spotArea.isNotEmpty &&
          messageId != null &&
          messageId.isNotEmpty) {
        await LocalNotificationsService.instance.showSpotChatMessage(
          spotName: spotName,
          spotArea: spotArea,
          messageId: messageId,
          senderName:
              message.data['senderDisplayName']?.trim().isNotEmpty == true
              ? message.data['senderDisplayName']!.trim()
              : 'Chat del spot',
          body: message.data['preview']?.trim().isNotEmpty == true
              ? message.data['preview']!.trim()
              : 'Hay un mensaje nuevo en $spotName.',
        );
      }
      return;
    }
    final alarmId = message.data['alarmId']?.trim();
    final repeatWindowRaw = message.data['repeatWindow']?.trim();
    final maxRepeats = int.tryParse(message.data['maxRepeats'] ?? '');
    final occurrenceIndex =
        int.tryParse(message.data['occurrenceIndex'] ?? '') ?? 0;
    if (message.data['type'] == 'spot_alarm' &&
        pushPreferences.spotAlarmsEnabled &&
        alarmId != null &&
        alarmId.isNotEmpty &&
        repeatWindowRaw != null &&
        maxRepeats != null &&
        maxRepeats > 0) {
      await LocalNotificationsService.instance.scheduleAlarmCycleFromRemotePush(
        alarmId: alarmId,
        title: message.data['title']?.trim().isNotEmpty == true
            ? message.data['title']!.trim()
            : 'Alarma activa',
        body: message.data['body']?.trim().isNotEmpty == true
            ? message.data['body']!.trim()
            : 'Las condiciones del spot ya se estan cumpliendo.',
        repeatWindow: AlarmRepeatWindow.values.firstWhere(
          (value) => value.name == repeatWindowRaw,
          orElse: () => AlarmRepeatWindow.min10,
        ),
        maxRepeats: maxRepeats,
        occurrenceIndex: occurrenceIndex,
        includeImmediateNotification: true,
      );
    }
  } catch (_) {
    // Ignore if Firebase is not configured on this build yet.
  }
}

Future<void> _ensureFirebaseInitializedIfNeeded() async {
  if (kIsWeb) {
    return;
  }
  if (Firebase.apps.isNotEmpty) {
    return;
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class FirebasePushMessagingService {
  FirebasePushMessagingService._();

  static final FirebasePushMessagingService instance =
      FirebasePushMessagingService._();
  static const MethodChannel _androidPushChannel = MethodChannel(
    'windwisher/push',
  );

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  StreamSubscription<RemoteMessage>? _messageOpenedSubscription;
  final StreamController<DirectMessageNotificationEvent>
  _directMessageOpenController =
      StreamController<DirectMessageNotificationEvent>.broadcast();
  final StreamController<SpotChatNotificationEvent> _spotChatOpenController =
      StreamController<SpotChatNotificationEvent>.broadcast();
  DirectMessageNotificationEvent? _pendingDirectMessageOpen;
  SpotChatNotificationEvent? _pendingSpotChatOpen;
  bool _initialized = false;
  String? _lastInitializationError;

  Stream<DirectMessageNotificationEvent> get directMessageOpenStream =>
      _directMessageOpenController.stream;

  Stream<SpotChatNotificationEvent> get spotChatOpenStream =>
      _spotChatOpenController.stream;

  String? get lastInitializationError => _lastInitializationError;

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

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      _initialized = true;
      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(false);
      return;
    }

    if (_isIosSimulator()) {
      _initialized = true;
      debugPrint(
        'FirebasePushMessagingService: iOS simulator detected; skipping Firebase Messaging initialization.',
      );
      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(false);
      return;
    }

    try {
      if (Platform.isAndroid) {
        await _ensureFirebaseInitializedIfNeeded();
        await PushNotificationSubscriptionService.instance
            .setRemoteProviderConfigured(true);
        _lastInitializationError = null;
        final token = await _getAndroidFcmToken();
        if (token != null && token.trim().isNotEmpty) {
          await PushNotificationSubscriptionService.instance
              .registerDeviceToken(
                token: token,
                provider: 'fcm',
                platform: _platformLabel(),
                deviceLabel: _deviceLabel(),
              );
        }
        await _bindForegroundMessagingHandlers(bestEffort: true);
        _initialized = true;
        return;
      }

      await _ensureFirebaseInitializedIfNeeded();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(true);
      _lastInitializationError = null;

      if (Platform.isIOS) {
        final apnsToken = await _waitForApnsToken(messaging);
        if (apnsToken == null || apnsToken.trim().isEmpty) {
          debugPrint(
            'FirebasePushMessagingService: APNs token not available on iOS; skipping FCM token registration.',
          );
          _initialized = true;
          return;
        }
      }

      final token = await messaging.getToken();
      if (token != null && token.trim().isNotEmpty) {
        await PushNotificationSubscriptionService.instance.registerDeviceToken(
          token: token,
          provider: 'fcm',
          platform: _platformLabel(),
          deviceLabel: _deviceLabel(),
        );
      }

      await _bindForegroundMessagingHandlers();

      _initialized = true;
    } catch (error, stackTrace) {
      _initialized = false;
      _lastInitializationError = error.toString();
      debugPrint('FirebasePushMessagingService.initialize failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(false);
    }
  }

  Future<PushSubscriptionSyncStatus> refreshDeviceRegistration() async {
    if (!_initialized ||
        !PushNotificationSubscriptionService
            .instance
            .remoteProviderConfigured) {
      await initialize();
    }

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      return PushSubscriptionSyncStatus.providerNotConfigured;
    }

    if (_isIosSimulator()) {
      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(false);
      return PushNotificationSubscriptionService.instance.currentStatus;
    }

    try {
      if (Platform.isAndroid) {
        await PushNotificationSubscriptionService.instance
            .setRemoteProviderConfigured(true);
        _lastInitializationError = null;
        final token = await _getAndroidFcmToken();
        if (token != null && token.trim().isNotEmpty) {
          return await PushNotificationSubscriptionService.instance
              .registerDeviceToken(
                token: token,
                provider: 'fcm',
                platform: _platformLabel(),
                deviceLabel: _deviceLabel(),
              );
        }
        return PushNotificationSubscriptionService.instance.currentStatus;
      }

      await _ensureFirebaseInitializedIfNeeded();
      final messaging = FirebaseMessaging.instance;
      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(true);
      _lastInitializationError = null;
      if (Platform.isIOS) {
        final apnsToken = await _waitForApnsToken(messaging);
        if (apnsToken == null || apnsToken.trim().isEmpty) {
          return PushNotificationSubscriptionService.instance.currentStatus;
        }
      }
      final token = await messaging.getToken();
      if (token != null && token.trim().isNotEmpty) {
        return await PushNotificationSubscriptionService.instance
            .registerDeviceToken(
              token: token,
              provider: 'fcm',
              platform: _platformLabel(),
              deviceLabel: _deviceLabel(),
            );
      }
      return PushNotificationSubscriptionService.instance.currentStatus;
    } catch (error, stackTrace) {
      _lastInitializationError = error.toString();
      debugPrint(
        'FirebasePushMessagingService.refreshDeviceRegistration failed: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(false);
      return PushNotificationSubscriptionService.instance.currentStatus;
    }
  }

  Future<String?> _getAndroidFcmToken() async {
    final token = await _androidPushChannel.invokeMethod<String>('getFcmToken');
    return token?.trim().isEmpty ?? true ? null : token?.trim();
  }

  Future<void> _bindForegroundMessagingHandlers({
    bool bestEffort = false,
  }) async {
    try {
      await _foregroundMessageSubscription?.cancel();
      await _messageOpenedSubscription?.cancel();
      await _tokenRefreshSubscription?.cancel();

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((
        message,
      ) async {
        await _showForegroundNotification(message);
      });
      _messageOpenedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleOpenedRemoteMessage,
      );

      final messaging = FirebaseMessaging.instance;
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleOpenedRemoteMessage(initialMessage);
      }
      _tokenRefreshSubscription = messaging.onTokenRefresh.listen((
        nextToken,
      ) async {
        if (nextToken.trim().isEmpty) {
          return;
        }
        await PushNotificationSubscriptionService.instance.registerDeviceToken(
          token: nextToken,
          provider: 'fcm',
          platform: _platformLabel(),
          deviceLabel: _deviceLabel(),
        );
      });
    } catch (error, stackTrace) {
      if (!bestEffort) {
        rethrow;
      }
      debugPrint(
        'FirebasePushMessagingService: no se pudieron enlazar handlers de mensajeria en Android: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> dispose() async {
    await _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = null;
    await _messageOpenedSubscription?.cancel();
    _messageOpenedSubscription = null;
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final data = message.data;
    final pushPreferences = PushNotificationSubscriptionService.instance;
    if (!pushPreferences.enabled) {
      return;
    }
    if (data['type'] == 'direct_message') {
      if (!pushPreferences.directMessagesEnabled) {
        return;
      }
      await _showForegroundDirectMessageNotification(message);
      return;
    }
    if (data['type'] == 'spot_chat') {
      if (!pushPreferences.spotChatMentionsEnabled) {
        return;
      }
      await _showForegroundSpotChatNotification(message);
      return;
    }
    if (data['type'] != 'spot_alarm') {
      return;
    }
    if (!pushPreferences.spotAlarmsEnabled) {
      return;
    }
    final alarmId = data['alarmId']?.trim();
    if (alarmId == null || alarmId.isEmpty) {
      return;
    }
    final title = message.notification?.title?.trim().isNotEmpty == true
        ? message.notification!.title!.trim()
        : 'Alarma de spot';
    final body = message.notification?.body?.trim().isNotEmpty == true
        ? message.notification!.body!.trim()
        : 'La alarma ya esta activa.';
    final repeatWindow = AlarmRepeatWindow.values.firstWhere(
      (value) => value.name == (data['repeatWindow']?.trim() ?? ''),
      orElse: () => AlarmRepeatWindow.min10,
    );
    final maxRepeats = int.tryParse(data['maxRepeats']?.trim() ?? '') ?? 1;
    final occurrenceIndex =
        int.tryParse(data['occurrenceIndex']?.trim() ?? '') ?? 0;
    await LocalNotificationsService.instance.showSpotAlarm(
      alarmId: alarmId,
      title: title,
      body: body,
      repeatWindow: repeatWindow,
      maxRepeats: maxRepeats,
      occurrenceIndex: occurrenceIndex,
    );
  }

  void _handleOpenedRemoteMessage(RemoteMessage message) {
    final data = message.data;
    if (data['type'] == 'spot_alarm') {
      unawaited(_handleOpenedSpotAlarmMessage(message));
      return;
    }
    if (data['type'] == 'spot_chat') {
      _handleOpenedSpotChatMessage(message);
      return;
    }
    if (data['type'] != 'direct_message') {
      return;
    }
    final threadId = data['threadId']?.trim();
    final messageId = data['messageId']?.trim();
    if (threadId == null ||
        threadId.isEmpty ||
        messageId == null ||
        messageId.isEmpty) {
      return;
    }
    final event = DirectMessageNotificationEvent(
      threadId: threadId,
      messageId: messageId,
    );
    _pendingDirectMessageOpen = event;
    _directMessageOpenController.add(event);
  }

  Future<void> _handleOpenedSpotAlarmMessage(RemoteMessage message) async {
    final data = message.data;
    final alarmId = data['alarmId']?.trim();
    final repeatWindowRaw = data['repeatWindow']?.trim();
    final maxRepeats = int.tryParse(data['maxRepeats']?.trim() ?? '');
    final occurrenceIndex =
        int.tryParse(data['occurrenceIndex']?.trim() ?? '') ?? 0;
    if (alarmId == null ||
        alarmId.isEmpty ||
        repeatWindowRaw == null ||
        repeatWindowRaw.isEmpty ||
        maxRepeats == null ||
        maxRepeats <= 0) {
      return;
    }
    final title = message.notification?.title?.trim().isNotEmpty == true
        ? message.notification!.title!.trim()
        : (data['title']?.trim().isNotEmpty == true
              ? data['title']!.trim()
              : 'Alarma activa');
    final body = message.notification?.body?.trim().isNotEmpty == true
        ? message.notification!.body!.trim()
        : (data['body']?.trim().isNotEmpty == true
              ? data['body']!.trim()
              : 'Las condiciones del spot ya se estan cumpliendo.');
    final repeatWindow = AlarmRepeatWindow.values.firstWhere(
      (value) => value.name == repeatWindowRaw,
      orElse: () => AlarmRepeatWindow.min10,
    );
    await LocalNotificationsService.instance.handleRemoteSpotAlarmPushOpen(
      alarmId: alarmId,
      title: title,
      body: body,
      repeatWindow: repeatWindow,
      maxRepeats: maxRepeats,
      occurrenceIndex: occurrenceIndex,
    );
  }

  void _handleOpenedSpotChatMessage(RemoteMessage message) {
    final data = message.data;
    final spotName = data['spotName']?.trim();
    final spotArea = data['spotArea']?.trim();
    final messageId = data['messageId']?.trim();
    if (spotName == null ||
        spotName.isEmpty ||
        spotArea == null ||
        spotArea.isEmpty ||
        messageId == null ||
        messageId.isEmpty) {
      return;
    }
    final event = SpotChatNotificationEvent(
      spotName: spotName,
      spotArea: spotArea,
      messageId: messageId,
    );
    _pendingSpotChatOpen = event;
    _spotChatOpenController.add(event);
  }

  Future<void> _showForegroundDirectMessageNotification(
    RemoteMessage message,
  ) async {
    final data = message.data;
    final threadId = data['threadId']?.trim();
    final messageId = data['messageId']?.trim();
    if (threadId == null ||
        threadId.isEmpty ||
        messageId == null ||
        messageId.isEmpty) {
      return;
    }
    if (Platform.isIOS && message.notification != null) {
      return;
    }
    final senderName = message.notification?.title?.trim().isNotEmpty == true
        ? message.notification!.title!.trim()
        : (data['senderDisplayName']?.trim().isNotEmpty == true
              ? data['senderDisplayName']!.trim()
              : 'Nuevo mensaje');
    final body = message.notification?.body?.trim().isNotEmpty == true
        ? message.notification!.body!.trim()
        : (data['preview']?.trim().isNotEmpty == true
              ? data['preview']!.trim()
              : 'Tienes un mensaje nuevo.');
    await LocalNotificationsService.instance.showDirectMessage(
      threadId: threadId,
      messageId: messageId,
      senderName: senderName,
      body: body,
    );
  }

  Future<void> _showForegroundSpotChatNotification(
    RemoteMessage message,
  ) async {
    final data = message.data;
    final spotName = data['spotName']?.trim();
    final spotArea = data['spotArea']?.trim();
    final messageId = data['messageId']?.trim();
    if (spotName == null ||
        spotName.isEmpty ||
        spotArea == null ||
        spotArea.isEmpty ||
        messageId == null ||
        messageId.isEmpty) {
      return;
    }
    if (Platform.isIOS && message.notification != null) {
      return;
    }
    final senderName = message.notification?.title?.trim().isNotEmpty == true
        ? message.notification!.title!.trim()
        : (data['senderDisplayName']?.trim().isNotEmpty == true
              ? data['senderDisplayName']!.trim()
              : 'Chat del spot');
    final body = message.notification?.body?.trim().isNotEmpty == true
        ? message.notification!.body!.trim()
        : (data['preview']?.trim().isNotEmpty == true
              ? data['preview']!.trim()
              : 'Hay un mensaje nuevo en $spotName.');
    await LocalNotificationsService.instance.showSpotChatMessage(
      spotName: spotName,
      spotArea: spotArea,
      messageId: messageId,
      senderName: senderName,
      body: body,
    );
  }

  String _platformLabel() {
    if (Platform.isAndroid) {
      return 'android';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    return 'unknown';
  }

  String _deviceLabel() {
    if (Platform.isAndroid) {
      return 'Android';
    }
    if (Platform.isIOS) {
      return 'iPhone';
    }
    return 'Dispositivo';
  }

  Future<String?> _waitForApnsToken(FirebaseMessaging messaging) async {
    for (var attempt = 0; attempt < 8; attempt += 1) {
      final token = await messaging.getAPNSToken();
      if (token != null && token.trim().isNotEmpty) {
        return token;
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return null;
  }

  bool _isIosSimulator() {
    if (!Platform.isIOS) {
      return false;
    }
    final environment = Platform.environment;
    return environment.containsKey('SIMULATOR_DEVICE_NAME') ||
        environment.containsKey('SIMULATOR_UDID') ||
        environment.containsKey('SIMULATOR_MODEL_IDENTIFIER');
  }
}
