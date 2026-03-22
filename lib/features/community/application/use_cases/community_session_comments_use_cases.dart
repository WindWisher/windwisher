import 'package:windwisher/features/community/domain/entities/session_comment.dart';
import 'package:windwisher/features/community/domain/ports/out/community_session_comments_port.dart';

class GetSessionCommentsUseCase {
  const GetSessionCommentsUseCase(this._port);

  final CommunitySessionCommentsPort _port;

  List<SessionComment> call({required String sessionId}) {
    return _port.getComments(sessionId: sessionId);
  }

  Future<List<SessionComment>> load({required String sessionId}) {
    return _port.loadComments(sessionId: sessionId);
  }
}

class AddSessionCommentUseCase {
  const AddSessionCommentUseCase(this._port);

  final CommunitySessionCommentsPort _port;

  Future<SessionComment> call({
    required String sessionId,
    required String authorUsername,
    required String text,
  }) {
    return _port.addComment(
      sessionId: sessionId,
      authorUsername: authorUsername,
      text: text,
    );
  }
}
