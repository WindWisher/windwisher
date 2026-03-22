import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';

abstract class ProfileMessagesRepositoryPort {
  List<DirectMessageThread> getDirectMessageThreads();

  List<AppMessageIndexEntry> getIndexedMessages();

  Future<void> hydrate();

  void toggleMuteDirectThread(String threadId);

  bool blockDirectThread(String threadId);

  void deleteDirectThread(String threadId);

  void updateIndexedMessage(AppMessageIndexEntry updated);

  void deleteIndexedMessage(String id);
}
