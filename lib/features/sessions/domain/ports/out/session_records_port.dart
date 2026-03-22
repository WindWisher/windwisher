import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';

abstract class SessionRecordsPort {
  List<RecordedSession> getRecordedSessions();

  Future<List<RecordedSession>> loadRecordedSessions();

  Future<void> saveRecordedSession(RecordedSession session);

  Future<void> deleteRecordedSession(String sessionId);
}
