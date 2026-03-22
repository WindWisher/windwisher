import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_sync_client.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';

enum PushSubscriptionSyncStatus {
  synced,
  disabled,
  unauthenticated,
  providerNotConfigured,
  missingDeviceToken,
}

class PushNotificationSubscriptionService extends ChangeNotifier {
  PushNotificationSubscriptionService._()
    : _file = File(AppStoragePaths.resolve('push_notifications_state_v1.json')),
      _syncClient = PushNotificationSubscriptionSyncClient.auto();

  static final PushNotificationSubscriptionService instance =
      PushNotificationSubscriptionService._();

  final File _file;
  final PushNotificationSubscriptionSyncClient _syncClient;
  StreamSubscription<AuthState>? _authStateSubscription;
  bool _initialized = false;
  bool _enabled = true;
  bool _remoteProviderConfigured = false;
  String? _deviceToken;
  String? _provider;
  String? _platform;
  String? _deviceLabel;

  bool get enabled => _enabled;

  bool get remoteProviderConfigured => _remoteProviderConfigured;

  String? get deviceToken => _deviceToken;

  PushSubscriptionSyncStatus get currentStatus => _syncStatusForCurrentState();

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await _load();
    _attachAuthListener();
  }

  Future<PushSubscriptionSyncStatus> setEnabled(bool value) async {
    await initialize();
    if (_enabled == value) {
      return _syncStatusForCurrentState();
    }
    _enabled = value;
    await _save();
    await _syncRemoteStateIfPossible();
    notifyListeners();
    return _syncStatusForCurrentState();
  }

  Future<PushSubscriptionSyncStatus> registerDeviceToken({
    required String token,
    required String provider,
    required String platform,
    String? deviceLabel,
  }) async {
    await initialize();
    _deviceToken = token.trim().isEmpty ? null : token.trim();
    _provider = provider.trim().isEmpty ? null : provider.trim();
    _platform = platform.trim().isEmpty ? null : platform.trim();
    _deviceLabel = deviceLabel?.trim().isEmpty ?? true
        ? null
        : deviceLabel?.trim();
    await _save();
    await _syncRemoteStateIfPossible();
    notifyListeners();
    return _syncStatusForCurrentState();
  }

  Future<void> setRemoteProviderConfigured(bool value) async {
    await initialize();
    if (_remoteProviderConfigured == value) {
      return;
    }
    _remoteProviderConfigured = value;
    await _save();
    notifyListeners();
  }

  Future<void> clearDeviceToken() async {
    await initialize();
    final token = _deviceToken;
    _deviceToken = null;
    _provider = null;
    _platform = null;
    _deviceLabel = null;
    await _save();
    if (token != null && _syncClient.canSync) {
      await _syncClient.deleteSubscription(token);
    }
    notifyListeners();
  }

  PushSubscriptionSyncStatus _syncStatusForCurrentState() {
    if (!_enabled) {
      return PushSubscriptionSyncStatus.disabled;
    }
    if (!remoteProviderConfigured) {
      return PushSubscriptionSyncStatus.providerNotConfigured;
    }
    if (_deviceToken == null || _deviceToken!.isEmpty) {
      return PushSubscriptionSyncStatus.missingDeviceToken;
    }
    User? user;
    try {
      user = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      user = null;
    }
    if (user == null) {
      return PushSubscriptionSyncStatus.unauthenticated;
    }
    return PushSubscriptionSyncStatus.synced;
  }

  Future<void> _load() async {
    if (!await _file.exists()) {
      await _save();
      return;
    }
    try {
      final raw = await _file.readAsString();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _enabled = json['enabled'] as bool? ?? true;
      _remoteProviderConfigured =
          json['remoteProviderConfigured'] as bool? ?? false;
      _deviceToken = json['deviceToken'] as String?;
      _provider = json['provider'] as String?;
      _platform = json['platform'] as String?;
      _deviceLabel = json['deviceLabel'] as String?;
    } catch (_) {
      _enabled = true;
      _remoteProviderConfigured = false;
      _deviceToken = null;
      _provider = null;
      _platform = null;
      _deviceLabel = null;
      await _save();
    }
  }

  Future<void> _save() async {
    final raw = const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
      'enabled': _enabled,
      'remoteProviderConfigured': _remoteProviderConfigured,
      'deviceToken': _deviceToken,
      'provider': _provider,
      'platform': _platform,
      'deviceLabel': _deviceLabel,
    });
    await _file.writeAsString(raw);
  }

  Future<void> _syncRemoteStateIfPossible() async {
    final token = _deviceToken;
    if (!_syncClient.canSync || token == null || token.isEmpty) {
      return;
    }
    if (!_enabled) {
      await _syncClient.setSubscriptionEnabled(
        deviceToken: token,
        enabled: false,
      );
      return;
    }
    if (!remoteProviderConfigured) {
      return;
    }
    final provider = _provider;
    final platform = _platform;
    if (provider == null || platform == null) {
      return;
    }
    await _syncClient.upsertSubscription(
      deviceToken: token,
      platform: platform,
      provider: provider,
      deviceLabel: _deviceLabel,
      enabled: true,
    );
  }

  void _attachAuthListener() {
    if (_authStateSubscription != null) {
      return;
    }
    try {
      _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((_) {
            unawaited(_syncRemoteStateIfPossible());
          });
    } catch (_) {
      _authStateSubscription = null;
    }
  }
}
