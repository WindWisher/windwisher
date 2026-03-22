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

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FirebaseMessaging.onBackgroundMessage(
        firebaseMessagingBackgroundHandler,
      );

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      await PushNotificationSubscriptionService.instance
          .setRemoteProviderConfigured(true);

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
}
