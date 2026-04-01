import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';

class SpotAlarmCycleRuntimeService {
  SpotAlarmCycleRuntimeService._()
    : _file = kIsWeb
          ? null
          : File(AppStoragePaths.resolve('spot_alarm_cycle_runtime_v1.json')) {
    _load();
  }

  static final SpotAlarmCycleRuntimeService instance =
      SpotAlarmCycleRuntimeService._();

  final File? _file;
  final Map<String, _AlarmCycleState> _cyclesByAlarmId =
      <String, _AlarmCycleState>{};

  String startCycle({
    required String alarmId,
    required int maxRepeats,
    required String repeatWindowName,
  }) {
    final cycleId = DateTime.now().millisecondsSinceEpoch.toString();
    _cyclesByAlarmId[alarmId] = _AlarmCycleState(
      cycleId: cycleId,
      maxRepeats: maxRepeats,
      repeatWindowName: repeatWindowName,
      stopped: false,
    );
    _save();
    return cycleId;
  }

  bool isCurrentCycle({
    required String alarmId,
    required String cycleId,
  }) {
    final state = _cyclesByAlarmId[alarmId];
    return state != null && state.cycleId == cycleId;
  }

  void stopCycle({
    required String alarmId,
    required String cycleId,
  }) {
    final current = _cyclesByAlarmId[alarmId];
    if (current == null || current.cycleId != cycleId) {
      return;
    }
    _cyclesByAlarmId[alarmId] = current.copyWith(stopped: true);
    _save();
  }

  void clearCycle({
    required String alarmId,
    required String cycleId,
  }) {
    final current = _cyclesByAlarmId[alarmId];
    if (current == null || current.cycleId != cycleId) {
      return;
    }
    _cyclesByAlarmId.remove(alarmId);
    _save();
  }

  void _load() {
    final file = _file;
    if (file == null || !file.existsSync()) {
      return;
    }
    try {
      final raw = file.readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final rawCycles = json['cyclesByAlarmId'] as Map<String, dynamic>? ?? {};
      _cyclesByAlarmId
        ..clear()
        ..addAll(
          rawCycles.map(
            (alarmId, value) => MapEntry(
              alarmId,
              _AlarmCycleState.fromJson(
                (value as Map).cast<String, dynamic>(),
              ),
            ),
          ),
        );
    } catch (_) {
      _cyclesByAlarmId.clear();
      _save();
    }
  }

  void _save() {
    final file = _file;
    if (file == null) {
      return;
    }
    final payload = <String, dynamic>{
      'cyclesByAlarmId': _cyclesByAlarmId.map(
        (alarmId, state) => MapEntry(alarmId, state.toJson()),
      ),
    };
    file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(payload));
  }
}

class _AlarmCycleState {
  const _AlarmCycleState({
    required this.cycleId,
    required this.maxRepeats,
    required this.repeatWindowName,
    required this.stopped,
  });

  final String cycleId;
  final int maxRepeats;
  final String repeatWindowName;
  final bool stopped;

  _AlarmCycleState copyWith({
    bool? stopped,
  }) {
    return _AlarmCycleState(
      cycleId: cycleId,
      maxRepeats: maxRepeats,
      repeatWindowName: repeatWindowName,
      stopped: stopped ?? this.stopped,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'cycleId': cycleId,
      'maxRepeats': maxRepeats,
      'repeatWindowName': repeatWindowName,
      'stopped': stopped,
    };
  }

  factory _AlarmCycleState.fromJson(Map<String, dynamic> json) {
    return _AlarmCycleState(
      cycleId: json['cycleId'] as String? ?? '',
      maxRepeats: (json['maxRepeats'] as num?)?.toInt() ?? 1,
      repeatWindowName: json['repeatWindowName'] as String? ?? 'min10',
      stopped: json['stopped'] as bool? ?? false,
    );
  }
}
