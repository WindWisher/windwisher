import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/spots/infrastructure/services/spot_alarm_sync_client.dart';

class SpotAlarmCatalog extends ChangeNotifier {
  SpotAlarmCatalog._() : _syncClient = SpotAlarmSyncClient.auto() {
    _activeStorageScope = _storageScopeForCurrentUser();
    _load();
    _authStateSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      _handleAuthScopeChanged();
    });
    if (_syncClient.canSync) {
      unawaited(hydrateFromRemote());
    }
  }

  static final SpotAlarmCatalog instance = SpotAlarmCatalog._();

  final SpotAlarmSyncClient _syncClient;
  StreamSubscription<AuthState>? _authStateSubscription;
  bool _globalEnabled = true;
  late String _activeStorageScope;
  final Map<String, bool> _spotEnabledByKey = <String, bool>{};
  final List<SpotAlarmRecord> _alarms = <SpotAlarmRecord>[];
  bool _remoteHydrated = false;
  String? _lastSyncError;

  bool get globalEnabled => _globalEnabled;
  bool get hasRemoteSync => _syncClient.canSync;
  String? get lastSyncError => _lastSyncError;

  File? get _file {
    if (kIsWeb) {
      return null;
    }
    return File(
      AppStoragePaths.resolve('spot_alarm_catalog_v1_$_activeStorageScope.json'),
    );
  }

  String _storageScopeForCurrentUser() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
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
    }
  }

  List<SpotAlarmRecord> get alarms =>
      List<SpotAlarmRecord>.unmodifiable(_alarms);

  Future<void> hydrateFromRemote() async {
    if (_remoteHydrated) {
      return;
    }
    final snapshot = await _syncClient.loadSnapshot();
    if (snapshot == null) {
      return;
    }
    _globalEnabled = snapshot.globalEnabled;
    _spotEnabledByKey
      ..clear()
      ..addAll(snapshot.spotEnabledByKey);
    _alarms
      ..clear()
      ..addAll(snapshot.alarms);
    _remoteHydrated = true;
    _save();
    notifyListeners();
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
      _lastSyncError = error.toString();
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  Future<bool> deleteAlarm(String alarmId) async {
    _alarms.removeWhere((alarm) => alarm.id == alarmId);
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
    bool clearLastTriggeredAt = false,
  }) {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index < 0) {
      return;
    }
    _alarms[index] = _alarms[index].copyWith(
      triggerCount: triggerCount,
      lastTriggeredAt: lastTriggeredAt,
      clearLastTriggeredAt: clearLastTriggeredAt,
    );
    _save();
    unawaited(_syncClient.saveAlarm(_alarms[index]));
    notifyListeners();
  }

  void snoozeAlarm(String alarmId, {DateTime? snoozedAt}) {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index < 0) {
      return;
    }
    _alarms[index] = _alarms[index].copyWith(
      lastTriggeredAt: snoozedAt ?? DateTime.now(),
    );
    _save();
    unawaited(_syncClient.saveAlarm(_alarms[index]));
    notifyListeners();
  }

  void stopAlarmUntilConditionsReset(String alarmId) {
    final index = _alarms.indexWhere((alarm) => alarm.id == alarmId);
    if (index < 0) {
      return;
    }
    final alarm = _alarms[index];
    _alarms[index] = alarm.copyWith(
      triggerCount: alarm.maxRepeats,
      lastTriggeredAt: DateTime.now(),
    );
    _save();
    unawaited(_syncClient.saveAlarm(_alarms[index]));
    notifyListeners();
  }

  void _load() {
    _globalEnabled = true;
    _spotEnabledByKey.clear();
    _alarms.clear();

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
    } catch (_) {
      _save();
    }
  }


  @override
  void dispose() {
    _authStateSubscription?.cancel();
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
    };
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }
}

class SpotAlarmRecord {
  const SpotAlarmRecord({
    required this.id,
    required this.spotKey,
    required this.spotName,
    required this.spotArea,
    required this.stationProvider,
    required this.stationKey,
    required this.stationName,
    required this.windRange,
    required this.startHour,
    required this.endHour,
    this.startMinute = 0,
    this.endMinute = 0,
    required this.directions,
    required this.repeatWindow,
    this.maxRepeats = 3,
    this.triggerCount = 0,
    this.lastTriggeredAt,
  });

