import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_sync_client.dart';
import 'package:windwisher/core/notifications/push_notification_preferences.dart';
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
  static const _webStorageKey = 'push_notifications_state_v2';

  final File _file;
  final PushNotificationSubscriptionSyncClient _syncClient;
  StreamSubscription<AuthState>? _authStateSubscription;
  bool _initialized = false;
  final PushNotificationPreferences _preferences =
      PushNotificationPreferences();
  bool _remoteProviderConfigured = false;
  String? _deviceToken;
  String? _provider;
  String? _platform;
  String? _deviceLabel;

  bool get enabled => _preferences.enabledFor(_currentAccountKey);

  bool categoryEnabled(PushNotificationCategory category) =>
      _preferences.categoryEnabledFor(_currentAccountKey, category);

  bool get spotAlarmsEnabled =>
      categoryEnabled(PushNotificationCategory.spotAlarms);

  bool get directMessagesEnabled =>
      categoryEnabled(PushNotificationCategory.directMessages);

  bool get spotChatMentionsEnabled =>
      categoryEnabled(PushNotificationCategory.spotChatMentions);

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
    notifyListeners();
  }

  Future<PushSubscriptionSyncStatus> setEnabled(bool value) async {
    await initialize();
    if (enabled == value) {
      return _syncStatusForCurrentState();
    }
    _preferences.setEnabled(_currentAccountKey, value);
    await _save();
    await _syncRemoteStateIfPossible();
    notifyListeners();
    return _syncStatusForCurrentState();
  }

  Future<PushSubscriptionSyncStatus> setCategoryEnabled(
    PushNotificationCategory category,
    bool value,
  ) async {
    await initialize();
    if (categoryEnabled(category) == value) {
      return _syncStatusForCurrentState();
    }
    _preferences.setCategoryEnabled(_currentAccountKey, category, value);
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

  Future<void> disableCurrentDeviceSubscriptionForSignedInUser() async {
    await initialize();
    final token = _deviceToken;
    if (token == null || token.isEmpty || !_syncClient.canSync) {
      return;
    }
    await _syncClient.setSubscriptionEnabled(
      deviceToken: token,
      enabled: false,
    );
  }

  PushSubscriptionSyncStatus _syncStatusForCurrentState() {
    if (!enabled) {
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
    if (kIsWeb) {
      final preferences = await SharedPreferences.getInstance();
      final raw = preferences.getString(_webStorageKey);
      if (raw == null || raw.isEmpty) {
        return;
      }
      try {
        _loadJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        _resetState();
        await preferences.remove(_webStorageKey);
      }
      return;
    }
    if (!await _file.exists()) {
      await _save();
      return;
    }
    try {
      final raw = await _file.readAsString();
      _loadJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      _resetState();
      await _save();
    }
  }

  Future<void> _save() async {
    final raw = const JsonEncoder.withIndent('  ').convert(<String, dynamic>{
      'schemaVersion': 3,
      'enabledByAccount': _preferences.toJson(),
      'categoriesByAccount': _preferences.categoriesToJson(),
      'remoteProviderConfigured': _remoteProviderConfigured,
      'deviceToken': _deviceToken,
      'provider': _provider,
      'platform': _platform,
      'deviceLabel': _deviceLabel,
    });
    if (kIsWeb) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(_webStorageKey, raw);
      return;
    }
    await _file.writeAsString(raw);
  }

  void _loadJson(Map<String, dynamic> json) {
    _preferences.load(json, legacyAccountKey: _currentAccountKey);
    _remoteProviderConfigured =
        json['remoteProviderConfigured'] as bool? ?? false;
    _deviceToken = json['deviceToken'] as String?;
    _provider = json['provider'] as String?;
    _platform = json['platform'] as String?;
    _deviceLabel = json['deviceLabel'] as String?;
  }

  void _resetState() {
    _preferences.clear();
    _remoteProviderConfigured = false;
    _deviceToken = null;
    _provider = null;
    _platform = null;
    _deviceLabel = null;
  }

  Future<void> _syncRemoteStateIfPossible() async {
    final token = _deviceToken;
    if (!_syncClient.canSync || token == null || token.isEmpty) {
      return;
    }
    if (!enabled) {
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
      spotAlarmsEnabled: spotAlarmsEnabled,
      directMessagesEnabled: directMessagesEnabled,
      spotChatMentionsEnabled: spotChatMentionsEnabled,
    );
  }

  void _attachAuthListener() {
    if (_authStateSubscription != null) {
      return;
    }
    try {
      _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((_) {
            notifyListeners();
            unawaited(_syncRemoteStateIfPossible());
          });
    } catch (_) {
      _authStateSubscription = null;
    }
  }

  String get _currentAccountKey {
    try {
      return Supabase.instance.client.auth.currentUser?.id ?? 'signed-out';
    } catch (_) {
      return 'signed-out';
    }
  }
}
