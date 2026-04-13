import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_message.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_user_candidate.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_messages_repository_port.dart';

class GetDirectMessageThreadsUseCase {
  const GetDirectMessageThreadsUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  List<DirectMessageThread> call() {
    return _repository.getDirectMessageThreads();
  }

  Future<void> load() {
    return _repository.hydrate();
  }
}

class GetIndexedMessagesUseCase {
  const GetIndexedMessagesUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  List<AppMessageIndexEntry> call() {
    return _repository.getIndexedMessages();
  }
}

class GetDirectChatUserCandidatesUseCase {
  const GetDirectChatUserCandidatesUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  List<DirectChatUserCandidate> call() {
    return _repository.getDirectChatUserCandidates();
  }
}

class ToggleMuteDirectThreadUseCase {
  const ToggleMuteDirectThreadUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  void call(String threadId) {
    _repository.toggleMuteDirectThread(threadId);
  }
}

class ToggleBlockDirectThreadUseCase {
  const ToggleBlockDirectThreadUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  bool call(String threadId) {
    return _repository.toggleBlockDirectThread(threadId);
  }
}

class DeleteDirectThreadUseCase {
  const DeleteDirectThreadUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  void call(String threadId) {
    _repository.deleteDirectThread(threadId);
  }
}

class CreateOrOpenDirectChatUseCase {
  const CreateOrOpenDirectChatUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Future<DirectMessageThread?> call(String userId) {
    return _repository.createOrOpenDirectChat(userId);
  }
}

class LoadDirectChatMessagesUseCase {
  const LoadDirectChatMessagesUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Future<List<DirectChatMessage>> call(String threadId) {
    return _repository.loadDirectChatMessages(threadId);
  }
}

class MarkDirectThreadAsReadUseCase {
  const MarkDirectThreadAsReadUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Future<void> call(String threadId) {
    return _repository.markDirectThreadAsRead(threadId);
  }
}

class WatchDirectThreadsUseCase {
  const WatchDirectThreadsUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Stream<void> call() {
    return _repository.watchDirectThreads();
  }
}

class WatchDirectChatMessagesUseCase {
  const WatchDirectChatMessagesUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Stream<void> call(String threadId) {
    return _repository.watchDirectChatMessages(threadId);
  }
}

class WatchDirectChatTypingUseCase {
  const WatchDirectChatTypingUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Stream<bool> call(String threadId) {
    return _repository.watchDirectChatTyping(threadId);
  }
}

class SendDirectChatTypingStateUseCase {
  const SendDirectChatTypingStateUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Future<void> call({
    required String threadId,
    required String participantLabel,
    required bool isTyping,
  }) {
    return _repository.sendDirectChatTypingState(
      threadId: threadId,
      participantLabel: participantLabel,
      isTyping: isTyping,
    );
  }
}

class SendDirectChatMessageUseCase {
  const SendDirectChatMessageUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Future<DirectChatMessage?> call(
    String threadId,
    String body, {
    String? replyToMessageId,
  }) {
    return _repository.sendDirectChatMessage(
      threadId,
      body,
      replyToMessageId: replyToMessageId,
    );
  }
}

class SendDirectChatMediaMessageUseCase {
  const SendDirectChatMediaMessageUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Future<DirectChatMessage?> call({
    required String threadId,
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required bool isVideo,
    String? replyToMessageId,
  }) {
    return _repository.sendDirectChatMediaMessage(
      threadId: threadId,
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      isVideo: isVideo,
      replyToMessageId: replyToMessageId,
    );
  }
}

class UpdateDirectChatMessageUseCase {
  const UpdateDirectChatMessageUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Future<DirectChatMessage?> call(String messageId, String body) {
    return _repository.updateDirectChatMessage(messageId, body);
  }
}

class DeleteDirectChatMessagesUseCase {
  const DeleteDirectChatMessagesUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  Future<void> call(List<String> messageIds) {
    return _repository.deleteDirectChatMessages(messageIds);
  }
}

class UpdateIndexedMessageUseCase {
  const UpdateIndexedMessageUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  void call(AppMessageIndexEntry updated) {
    _repository.updateIndexedMessage(updated);
  }
}

class DeleteIndexedMessageUseCase {
  const DeleteIndexedMessageUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  void call(String id) {
    _repository.deleteIndexedMessage(id);
  }
}
