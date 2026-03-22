import 'package:windwisher/features/community/domain/entities/session_comment.dart';
import 'package:windwisher/features/community/domain/ports/out/community_session_comments_port.dart';

class InMemoryCommunitySessionCommentsAdapter
    implements CommunitySessionCommentsPort {
  final Map<String, List<SessionComment>> _commentsBySessionId =
      <String, List<SessionComment>>{};
  int _nextCommentNumber = 1;

  @override
  List<SessionComment> getComments({required String sessionId}) {
    return List<SessionComment>.from(
      _commentsBySessionId[sessionId] ?? const <SessionComment>[],
    );
  }

  @override
  Future<List<SessionComment>> loadComments({required String sessionId}) async {
    return getComments(sessionId: sessionId);
  }

  @override
  Future<SessionComment> addComment({
    required String sessionId,
    required String authorUsername,
    required String text,
  }) async {
    final comment = SessionComment(
      id: 'comment-${_nextCommentNumber++}',
      sessionId: sessionId,
      authorUsername: authorUsername,
      text: text,
      createdAt: DateTime.now(),
    );
    final list = _commentsBySessionId.putIfAbsent(
      sessionId,
      () => <SessionComment>[],
    );
    list.add(comment);
    return comment;
  }
}
