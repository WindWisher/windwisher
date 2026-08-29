import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/core/config/env/initialized_supabase_client.dart';
import 'package:windwisher/features/spots/application/models/spot_alarm_record.dart';
import 'package:windwisher/features/spots/application/services/spot_alarm_sync_service.dart';
import 'package:windwisher/features/spots/di/spots_module.dart';

export 'package:windwisher/features/spots/application/models/spot_alarm_record.dart';

class SpotAlarmCatalog extends ChangeNotifier {
  SpotAlarmCatalog._() : _syncClient = SpotsModule.createAlarmSyncService() {
    final client = resolveInitializedSupabaseClient();
    _activeStorageScope = _storageScopeForClient(client);
    _load();
    _authStateSubscription = client?.auth.onAuthStateChange.listen((_) {
      _handleAuthScopeChanged();
    });
    if (_syncClient.canSync) {
      unawaited(hydrateFromRemote());
    } else if (_pendingSyncAlarmIds.isNotEmpty) {
      _schedulePendingAlarmSyncRetry();
    }
  }

  static final SpotAlarmCatalog instance = SpotAlarmCatalog._();
  static const int _maxPendingSyncAttempts = 5;
  static const List<Duration> _pendingSyncRetryDelays = <Duration>[
    Duration(seconds: 30),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 15),
    Duration(minutes: 30),
  ];

  final SpotAlarmSyncService _syncClient;
  StreamSubscription<AuthState>? _authStateSubscription;
  bool _globalEnabled = true;
  late String _activeStorageScope;
  final Map<String, bool> _spotEnabledByKey = <String, bool>{};
  final List<SpotAlarmRecord> _alarms = <SpotAlarmRecord>[];
  final Set<String> _pendingSyncAlarmIds = <String>{};
  final Map<String, int> _pendingSyncAttemptsByAlarmId = <String, int>{};
  Timer? _pendingSyncRetryTimer;
  bool _remoteHydrated = false;
  String? _lastSyncError;

  bool get globalEnabled => _globalEnabled;
  bool get hasRemoteSync => _syncClient.canSync;
  bool get hasPendingAlarmSync => _pendingSyncAlarmIds.isNotEmpty;
  int get pendingAlarmSyncCount => _pendingSyncAlarmIds.length;
  String? get lastSyncError => _lastSyncError;

  File? get _file {
    if (kIsWeb) {
      return null;
    }
    return File(
      AppStoragePaths.resolve(
        'spot_alarm_catalog_v1_$_activeStorageScope.json',
      ),
    );
  }

  String _storageScopeForCurrentUser() {
    return _storageScopeForClient(resolveInitializedSupabaseClient());
  }

  String _storageScopeForClient(SupabaseClient? client) {
    final userId = client?.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      return 'guest';
    }
    return userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  Future<void> _handleAuthScopeChanged() async {
    final nextScope = _storageScopeForCurrentUser();
    if (_activeStorageScope == nextScope) {
      return;
    }
    _activeStorageScope = nextScope;
    _remoteHydrated = false;
    _lastSyncError = null;
    _load();
    notifyListeners();
    if (_syncClient.canSync) {
      await hydrateFromRemote();
    } else if (_pendingSyncAlarmIds.isNotEmpty) {
      _schedulePendingAlarmSyncRetry();
    }
  }

  List<SpotAlarmRecord> get alarms =>
      List<SpotAlarmRecord>.unmodifiable(_alarms);

  Future<void> hydrateFromRemote() async {
    if (_remoteHydrated) {
      return;
    }
    await retryPendingAlarmSync();
    final snapshot = await _syncClient.loadSnapshot();
    if (snapshot == null) {
      return;
    }
    final pendingLocalAlarms = _alarms
        .where((alarm) => _pendingSyncAlarmIds.contains(alarm.id))
        .toList(growable: false);
    _globalEnabled = snapshot.globalEnabled;
    _spotEnabledByKey
      ..clear()
      ..addAll(snapshot.spotEnabledByKey);
    _alarms
      ..clear()
      ..addAll(snapshot.alarms);
    for (final pendingAlarm in pendingLocalAlarms) {
      final index = _alarms.indexWhere((alarm) => alarm.id == pendingAlarm.id);
      if (index >= 0) {
        _alarms[index] = pendingAlarm;
      } else {
        _alarms.add(pendingAlarm);
      }
    }
    _remoteHydrated = true;
    _save();
    notifyListeners();
  }

  Future<int> retryPendingAlarmSync() async {
    if (!_syncClient.canSync || _pendingSyncAlarmIds.isEmpty) {
      return 0;
    }
    var synced = 0;
    final pendingIds = _pendingSyncAlarmIds.toList(growable: false);
    for (final alarmId in pendingIds) {
      final attempts = _pendingSyncAttemptsByAlarmId[alarmId] ?? 0;
      if (attempts >= _maxPendingSyncAttempts) {
        continue;
      }
      final alarm = _alarmById(alarmId);
      if (alarm == null) {
        _pendingSyncAlarmIds.remove(alarmId);
        _pendingSyncAttemptsByAlarmId.remove(alarmId);
        continue;
      }
      try {
        _lastSyncError = null;
        await _syncClient.saveAlarm(alarm);
        _pendingSyncAlarmIds.remove(alarmId);
        _pendingSyncAttemptsByAlarmId.remove(alarmId);
        synced += 1;
      } catch (error) {
        _pendingSyncAttemptsByAlarmId[alarmId] = attempts + 1;
        _lastSyncError = error.toString();
      }
    }
    _save();
    notifyListeners();
    if (_pendingSyncAlarmIds.isNotEmpty) {
      _schedulePendingAlarmSyncRetry();
    }
    return synced;
  }

  bool isSpotEnabled(String spotKey) => _spotEnabledByKey[spotKey] ?? true;

  Future<void> setGlobalEnabled(bool value) async {
    if (_globalEnabled == value) {
      return;
    }
    _globalEnabled = value;
    _save();
    try {
      _lastSyncError = null;
      await _syncClient.saveGlobalEnabled(value);
    } catch (error) {
      _lastSyncError = error.toString();
    }
    notifyListeners();
  }

  Future<void> setSpotEnabled(String spotKey, bool value) async {
    if ((_spotEnabledByKey[spotKey] ?? true) == value) {
      return;
    }
    _spotEnabledByKey[spotKey] = value;
    _save();
    try {
      _lastSyncError = null;
      await _syncClient.saveSpotEnabled(spotKey: spotKey, enabled: value);
    } catch (error) {
      _lastSyncError = error.toString();
    }
    notifyListeners();
  }

  Future<void> setAlarmEnabled(String alarmId, bool value) async {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index < 0 || _alarms[index].enabled == value) {
      return;
    }
    _alarms[index] = _alarms[index].copyWith(enabled: value);
    _save();
    try {
      _lastSyncError = null;
      await _syncClient.saveAlarm(_alarms[index]);
      _pendingSyncAlarmIds.remove(alarmId);
      _pendingSyncAttemptsByAlarmId.remove(alarmId);
    } catch (error) {
      _pendingSyncAlarmIds.add(alarmId);
      _pendingSyncAttemptsByAlarmId[alarmId] =
          (_pendingSyncAttemptsByAlarmId[alarmId] ?? 0) + 1;
      _lastSyncError = error.toString();
      _schedulePendingAlarmSyncRetry();
    }
    _save();
    notifyListeners();
  }

  List<SpotAlarmRecord> alarmsForSpot(String spotKey) {
    return _alarms
        .where((alarm) => alarm.spotKey == spotKey)
        .toList(growable: false);
  }

  bool hasEquivalentAlarm(SpotAlarmRecord alarm, {String? excludingId}) {
    return _alarms.any(
      (entry) => entry.id != excludingId && entry.isEquivalentTo(alarm),
    );
  }

  Future<bool> saveAlarm(SpotAlarmRecord alarm) async {
    final index = _alarms.indexWhere((entry) => entry.id == alarm.id);
    if (index >= 0) {
      _alarms[index] = alarm;
    } else {
      _alarms.add(alarm);
    }
    _save();
    try {
      _lastSyncError = null;
      await _syncClient.saveAlarm(alarm);
    } catch (error) {
      _pendingSyncAlarmIds.add(alarm.id);
      _pendingSyncAttemptsByAlarmId[alarm.id] =
          (_pendingSyncAttemptsByAlarmId[alarm.id] ?? 0) + 1;
      _save();
      _lastSyncError = error.toString();
      _schedulePendingAlarmSyncRetry();
      notifyListeners();
      return false;
    }
    _pendingSyncAlarmIds.remove(alarm.id);
    _pendingSyncAttemptsByAlarmId.remove(alarm.id);
    _save();
    notifyListeners();
    return true;
  }

  Future<bool> deleteAlarm(String alarmId) async {
    _alarms.removeWhere((alarm) => alarm.id == alarmId);
    _pendingSyncAlarmIds.remove(alarmId);
    _pendingSyncAttemptsByAlarmId.remove(alarmId);
    _save();
    try {
      _lastSyncError = null;
      await _syncClient.deleteAlarm(alarmId);
    } catch (error) {
      _lastSyncError = error.toString();
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  void updateTriggerState({
    required String alarmId,
    required int triggerCount,
    DateTime? lastTriggeredAt,
    bool? stoppedUntilReset,
    bool clearLastTriggeredAt = false,
    bool clearSnoozedUntil = false,
  }) {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index < 0) {
      return;
    }
    _alarms[index] = _alarms[index].copyWith(
      triggerCount: triggerCount,
      lastTriggeredAt: lastTriggeredAt,
      stoppedUntilReset: stoppedUntilReset,
      clearLastTriggeredAt: clearLastTriggeredAt,
      clearSnoozedUntil: clearSnoozedUntil,
    );
    _save();
    _queueBestEffortAlarmSync(_alarms[index]);
    notifyListeners();
  }

  Future<void> snoozeAlarm(String alarmId, {DateTime? snoozedAt}) async {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index < 0) {
      return;
    }
    final alarm = _alarms[index];
    final now = snoozedAt ?? DateTime.now();
    _alarms[index] = _alarms[index].copyWith(
      triggerCount: alarm.triggerCount,
      lastTriggeredAt: now,
      snoozedUntil: now.add(alarm.repeatWindow.duration),
      stoppedUntilReset: false,
    );
    _save();
    await _syncAlarmRuntimeControlsNow(_alarms[index]);
    notifyListeners();
  }

  Future<void> snoozeAlarmFromNotification({
    required String alarmId,
    required DateTime snoozedUntil,
    DateTime? snoozedAt,
  }) async {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index < 0) {
      await _syncClient.saveAlarmRuntimeControlsFromNotification(
        alarmId: alarmId,
        snoozedUntil: snoozedUntil,
        stoppedUntilReset: false,
      );
      return;
    }
    final alarm = _alarms[index];
    _alarms[index] = _alarms[index].copyWith(
      triggerCount: alarm.triggerCount,
      lastTriggeredAt: snoozedAt ?? DateTime.now(),
      snoozedUntil: snoozedUntil,
      stoppedUntilReset: false,
    );
    _save();
    await _syncAlarmRuntimeControlsNow(_alarms[index]);
    notifyListeners();
  }

  Future<void> stopAlarmUntilConditionsReset(String alarmId) async {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index < 0) {
      await _syncClient.saveAlarmRuntimeControlsFromNotification(
        alarmId: alarmId,
        stoppedUntilReset: true,
      );
      return;
    }
    final alarm = _alarms[index];
    _alarms[index] = alarm.copyWith(
      triggerCount: alarm.triggerCount,
      lastTriggeredAt: DateTime.now(),
      stoppedUntilReset: true,
      clearSnoozedUntil: true,
    );
    _save();
    await _syncAlarmRuntimeControlsNow(_alarms[index]);
    notifyListeners();
  }

  SpotAlarmRecord? _alarmById(String alarmId) {
    for (final alarm in _alarms) {
      if (alarm.id == alarmId) {
        return alarm;
      }
    }
    return null;
  }

  void _queueBestEffortAlarmSync(SpotAlarmRecord alarm) {
    unawaited(
      _syncClient
          .saveAlarm(alarm)
          .then((_) {
            _pendingSyncAlarmIds.remove(alarm.id);
            _pendingSyncAttemptsByAlarmId.remove(alarm.id);
            _save();
            notifyListeners();
          })
          .catchError((Object error) {
            _pendingSyncAlarmIds.add(alarm.id);
            _pendingSyncAttemptsByAlarmId[alarm.id] =
                (_pendingSyncAttemptsByAlarmId[alarm.id] ?? 0) + 1;
            _lastSyncError = error.toString();
            _save();
            _schedulePendingAlarmSyncRetry();
            notifyListeners();
          }),
    );
  }

  Future<void> _syncAlarmRuntimeControlsNow(SpotAlarmRecord alarm) async {
    try {
      _lastSyncError = null;
      await _syncClient.saveAlarmRuntimeControls(
        alarmId: alarm.id,
        snoozedUntil: alarm.snoozedUntil,
        stoppedUntilReset: alarm.stoppedUntilReset,
      );
    } catch (error) {
      _lastSyncError = error.toString();
    }
    _save();
  }

  void _schedulePendingAlarmSyncRetry() {
    if (_pendingSyncRetryTimer?.isActive ?? false) {
      return;
    }
    final delay = _nextPendingSyncRetryDelay();
    if (delay == null) {
      return;
    }
    _pendingSyncRetryTimer = Timer(delay, () {
      _pendingSyncRetryTimer = null;
      if (_pendingSyncAlarmIds.isEmpty) {
        return;
      }
      unawaited(retryPendingAlarmSync());
    });
  }

  Duration? _nextPendingSyncRetryDelay() {
    int? minAttempts;
    for (final alarmId in _pendingSyncAlarmIds) {
      final attempts = _pendingSyncAttemptsByAlarmId[alarmId] ?? 0;
      if (attempts >= _maxPendingSyncAttempts) {
        continue;
      }
      minAttempts = minAttempts == null
          ? attempts
          : math.min(minAttempts, attempts);
    }
    if (minAttempts == null) {
      return null;
    }
    final delayIndex = minAttempts.clamp(0, _pendingSyncRetryDelays.length - 1);
    return _pendingSyncRetryDelays[delayIndex];
  }

  void _load() {
    _globalEnabled = true;
    _spotEnabledByKey.clear();
    _alarms.clear();
    _pendingSyncAlarmIds.clear();
    _pendingSyncAttemptsByAlarmId.clear();

    final file = _file;
    if (file == null) {
      return;
    }
    if (!file.existsSync()) {
      _save();
      return;
    }

    try {
      final raw = file.readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _globalEnabled = json['globalEnabled'] as bool? ?? true;

      final rawSpotEnabled = json['spotEnabledByKey'] as Map<String, dynamic>?;
      _spotEnabledByKey
        ..clear()
        ..addAll(
          rawSpotEnabled?.map(
                (key, value) => MapEntry(key, value as bool? ?? true),
              ) ??
              const <String, bool>{},
        );

      final rawAlarms = json['alarms'] as List<dynamic>?;
      _alarms
        ..clear()
        ..addAll(
          rawAlarms
                  ?.whereType<Map<String, dynamic>>()
                  .map(SpotAlarmRecord.fromJson)
                  .toList(growable: false) ??
              const <SpotAlarmRecord>[],
        );
      final rawPendingSyncAlarmIds =
          json['pendingSyncAlarmIds'] as List<dynamic>?;
      _pendingSyncAlarmIds
        ..clear()
        ..addAll(
          rawPendingSyncAlarmIds
                  ?.map((value) => value.toString())
                  .where((value) => value.isNotEmpty) ??
              const <String>[],
        );
      final rawPendingSyncAttempts =
          json['pendingSyncAttemptsByAlarmId'] as Map<String, dynamic>?;
      _pendingSyncAttemptsByAlarmId
        ..clear()
        ..addAll(
          rawPendingSyncAttempts?.map(
                (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
              ) ??
              const <String, int>{},
        );
    } catch (_) {
      _save();
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _pendingSyncRetryTimer?.cancel();
    super.dispose();
  }

  void _save() {
    final file = _file;
    if (file == null) {
      return;
    }
    final data = <String, dynamic>{
      'globalEnabled': _globalEnabled,
      'spotEnabledByKey': _spotEnabledByKey,
      'alarms': _alarms.map((alarm) => alarm.toJson()).toList(growable: false),
      'pendingSyncAlarmIds': _pendingSyncAlarmIds.toList(growable: false),
      'pendingSyncAttemptsByAlarmId': _pendingSyncAttemptsByAlarmId,
    };
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }
}
