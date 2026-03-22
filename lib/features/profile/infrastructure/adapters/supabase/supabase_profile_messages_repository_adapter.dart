import 'dart:async';

import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_messages_repository_port.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/in_memory/in_memory_profile_messages_repository_adapter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileMessagesRepositoryAdapter
    implements ProfileMessagesRepositoryPort {
  SupabaseProfileMessagesRepositoryAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client,
      _fallbackIndexed = InMemoryProfileMessagesRepositoryAdapter();

  final SupabaseClient _client;
  final InMemoryProfileMessagesRepositoryAdapter _fallbackIndexed;

  final List<DirectMessageThread> _directThreads = <DirectMessageThread>[];
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
  Future<void> hydrate() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _directThreads.clear();
      _indexedMessages
        ..clear()
        ..addAll(_fallbackIndexed.getIndexedMessages());
      _mutedThreadIds.clear();
      _blockedThreadIds.clear();
      _deletedThreadIds.clear();
      return;
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
        .select('thread_id, body, created_at')
        .inFilter('thread_id', threadIds)
        .order('created_at', ascending: false);
    final allParticipants = await _client
        .from('direct_thread_participants')
        .select('thread_id, user_id, profiles!inner(display_name)')
        .inFilter('thread_id', threadIds);
    final stateRows = await _client
        .from('direct_thread_user_states')
        .select('thread_id, is_muted, is_blocked, is_deleted')
        .eq('user_id', user.id)
        .inFilter('thread_id', threadIds);

    _mutedThreadIds.clear();
    _blockedThreadIds.clear();
    _deletedThreadIds.clear();
    for (final row in (stateRows as List<dynamic>).whereType<Map<String, dynamic>>()) {
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
    }

    final latestMessageByThread = <String, Map<String, dynamic>>{};
    for (final row in (messagesRows as List<dynamic>).whereType<Map<String, dynamic>>()) {
      final threadId = row['thread_id'] as String?;
      if (threadId == null || latestMessageByThread.containsKey(threadId)) {
        continue;
      }
      latestMessageByThread[threadId] = row;
    }

    final participantNameByThread = <String, String>{};
    for (final row in (allParticipants as List<dynamic>).whereType<Map<String, dynamic>>()) {
      final threadId = row['thread_id'] as String?;
      final participantId = row['user_id'] as String?;
      if (threadId == null ||
          participantId == null ||
          participantId == user.id ||
          participantNameByThread.containsKey(threadId)) {
        continue;
      }
      final profile = row['profiles'];
      if (profile is Map<String, dynamic>) {
        participantNameByThread[threadId] =
            (profile['display_name'] as String?)?.trim().isNotEmpty == true
            ? (profile['display_name'] as String).trim()
            : 'Rider';
      } else if (profile is List && profile.isNotEmpty) {
        final first = profile.first;
        if (first is Map<String, dynamic>) {
          participantNameByThread[threadId] =
              (first['display_name'] as String?)?.trim().isNotEmpty == true
              ? (first['display_name'] as String).trim()
              : 'Rider';
        }
      }
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
                participant: participantName ?? (title.isNotEmpty ? title : 'Chat'),
                preview: (latest?['body'] as String?) ?? 'Sin mensajes todavia.',
                lastActivity:
                    DateTime.tryParse((latest?['created_at'] as String?) ?? '') ??
                    updatedAt,
                unreadCount: 0,
                isMuted: _mutedThreadIds.contains(id),
                isBlocked: _blockedThreadIds.contains(id),
                lastLocation: 'Mensajes directos',
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
  bool blockDirectThread(String threadId) {
    if (_blockedThreadIds.contains(threadId)) {
      return false;
    }
    _blockedThreadIds.add(threadId);
    _applyLocalFlags(threadId);
    unawaited(_persistThreadState(threadId));
    return true;
  }

  @override
  void deleteDirectThread(String threadId) {
    _deletedThreadIds.add(threadId);
    _directThreads.removeWhere((item) => item.id == threadId);
    unawaited(_persistThreadState(threadId));
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

  Future<void> _persistIndexedMessageUpdate(AppMessageIndexEntry updated) async {
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

  List<AppMessageIndexEntry> _buildIndexedEntries(
    dynamic sessionCommentRows,
    dynamic authoredMessageRows,
  ) {
    final entries = <AppMessageIndexEntry>[];

    for (final row in (sessionCommentRows as List<dynamic>).whereType<Map<String, dynamic>>()) {
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

    for (final row in (authoredMessageRows as List<dynamic>).whereType<Map<String, dynamic>>()) {
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
