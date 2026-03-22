import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/entities/session_like_state.dart';
import 'package:windwisher/features/community/domain/ports/out/community_session_reactions_port.dart';

class InMemoryCommunitySessionReactionsAdapter
    implements CommunitySessionReactionsPort {
  InMemoryCommunitySessionReactionsAdapter({
    required List<FollowingSession> initialSessions,
  }) {
    for (final session in initialSessions) {
      _likesCountBySessionId[session.id] = session.likesCount;
    }
  }

  final Map<String, int> _likesCountBySessionId = <String, int>{};
  final Set<String> _likedByUserAndSession = <String>{};

  @override
  SessionLikeState getLikeState({
    required String sessionId,
    required String username,
  }) {
    return SessionLikeState(
      sessionId: sessionId,
      likesCount: _likesCountBySessionId[sessionId] ?? 0,
      isLikedByUser: _isLikedByUser(sessionId: sessionId, username: username),
    );
  }

  @override
  Future<SessionLikeState> loadLikeState({
    required String sessionId,
    required String username,
  }) async {
    return getLikeState(sessionId: sessionId, username: username);
  }

  @override
  Future<SessionLikeState> toggleLike({
    required String sessionId,
    required String username,
  }) async {
    final key = _likeKey(sessionId: sessionId, username: username);
    final isLiked = _likedByUserAndSession.contains(key);
    final current = _likesCountBySessionId[sessionId] ?? 0;

    if (isLiked) {
      _likedByUserAndSession.remove(key);
      _likesCountBySessionId[sessionId] = current > 0 ? current - 1 : 0;
    } else {
      _likedByUserAndSession.add(key);
      _likesCountBySessionId[sessionId] = current + 1;
    }

    return getLikeState(sessionId: sessionId, username: username);
  }

  bool _isLikedByUser({required String sessionId, required String username}) {
    final key = _likeKey(sessionId: sessionId, username: username);
    return _likedByUserAndSession.contains(key);
  }

  String _likeKey({required String sessionId, required String username}) {
    return '$username::$sessionId';
  }
}
