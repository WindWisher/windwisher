import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/spots/infrastructure/services/spot_alarm_sync_client.dart';

class SpotAlarmCatalog extends ChangeNotifier {
  SpotAlarmCatalog._()
    : _file = File(AppStoragePaths.resolve('spot_alarm_catalog_v1.json')),
      _syncClient = SpotAlarmSyncClient.auto() {
    _load();
  }

  static final SpotAlarmCatalog instance = SpotAlarmCatalog._();

  final File _file;
  final SpotAlarmSyncClient _syncClient;
  bool _globalEnabled = true;
  final Map<String, bool> _spotEnabledByKey = <String, bool>{};
  final List<SpotAlarmRecord> _alarms = <SpotAlarmRecord>[];
  bool _remoteHydrated = false;

  bool get globalEnabled => _globalEnabled;
  bool get hasRemoteSync => _syncClient.canSync;

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

  void setGlobalEnabled(bool value) {
    if (_globalEnabled == value) {
      return;
    }
    _globalEnabled = value;
    _save();
    _syncClient.saveGlobalEnabled(value);
    notifyListeners();
  }

  void setSpotEnabled(String spotKey, bool value) {
    if ((_spotEnabledByKey[spotKey] ?? true) == value) {
      return;
    }
    _spotEnabledByKey[spotKey] = value;
    _save();
    _syncClient.saveSpotEnabled(spotKey: spotKey, enabled: value);
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

  void saveAlarm(SpotAlarmRecord alarm) {
    final index = _alarms.indexWhere((entry) => entry.id == alarm.id);
    if (index >= 0) {
      _alarms[index] = alarm;
    } else {
      _alarms.add(alarm);
    }
    _save();
    _syncClient.saveAlarm(alarm);
    notifyListeners();
  }

  void deleteAlarm(String alarmId) {
    _alarms.removeWhere((alarm) => alarm.id == alarmId);
    _save();
    _syncClient.deleteAlarm(alarmId);
    notifyListeners();
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
    _syncClient.saveAlarm(_alarms[index]);
    notifyListeners();
  }

  void _load() {
    if (!_file.existsSync()) {
      _save();
      return;
    }

    try {
      final raw = _file.readAsStringSync();
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
      _globalEnabled = true;
      _spotEnabledByKey.clear();
      _alarms.clear();
      _save();
    }
  }

  void _save() {
    final data = <String, dynamic>{
      'globalEnabled': _globalEnabled,
      'spotEnabledByKey': _spotEnabledByKey,
      'alarms': _alarms.map((alarm) => alarm.toJson()).toList(growable: false),
    };
    _file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
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
  final Set<String> directions;
  final AlarmRepeatWindow repeatWindow;
  final int maxRepeats;
  final int triggerCount;
  final DateTime? lastTriggeredAt;

  SpotAlarmRecord copyWith({
    RangeValues? windRange,
    int? startHour,
    int? endHour,
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
        repeatWindow == other.repeatWindow &&
        maxRepeats == other.maxRepeats &&
        directions.length == other.directions.length &&
        directions.containsAll(other.directions);
  }
}

enum AlarmRepeatWindow { min5, min10, min15, min30 }
