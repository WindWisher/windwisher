import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

class SpotAlarmSyncSnapshot {
  const SpotAlarmSyncSnapshot({
    required this.globalEnabled,
    required this.spotEnabledByKey,
    required this.alarms,
  });

  final bool globalEnabled;
  final Map<String, bool> spotEnabledByKey;
  final List<SpotAlarmRecord> alarms;
}

class SpotAlarmSyncClient {
  SpotAlarmSyncClient._({
    required SupabaseClient? client,
    required bool useSupabase,
  }) : _client = client,
       _useSupabase = useSupabase;

  factory SpotAlarmSyncClient.auto({SupabaseClient? client}) {
    final hasSupabase =
        EnvConfig.supabaseUrl.trim().isNotEmpty &&
        EnvConfig.supabaseAnonKey.trim().isNotEmpty;
    return SpotAlarmSyncClient._(
      client: hasSupabase ? (client ?? Supabase.instance.client) : null,
      useSupabase: hasSupabase,
    );
  }

  static const String _globalScopeKey = '__global__';

  final SupabaseClient? _client;
  final bool _useSupabase;

  bool get canSync => _useSupabase && _client?.auth.currentUser != null;

  Future<SpotAlarmSyncSnapshot?> loadSnapshot() async {
    if (!canSync || _client == null) {
      return null;
    }

    final alarmRows = await _client
        .from('spot_alarms')
        .select()
        .order('created_at', ascending: false);
    final preferenceRows = await _client
        .from('spot_alarm_preferences')
        .select();

    var globalEnabled = true;
    final spotEnabledByKey = <String, bool>{};
    for (final row
        in (preferenceRows as List<dynamic>)
            .whereType<Map<String, dynamic>>()) {
      final scopeKey = row['scope_key'] as String? ?? '';
      final enabled = row['enabled'] as bool? ?? true;
      if (scopeKey == _globalScopeKey) {
        globalEnabled = enabled;
      } else if (scopeKey.isNotEmpty) {
        spotEnabledByKey[scopeKey] = enabled;
      }
    }

    final alarms = (alarmRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_alarmFromRow)
        .toList(growable: false);
    return SpotAlarmSyncSnapshot(
      globalEnabled: globalEnabled,
      spotEnabledByKey: spotEnabledByKey,
      alarms: alarms,
    );
  }

  void saveAlarm(SpotAlarmRecord alarm) {
    if (!canSync || _client == null) {
      return;
    }
    unawaited(
      _client.from('spot_alarms').upsert(<String, dynamic>{
        'id': alarm.id,
        'spot_key': alarm.spotKey,
        'spot_name': alarm.spotName,
        'spot_area': alarm.spotArea,
        'station_provider': alarm.stationProvider,
        'station_key': alarm.stationKey,
        'station_name': alarm.stationName,
        'wind_range_start': alarm.windRange.start,
        'wind_range_end': alarm.windRange.end,
        'start_hour': alarm.startHour,
        'end_hour': alarm.endHour,
        'directions': alarm.directions.toList(growable: false),
        'repeat_window': alarm.repeatWindow.name,
        'max_repeats': alarm.maxRepeats,
        'trigger_count': alarm.triggerCount,
        'last_triggered_at': alarm.lastTriggeredAt?.toUtc().toIso8601String(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }

  void deleteAlarm(String alarmId) {
    if (!canSync || _client == null) {
      return;
    }
    unawaited(_client.from('spot_alarms').delete().eq('id', alarmId));
  }

  void saveGlobalEnabled(bool enabled) {
    _savePreference(scopeKey: _globalScopeKey, enabled: enabled);
  }

  void saveSpotEnabled({required String spotKey, required bool enabled}) {
    _savePreference(scopeKey: spotKey, enabled: enabled);
  }

  SpotAlarmRecord _alarmFromRow(Map<String, dynamic> row) {
    final rawDirections = row['directions'] as List<dynamic>? ?? const [];
    return SpotAlarmRecord(
      id: row['id'] as String? ?? '',
      spotKey: row['spot_key'] as String? ?? '',
      spotName: row['spot_name'] as String? ?? '',
      spotArea: row['spot_area'] as String? ?? '',
      stationProvider: row['station_provider'] as String? ?? '',
      stationKey: row['station_key'] as String? ?? '',
      stationName: row['station_name'] as String? ?? '',
      windRange: RangeValues(
        (row['wind_range_start'] as num?)?.toDouble() ?? 0,
        (row['wind_range_end'] as num?)?.toDouble() ?? 0,
      ),
      startHour: (row['start_hour'] as num?)?.toInt() ?? 0,
      endHour: (row['end_hour'] as num?)?.toInt() ?? 0,
      directions: rawDirections
          .map((entry) => entry.toString())
          .where((entry) => entry.isNotEmpty)
          .toSet(),
      repeatWindow: AlarmRepeatWindow.values.firstWhere(
        (value) => value.name == (row['repeat_window'] as String? ?? ''),
        orElse: () => AlarmRepeatWindow.min10,
      ),
      maxRepeats: (row['max_repeats'] as num?)?.toInt() ?? 3,
      triggerCount: (row['trigger_count'] as num?)?.toInt() ?? 0,
      lastTriggeredAt: DateTime.tryParse(
        row['last_triggered_at'] as String? ?? '',
      )?.toLocal(),
    );
  }

  void _savePreference({required String scopeKey, required bool enabled}) {
    if (!canSync || _client == null) {
      return;
    }
    unawaited(
      _client.from('spot_alarm_preferences').upsert(<String, dynamic>{
        'scope_key': scopeKey,
        'enabled': enabled,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }),
    );
  }
}
