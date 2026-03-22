import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_records_port.dart';

class GetRecordedSessionsUseCase {
  const GetRecordedSessionsUseCase(this._port);

  final SessionRecordsPort _port;

  List<RecordedSession> call() {
    return _port.getRecordedSessions();
  }

  Future<List<RecordedSession>> load() {
    return _port.loadRecordedSessions();
  }
}

class SaveRecordedSessionUseCase {
  const SaveRecordedSessionUseCase(this._port);

  final SessionRecordsPort _port;

  Future<void> call(RecordedSession session) {
    return _port.saveRecordedSession(session);
  }
}

class DeleteRecordedSessionUseCase {
  const DeleteRecordedSessionUseCase(this._port);

  final SessionRecordsPort _port;

  Future<void> call(String sessionId) {
    return _port.deleteRecordedSession(sessionId);
  }
}
