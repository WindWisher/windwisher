import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:windwisher/firebase_options.dart';
import 'package:windwisher/core/notifications/local_notifications_service.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final alarmId = message.data['alarmId']?.trim();
    final repeatWindowRaw = message.data['repeatWindow']?.trim();
    final maxRepeats = int.tryParse(message.data['maxRepeats'] ?? '');
    if (message.data['type'] == 'spot_alarm' &&
        alarmId != null &&
        alarmId.isNotEmpty &&
        repeatWindowRaw != null &&
        maxRepeats != null &&
        maxRepeats > 0) {
      await LocalNotificationsService.instance.scheduleAlarmCycleFromRemotePush(
        alarmId: alarmId,
        title: message.notification?.title?.trim().isNotEmpty == true
            ? message.notification!.title!.trim()
            : 'Alarma de spot',
        body: message.notification?.body?.trim().isNotEmpty == true
            ? message.notification!.body!.trim()
            : 'La alarma ya esta activa.',
        repeatWindow: AlarmRepeatWindow.values.firstWhere(
          (value) => value.name == repeatWindowRaw,
          orElse: () => AlarmRepeatWindow.min10,
        ),
        maxRepeats: maxRepeats,
      );
    }
  } catch (_) {
    // Ignore if Firebase is not configured on this build yet.
  }
}

class FirebasePushMessagingService {
  FirebasePushMessagingService._();

  static final FirebasePushMessagingService instance =
      FirebasePushMessagingService._();

  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(false);
      return;
    }

    if (_isIosSimulator()) {
      debugPrint(
        'FirebasePushMessagingService: iOS simulator detected; skipping Firebase Messaging initialization.',
      );
      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(false);
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (_isIosSimulator()) {
        debugPrint(
          'FirebasePushMessagingService: iOS simulator detected; skipping FCM token registration.',
        );
        await PushNotificationSubscriptionService.instance
            .setRemoteProviderConfigured(false);
        return;
      }

      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(true);

      if (Platform.isIOS) {
        final apnsToken = await _waitForApnsToken(messaging);
        if (apnsToken == null || apnsToken.trim().isEmpty) {
          debugPrint(
            'FirebasePushMessagingService: APNs token not available on iOS; skipping FCM token registration.',
          );
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

      _foregroundMessageSubscription = FirebaseMessaging.onMessage.listen((
        message,
      ) async {
        await _showForegroundAlarmNotification(message);
      });

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
    } catch (_) {
      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(false);
    }
  }

  Future<void> dispose() async {
    await _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = null;
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }

  Future<void> _showForegroundAlarmNotification(RemoteMessage message) async {
    final data = message.data;
    if (data['type'] != 'spot_alarm') {
      return;
    }
    final alarmId = data['alarmId']?.trim();
    if (alarmId == null || alarmId.isEmpty) {
      return;
    }
    final title =
        message.notification?.title?.trim().isNotEmpty == true
        ? message.notification!.title!.trim()
        : 'Alarma de spot';
    final body =
        message.notification?.body?.trim().isNotEmpty == true
        ? message.notification!.body!.trim()
        : 'La alarma ya esta activa.';
    final repeatWindow = AlarmRepeatWindow.values.firstWhere(
      (value) => value.name == (data['repeatWindow']?.trim() ?? ''),
      orElse: () => AlarmRepeatWindow.min10,
    );
    final maxRepeats = int.tryParse(data['maxRepeats']?.trim() ?? '') ?? 1;
    await LocalNotificationsService.instance.showSpotAlarm(
      alarmId: alarmId,
      title: title,
      body: body,
      repeatWindow: repeatWindow,
      maxRepeats: maxRepeats,
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
