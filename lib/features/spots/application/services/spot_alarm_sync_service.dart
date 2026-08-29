import 'package:windwisher/features/spots/application/models/spot_alarm_record.dart';

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

abstract interface class SpotAlarmSyncService {
  bool get canSync;
  String? get lastError;

  Future<SpotAlarmSyncSnapshot?> loadSnapshot();
  Future<void> saveAlarm(SpotAlarmRecord alarm);
  Future<void> deleteAlarm(String alarmId);
  Future<void> saveAlarmRuntimeControls({
    required String alarmId,
    DateTime? snoozedUntil,
    required bool stoppedUntilReset,
  });
  Future<void> saveAlarmRuntimeControlsFromNotification({
    required String alarmId,
    DateTime? snoozedUntil,
    required bool stoppedUntilReset,
  });
  Future<void> saveGlobalEnabled(bool enabled);
  Future<void> saveSpotEnabled({
    required String spotKey,
    required bool enabled,
  });
}
