import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/local_file_session_records_adapter.dart';
import 'package:windwisher/features/sessions/presentation/pages/session_detail_page.dart';

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
      gearSetupName: 'Big Air 30kt',
      hasSessionPhoto: false,
      sessionMediaLabel: 'Pantallazo del mapa del spot',
      sessionPhotoLocalPath: null,
      spotName: 'Tarifa',
      insights: SessionInsightData.fromSession(
        title: 'Sesion test',
        deviceName: 'Woo Sports',
        deviceKind: 'Woo Sports',
        endedAt: DateTime(2026, 3, 4, 20, 30),
        durationLabel: '55:00',
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
  return SessionInsightData.fromSession(
    title: 'Sesion',
    deviceName: 'Dispositivo',
    deviceKind: 'Dispositivo Android',
    endedAt: DateTime(2026, 3, 4, 20, 0),
    durationLabel: '45:00',
  );
}
