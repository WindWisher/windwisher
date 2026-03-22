import 'package:windwisher/features/community/domain/entities/session_like_state.dart';

abstract class CommunitySessionReactionsPort {
  SessionLikeState getLikeState({
    required String sessionId,
    required String username,
  });

  Future<SessionLikeState> loadLikeState({
    required String sessionId,
    required String username,
  });

  Future<SessionLikeState> toggleLike({
    required String sessionId,
    required String username,
  });
}
