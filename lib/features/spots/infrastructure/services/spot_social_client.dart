import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/spots/domain/entities/spot_social_post.dart';

class SpotSocialClient {
  SpotSocialClient._({
    required SupabaseClient? client,
    required bool useSupabase,
  }) : _client = client,
       _useSupabase = useSupabase;

  factory SpotSocialClient.auto({SupabaseClient? client}) {
    final hasSupabase =
        EnvConfig.supabaseUrl.trim().isNotEmpty &&
        EnvConfig.supabaseAnonKey.trim().isNotEmpty;
    return SpotSocialClient._(
      client: hasSupabase ? (client ?? Supabase.instance.client) : null,
      useSupabase: hasSupabase,
    );
  }

  final SupabaseClient? _client;
  final bool _useSupabase;

  final Map<String, List<SpotSocialPost>> _memoryFeedBySpot =
      <String, List<SpotSocialPost>>{};

  bool get requiresAuthenticatedWrites => _useSupabase;

  bool get canWrite {
    if (!_useSupabase) {
      return true;
    }
    return _client?.auth.currentUser != null;
  }

  Future<List<SpotSocialPost>> loadPosts({
    required String spotName,
    required String spotArea,
  }) async {
    if (!_useSupabase || _client == null) {
      return List<SpotSocialPost>.from(
        _memoryFeedBySpot[_spotKey(spotName, spotArea)] ?? const [],
      );
    }

    final userId = _client.auth.currentUser?.id;
    final spotKey = _spotKey(spotName, spotArea);
    final postRows = await _client
        .from('spot_social_posts')
        .select()
        .eq('spot_key', spotKey)
        .order('created_at', ascending: false);

    final postMaps = (postRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    final postIds = postMaps
        .map((row) => row['id'] as String? ?? '')
        .where((id) => id.isNotEmpty)
        .toList(growable: false);

    final repliesByPostId = <String, List<SpotSocialReply>>{};
    if (postIds.isNotEmpty) {
      final replyRows = await _client
          .from('spot_social_replies')
          .select()
          .inFilter('post_id', postIds)
          .order('created_at');
      final replyMaps = (replyRows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      for (final postId in postIds) {
        final rawReplies = replyMaps
            .where((row) => row['post_id'] == postId)
            .map((row) => _replyFromRow(row, currentUserId: userId))
            .toList(growable: false);
        repliesByPostId[postId] = _nestReplies(rawReplies);
      }
    }

    final posts = postMaps
        .map(
          (row) => _postFromRow(
            row,
            currentUserId: userId,
            replies: repliesByPostId[row['id'] as String? ?? ''] ?? const [],
          ),
        )
        .toList(growable: false);
    _memoryFeedBySpot[spotKey] = List<SpotSocialPost>.from(posts);
    return List<SpotSocialPost>.from(posts);
  }

  Future<SpotSocialPost> addPost({
    required String spotName,
    required String spotArea,
    required String authorUsername,
    required String authorDisplayName,
    required String message,
  }) async {
    if (!_useSupabase || _client == null) {
      final post = SpotSocialPost(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        spotName: spotName,
        spotArea: spotArea,
        authorUsername: authorUsername,
        authorDisplayName: authorDisplayName,
        message: message,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isMine: true,
      );
      final key = _spotKey(spotName, spotArea);
      final feed = _memoryFeedBySpot.putIfAbsent(key, () => <SpotSocialPost>[]);
      feed.insert(0, post);
      return post;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesion para publicar en Social.');
    }
    final inserted = await _client
        .from('spot_social_posts')
        .insert(<String, dynamic>{
          'spot_name': spotName,
          'spot_area': spotArea,
          'spot_key': _spotKey(spotName, spotArea),
          'author_user_id': user.id,
          'author_username': authorUsername,
          'author_display_name': authorDisplayName,
          'message': message,
        })
        .select()
        .single();
    return _postFromRow(
      inserted,
      currentUserId: user.id,
      replies: const <SpotSocialReply>[],
    );
  }

  Future<SpotSocialReply> addReply({
    required String postId,
    required String authorUsername,
    required String authorDisplayName,
    required String message,
    String? parentReplyId,
  }) async {
    if (!_useSupabase || _client == null) {
      final reply = SpotSocialReply(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        postId: postId,
        parentReplyId: parentReplyId,
        authorUsername: authorUsername,
        authorDisplayName: authorDisplayName,
        message: message,
        createdAt: DateTime.now(),
        isMine: true,
      );
      _insertLocalReply(reply);
      return reply;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesion para responder en Social.');
    }
    final inserted = await _client
        .from('spot_social_replies')
        .insert(<String, dynamic>{
          'post_id': postId,
          'parent_reply_id': parentReplyId,
          'author_user_id': user.id,
          'author_username': authorUsername,
          'author_display_name': authorDisplayName,
          'message': message,
        })
        .select()
        .single();
    return _replyFromRow(inserted, currentUserId: user.id);
  }

  Future<SpotSocialPost> updatePost({
    required String postId,
    required String message,
  }) async {
    if (!_useSupabase || _client == null) {
      for (final entry in _memoryFeedBySpot.entries) {
        final index = entry.value.indexWhere((post) => post.id == postId);
        if (index < 0) {
          continue;
        }
        final updated = entry.value[index].copyWith(
          message: message,
          updatedAt: DateTime.now(),
        );
        entry.value[index] = updated;
        return updated;
      }
      throw StateError('No se encontro la publicacion a editar.');
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesion para editar en Social.');
    }
    final updated = await _client
        .from('spot_social_posts')
        .update(<String, dynamic>{
          'message': message,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', postId)
        .select()
        .single();
    return _postFromRow(
      updated,
      currentUserId: user.id,
      replies: const <SpotSocialReply>[],
    );
  }

  Future<void> deletePost({required String postId}) async {
    if (!_useSupabase || _client == null) {
      for (final entry in _memoryFeedBySpot.entries) {
        entry.value.removeWhere((post) => post.id == postId);
      }
      return;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesion para eliminar en Social.');
    }
    await _client.from('spot_social_posts').delete().eq('id', postId);
  }

  SpotSocialPost _postFromRow(
    Map<String, dynamic> row, {
    required String? currentUserId,
    required List<SpotSocialReply> replies,
  }) {
    final authorId = row['author_user_id'] as String?;
    return SpotSocialPost(
      id: row['id'] as String? ?? '',
      spotName: row['spot_name'] as String? ?? '',
      spotArea: row['spot_area'] as String? ?? '',
      authorUsername: row['author_username'] as String? ?? 'rider',
      authorDisplayName: row['author_display_name'] as String? ?? 'Rider',
      message: row['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(row['updated_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      isMine: currentUserId != null && currentUserId == authorId,
      replies: replies,
    );
  }

  SpotSocialReply _replyFromRow(
    Map<String, dynamic> row, {
    required String? currentUserId,
  }) {
    final authorId = row['author_user_id'] as String?;
    return SpotSocialReply(
      id: row['id'] as String? ?? '',
      postId: row['post_id'] as String? ?? '',
      parentReplyId: row['parent_reply_id'] as String?,
      authorUsername: row['author_username'] as String? ?? 'rider',
      authorDisplayName: row['author_display_name'] as String? ?? 'Rider',
      message: row['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      isMine: currentUserId != null && currentUserId == authorId,
    );
  }

  List<SpotSocialReply> _nestReplies(List<SpotSocialReply> flatReplies) {
    final byId = <String, SpotSocialReply>{};
    final childrenByParentId = <String, List<SpotSocialReply>>{};
    for (final reply in flatReplies) {
      byId[reply.id] = reply.copyWith(replies: const <SpotSocialReply>[]);
    }
    for (final reply in byId.values) {
      final parentId = reply.parentReplyId;
      if (parentId == null || parentId.isEmpty || !byId.containsKey(parentId)) {
        continue;
      }
      childrenByParentId
          .putIfAbsent(parentId, () => <SpotSocialReply>[])
          .add(reply);
    }
    SpotSocialReply attachChildren(SpotSocialReply reply) {
      final children =
          (childrenByParentId[reply.id] ?? const <SpotSocialReply>[])
              .map(attachChildren)
              .toList(growable: false);
      return reply.copyWith(replies: children);
    }

    return byId.values
        .where(
          (reply) =>
              reply.parentReplyId == null ||
              reply.parentReplyId!.isEmpty ||
              !byId.containsKey(reply.parentReplyId),
        )
        .map(attachChildren)
        .toList(growable: false);
  }

  void _insertLocalReply(SpotSocialReply reply) {
    for (final entry in _memoryFeedBySpot.entries) {
      final postIndex = entry.value.indexWhere(
        (post) => post.id == reply.postId,
      );
      if (postIndex < 0) {
        continue;
      }
      final post = entry.value[postIndex];
      final nextReplies = List<SpotSocialReply>.from(post.replies);
      if (reply.parentReplyId == null || reply.parentReplyId!.isEmpty) {
        nextReplies.insert(0, reply);
      } else {
        _appendNestedReply(nextReplies, reply.parentReplyId!, reply);
      }
      entry.value[postIndex] = post.copyWith(replies: nextReplies);
      return;
    }
  }

  bool _appendNestedReply(
    List<SpotSocialReply> replies,
    String parentReplyId,
    SpotSocialReply reply,
  ) {
    for (var index = 0; index < replies.length; index += 1) {
      final current = replies[index];
      if (current.id == parentReplyId) {
        final children = List<SpotSocialReply>.from(current.replies)
          ..insert(0, reply);
        replies[index] = current.copyWith(replies: children);
        return true;
      }
      final children = List<SpotSocialReply>.from(current.replies);
      if (_appendNestedReply(children, parentReplyId, reply)) {
        replies[index] = current.copyWith(replies: children);
        return true;
      }
    }
    return false;
  }

  String _spotKey(String spotName, String spotArea) {
    return '${spotName.trim().toLowerCase()}::${spotArea.trim().toLowerCase()}';
  }
}
