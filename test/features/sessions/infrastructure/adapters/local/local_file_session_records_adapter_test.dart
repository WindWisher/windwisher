import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

void main() {
  test('persists recorded sessions across adapter instances', () async {
    const fileName = 'sessions_records_test_v1.json';
    final file = File(AppStoragePaths.resolve(fileName));
    if (file.existsSync()) {
      file.deleteSync();
    }

    final adapter = LocalFileSessionRecordsAdapter(
      fileName: fileName,
      encodeInsights: _encodeInsights,
      decodeInsights: _decodeInsights,
    );

    final session = RecordedSession(
      id: 'session-1',
      title: 'Sesion test',
      deviceName: 'Woo Sports',
      endedAt: DateTime(2026, 3, 4, 20, 30),
      duration: const Duration(minutes: 55),
      summary: 'Resumen test',
      gearSetupId: 'setup-1',
      gearSetupName: 'Big Air 30kt',
      hasSessionPhoto: false,
      sessionMediaLabel: 'Pantallazo del mapa del spot',
      sessionPhotoLocalPath: null,
      spotName: 'Tarifa',
      insights: SessionInsightData.empty(
        deviceKind: 'Woo Sports',
      ).copyWith(
        deviceSensorKeys: const ['gps', 'accelerometer', 'gyroscope'],
        maxSpeedKnots: 22.4,
        distanceKm: 18.6,
        groups: SessionInsightData.buildGroupsForRecordedSession(
          values: const <String, String>{
            'duracion_total': '55 min',
            'distancia_total': '18.6 km',
            'velocidad_max': '22.4 kt',
          },
        ),
      ),
    );
    await adapter.saveRecordedSession(session);

    final reloaded = LocalFileSessionRecordsAdapter(
      fileName: fileName,
      encodeInsights: _encodeInsights,
      decodeInsights: _decodeInsights,
    );

    final sessions = reloaded.getRecordedSessions();
    expect(sessions, hasLength(1));
    expect(sessions.first.id, 'session-1');
    expect(sessions.first.summary, 'Resumen test');
    expect(sessions.first.insights, isA<SessionInsightData>());

    await reloaded.deleteRecordedSession('session-1');
    final emptyReloaded = LocalFileSessionRecordsAdapter(
      fileName: fileName,
      encodeInsights: _encodeInsights,
      decodeInsights: _decodeInsights,
    );
    expect(emptyReloaded.getRecordedSessions(), isEmpty);

    if (file.existsSync()) {
      file.deleteSync();
    }
  });
}

Object? _encodeInsights(Object value) {
  if (value is SessionInsightData) {
    return value.toJson();
  }
  return value;
}

Object _decodeInsights(Object? value) {
  if (value is Map<String, dynamic>) {
    return SessionInsightData.fromJson(value);
  }
  return SessionInsightData.empty(deviceKind: 'Dispositivo Android');
}
