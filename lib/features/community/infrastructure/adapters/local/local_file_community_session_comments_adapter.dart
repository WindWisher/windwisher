import 'package:windwisher/features/community/domain/entities/session_comment.dart';
import 'package:windwisher/features/community/domain/ports/out/community_session_comments_port.dart';
import 'package:windwisher/features/community/infrastructure/persistence/community_social_state_store.dart';

class LocalFileCommunitySessionCommentsAdapter
    implements CommunitySessionCommentsPort {
  LocalFileCommunitySessionCommentsAdapter(this._store);

  final CommunitySocialStateStore _store;

  @override
  Future<SessionComment> addComment({
    required String sessionId,
    required String authorUsername,
    required String text,
  }) async {
    return _store.addComment(
      sessionId: sessionId,
      authorUsername: authorUsername,
      text: text,
    );
  }

  @override
  List<SessionComment> getComments({required String sessionId}) {
    return _store.getComments(sessionId: sessionId);
  }

  @override
  Future<List<SessionComment>> loadComments({required String sessionId}) async {
    return getComments(sessionId: sessionId);
  }
}
