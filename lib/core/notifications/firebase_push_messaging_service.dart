import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:windwisher/firebase_options.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {
    // Ignore if Firebase is not configured on this build yet.
  }
}

class FirebasePushMessagingService {
  FirebasePushMessagingService._();

  static final FirebasePushMessagingService instance =
      FirebasePushMessagingService._();

  StreamSubscription<String>? _tokenRefreshSubscription;
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
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
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