  final String id;
  final String spotKey;
  final String spotName;
  final String spotArea;
  final String stationProvider;
  final String stationKey;
  final String stationName;
  final RangeValues windRange;
  final int startHour;
  final int endHour;
  final int startMinute;
  final int endMinute;
  final Set<String> directions;
  final AlarmRepeatWindow repeatWindow;
  final int maxRepeats;
  final int triggerCount;
  final DateTime? lastTriggeredAt;

  SpotAlarmRecord copyWith({
    RangeValues? windRange,
    int? startHour,
    int? endHour,
    int? startMinute,
    int? endMinute,
    Set<String>? directions,
    AlarmRepeatWindow? repeatWindow,
    int? maxRepeats,
    int? triggerCount,
    DateTime? lastTriggeredAt,
    bool clearLastTriggeredAt = false,
  }) {
    return SpotAlarmRecord(
      id: id,
      spotKey: spotKey,
      spotName: spotName,
      spotArea: spotArea,
      stationProvider: stationProvider,
      stationKey: stationKey,
      stationName: stationName,
      windRange: windRange ?? this.windRange,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      startMinute: startMinute ?? this.startMinute,
      endMinute: endMinute ?? this.endMinute,
      directions: directions ?? this.directions,
      repeatWindow: repeatWindow ?? this.repeatWindow,
      maxRepeats: maxRepeats ?? this.maxRepeats,
      triggerCount: triggerCount ?? this.triggerCount,
      lastTriggeredAt: clearLastTriggeredAt
          ? null
          : (lastTriggeredAt ?? this.lastTriggeredAt),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'spotKey': spotKey,
      'spotName': spotName,
      'spotArea': spotArea,
      'stationProvider': stationProvider,
      'stationKey': stationKey,
      'stationName': stationName,
      'windRangeStart': windRange.start,
      'windRangeEnd': windRange.end,
      'startHour': startHour,
      'endHour': endHour,
      'startMinute': startMinute,
      'endMinute': endMinute,
      'directions': directions.toList(growable: false),
      'repeatWindow': repeatWindow.name,
      'maxRepeats': maxRepeats,
      'triggerCount': triggerCount,
      'lastTriggeredAt': lastTriggeredAt?.toIso8601String(),
    };
  }

  factory SpotAlarmRecord.fromJson(Map<String, dynamic> json) {
    final rawDirections = json['directions'] as List<dynamic>? ?? const [];
    final repeatWindowName = json['repeatWindow'] as String? ?? '';
    return SpotAlarmRecord(
      id: json['id'] as String? ?? '',
      spotKey: json['spotKey'] as String? ?? '',
      spotName: json['spotName'] as String? ?? '',
      spotArea: json['spotArea'] as String? ?? '',
      stationProvider: json['stationProvider'] as String? ?? '',
      stationKey: json['stationKey'] as String? ?? '',
      stationName: json['stationName'] as String? ?? '',
      windRange: RangeValues(
        (json['windRangeStart'] as num?)?.toDouble() ?? 0,
        (json['windRangeEnd'] as num?)?.toDouble() ?? 0,
      ),
      startHour: (json['startHour'] as num?)?.toInt() ?? 0,
      endHour: (json['endHour'] as num?)?.toInt() ?? 0,
      startMinute: (json['startMinute'] as num?)?.toInt() ?? 0,
      endMinute: (json['endMinute'] as num?)?.toInt() ?? 0,
      directions: rawDirections
          .map((value) => value.toString())
          .where((value) => value.isNotEmpty)
          .toSet(),
      repeatWindow: AlarmRepeatWindow.values.firstWhere(
        (value) => value.name == repeatWindowName,
        orElse: () => AlarmRepeatWindow.min10,
      ),
      maxRepeats: (json['maxRepeats'] as num?)?.toInt() ?? 3,
      triggerCount: (json['triggerCount'] as num?)?.toInt() ?? 0,
      lastTriggeredAt: DateTime.tryParse(
        json['lastTriggeredAt'] as String? ?? '',
      ),
    );
  }

  bool isEquivalentTo(SpotAlarmRecord other) {
    return spotKey == other.spotKey &&
        stationProvider == other.stationProvider &&
        stationKey == other.stationKey &&
        windRange.start == other.windRange.start &&
        windRange.end == other.windRange.end &&
        startHour == other.startHour &&
        endHour == other.endHour &&
        startMinute == other.startMinute &&
        endMinute == other.endMinute &&
        repeatWindow == other.repeatWindow &&
        maxRepeats == other.maxRepeats &&
        directions.length == other.directions.length &&
        directions.containsAll(other.directions);
  }
}

enum AlarmRepeatWindow { min1, min5, min10, min15, min30 }
