import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
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

class ToggleMuteDirectThreadUseCase {
  const ToggleMuteDirectThreadUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  void call(String threadId) {
    _repository.toggleMuteDirectThread(threadId);
  }
}

class BlockDirectThreadUseCase {
  const BlockDirectThreadUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  bool call(String threadId) {
    return _repository.blockDirectThread(threadId);
  }
}

class DeleteDirectThreadUseCase {
  const DeleteDirectThreadUseCase(this._repository);

  final ProfileMessagesRepositoryPort _repository;

  void call(String threadId) {
    _repository.deleteDirectThread(threadId);
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
