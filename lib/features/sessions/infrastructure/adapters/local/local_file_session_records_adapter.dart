import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_records_port.dart';

class LocalFileSessionRecordsAdapter implements SessionRecordsPort {
  LocalFileSessionRecordsAdapter({
    required Object? Function(Object value) encodeInsights,
    required Object Function(Object? value) decodeInsights,
    String fileName = 'sessions_records_v1.json',
  }) : _encodeInsights = encodeInsights,
       _decodeInsights = decodeInsights,
       _file = File(AppStoragePaths.resolve(fileName)) {
    _load();
  }

  final Object? Function(Object value) _encodeInsights;
  final Object Function(Object? value) _decodeInsights;
  final File _file;
  final List<RecordedSession> _sessions = <RecordedSession>[];

  @override
  List<RecordedSession> getRecordedSessions() {
    return List<RecordedSession>.unmodifiable(_sessions);
  }

  @override
  Future<List<RecordedSession>> loadRecordedSessions() async {
    return getRecordedSessions();
  }

  @override
  Future<void> saveRecordedSession(RecordedSession session) async {
    final index = _sessions.indexWhere((item) => item.id == session.id);
    if (index >= 0) {
      _sessions[index] = session;
    } else {
      _sessions.insert(0, session);
    }
    _save();
  }

  @override
  Future<void> deleteRecordedSession(String sessionId) async {
    _sessions.removeWhere((item) => item.id == sessionId);
    _save();
  }

  void _load() {
    if (!_file.existsSync()) {
      _save();
      return;
    }

    try {
      final raw = _file.readAsStringSync();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final rawSessions = data['sessions'] as List<dynamic>? ?? const [];
      _sessions
        ..clear()
        ..addAll(
          rawSessions.whereType<Map<String, dynamic>>().map(
            (entry) => RecordedSession.fromJson(
              entry,
              decodeInsights: _decodeInsights,
            ),
          ),
        );
    } catch (_) {
      _sessions.clear();
      _save();
    }
  }

  void _save() {
    final data = <String, dynamic>{
      'sessions': _sessions
          .map((session) => session.toJson(encodeInsights: _encodeInsights))
          .toList(growable: false),
    };
    _file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }
}
