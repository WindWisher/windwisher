import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

void main() {
  test('SpotAlarmRecord detects equivalent alarms with same configuration', () {
    const base = SpotAlarmRecord(
      id: 'a1',
      spotKey: 'oliva-puerto',
      spotName: 'Oliva Puerto',
      spotArea: 'Valencia',
      stationProvider: 'AVAMET',
      stationKey: 'avamet:c25m181e07',
      stationName: 'Club Nautico de Oliva',
      windRange: RangeValues(12, 20),
      startHour: 10,
      endHour: 18,
      directions: {'N', 'NE', 'E'},
      repeatWindow: AlarmRepeatWindow.min10,
    );

    const sameConfigDifferentId = SpotAlarmRecord(
      id: 'a2',
      spotKey: 'oliva-puerto',
      spotName: 'Oliva Puerto',
      spotArea: 'Valencia',
      stationProvider: 'AVAMET',
      stationKey: 'avamet:c25m181e07',
      stationName: 'Club Nautico de Oliva',
      windRange: RangeValues(12, 20),
      startHour: 10,
      endHour: 18,
      directions: {'E', 'N', 'NE'},
      repeatWindow: AlarmRepeatWindow.min10,
    );

    const differentConfig = SpotAlarmRecord(
      id: 'a3',
      spotKey: 'oliva-puerto',
      spotName: 'Oliva Puerto',
      spotArea: 'Valencia',
      stationProvider: 'AVAMET',
      stationKey: 'avamet:c25m181e07',
      stationName: 'Club Nautico de Oliva',
      windRange: RangeValues(14, 22),
      startHour: 10,
      endHour: 18,
      directions: {'E', 'N', 'NE'},
      repeatWindow: AlarmRepeatWindow.min10,
    );

    expect(base.isEquivalentTo(sameConfigDifferentId), isTrue);
    expect(base.isEquivalentTo(differentConfig), isFalse);
  });
}
