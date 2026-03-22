import 'package:windwisher/features/community/domain/entities/session_like_state.dart';
import 'package:windwisher/features/community/domain/ports/out/community_session_reactions_port.dart';
import 'package:windwisher/features/community/infrastructure/persistence/community_social_state_store.dart';

class LocalFileCommunitySessionReactionsAdapter
    implements CommunitySessionReactionsPort {
  LocalFileCommunitySessionReactionsAdapter(this._store);

  final CommunitySocialStateStore _store;

  @override
  SessionLikeState getLikeState({
    required String sessionId,
    required String username,
  }) {
    return _store.getLikeState(sessionId: sessionId, username: username);
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
    return _store.toggleLike(sessionId: sessionId, username: username);
  }
}
