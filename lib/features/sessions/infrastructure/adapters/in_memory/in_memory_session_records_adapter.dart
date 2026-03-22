import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_records_port.dart';

class InMemorySessionRecordsAdapter implements SessionRecordsPort {
  final List<RecordedSession> _sessions = [];

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
      return;
    }
    _sessions.insert(0, session);
  }

  @override
  Future<void> deleteRecordedSession(String sessionId) async {
    _sessions.removeWhere((item) => item.id == sessionId);
  }
}
