import 'package:windwisher/features/community/domain/entities/session_like_state.dart';
import 'package:windwisher/features/community/domain/ports/out/community_session_reactions_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCommunitySessionReactionsAdapter
    implements CommunitySessionReactionsPort {
  SupabaseCommunitySessionReactionsAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final Map<String, SessionLikeState> _cache = <String, SessionLikeState>{};

  @override
  SessionLikeState getLikeState({
    required String sessionId,
    required String username,
  }) {
    return _cache[sessionId] ??
        SessionLikeState(
          sessionId: sessionId,
          likesCount: 0,
          isLikedByUser: false,
        );
  }

  @override
  Future<SessionLikeState> loadLikeState({
    required String sessionId,
    required String username,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      final state = SessionLikeState(
        sessionId: sessionId,
        likesCount: 0,
        isLikedByUser: false,
      );
      _cache[sessionId] = state;
      return state;
    }

    final likesResponse = await _client
        .from('session_likes')
        .select('user_id')
        .eq('session_id', sessionId);
    final rows = (likesResponse as List<dynamic>).whereType<Map<String, dynamic>>();
    final state = SessionLikeState(
      sessionId: sessionId,
      likesCount: rows.length,
      isLikedByUser: rows.any((row) => row['user_id'] == user.id),
    );
    _cache[sessionId] = state;
    return state;
  }

  @override
  Future<SessionLikeState> toggleLike({
    required String sessionId,
    required String username,
  }) async {
    if (_client.auth.currentUser == null) {
      return getLikeState(sessionId: sessionId, username: username);
    }

    final response = await _client.rpc(
      'toggle_session_like',
      params: <String, dynamic>{'target_session_id': sessionId},
    );
    final rows = (response as List<dynamic>).whereType<Map<String, dynamic>>().toList();
    if (rows.isEmpty) {
      final current = getLikeState(sessionId: sessionId, username: username);
      return current;
    }
    final row = rows.first;
    final state = SessionLikeState(
      sessionId: row['session_id'] as String? ?? sessionId,
      isLikedByUser: row['is_liked'] as bool? ?? false,
      likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
    );
    _cache[sessionId] = state;
    return state;
  }
}
