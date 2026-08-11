import 'dart:async';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/initialized_supabase_client.dart';
import 'package:windwisher/features/spots/domain/entities/spot_social_post.dart';

class SpotSocialAttachmentDraft {
  const SpotSocialAttachmentDraft({
    required this.type,
    required this.fileName,
    required this.bytes,
    this.mimeType,
    this.thumbnailBytes,
    this.thumbnailMimeType,
  });

  final SpotSocialAttachmentType type;
  final String fileName;
  final Uint8List bytes;
  final String? mimeType;
  final Uint8List? thumbnailBytes;
  final String? thumbnailMimeType;
}

class SpotSocialClient {
  SpotSocialClient._({
    required SupabaseClient? client,
    required bool useSupabase,
    required String presenceKey,
  }) : _client = client,
       _useSupabase = useSupabase,
       _presenceKey = presenceKey;

  static const String _attachmentsBucket = 'spot-social-media';

  static String buildSpotKey({
    required String spotName,
    required String spotArea,
  }) {
    return '${spotName.trim().toLowerCase()}::${spotArea.trim().toLowerCase()}';
  }

  factory SpotSocialClient.auto({SupabaseClient? client}) {
    final resolvedClient = resolveInitializedSupabaseClient(client);
    return SpotSocialClient._(
      client: resolvedClient,
      useSupabase: resolvedClient != null,
      presenceKey:
          resolvedClient?.auth.currentUser?.id ??
          'anon-${DateTime.now().microsecondsSinceEpoch}',
    );
  }

  final SupabaseClient? _client;
  final bool _useSupabase;
  final String _presenceKey;

  final Map<String, List<SpotSocialPost>> _memoryFeedBySpot =
      <String, List<SpotSocialPost>>{};

  bool get requiresAuthenticatedWrites => _useSupabase;

  bool get canWrite {
    if (!_useSupabase) {
      return true;
    }
    return _client?.auth.currentUser != null;
  }

