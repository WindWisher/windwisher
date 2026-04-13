import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_message.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_user_candidate.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_messages_repository_port.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/in_memory/in_memory_profile_messages_repository_adapter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class SupabaseProfileMessagesRepositoryAdapter
    implements ProfileMessagesRepositoryPort {
  static const Uuid _uuid = Uuid();
  static const String _attachmentsBucket = 'direct-chat-media';
  SupabaseProfileMessagesRepositoryAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      _fallbackIndexed = InMemoryProfileMessagesRepositoryAdapter();

  final SupabaseClient _client;
  final InMemoryProfileMessagesRepositoryAdapter _fallbackIndexed;

  final List<DirectMessageThread> _directThreads = <DirectMessageThread>[];
  final List<DirectChatUserCandidate> _userCandidates =
      <DirectChatUserCandidate>[];
  final List<AppMessageIndexEntry> _indexedMessages = <AppMessageIndexEntry>[];
  final Set<String> _mutedThreadIds = <String>{};
  final Set<String> _blockedThreadIds = <String>{};
  final Set<String> _deletedThreadIds = <String>{};

  @override
  List<DirectMessageThread> getDirectMessageThreads() {
    return List<DirectMessageThread>.unmodifiable(_directThreads);
  }

  @override
  List<AppMessageIndexEntry> getIndexedMessages() {
    return List<AppMessageIndexEntry>.unmodifiable(_indexedMessages);
  }

  @override
  List<DirectChatUserCandidate> getDirectChatUserCandidates() {
    return List<DirectChatUserCandidate>.unmodifiable(_userCandidates);
  }

  @override
  Future<void> hydrate() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _directThreads.clear();
      _userCandidates
        ..clear()
        ..addAll(_fallbackIndexed.getDirectChatUserCandidates());
      _indexedMessages
        ..clear()
        ..addAll(_fallbackIndexed.getIndexedMessages());
      _mutedThreadIds.clear();
      _blockedThreadIds.clear();
      _deletedThreadIds.clear();
      return;
    }

    final candidateRows = await _client
        .from('public_profiles')
        .select('id, display_name, handle, avatar_path')
        .neq('id', user.id);
    _userCandidates
      ..clear()
      ..addAll(
        (candidateRows as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(_candidateFromRow)
            .where((candidate) => candidate.displayName.isNotEmpty)
            .toList(growable: false)
          ..sort(
            (a, b) => a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            ),
          ),
      );

    final participantRows = await _client
        .from('direct_thread_participants')
        .select('thread_id')
        .eq('user_id', user.id);

    final threadIds = (participantRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['thread_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList(growable: false);

    if (threadIds.isEmpty) {
      _directThreads.clear();
      return;
    }

    final threadsRows = await _client
        .from('direct_threads')
        .select('id, title, updated_at')
        .inFilter('id', threadIds);
    final messagesRows = await _client
        .from('direct_messages')
        .select('thread_id, body, created_at, attachment_type, sender_user_id')
        .inFilter('thread_id', threadIds)
        .order('created_at', ascending: false);
    final allParticipants = await _client
        .from('direct_thread_participants')
        .select('thread_id, user_id')
        .inFilter('thread_id', threadIds);
    final participantIds = (allParticipants as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['user_id'] as String?)
        .whereType<String>()
        .where((participantId) => participantId != user.id)
        .toSet()
        .toList(growable: false);
    final participantProfiles = participantIds.isEmpty
        ? const <dynamic>[]
        : await _client
              .from('public_profiles')
              .select('id, display_name, avatar_path')
              .inFilter('id', participantIds);
    final stateRows = await _client
        .from('direct_thread_user_states')
        .select(
          'thread_id, is_muted, is_blocked, is_deleted, last_read_message_created_at',
        )
        .eq('user_id', user.id)
        .inFilter('thread_id', threadIds);

    _mutedThreadIds.clear();
    _blockedThreadIds.clear();
    _deletedThreadIds.clear();
    final lastReadAtByThread = <String, DateTime?>{};
    for (final row
        in (stateRows as List<dynamic>).whereType<Map<String, dynamic>>()) {
      final threadId = row['thread_id'] as String?;
      if (threadId == null) {
        continue;
      }
      if (row['is_muted'] == true) {
        _mutedThreadIds.add(threadId);
      }
      if (row['is_blocked'] == true) {
        _blockedThreadIds.add(threadId);
      }
      if (row['is_deleted'] == true) {
        _deletedThreadIds.add(threadId);
      }
      lastReadAtByThread[threadId] = DateTime.tryParse(
        (row['last_read_message_created_at'] as String?) ?? '',
      );
    }

    final latestMessageByThread = <String, Map<String, dynamic>>{};
    final unreadCountByThread = <String, int>{};
    for (final row
        in (messagesRows as List<dynamic>).whereType<Map<String, dynamic>>()) {
      final threadId = row['thread_id'] as String?;
      if (threadId == null) {
        continue;
      }
      latestMessageByThread.putIfAbsent(threadId, () => row);
      final senderUserId = row['sender_user_id'] as String?;
      if (senderUserId == user.id) {
        continue;
      }
      final createdAt = DateTime.tryParse((row['created_at'] as String?) ?? '');
      final lastReadAt = lastReadAtByThread[threadId];
      if (createdAt == null ||
          (lastReadAt != null && !createdAt.isAfter(lastReadAt))) {
        continue;
      }
      unreadCountByThread[threadId] = (unreadCountByThread[threadId] ?? 0) + 1;
    }

    final displayNameByParticipantId = <String, String>{};
    final avatarPathByParticipantId = <String, String?>{};
    for (final row in participantProfiles.whereType<Map<String, dynamic>>()) {
      final participantId = row['id'] as String?;
      if (participantId == null || participantId.isEmpty) {
        continue;
      }
      final displayName = (row['display_name'] as String?)?.trim();
      displayNameByParticipantId[participantId] =
          displayName == null || displayName.isEmpty ? 'Rider' : displayName;
      avatarPathByParticipantId[participantId] = (row['avatar_path'] as String?)
          ?.trim();
    }

    final participantNameByThread = <String, String>{};
    final participantAvatarByThread = <String, String?>{};
    for (final row
        in (allParticipants as List<dynamic>)
            .whereType<Map<String, dynamic>>()) {
      final threadId = row['thread_id'] as String?;
      final participantId = row['user_id'] as String?;
      if (threadId == null ||
          participantId == null ||
          participantId == user.id ||
          participantNameByThread.containsKey(threadId)) {
        continue;
      }
      participantNameByThread[threadId] =
          displayNameByParticipantId[participantId] ?? 'Rider';
      participantAvatarByThread[threadId] =
          avatarPathByParticipantId[participantId];
    }

    _directThreads
      ..clear()
      ..addAll(
        (threadsRows as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((row) {
              final id = row['id'] as String? ?? '';
              final latest = latestMessageByThread[id];
              final updatedAt =
                  DateTime.tryParse((row['updated_at'] as String?) ?? '') ??
                  DateTime.now();
              final title = (row['title'] as String?)?.trim() ?? '';
              final participantName = participantNameByThread[id];
              return DirectMessageThread(
                id: id,
                participant:
                    participantName ?? (title.isNotEmpty ? title : 'Chat'),
                preview: _messagePreviewFromRow(latest),
                lastActivity:
                    DateTime.tryParse(
                      (latest?['created_at'] as String?) ?? '',
                    ) ??
                    updatedAt,
                unreadCount: unreadCountByThread[id] ?? 0,
                isMuted: _mutedThreadIds.contains(id),
                isBlocked: _blockedThreadIds.contains(id),
                lastLocation: 'Mensajes directos',
                participantAvatarPath: participantAvatarByThread[id],
              );
            })
            .where((thread) => !_deletedThreadIds.contains(thread.id))
            .toList(growable: false)
          ..sort((a, b) => b.lastActivity.compareTo(a.lastActivity)),
      );

    final sessionCommentRows = await _client
        .from('session_comments')
        .select('id, text, created_at, sessions!inner(title, spot_name)')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    final authoredMessageRows = await _client
        .from('direct_messages')
        .select('id, body, created_at, direct_threads!inner(title)')
        .eq('sender_user_id', user.id)
        .order('created_at', ascending: false);

    _indexedMessages
      ..clear()
      ..addAll(_buildIndexedEntries(sessionCommentRows, authoredMessageRows));
    if (_indexedMessages.isEmpty) {
      _indexedMessages.addAll(_fallbackIndexed.getIndexedMessages());
    }
  }

  @override
  void toggleMuteDirectThread(String threadId) {
    if (_mutedThreadIds.contains(threadId)) {
      _mutedThreadIds.remove(threadId);
    } else {
      _mutedThreadIds.add(threadId);
    }
    _applyLocalFlags(threadId);
    unawaited(_persistThreadState(threadId));
  }

  @override
  bool toggleBlockDirectThread(String threadId) {
    final nextBlocked = !_blockedThreadIds.contains(threadId);
    if (nextBlocked) {
      _blockedThreadIds.add(threadId);
    } else {
      _blockedThreadIds.remove(threadId);
    }
    _applyLocalFlags(threadId);
    unawaited(_persistThreadState(threadId));
    return nextBlocked;
  }

  @override
  void deleteDirectThread(String threadId) {
    _deletedThreadIds.add(threadId);
    _directThreads.removeWhere((item) => item.id == threadId);
    unawaited(_persistThreadState(threadId));
  }

  @override
  Future<DirectMessageThread?> createOrOpenDirectChat(String userId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    DirectChatUserCandidate? candidate;
    for (final item in _userCandidates) {
      if (item.id == userId) {
        candidate = item;
        break;
      }
    }
    if (candidate == null) {
      return null;
    }

    final participantRows = await _client
        .from('direct_thread_participants')
        .select('thread_id')
        .eq('user_id', user.id);
    final threadIds = (participantRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['thread_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList(growable: false);

    if (threadIds.isNotEmpty) {
      final allParticipants = await _client
          .from('direct_thread_participants')
          .select('thread_id, user_id')
          .inFilter('thread_id', threadIds);
      final participantsByThread = <String, Set<String>>{};
      for (final row
          in (allParticipants as List<dynamic>)
              .whereType<Map<String, dynamic>>()) {
        final threadId = row['thread_id'] as String?;
        final participantId = row['user_id'] as String?;
        if (threadId == null || participantId == null) {
          continue;
        }
        participantsByThread
            .putIfAbsent(threadId, () => <String>{})
            .add(participantId);
      }
      for (final entry in participantsByThread.entries) {
        if (entry.value.length == 2 &&
            entry.value.contains(user.id) &&
            entry.value.contains(userId)) {
          _deletedThreadIds.remove(entry.key);
          await _persistThreadState(entry.key);
          await hydrate();
          for (final thread in _directThreads) {
            if (thread.id == entry.key) {
              return thread;
            }
          }
          return null;
        }
      }
    }

    final threadId = _uuid.v4();

    await _client.from('direct_threads').insert(<String, dynamic>{
      'id': threadId,
      'created_by': user.id,
      'title': candidate.displayName,
    });

    await _client.from('direct_thread_participants').insert(
      <Map<String, dynamic>>[
        <String, dynamic>{'thread_id': threadId, 'user_id': user.id},
        <String, dynamic>{'thread_id': threadId, 'user_id': userId},
      ],
    );

    _deletedThreadIds.remove(threadId);
    await hydrate();

    for (final thread in _directThreads) {
      if (thread.id == threadId) {
        return thread;
      }
    }
    return DirectMessageThread(
      id: threadId,
      participant: candidate.displayName,
      preview: 'Sin mensajes todavia.',
      lastActivity: DateTime.now(),
      unreadCount: 0,
      isMuted: false,
      isBlocked: false,
      lastLocation: 'Mensajes directos',
      participantAvatarPath: candidate.avatarPath,
    );
  }

  @override
  Future<List<DirectChatMessage>> loadDirectChatMessages(
    String threadId,
  ) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const <DirectChatMessage>[];
    }

    final participantRows = await _client
        .from('direct_thread_participants')
        .select('user_id')
        .eq('thread_id', threadId);
    final peerUserId = (participantRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['user_id'] as String?)
        .whereType<String>()
        .firstWhere((id) => id != user.id, orElse: () => '');
    DateTime? peerLastReadAt;
    if (peerUserId.isNotEmpty) {
      final peerState = await _client
          .from('direct_thread_user_states')
          .select('last_read_message_created_at')
          .eq('thread_id', threadId)
          .eq('user_id', peerUserId)
          .maybeSingle();
      peerLastReadAt = DateTime.tryParse(
        (peerState?['last_read_message_created_at'] as String?) ?? '',
      );
    }

    final rows = await _client
        .from('direct_messages')
        .select(_directMessageSelect)
        .eq('thread_id', threadId)
        .order('created_at', ascending: true);

    final typedRows = (rows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    final rowById = <String, Map<String, dynamic>>{};
    for (final row in typedRows) {
      final id = row['id'] as String?;
      if (id != null && id.isNotEmpty) {
        rowById[id] = row;
      }
    }

    return typedRows
        .map(
          (row) => _messageFromRow(
            row,
            currentUserId: user.id,
            fallbackThreadId: threadId,
            replyLookup: rowById,
            peerLastReadAt: peerLastReadAt,
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<void> markDirectThreadAsRead(String threadId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    final latestRows = await _client
        .from('direct_messages')
        .select('created_at')
        .eq('thread_id', threadId)
        .order('created_at', ascending: false)
        .limit(1);
    final latest = (latestRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    final lastReadAt = latest.isEmpty
        ? DateTime.now().toUtc().toIso8601String()
        : ((latest.first['created_at'] as String?) ??
              DateTime.now().toUtc().toIso8601String());
    await _client.from('direct_thread_user_states').upsert(<String, dynamic>{
      'thread_id': threadId,
      'user_id': user.id,
      'is_muted': _mutedThreadIds.contains(threadId),
      'is_blocked': _blockedThreadIds.contains(threadId),
      'is_deleted': _deletedThreadIds.contains(threadId),
      'last_read_message_created_at': lastReadAt,
    });
    final index = _directThreads.indexWhere((item) => item.id == threadId);
    if (index >= 0) {
      _directThreads[index] = _directThreads[index].copyWith(unreadCount: 0);
    }
  }

  @override
  Stream<bool> watchDirectChatTyping(String threadId) {
    final user = _client.auth.currentUser;
    if (user == null) {
      return Stream<bool>.value(false);
    }
    final controller = StreamController<bool>();
    final channel = _client.channel('direct-chat-typing:$threadId');

    channel
        .onBroadcast(
          event: 'typing',
          callback: (payload) {
            final data = payload['payload'];
            if (data is! Map) {
              return;
            }
            final senderId = data['sender_id'] as String?;
            if (senderId == null || senderId == user.id) {
              return;
            }
            controller.add(data['is_typing'] == true);
          },
        )
        .subscribe();

    controller.onCancel = () async {
      await _client.removeChannel(channel);
    };

    return controller.stream;
  }

  @override
  Future<void> sendDirectChatTypingState({
    required String threadId,
    required String participantLabel,
    required bool isTyping,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    final channel = _client.channel('direct-chat-typing:$threadId');
    channel.subscribe((status, [_]) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        await channel.sendBroadcastMessage(
          event: 'typing',
          payload: <String, dynamic>{
            'sender_id': user.id,
            'participant_label': participantLabel,
            'is_typing': isTyping,
          },
        );
        await _client.removeChannel(channel);
      }
    });
  }

  @override
  Stream<void> watchDirectThreads() {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Stream<void>.empty();
    }
    final controller = StreamController<void>();
    final channel = _client.channel(
      'direct-threads:${user.id}:${DateTime.now().microsecondsSinceEpoch}',
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
          table: 'direct_messages',
          callback: (_) => emitRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'direct_thread_user_states',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (_) => emitRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'direct_thread_participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (_) => emitRefresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'direct_threads',
          callback: (_) => emitRefresh(),
        )
        .subscribe();

    controller.onCancel = () async {
      await _client.removeChannel(channel);
    };

    return controller.stream;
  }

  @override
  Stream<void> watchDirectChatMessages(String threadId) {
    final user = _client.auth.currentUser;
    if (user == null) {
      return const Stream<void>.empty();
    }
    final controller = StreamController<void>();
    final channel = _client.channel(
      'direct-chat:$threadId:${DateTime.now().microsecondsSinceEpoch}',
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
          table: 'direct_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'thread_id',
            value: threadId,
          ),
          callback: (_) => emitRefresh(),
        )
        .subscribe();

    controller.onCancel = () async {
      await _client.removeChannel(channel);
    };

    return controller.stream;
  }

  @override
  Future<DirectChatMessage?> sendDirectChatMessage(
    String threadId,
    String body, {
    String? replyToMessageId,
  }) async {
    final user = _client.auth.currentUser;
    final trimmed = body.trim();
    if (user == null || trimmed.isEmpty) {
      return null;
    }

    final row = await _client
        .from('direct_messages')
        .insert(<String, dynamic>{
          'thread_id': threadId,
          'sender_user_id': user.id,
          'body': trimmed,
          'attachment_type': 'text',
          'reply_to_message_id': replyToMessageId,
        })
        .select(_directMessageSelect)
        .single();

    final message = _messageFromRow(
      row,
      currentUserId: user.id,
      fallbackThreadId: threadId,
    );
    _upsertThreadPreview(
      threadId: threadId,
      preview: message.content,
      sentAt: message.sentAt,
    );
    await _triggerDirectMessagePush(message.id);
    return message;
  }

  @override
  Future<DirectChatMessage?> sendDirectChatMediaMessage({
    required String threadId,
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required bool isVideo,
    String? replyToMessageId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null || bytes.isEmpty) {
      return null;
    }

    final safeFileName = _sanitizeFileName(fileName);
    final extension = _fileExtension(safeFileName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final attachmentType = isVideo ? 'video' : 'image';
    final storagePath =
        '${user.id}/$threadId/$timestamp-$attachmentType${extension.isEmpty ? '' : '.$extension'}';

    await _client.storage
        .from(_attachmentsBucket)
        .uploadBinary(
          storagePath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(
            contentType: mimeType.trim().isEmpty
                ? _defaultMimeType(isVideo: isVideo, fileName: safeFileName)
                : mimeType.trim(),
            upsert: false,
          ),
        );

    final publicUrl = _client.storage
        .from(_attachmentsBucket)
        .getPublicUrl(storagePath);
    final body = isVideo ? 'Video enviado' : 'Foto enviada';

    final row = await _client
        .from('direct_messages')
        .insert(<String, dynamic>{
          'thread_id': threadId,
          'sender_user_id': user.id,
          'body': body,
          'attachment_type': attachmentType,
          'storage_path': storagePath,
          'public_url': publicUrl,
          'file_name': safeFileName,
          'mime_type': mimeType.trim().isEmpty
              ? _defaultMimeType(isVideo: isVideo, fileName: safeFileName)
              : mimeType.trim(),
          'size_bytes': bytes.length,
          'reply_to_message_id': replyToMessageId,
        })
        .select(_directMessageSelect)
        .single();

    final message = _messageFromRow(
      row,
      currentUserId: user.id,
      fallbackThreadId: threadId,
    );
    _upsertThreadPreview(
      threadId: threadId,
      preview: message.content,
      sentAt: message.sentAt,
    );
    await _triggerDirectMessagePush(message.id);
    return message;
  }

  @override
  Future<DirectChatMessage?> updateDirectChatMessage(
    String messageId,
    String body,
  ) async {
    final user = _client.auth.currentUser;
    final trimmed = body.trim();
    if (user == null || trimmed.isEmpty) {
      return null;
    }

    final row = await _client
        .from('direct_messages')
        .update(<String, dynamic>{'body': trimmed})
        .eq('id', messageId)
        .eq('sender_user_id', user.id)
        .select(_directMessageSelect)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    final message = _messageFromRow(
      row,
      currentUserId: user.id,
      fallbackThreadId: '',
      forceEdited: true,
    );
    _upsertThreadPreview(
      threadId: message.threadId,
      preview: message.content,
      sentAt: message.sentAt,
    );
    return message;
  }

  @override
  Future<void> deleteDirectChatMessages(List<String> messageIds) async {
    final user = _client.auth.currentUser;
    if (user == null || messageIds.isEmpty) {
      return;
    }

    final rows = await _client
        .from('direct_messages')
        .select('id, thread_id')
        .inFilter('id', messageIds)
        .eq('sender_user_id', user.id);
    final threadIds = (rows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['thread_id'] as String?)
        .whereType<String>()
        .toSet()
        .toList(growable: false);

    await _client
        .from('direct_messages')
        .delete()
        .inFilter('id', messageIds)
        .eq('sender_user_id', user.id);

    for (final threadId in threadIds) {
      await _refreshThreadPreview(threadId);
    }
  }

  @override
  void updateIndexedMessage(AppMessageIndexEntry updated) {
    final index = _indexedMessages.indexWhere((item) => item.id == updated.id);
    if (index >= 0) {
      _indexedMessages[index] = updated;
      unawaited(_persistIndexedMessageUpdate(updated));
      return;
    }
    _fallbackIndexed.updateIndexedMessage(updated);
  }

  @override
  void deleteIndexedMessage(String id) {
    final hadEntry = _indexedMessages.any((item) => item.id == id);
    _indexedMessages.removeWhere((item) => item.id == id);
    if (!hadEntry) {
      _fallbackIndexed.deleteIndexedMessage(id);
      return;
    }
    unawaited(_persistIndexedMessageDelete(id));
  }

  void _upsertThreadPreview({
    required String threadId,
    required String preview,
    required DateTime sentAt,
  }) {
    final index = _directThreads.indexWhere((item) => item.id == threadId);
    if (index < 0) {
      return;
    }
    final current = _directThreads.removeAt(index);
    _directThreads.insert(
      0,
      DirectMessageThread(
        id: current.id,
        participant: current.participant,
        participantAvatarPath: current.participantAvatarPath,
        preview: preview,
        lastActivity: sentAt,
        unreadCount: current.unreadCount,
        isMuted: current.isMuted,
        isBlocked: current.isBlocked,
        lastLocation: current.lastLocation,
      ),
    );
  }

  Future<void> _refreshThreadPreview(String threadId) async {
    final latestRows = await _client
        .from('direct_messages')
        .select('body, created_at')
        .eq('thread_id', threadId)
        .order('created_at', ascending: false)
        .limit(1);
    final latest = (latestRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    final index = _directThreads.indexWhere((item) => item.id == threadId);
    if (index < 0) {
      return;
    }
    final current = _directThreads[index];
    if (latest.isEmpty) {
      _directThreads[index] = DirectMessageThread(
        id: current.id,
        participant: current.participant,
        participantAvatarPath: current.participantAvatarPath,
        preview: 'Sin mensajes todavia.',
        lastActivity: current.lastActivity,
        unreadCount: current.unreadCount,
        isMuted: current.isMuted,
        isBlocked: current.isBlocked,
        lastLocation: current.lastLocation,
      );
      return;
    }
    final row = latest.first;
    _directThreads[index] = DirectMessageThread(
      id: current.id,
      participant: current.participant,
      participantAvatarPath: current.participantAvatarPath,
      preview: (row['body'] as String?)?.trim() ?? 'Sin mensajes todavia.',
      lastActivity:
          DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          current.lastActivity,
      unreadCount: current.unreadCount,
      isMuted: current.isMuted,
      isBlocked: current.isBlocked,
      lastLocation: current.lastLocation,
    );
  }

  void _applyLocalFlags(String threadId) {
    final index = _directThreads.indexWhere((item) => item.id == threadId);
    if (index < 0) {
      return;
    }
    final current = _directThreads[index];
    _directThreads[index] = current.copyWith(
      isMuted: _mutedThreadIds.contains(threadId),
      isBlocked: _blockedThreadIds.contains(threadId),
    );
  }

  Future<void> _triggerDirectMessagePush(String messageId) async {
    final response = await _client.functions.invoke(
      'direct-message-push',
      headers: const <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{'messageId': messageId}),
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final sent = data['sent'] is num ? (data['sent'] as num).toInt() : int.tryParse('${data['sent']}') ?? 0;
      final failed = data['failed'] is num ? (data['failed'] as num).toInt() : int.tryParse('${data['failed']}') ?? 0;
      final reason = data['reason']?.toString() ?? 'unknown';
      debugPrint(
        'direct-message-push result: messageId=$messageId sent=$sent failed=$failed reason=$reason',
      );
      if (sent <= 0) {
        throw Exception('Push no enviada: $reason');
      }
      return;
    }
    debugPrint(
      'direct-message-push result: messageId=$messageId raw=${response.data}',
    );
    throw Exception('Push no confirmada para el mensaje enviado.');
  }

  Future<void> _persistThreadState(String threadId) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from('direct_thread_user_states').upsert(<String, dynamic>{
      'thread_id': threadId,
      'user_id': user.id,
      'is_muted': _mutedThreadIds.contains(threadId),
      'is_blocked': _blockedThreadIds.contains(threadId),
      'is_deleted': _deletedThreadIds.contains(threadId),
    });
  }

  Future<void> _persistIndexedMessageUpdate(
    AppMessageIndexEntry updated,
  ) async {
    if (updated.id.startsWith('session-comment-')) {
      final commentId = updated.id.substring('session-comment-'.length);
      await _client
          .from('session_comments')
          .update(<String, dynamic>{'text': updated.message})
          .eq('id', commentId);
      return;
    }
    if (updated.id.startsWith('direct-message-')) {
      final messageId = updated.id.substring('direct-message-'.length);
      await _client
          .from('direct_messages')
          .update(<String, dynamic>{'body': updated.message})
          .eq('id', messageId);
    }
  }

  Future<void> _persistIndexedMessageDelete(String id) async {
    if (id.startsWith('session-comment-')) {
      final commentId = id.substring('session-comment-'.length);
      await _client.from('session_comments').delete().eq('id', commentId);
      return;
    }
    if (id.startsWith('direct-message-')) {
      final messageId = id.substring('direct-message-'.length);
      await _client.from('direct_messages').delete().eq('id', messageId);
    }
  }

  DirectChatUserCandidate _candidateFromRow(Map<String, dynamic> row) {
    final displayName = (row['display_name'] as String?)?.trim();
    final handle = (row['handle'] as String?)?.trim();
    return DirectChatUserCandidate(
      id: row['id'] as String? ?? '',
      displayName: displayName == null || displayName.isEmpty
          ? (handle == null || handle.isEmpty
                ? 'Rider'
                : handle.replaceFirst('@', ''))
          : displayName,
      handle: handle == null || handle.isEmpty
          ? '@rider'
          : (handle.startsWith('@') ? handle : '@$handle'),
      avatarPath: (row['avatar_path'] as String?)?.trim(),
    );
  }

  static const String _directMessageSelect =
      'id, thread_id, sender_user_id, body, created_at, attachment_type, public_url, thumbnail_url, file_name, mime_type, reply_to_message_id';

  DirectChatMessage _messageFromRow(
    Map<String, dynamic> row, {
    required String currentUserId,
    required String fallbackThreadId,
    bool forceEdited = false,
    Map<String, Map<String, dynamic>>? replyLookup,
    DateTime? peerLastReadAt,
  }) {
    final attachmentType =
        (row['attachment_type'] as String?)?.trim() ?? 'text';
    final type = switch (attachmentType) {
      'image' => DirectChatMessageType.image,
      'video' => DirectChatMessageType.video,
      _ => DirectChatMessageType.text,
    };
    final replyToMessageId = row['reply_to_message_id'] as String?;
    final repliedRow = replyToMessageId == null || replyLookup == null
        ? null
        : replyLookup[replyToMessageId];
    final repliedAttachmentType =
        (repliedRow?['attachment_type'] as String?)?.trim() ?? 'text';
    final repliedType = repliedRow == null
        ? null
        : switch (repliedAttachmentType) {
            'image' => DirectChatMessageType.image,
            'video' => DirectChatMessageType.video,
            _ => DirectChatMessageType.text,
          };
    return DirectChatMessage(
      id: row['id'] as String? ?? '',
      threadId: row['thread_id'] as String? ?? fallbackThreadId,
      content: (row['body'] as String?)?.trim() ?? '',
      sentAt:
          DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.now(),
      isMine: row['sender_user_id'] == currentUserId,
      type: type,
      mediaUrl: row['public_url'] as String?,
      thumbnailUrl: row['thumbnail_url'] as String?,
      fileName: row['file_name'] as String?,
      mimeType: row['mime_type'] as String?,
      isEdited: forceEdited,
      replyToMessageId: replyToMessageId,
      replyToContent: (repliedRow?['body'] as String?)?.trim(),
      replyToType: repliedType,
      isReplyToMine: repliedRow == null
          ? null
          : repliedRow['sender_user_id'] == currentUserId,
    );
  }

  String _messagePreviewFromRow(Map<String, dynamic>? row) {
    if (row == null) {
      return 'Sin mensajes todavia.';
    }
    final attachmentType =
        (row['attachment_type'] as String?)?.trim() ?? 'text';
    if (attachmentType == 'image') {
      return 'Foto enviada';
    }
    if (attachmentType == 'video') {
      return 'Video enviado';
    }
    final body = (row['body'] as String?)?.trim();
    return body == null || body.isEmpty ? 'Sin mensajes todavia.' : body;
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
    if (dot < 0 || dot == value.length - 1) {
      return '';
    }
    return value.substring(dot + 1).toLowerCase();
  }

  String _defaultMimeType({required bool isVideo, required String fileName}) {
    final extension = _fileExtension(fileName);
    if (isVideo) {
      return switch (extension) {
        'mov' => 'video/quicktime',
        'm4v' => 'video/x-m4v',
        'webm' => 'video/webm',
        _ => 'video/mp4',
      };
    }
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  List<AppMessageIndexEntry> _buildIndexedEntries(
    dynamic sessionCommentRows,
    dynamic authoredMessageRows,
  ) {
    final entries = <AppMessageIndexEntry>[];

    for (final row
        in (sessionCommentRows as List<dynamic>)
            .whereType<Map<String, dynamic>>()) {
      final id = row['id'] as String?;
      final text = (row['text'] as String?)?.trim();
      final createdAt = DateTime.tryParse((row['created_at'] as String?) ?? '');
      if (id == null || text == null || text.isEmpty || createdAt == null) {
        continue;
      }
      final session = row['sessions'];
      String contextLabel = 'Sesion';
      if (session is Map<String, dynamic>) {
        final title = (session['title'] as String?)?.trim();
        final spot = (session['spot_name'] as String?)?.trim();
        contextLabel = [
          if (title != null && title.isNotEmpty) title,
          if (spot != null && spot.isNotEmpty) spot,
        ].join(' · ');
        if (contextLabel.isEmpty) {
          contextLabel = 'Sesion';
        }
      }
      entries.add(
        AppMessageIndexEntry(
          id: 'session-comment-$id',
          channel: 'Sesiones',
          contextLabel: contextLabel,
          message: text,
          createdAt: createdAt,
        ),
      );
    }

    for (final row
        in (authoredMessageRows as List<dynamic>)
            .whereType<Map<String, dynamic>>()) {
      final id = row['id'] as String?;
      final body = (row['body'] as String?)?.trim();
      final createdAt = DateTime.tryParse((row['created_at'] as String?) ?? '');
      if (id == null || body == null || body.isEmpty || createdAt == null) {
        continue;
      }
      var contextLabel = 'Mensajes directos';
      final thread = row['direct_threads'];
      if (thread is Map<String, dynamic>) {
        final title = (thread['title'] as String?)?.trim();
        if (title != null && title.isNotEmpty) {
          contextLabel = title;
        }
      }
      entries.add(
        AppMessageIndexEntry(
          id: 'direct-message-$id',
          channel: 'Comunidad',
          contextLabel: contextLabel,
          message: body,
          createdAt: createdAt,
        ),
      );
    }

    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }
}
