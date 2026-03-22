import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/entities/session_comment.dart';
import 'package:windwisher/features/community/domain/entities/session_like_state.dart';

class CommunitySocialStateStore {
  CommunitySocialStateStore({required List<FollowingSession> seedSessions})
    : _file = File(AppStoragePaths.resolve('community_social_state_v1.json')) {
    _load(seedSessions);
  }

  final File _file;
  final Map<String, int> _likesCountBySessionId = <String, int>{};
  final Set<String> _likedByUserAndSession = <String>{};
  Set<String>? _followingUsernames;
  final Map<String, List<SessionComment>> _commentsBySessionId =
      <String, List<SessionComment>>{};
  int _nextCommentNumber = 1;

  Set<String>? getFollowingUsernames() {
    final usernames = _followingUsernames;
    return usernames == null ? null : Set<String>.from(usernames);
  }

  void saveFollowingUsernames(Set<String> usernames) {
    _followingUsernames = Set<String>.from(usernames);
    _save();
  }

  SessionLikeState getLikeState({
    required String sessionId,
    required String username,
  }) {
    return SessionLikeState(
      sessionId: sessionId,
      likesCount: _likesCountBySessionId[sessionId] ?? 0,
      isLikedByUser: _likedByUserAndSession.contains(
        _likeKey(username, sessionId),
      ),
    );
  }

  SessionLikeState toggleLike({
    required String sessionId,
    required String username,
  }) {
    final key = _likeKey(username, sessionId);
    final alreadyLiked = _likedByUserAndSession.contains(key);
    final current = _likesCountBySessionId[sessionId] ?? 0;

    if (alreadyLiked) {
      _likedByUserAndSession.remove(key);
      _likesCountBySessionId[sessionId] = current > 0 ? current - 1 : 0;
    } else {
      _likedByUserAndSession.add(key);
      _likesCountBySessionId[sessionId] = current + 1;
    }

    _save();
    return getLikeState(sessionId: sessionId, username: username);
  }

  List<SessionComment> getComments({required String sessionId}) {
    return List<SessionComment>.from(
      _commentsBySessionId[sessionId] ?? const <SessionComment>[],
    );
  }

  SessionComment addComment({
    required String sessionId,
    required String authorUsername,
    required String text,
  }) {
    final comment = SessionComment(
      id: 'comment-${_nextCommentNumber++}',
      sessionId: sessionId,
      authorUsername: authorUsername,
      text: text,
      createdAt: DateTime.now(),
    );
    final comments = _commentsBySessionId.putIfAbsent(
      sessionId,
      () => <SessionComment>[],
    );
    comments.add(comment);
    _save();
    return comment;
  }

  void _load(List<FollowingSession> seedSessions) {
    if (_file.existsSync()) {
      try {
        final raw = _file.readAsStringSync();
        final data = jsonDecode(raw) as Map<String, dynamic>;

        final likesBySession =
            data['likesCountBySessionId'] as Map<String, dynamic>?;
        if (likesBySession != null) {
          for (final entry in likesBySession.entries) {
            _likesCountBySessionId[entry.key] = (entry.value as num).toInt();
          }
        }

        final likedPairs = data['likedByUserAndSession'] as List<dynamic>?;
        if (likedPairs != null) {
          _likedByUserAndSession.addAll(likedPairs.map((e) => e.toString()));
        }

        final following = data['followingUsernames'] as List<dynamic>?;
        if (following != null) {
          _followingUsernames = following
              .map((entry) => entry.toString())
              .toSet();
        }

        final commentsBySession =
            data['commentsBySessionId'] as Map<String, dynamic>?;
        if (commentsBySession != null) {
          for (final entry in commentsBySession.entries) {
            final list = entry.value as List<dynamic>;
            _commentsBySessionId[entry.key] = list
                .map(
                  (rawComment) =>
                      _commentFromJson(rawComment as Map<String, dynamic>),
                )
                .toList(growable: true);
          }
        }

        _nextCommentNumber = (data['nextCommentNumber'] as num?)?.toInt() ?? 1;
      } catch (_) {
        _seedLikes(seedSessions);
        _save();
      }
    } else {
      _seedLikes(seedSessions);
      _save();
    }

    for (final session in seedSessions) {
      _likesCountBySessionId.putIfAbsent(session.id, () => session.likesCount);
    }
  }

  void _seedLikes(List<FollowingSession> seedSessions) {
    for (final session in seedSessions) {
      _likesCountBySessionId[session.id] = session.likesCount;
    }
  }

  void _save() {
    final data = <String, dynamic>{
      'likesCountBySessionId': _likesCountBySessionId,
      'likedByUserAndSession': _likedByUserAndSession.toList(growable: false),
      'followingUsernames': _followingUsernames?.toList(growable: false),
      'commentsBySessionId': _commentsBySessionId.map(
        (key, value) =>
            MapEntry(key, value.map(_commentToJson).toList(growable: false)),
      ),
      'nextCommentNumber': _nextCommentNumber,
    };
    _file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }

  String _likeKey(String username, String sessionId) => '$username::$sessionId';

  Map<String, dynamic> _commentToJson(SessionComment comment) {
    return <String, dynamic>{
      'id': comment.id,
      'sessionId': comment.sessionId,
      'authorUsername': comment.authorUsername,
      'text': comment.text,
      'createdAt': comment.createdAt.toIso8601String(),
    };
  }

  SessionComment _commentFromJson(Map<String, dynamic> json) {
    return SessionComment(
      id: json['id'] as String,
      sessionId: json['sessionId'] as String,
      authorUsername: json['authorUsername'] as String,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