  Stream<void> watchSpotFeed({
    required String spotName,
    required String spotArea,
  }) {
    if (!_useSupabase || _client == null) {
      return const Stream<void>.empty();
    }

    final spotKey = _spotKey(spotName, spotArea);
    final controller = StreamController<void>();
    final channel = _client.channel(
      'spot-social:$spotKey:${DateTime.now().microsecondsSinceEpoch}',
    );

    void emitRefresh() {
      if (!controller.isClosed) {
        controller.add(null);
      }
    }

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'spot_social_posts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'spot_key',
            value: spotKey,
          ),
          callback: (_) => emitRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'spot_social_replies',
          callback: (_) => emitRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'spot_social_attachments',
          callback: (_) => emitRefresh(),
        )
        .subscribe();

    controller.onCancel = () async {
      await _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Stream<int> watchSpotPresence({
    required String spotName,
    required String spotArea,
  }) {
    if (!_useSupabase || _client == null) {
      return Stream<int>.value(0);
    }

    final spotKey = _spotKey(spotName, spotArea);
    final controller = StreamController<int>();
    final channel = _client.channel(
      'spot-social-presence:$spotKey',
      opts: RealtimeChannelConfig(key: _presenceKey, enabled: true),
    );

    void emitPresenceCount() {
      if (controller.isClosed) {
        return;
      }
      controller.add(channel.presenceState().length);
    }

    channel
        .onPresenceSync((_) {
          emitPresenceCount();
        })
        .onPresenceJoin((_) {
          emitPresenceCount();
        })
        .onPresenceLeave((_) {
          emitPresenceCount();
        })
        .subscribe((status, [_]) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await channel.track(<String, dynamic>{
              'online_at': DateTime.now().toIso8601String(),
            });
            emitPresenceCount();
          }
        });

    controller.onCancel = () async {
      await channel.untrack();
      await _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Stream<Set<String>> watchSpotTyping({
    required String spotName,
    required String spotArea,
  }) {
    if (!_useSupabase || _client == null) {
      return Stream<Set<String>>.value(const <String>{});
    }

    final spotKey = _spotKey(spotName, spotArea);
    final controller = StreamController<Set<String>>();
    final channel = _client.channel('spot-social-typing:$spotKey');
    final typingUsers = <String>{};

    void emitTypingUsers() {
      if (!controller.isClosed) {
        controller.add(Set<String>.from(typingUsers));
      }
    }

    channel
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            final data = payload['payload'];
            if (data is! Map) {
              return;
            }
            final senderId = data['sender_id'] as String?;
            if (senderId == null || senderId == _presenceKey) {
              return;
            }
            final displayName =
                (data['display_name'] as String?)?.trim().isNotEmpty == true
                ? (data['display_name'] as String).trim()
                : 'Rider';
            final isTyping = data['is_typing'] == true;
            if (isTyping) {
              typingUsers.add(displayName);
            } else {
              typingUsers.remove(displayName);
            }
            emitTypingUsers();
          },
        )
        .subscribe();

    controller.onCancel = () async {
      await _client.removeChannel(channel);
    };

    return controller.stream;
  }

  Future<void> sendTypingState({
    required String spotName,
    required String spotArea,
    required String displayName,
    required bool isTyping,
  }) async {
    if (!_useSupabase || _client == null) {
      return;
    }
    final spotKey = _spotKey(spotName, spotArea);
    final channel = _client.channel('spot-social-typing:$spotKey');
    channel.subscribe((status, [_]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await channel.sendBroadcastMessage(
          event: 'typing',
          payload: <String, dynamic>{
            'sender_id': _presenceKey,
            'display_name': displayName,
            'is_typing': isTyping,
          },
        );
        await _client.removeChannel(channel);
      }
    });
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
    final attachmentsByPostId = <String, List<SpotSocialAttachment>>{};
    final attachmentsByReplyId = <String, List<SpotSocialAttachment>>{};
    var replyMaps = <Map<String, dynamic>>[];
    var avatarPathByUserId = <String, String?>{};
    if (postIds.isNotEmpty) {
      final replyRows = await _client
          .from('spot_social_replies')
          .select()
          .inFilter('post_id', postIds)
          .order('created_at');
      replyMaps = (replyRows as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      final replyIds = replyMaps
          .map((row) => row['id'] as String? ?? '')
          .where((id) => id.isNotEmpty)
          .toList(growable: false);
      final postAttachmentRows = await _client
          .from('spot_social_attachments')
          .select()
          .inFilter('post_id', postIds)
          .order('created_at');
      for (final row
          in (postAttachmentRows as List<dynamic>)
              .whereType<Map<String, dynamic>>()) {
        final postId = row['post_id'] as String?;
        if (postId == null || postId.isEmpty) {
          continue;
        }
        final attachments = attachmentsByPostId.putIfAbsent(
          postId,
          () => <SpotSocialAttachment>[],
        );
        attachments.add(_attachmentFromRow(row));
      }
      if (replyIds.isNotEmpty) {
        final replyAttachmentRows = await _client
            .from('spot_social_attachments')
            .select()
            .inFilter('reply_id', replyIds)
            .order('created_at');
        for (final row
            in (replyAttachmentRows as List<dynamic>)
                .whereType<Map<String, dynamic>>()) {
          final replyId = row['reply_id'] as String?;
          if (replyId == null || replyId.isEmpty) {
            continue;
          }
          attachmentsByReplyId
              .putIfAbsent(replyId, () => <SpotSocialAttachment>[])
              .add(_attachmentFromRow(row));
        }
      }
      avatarPathByUserId = await _loadAvatarPathsByUserId([
        ...postMaps.map((row) => row['author_user_id'] as String?),
        ...replyMaps.map((row) => row['author_user_id'] as String?),
      ]);

      for (final postId in postIds) {
        final rawReplies = replyMaps
            .where((row) => row['post_id'] == postId)
            .map(
              (row) => _replyFromRow(
                row,
                currentUserId: userId,
                avatarPathByUserId: avatarPathByUserId,
                attachments:
                    attachmentsByReplyId[row['id'] as String? ?? ''] ??
                    const [],
              ),
            )
            .toList(growable: false);
        repliesByPostId[postId] = _nestReplies(rawReplies);
      }
    }

    final posts = postMaps
        .map(
          (row) => _postFromRow(
            row,
            currentUserId: userId,
            avatarPathByUserId: avatarPathByUserId,
            attachments:
                attachmentsByPostId[row['id'] as String? ?? ''] ?? const [],
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
    List<SpotSocialAttachmentDraft> attachments = const [],
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
        attachments: attachments
            .map(
              (item) => SpotSocialAttachment(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                type: item.type,
                url: '',
                storagePath: item.fileName,
                fileName: item.fileName,
                mimeType: item.mimeType,
                sizeBytes: item.bytes.length,
              ),
            )
            .toList(growable: false),
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
    final postId = inserted['id'] as String? ?? '';
    final uploadedAttachments = await _uploadAttachmentsForPost(
      postId: postId,
      authorUserId: user.id,
      attachments: attachments,
    );
    return _postFromRow(
      inserted,
      currentUserId: user.id,
      attachments: uploadedAttachments,
      replies: const <SpotSocialReply>[],
    );
  }

  Future<SpotSocialReply> addReply({
    required String postId,
    required String authorUsername,
    required String authorDisplayName,
    required String message,
    String? parentReplyId,
    List<SpotSocialAttachmentDraft> attachments = const [],
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
        attachments: attachments
            .map(
              (item) => SpotSocialAttachment(
                id: DateTime.now().microsecondsSinceEpoch.toString(),
                type: item.type,
                url: '',
                storagePath: item.fileName,
                fileName: item.fileName,
                mimeType: item.mimeType,
                sizeBytes: item.bytes.length,
              ),
            )
            .toList(growable: false),
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
    final replyId = inserted['id'] as String? ?? '';
    final uploadedAttachments = await _uploadAttachmentsForReply(
      replyId: replyId,
      authorUserId: user.id,
      attachments: attachments,
    );
    return _replyFromRow(
      inserted,
      currentUserId: user.id,
      attachments: uploadedAttachments,
    );
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
      attachments: const <SpotSocialAttachment>[],
      replies: const <SpotSocialReply>[],
    );
  }

  Future<SpotSocialReply> updateReply({
    required String replyId,
    required String message,
  }) async {
    if (!_useSupabase || _client == null) {
      for (final entry in _memoryFeedBySpot.entries) {
        for (var index = 0; index < entry.value.length; index += 1) {
          final post = entry.value[index];
          final nextReplies = List<SpotSocialReply>.from(post.replies);
          final updated = _updateLocalReplyMessage(
            replies: nextReplies,
            replyId: replyId,
            message: message,
          );
          if (updated != null) {
            entry.value[index] = post.copyWith(replies: nextReplies);
            return updated;
          }
        }
      }
      throw StateError('No se encontro la respuesta a editar.');
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesion para editar en Social.');
    }
    final updated = await _client
        .from('spot_social_replies')
        .update(<String, dynamic>{'message': message})
        .eq('id', replyId)
        .select()
        .single();
    return _replyFromRow(
      updated,
      currentUserId: user.id,
      attachments: const <SpotSocialAttachment>[],
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

  Future<void> deleteReply({required String replyId}) async {
    if (!_useSupabase || _client == null) {
      for (final entry in _memoryFeedBySpot.entries) {
        for (var index = 0; index < entry.value.length; index += 1) {
          final post = entry.value[index];
          final nextReplies = List<SpotSocialReply>.from(post.replies);
          if (_removeLocalReply(nextReplies, replyId)) {
            entry.value[index] = post.copyWith(replies: nextReplies);
            return;
          }
        }
      }
      return;
    }

    final user = _client.auth.currentUser;
    if (user == null) {
      throw StateError('Debes iniciar sesion para eliminar en Social.');
    }
    await _client.from('spot_social_replies').delete().eq('id', replyId);
  }

  SpotSocialReply? _updateLocalReplyMessage({
    required List<SpotSocialReply> replies,
    required String replyId,
    required String message,
  }) {
    for (var index = 0; index < replies.length; index += 1) {
      final current = replies[index];
      if (current.id == replyId) {
        final updated = current.copyWith(message: message);
        replies[index] = updated;
        return updated;
      }
      final nestedReplies = List<SpotSocialReply>.from(current.replies);
      final nestedUpdated = _updateLocalReplyMessage(
        replies: nestedReplies,
        replyId: replyId,
        message: message,
      );
      if (nestedUpdated != null) {
        replies[index] = current.copyWith(replies: nestedReplies);
        return nestedUpdated;
      }
    }
    return null;
  }

  bool _removeLocalReply(List<SpotSocialReply> replies, String replyId) {
    for (var index = 0; index < replies.length; index += 1) {
      final current = replies[index];
      if (current.id == replyId) {
        replies.removeAt(index);
        return true;
      }
      final nestedReplies = List<SpotSocialReply>.from(current.replies);
      if (_removeLocalReply(nestedReplies, replyId)) {
        replies[index] = current.copyWith(replies: nestedReplies);
        return true;
      }
    }
    return false;
  }

  SpotSocialPost _postFromRow(
    Map<String, dynamic> row, {
    required String? currentUserId,
    Map<String, String?> avatarPathByUserId = const <String, String?>{},
    required List<SpotSocialAttachment> attachments,
    required List<SpotSocialReply> replies,
  }) {
    final authorId = row['author_user_id'] as String?;
    return SpotSocialPost(
      id: row['id'] as String? ?? '',
      spotName: row['spot_name'] as String? ?? '',
      spotArea: row['spot_area'] as String? ?? '',
      authorUsername: row['author_username'] as String? ?? 'rider',
      authorDisplayName: row['author_display_name'] as String? ?? 'Rider',
      authorAvatarPath: authorId == null ? null : avatarPathByUserId[authorId],
      message: row['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(row['updated_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      isMine: currentUserId != null && currentUserId == authorId,
      attachments: attachments,
      replies: replies,
    );
  }

  SpotSocialReply _replyFromRow(
    Map<String, dynamic> row, {
    required String? currentUserId,
    Map<String, String?> avatarPathByUserId = const <String, String?>{},
    required List<SpotSocialAttachment> attachments,
  }) {
    final authorId = row['author_user_id'] as String?;
    return SpotSocialReply(
      id: row['id'] as String? ?? '',
      postId: row['post_id'] as String? ?? '',
      parentReplyId: row['parent_reply_id'] as String?,
      authorUsername: row['author_username'] as String? ?? 'rider',
      authorDisplayName: row['author_display_name'] as String? ?? 'Rider',
      authorAvatarPath: authorId == null ? null : avatarPathByUserId[authorId],
      message: row['message'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      isMine: currentUserId != null && currentUserId == authorId,
      attachments: attachments,
    );
  }

  Future<Map<String, String?>> _loadAvatarPathsByUserId(
    Iterable<String?> rawUserIds,
  ) async {
    if (!_useSupabase || _client == null) {
      return const <String, String?>{};
    }
    final userIds = rawUserIds
        .whereType<String>()
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList(growable: false);
    if (userIds.isEmpty) {
      return const <String, String?>{};
    }

    try {
      final rows = await _client
          .from('public_profiles')
          .select('id, avatar_path')
          .inFilter('id', userIds);
      final avatarPaths = <String, String?>{};
      for (final row
          in (rows as List<dynamic>).whereType<Map<String, dynamic>>()) {
        final id = (row['id'] as String?)?.trim();
        if (id == null || id.isEmpty) {
          continue;
        }
        avatarPaths[id] = (row['avatar_path'] as String?)?.trim();
      }
      return avatarPaths;
    } catch (_) {
      return const <String, String?>{};
    }
  }

  SpotSocialAttachment _attachmentFromRow(Map<String, dynamic> row) {
    return SpotSocialAttachment(
      id: row['id'] as String? ?? '',
      type: _attachmentTypeFromRaw(row['attachment_type'] as String?),
      url: row['public_url'] as String? ?? '',
      storagePath: row['storage_path'] as String? ?? '',
      fileName: row['file_name'] as String? ?? '',
      mimeType: row['mime_type'] as String?,
      sizeBytes: row['size_bytes'] as int?,
      thumbnailUrl: row['thumbnail_url'] as String?,
      createdAt:
          DateTime.tryParse(row['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
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
    return buildSpotKey(spotName: spotName, spotArea: spotArea);
  }

  SpotSocialAttachmentType _attachmentTypeFromRaw(String? raw) {
    return raw == 'video'
        ? SpotSocialAttachmentType.video
        : SpotSocialAttachmentType.image;
  }

  Future<List<SpotSocialAttachment>> _uploadAttachmentsForPost({
    required String postId,
    required String authorUserId,
    required List<SpotSocialAttachmentDraft> attachments,
  }) async {
    if (attachments.isEmpty || !_useSupabase || _client == null) {
      return const <SpotSocialAttachment>[];
    }
    final created = <SpotSocialAttachment>[];
    for (final attachment in attachments) {
      created.add(
        await _uploadAttachmentRecord(
          authorUserId: authorUserId,
          postId: postId,
          replyId: null,
          attachment: attachment,
        ),
      );
    }
    return created;
  }

  Future<List<SpotSocialAttachment>> _uploadAttachmentsForReply({
    required String replyId,
    required String authorUserId,
    required List<SpotSocialAttachmentDraft> attachments,
  }) async {
    if (attachments.isEmpty || !_useSupabase || _client == null) {
      return const <SpotSocialAttachment>[];
    }
    final created = <SpotSocialAttachment>[];
    for (final attachment in attachments) {
      created.add(
        await _uploadAttachmentRecord(
          authorUserId: authorUserId,
          postId: null,
          replyId: replyId,
          attachment: attachment,
        ),
      );
    }
    return created;
  }

  Future<SpotSocialAttachment> _uploadAttachmentRecord({
    required String authorUserId,
    required String? postId,
    required String? replyId,
    required SpotSocialAttachmentDraft attachment,
  }) async {
    final client = _client;
    if (client == null) {
      throw StateError('Supabase no configurado para subir adjuntos.');
    }
    final safeFileName = _sanitizeFileName(attachment.fileName);
    final extension = _fileExtension(safeFileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final basePath =
        '$authorUserId/$timestamp-${attachment.type.name}${extension.isEmpty ? '' : '.$extension'}';
    await client.storage
        .from(_attachmentsBucket)
        .uploadBinary(
          basePath,
          attachment.bytes,
          fileOptions: FileOptions(
            contentType:
                attachment.mimeType ?? _defaultMimeType(attachment.type),
            upsert: false,
          ),
        );
    String? thumbnailUrl;
    if (attachment.thumbnailBytes != null) {
      final thumbnailPath =
          '$authorUserId/$timestamp-${attachment.type.name}-thumb.jpg';
      await client.storage
          .from(_attachmentsBucket)
          .uploadBinary(
            thumbnailPath,
            attachment.thumbnailBytes!,
            fileOptions: FileOptions(
              contentType: attachment.thumbnailMimeType ?? 'image/jpeg',
              upsert: false,
            ),
          );
      thumbnailUrl = client.storage
          .from(_attachmentsBucket)
          .getPublicUrl(thumbnailPath);
    }
    final publicUrl = client.storage
        .from(_attachmentsBucket)
        .getPublicUrl(basePath);
    final inserted = await client
        .from('spot_social_attachments')
        .insert(<String, dynamic>{
          'post_id': postId,
          'reply_id': replyId,
          'author_user_id': authorUserId,
          'attachment_type': attachment.type.name,
          'storage_path': basePath,
          'public_url': publicUrl,
          'thumbnail_url': thumbnailUrl,
          'file_name': safeFileName,
          'mime_type': attachment.mimeType ?? _defaultMimeType(attachment.type),
          'size_bytes': attachment.bytes.length,
        })
        .select()
        .single();
    return _attachmentFromRow(inserted);
  }

  String _sanitizeFileName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'attachment';
    }
    return trimmed.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
  }

  String _fileExtension(String value) {
    final dot = value.lastIndexOf('.');
    if (dot <= 0 || dot == value.length - 1) {
      return '';
    }
    return value.substring(dot + 1).toLowerCase();
  }

  String _defaultMimeType(SpotSocialAttachmentType type) {
    return type == SpotSocialAttachmentType.video ? 'video/mp4' : 'image/jpeg';
  }
}
