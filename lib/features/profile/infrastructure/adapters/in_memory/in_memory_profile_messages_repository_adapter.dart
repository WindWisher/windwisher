import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_message.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_user_candidate.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_messages_repository_port.dart';

class InMemoryProfileMessagesRepositoryAdapter
    implements ProfileMessagesRepositoryPort {
  InMemoryProfileMessagesRepositoryAdapter({DateTime? now}) {
    final current = now ?? DateTime.now();
    _directThreads = [
      DirectMessageThread(
        id: 'dm-juan',
        participant: 'Juan Kitesurf',
        preview:
            'Mañana hay 24kt en Oliva. Si quieres vamos al downwind de las 10.',
        lastActivity: current.subtract(const Duration(minutes: 24)),
        unreadCount: 2,
        isMuted: false,
        isBlocked: false,
        lastLocation: 'Mensajes directos',
      ),
      DirectMessageThread(
        id: 'dm-marta',
        participant: 'Marta Loop',
        preview: 'Te comparto el setup que mejor me funciono con 30kt.',
        lastActivity: current.subtract(const Duration(hours: 3)),
        unreadCount: 0,
        isMuted: false,
        isBlocked: false,
        lastLocation: 'Mensajes directos',
      ),
      DirectMessageThread(
        id: 'dm-carlos',
        participant: 'Carlos Freeride',
        preview: 'Recibido, cierro la conversacion por hoy.',
        lastActivity: current.subtract(const Duration(days: 1)),
        unreadCount: 0,
        isMuted: true,
        isBlocked: false,
        lastLocation: 'Mensajes directos',
      ),
    ];
    _userCandidates = const [
      DirectChatUserCandidate(
        id: 'user-juan',
        displayName: 'Juan Kitesurf',
        handle: '@juan.kitesurf',
      ),
      DirectChatUserCandidate(
        id: 'user-marta',
        displayName: 'Marta Loop',
        handle: '@marta.loop',
      ),
      DirectChatUserCandidate(
        id: 'user-carlos',
        displayName: 'Carlos Freeride',
        handle: '@carlos.freeride',
      ),
      DirectChatUserCandidate(
        id: 'user-laura',
        displayName: 'Laura Big Air',
        handle: '@laura.bigair',
      ),
      DirectChatUserCandidate(
        id: 'user-sergio',
        displayName: 'Sergio Wave',
        handle: '@sergio.wave',
      ),
    ];
    _messagesByThread = {
      'dm-juan': [
        DirectChatMessage(
          id: 'msg-juan-1',
          threadId: 'dm-juan',
          content:
              'Mañana hay 24kt en Oliva. Si quieres vamos al downwind de las 10.',
          sentAt: current.subtract(const Duration(minutes: 24)),
          isMine: false,
          type: DirectChatMessageType.text,
        ),
        DirectChatMessage(
          id: 'msg-juan-2',
          threadId: 'dm-juan',
          content: 'Perfecto, si se mantiene me paso.',
          sentAt: current.subtract(const Duration(minutes: 18)),
          isMine: true,
          type: DirectChatMessageType.text,
        ),
      ],
      'dm-marta': [
        DirectChatMessage(
          id: 'msg-marta-1',
          threadId: 'dm-marta',
          content: 'Te comparto el setup que mejor me funciono con 30kt.',
          sentAt: current.subtract(const Duration(hours: 3)),
          isMine: false,
          type: DirectChatMessageType.text,
        ),
      ],
      'dm-carlos': [
        DirectChatMessage(
          id: 'msg-carlos-1',
          threadId: 'dm-carlos',
          content: 'Recibido, cierro la conversacion por hoy.',
          sentAt: current.subtract(const Duration(days: 1)),
          isMine: false,
          type: DirectChatMessageType.text,
        ),
      ],
    };
    _indexedMessages = [
      AppMessageIndexEntry(
        id: 'idx-community-1',
        channel: 'Comunidad',
        contextLabel: 'Post: Wind Window Gandia',
        message:
            'Subi el parte de hoy con rachas de 28kt y mejor ventana entre 14:00 y 16:00.',
        createdAt: current.subtract(const Duration(hours: 5)),
      ),
      AppMessageIndexEntry(
        id: 'idx-sessions-1',
        channel: 'Sesiones',
        contextLabel: 'Sesion en Oliva Norte',
        message: 'Anoté: buena ceñida con cometa 10m, ola corta al final.',
        createdAt: current.subtract(const Duration(hours: 9)),
      ),
      AppMessageIndexEntry(
        id: 'idx-spot-1',
        channel: 'Spots',
        contextLabel: 'Spot detail: Cullera Beach',
        message: 'Dejé comentario sobre corriente lateral en bajamar.',
        createdAt: current.subtract(const Duration(days: 1)),
      ),
      AppMessageIndexEntry(
        id: 'idx-community-2',
        channel: 'Comunidad',
        contextLabel: 'Chat grupo Big Air',
        message: 'Propuse abrir hilo de seguridad para saltos con mas de 30kt.',
        createdAt: current.subtract(const Duration(days: 2)),
      ),
    ];
  }

  late List<DirectMessageThread> _directThreads;
  late List<DirectChatUserCandidate> _userCandidates;
  late Map<String, List<DirectChatMessage>> _messagesByThread;
  late List<AppMessageIndexEntry> _indexedMessages;
  int _messageCounter = 100;

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
  Future<void> hydrate() async {}

  @override
  void toggleMuteDirectThread(String threadId) {
    final index = _directThreads.indexWhere((item) => item.id == threadId);
    if (index < 0) {
      return;
    }
    final current = _directThreads[index];
    _directThreads[index] = current.copyWith(isMuted: !current.isMuted);
  }

  @override
  bool toggleBlockDirectThread(String threadId) {
    final index = _directThreads.indexWhere((item) => item.id == threadId);
    if (index < 0) {
      return false;
    }
    final current = _directThreads[index];
    final nextBlocked = !current.isBlocked;
    _directThreads[index] = current.copyWith(isBlocked: nextBlocked);
    return nextBlocked;
  }

  @override
  void deleteDirectThread(String threadId) {
    _directThreads.removeWhere((item) => item.id == threadId);
    _messagesByThread.remove(threadId);
  }

  @override
  Future<DirectMessageThread?> createOrOpenDirectChat(String userId) async {
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
    final resolvedCandidate = candidate;
    final existingIndex = _directThreads.indexWhere(
      (thread) => thread.participant == resolvedCandidate.displayName,
    );
    if (existingIndex >= 0) {
      final existing = _directThreads.removeAt(existingIndex);
      _directThreads.insert(0, existing);
      return existing;
    }
    final thread = DirectMessageThread(
      id: 'dm-${resolvedCandidate.id}',
      participant: resolvedCandidate.displayName,
      preview: 'Sin mensajes todavia.',
      lastActivity: DateTime.now(),
      unreadCount: 0,
      isMuted: false,
      isBlocked: false,
      lastLocation: 'Mensajes directos',
      participantAvatarPath: resolvedCandidate.avatarPath,
    );
    _directThreads.insert(0, thread);
    _messagesByThread[thread.id] = <DirectChatMessage>[];
    return thread;
  }

  @override
  Future<List<DirectChatMessage>> loadDirectChatMessages(
    String threadId,
  ) async {
    return List<DirectChatMessage>.unmodifiable(
      _messagesByThread[threadId] ?? const <DirectChatMessage>[],
    );
  }

  @override
  Future<void> markDirectThreadAsRead(String threadId) async {
    final index = _directThreads.indexWhere((item) => item.id == threadId);
    if (index < 0) {
      return;
    }
    _directThreads[index] = _directThreads[index].copyWith(unreadCount: 0);
  }

  @override
  Stream<void> watchDirectThreads() {
    return const Stream<void>.empty();
  }

  @override
  Stream<void> watchDirectChatMessages(String threadId) {
    return const Stream<void>.empty();
  }

  @override
  Stream<bool> watchDirectChatTyping(String threadId) {
    return Stream<bool>.value(false);
  }

  @override
  Future<void> sendDirectChatTypingState({
    required String threadId,
    required String participantLabel,
    required bool isTyping,
  }) async {}

  @override
  Future<DirectChatMessage?> sendDirectChatMessage(
    String threadId,
    String body, {
    String? replyToMessageId,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final messages = _messagesByThread.putIfAbsent(
      threadId,
      () => <DirectChatMessage>[],
    );
    DirectChatMessage? replied;
    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      for (final item in messages) {
        if (item.id == replyToMessageId) {
          replied = item;
          break;
        }
      }
    }
    final message = DirectChatMessage(
      id: 'msg-${_messageCounter++}',
      threadId: threadId,
      content: trimmed,
      sentAt: DateTime.now(),
      isMine: true,
      replyToMessageId: replied?.id,
      replyToContent: replied?.content,
      replyToType: replied?.type,
      isReplyToMine: replied?.isMine,
    );
    messages.add(message);
    _touchThread(threadId: threadId, preview: trimmed, sentAt: message.sentAt);
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
    if (bytes.isEmpty) {
      return null;
    }
    final messages = _messagesByThread.putIfAbsent(
      threadId,
      () => <DirectChatMessage>[],
    );
    DirectChatMessage? replied;
    if (replyToMessageId != null && replyToMessageId.isNotEmpty) {
      for (final item in messages) {
        if (item.id == replyToMessageId) {
          replied = item;
          break;
        }
      }
    }
    final message = DirectChatMessage(
      id: 'msg-${_messageCounter++}',
      threadId: threadId,
      content: isVideo ? 'Video enviado' : 'Foto enviada',
      sentAt: DateTime.now(),
      isMine: true,
      type: isVideo ? DirectChatMessageType.video : DirectChatMessageType.image,
      mediaUrl: 'memory://$fileName',
      fileName: fileName,
      mimeType: mimeType,
      replyToMessageId: replied?.id,
      replyToContent: replied?.content,
      replyToType: replied?.type,
      isReplyToMine: replied?.isMine,
    );
    messages.add(message);
    _touchThread(
      threadId: threadId,
      preview: message.content,
      sentAt: message.sentAt,
    );
    return message;
  }

  @override
  Future<DirectChatMessage?> updateDirectChatMessage(
    String messageId,
    String body,
  ) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    for (final entry in _messagesByThread.entries) {
      final index = entry.value.indexWhere(
        (message) => message.id == messageId,
      );
      if (index < 0) {
        continue;
      }
      final current = entry.value[index];
      final updated = DirectChatMessage(
        id: current.id,
        threadId: current.threadId,
        content: trimmed,
        sentAt: current.sentAt,
        isMine: current.isMine,
        type: current.type,
        mediaUrl: current.mediaUrl,
        thumbnailUrl: current.thumbnailUrl,
        fileName: current.fileName,
        mimeType: current.mimeType,
        isEdited: true,
        replyToMessageId: current.replyToMessageId,
        replyToContent: current.replyToContent,
        replyToType: current.replyToType,
        isReplyToMine: current.isReplyToMine,
      );
      entry.value[index] = updated;
      _touchThread(
        threadId: current.threadId,
        preview: trimmed,
        sentAt: current.sentAt,
      );
      return updated;
    }
    return null;
  }

  @override
  Future<void> deleteDirectChatMessages(List<String> messageIds) async {
    if (messageIds.isEmpty) {
      return;
    }
    for (final entry in _messagesByThread.entries) {
      entry.value.removeWhere((message) => messageIds.contains(message.id));
      _syncThreadPreview(entry.key);
    }
  }

  @override
  void updateIndexedMessage(AppMessageIndexEntry updated) {
    final index = _indexedMessages.indexWhere((item) => item.id == updated.id);
    if (index < 0) {
      return;
    }
    _indexedMessages[index] = updated;
  }

  @override
  void deleteIndexedMessage(String id) {
    _indexedMessages.removeWhere((item) => item.id == id);
  }

  void _touchThread({
    required String threadId,
    required String preview,
    required DateTime sentAt,
  }) {
    final index = _directThreads.indexWhere((thread) => thread.id == threadId);
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

  void _syncThreadPreview(String threadId) {
    final messages = _messagesByThread[threadId] ?? const <DirectChatMessage>[];
    final latest = messages.isEmpty ? null : messages.last;
    final index = _directThreads.indexWhere((thread) => thread.id == threadId);
    if (index < 0) {
      return;
    }
    final current = _directThreads[index];
    _directThreads[index] = DirectMessageThread(
      id: current.id,
      participant: current.participant,
      participantAvatarPath: current.participantAvatarPath,
      preview: latest?.content ?? 'Sin mensajes todavia.',
      lastActivity: latest?.sentAt ?? current.lastActivity,
      unreadCount: current.unreadCount,
      isMuted: current.isMuted,
      isBlocked: current.isBlocked,
      lastLocation: current.lastLocation,
    );
  }
}
