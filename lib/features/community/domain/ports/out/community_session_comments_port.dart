import 'package:windwisher/features/community/domain/entities/session_comment.dart';

abstract class CommunitySessionCommentsPort {
  List<SessionComment> getComments({required String sessionId});

  Future<List<SessionComment>> loadComments({required String sessionId});

  Future<SessionComment> addComment({
    required String sessionId,
    required String authorUsername,
    required String text,
  });
}
