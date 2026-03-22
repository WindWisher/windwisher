import 'package:windwisher/features/community/domain/entities/session_comment.dart';
import 'package:windwisher/features/community/domain/ports/out/community_session_comments_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCommunitySessionCommentsAdapter
    implements CommunitySessionCommentsPort {
  SupabaseCommunitySessionCommentsAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final Map<String, List<SessionComment>> _cache = <String, List<SessionComment>>{};

  @override
  List<SessionComment> getComments({required String sessionId}) {
    return List<SessionComment>.from(_cache[sessionId] ?? const <SessionComment>[]);
  }

  @override
  Future<List<SessionComment>> loadComments({required String sessionId}) async {
    if (_client.auth.currentUser == null) {
      _cache[sessionId] = <SessionComment>[];
      return getComments(sessionId: sessionId);
    }

    final response = await _client
        .from('session_comments')
        .select()
        .eq('session_id', sessionId)
        .order('created_at');
    final comments = (response as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(_fromRow)
        .toList(growable: false);
    _cache[sessionId] = List<SessionComment>.from(comments);
    return getComments(sessionId: sessionId);
  }

  @override
  Future<SessionComment> addComment({
    required String sessionId,
    required String authorUsername,
    required String text,
  }) async {
    if (_client.auth.currentUser == null) {
      final fallback = SessionComment(
        id: '',
        sessionId: sessionId,
        authorUsername: authorUsername,
        text: text,
        createdAt: DateTime.now(),
      );
      return fallback;
    }

    final response = await _client.rpc(
      'add_session_comment',
      params: <String, dynamic>{
        'target_session_id': sessionId,
        'comment_text': text,
      },
    );
    final comment = _fromRow(response as Map<String, dynamic>);
    final list = _cache.putIfAbsent(sessionId, () => <SessionComment>[]);
    list.add(comment);
    return comment;
  }

  SessionComment _fromRow(Map<String, dynamic> row) {
    return SessionComment(
      id: row['id'] as String? ?? '',
      sessionId: row['session_id'] as String? ?? '',
      authorUsername: row['author_username'] as String? ?? 'user',
      text: row['text'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
