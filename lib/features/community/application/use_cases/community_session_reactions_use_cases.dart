import 'package:windwisher/features/community/domain/entities/session_like_state.dart';
import 'package:windwisher/features/community/domain/ports/out/community_session_reactions_port.dart';

class GetSessionLikeStateUseCase {
  const GetSessionLikeStateUseCase(this._port);

  final CommunitySessionReactionsPort _port;

  SessionLikeState call({required String sessionId, required String username}) {
    return _port.getLikeState(sessionId: sessionId, username: username);
  }

  Future<SessionLikeState> load({
    required String sessionId,
    required String username,
  }) {
    return _port.loadLikeState(sessionId: sessionId, username: username);
  }
}

class ToggleSessionLikeUseCase {
  const ToggleSessionLikeUseCase(this._port);

  final CommunitySessionReactionsPort _port;

  Future<SessionLikeState> call({
    required String sessionId,
    required String username,
  }) {
    return _port.toggleLike(sessionId: sessionId, username: username);
  }
}
