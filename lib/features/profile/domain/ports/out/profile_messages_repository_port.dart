import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_message.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_user_candidate.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';

abstract class ProfileMessagesRepositoryPort {
  List<DirectMessageThread> getDirectMessageThreads();

  List<AppMessageIndexEntry> getIndexedMessages();

  List<DirectChatUserCandidate> getDirectChatUserCandidates();

  Future<void> hydrate();

  void toggleMuteDirectThread(String threadId);

  bool toggleBlockDirectThread(String threadId);

  void deleteDirectThread(String threadId);

  Future<DirectMessageThread?> createOrOpenDirectChat(String userId);

  Future<List<DirectChatMessage>> loadDirectChatMessages(String threadId);

  Future<DirectChatMessage?> sendDirectChatMessage(
    String threadId,
    String body, {
    String? replyToMessageId,
  });

  Future<DirectChatMessage?> sendDirectChatMediaMessage({
    required String threadId,
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required bool isVideo,
    String? replyToMessageId,
  });

  Future<DirectChatMessage?> updateDirectChatMessage(String messageId, String body);

  Future<void> deleteDirectChatMessages(List<String> messageIds);

  void updateIndexedMessage(AppMessageIndexEntry updated);

  void deleteIndexedMessage(String id);
}
