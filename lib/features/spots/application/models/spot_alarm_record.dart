import 'package:flutter/material.dart';

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
    this.snoozedUntil,
    this.stoppedUntilReset = false,
    this.enabled = true,
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
  final DateTime? snoozedUntil;
  final bool stoppedUntilReset;
  final bool enabled;

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
    DateTime? snoozedUntil,
    bool? stoppedUntilReset,
    bool? enabled,
    bool clearLastTriggeredAt = false,
    bool clearSnoozedUntil = false,
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
      snoozedUntil: clearSnoozedUntil
          ? null
          : (snoozedUntil ?? this.snoozedUntil),
      stoppedUntilReset: stoppedUntilReset ?? this.stoppedUntilReset,
      enabled: enabled ?? this.enabled,
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
      'snoozedUntil': snoozedUntil?.toIso8601String(),
      'stoppedUntilReset': stoppedUntilReset,
      'enabled': enabled,
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
      snoozedUntil: DateTime.tryParse(json['snoozedUntil'] as String? ?? ''),
      stoppedUntilReset: json['stoppedUntilReset'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
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

extension AlarmRepeatWindowDuration on AlarmRepeatWindow {
  Duration get duration {
    return switch (this) {
      AlarmRepeatWindow.min1 => const Duration(minutes: 1),
      AlarmRepeatWindow.min5 => const Duration(minutes: 5),
      AlarmRepeatWindow.min10 => const Duration(minutes: 10),
      AlarmRepeatWindow.min15 => const Duration(minutes: 15),
      AlarmRepeatWindow.min30 => const Duration(minutes: 30),
    };
  }
}
