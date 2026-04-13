import 'package:flutter/foundation.dart';
import 'package:windwisher/features/profile/application/use_cases/profile_messages_use_cases.dart';
import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_message.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_user_candidate.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';

class ProfileMessagesController extends ChangeNotifier {
  ProfileMessagesController({
    required GetDirectMessageThreadsUseCase getDirectThreads,
    required GetIndexedMessagesUseCase getIndexedMessages,
    required GetDirectChatUserCandidatesUseCase getDirectChatUserCandidates,
    required ToggleMuteDirectThreadUseCase toggleMuteDirectThread,
    required ToggleBlockDirectThreadUseCase blockDirectThread,
    required DeleteDirectThreadUseCase deleteDirectThread,
    required CreateOrOpenDirectChatUseCase createOrOpenDirectChat,
    required LoadDirectChatMessagesUseCase loadDirectChatMessages,
    required MarkDirectThreadAsReadUseCase markDirectThreadAsRead,
    required WatchDirectThreadsUseCase watchDirectThreads,
    required WatchDirectChatMessagesUseCase watchDirectChatMessages,
    required WatchDirectChatTypingUseCase watchDirectChatTyping,
    required SendDirectChatTypingStateUseCase sendDirectChatTypingState,
    required SendDirectChatMessageUseCase sendDirectChatMessage,
    required SendDirectChatMediaMessageUseCase sendDirectChatMediaMessage,
    required UpdateDirectChatMessageUseCase updateDirectChatMessage,
    required DeleteDirectChatMessagesUseCase deleteDirectChatMessages,
    required UpdateIndexedMessageUseCase updateIndexedMessage,
    required DeleteIndexedMessageUseCase deleteIndexedMessage,
  }) : _getDirectThreads = getDirectThreads,
       _getIndexedMessages = getIndexedMessages,
       _getDirectChatUserCandidates = getDirectChatUserCandidates,
       _toggleMuteDirectThread = toggleMuteDirectThread,
       _blockDirectThread = blockDirectThread,
       _deleteDirectThread = deleteDirectThread,
       _createOrOpenDirectChat = createOrOpenDirectChat,
       _loadDirectChatMessages = loadDirectChatMessages,
       _markDirectThreadAsRead = markDirectThreadAsRead,
       _watchDirectThreads = watchDirectThreads,
       _watchDirectChatMessages = watchDirectChatMessages,
       _watchDirectChatTyping = watchDirectChatTyping,
       _sendDirectChatTypingState = sendDirectChatTypingState,
       _sendDirectChatMessage = sendDirectChatMessage,
       _sendDirectChatMediaMessage = sendDirectChatMediaMessage,
       _updateDirectChatMessage = updateDirectChatMessage,
       _deleteDirectChatMessages = deleteDirectChatMessages,
       _updateIndexedMessage = updateIndexedMessage,
       _deleteIndexedMessage = deleteIndexedMessage {
    _refresh();
  }

  final GetDirectMessageThreadsUseCase _getDirectThreads;
  final GetIndexedMessagesUseCase _getIndexedMessages;
  final GetDirectChatUserCandidatesUseCase _getDirectChatUserCandidates;
  final ToggleMuteDirectThreadUseCase _toggleMuteDirectThread;
  final ToggleBlockDirectThreadUseCase _blockDirectThread;
  final DeleteDirectThreadUseCase _deleteDirectThread;
  final CreateOrOpenDirectChatUseCase _createOrOpenDirectChat;
  final LoadDirectChatMessagesUseCase _loadDirectChatMessages;
  final MarkDirectThreadAsReadUseCase _markDirectThreadAsRead;
  final WatchDirectThreadsUseCase _watchDirectThreads;
  final WatchDirectChatMessagesUseCase _watchDirectChatMessages;
  final WatchDirectChatTypingUseCase _watchDirectChatTyping;
  final SendDirectChatTypingStateUseCase _sendDirectChatTypingState;
  final SendDirectChatMessageUseCase _sendDirectChatMessage;
  final SendDirectChatMediaMessageUseCase _sendDirectChatMediaMessage;
  final UpdateDirectChatMessageUseCase _updateDirectChatMessage;
  final DeleteDirectChatMessagesUseCase _deleteDirectChatMessages;
  final UpdateIndexedMessageUseCase _updateIndexedMessage;
  final DeleteIndexedMessageUseCase _deleteIndexedMessage;

  List<DirectMessageThread> _directThreads = const [];
  List<DirectChatUserCandidate> _directChatUserCandidates = const [];
  List<AppMessageIndexEntry> _indexedMessages = const [];
  int _selectedMessagesViewIndex = 0;
  String _messageSearchQuery = '';

  List<DirectMessageThread> get directThreads => _directThreads;

  List<DirectChatUserCandidate> get directChatUserCandidates =>
      _directChatUserCandidates;

  List<AppMessageIndexEntry> get indexedMessages => _indexedMessages;

  int get selectedMessagesViewIndex => _selectedMessagesViewIndex;

  String get messageSearchQuery => _messageSearchQuery;

  List<AppMessageIndexEntry> get filteredIndexedMessages {
    final query = _messageSearchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _indexedMessages;
    }
    return _indexedMessages
        .where((entry) {
          return entry.channel.toLowerCase().contains(query) ||
              entry.contextLabel.toLowerCase().contains(query) ||
              entry.message.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void setSelectedMessagesView(int index) {
    if (_selectedMessagesViewIndex == index) {
      return;
    }
    _selectedMessagesViewIndex = index;
    notifyListeners();
  }

  void setMessageSearchQuery(String value) {
    if (_messageSearchQuery == value) {
      return;
    }
    _messageSearchQuery = value;
    notifyListeners();
  }

  void toggleMuteDirectThread(String threadId) {
    _toggleMuteDirectThread(threadId);
    _refresh();
  }

  bool toggleBlockDirectThread(String threadId) {
    final changed = _blockDirectThread(threadId);
    _refresh();
    return changed;
  }

  void deleteDirectThread(String threadId) {
    _deleteDirectThread(threadId);
    _refresh();
  }

  Future<DirectMessageThread?> createOrOpenDirectChat(String userId) async {
    final thread = await _createOrOpenDirectChat(userId);
    _refresh();
    return thread;
  }

  Future<List<DirectChatMessage>> loadDirectChatMessages(String threadId) {
    return _loadDirectChatMessages(threadId);
  }

  Future<void> markDirectThreadAsRead(String threadId) async {
    await _markDirectThreadAsRead(threadId);
    _refresh();
  }

  Stream<void> watchDirectThreads() {
    return _watchDirectThreads();
  }

  Stream<void> watchDirectChatMessages(String threadId) {
    return _watchDirectChatMessages(threadId);
  }

  Stream<bool> watchDirectChatTyping(String threadId) {
    return _watchDirectChatTyping(threadId);
  }

  Future<void> sendDirectChatTypingState({
    required String threadId,
    required String participantLabel,
    required bool isTyping,
  }) {
    return _sendDirectChatTypingState(
      threadId: threadId,
      participantLabel: participantLabel,
      isTyping: isTyping,
    );
  }

  Future<DirectChatMessage?> sendDirectChatMessage(
    String threadId,
    String body, {
    String? replyToMessageId,
  }) async {
    final message = await _sendDirectChatMessage(
      threadId,
      body,
      replyToMessageId: replyToMessageId,
    );
    await hydrate();
    return message;
  }

  Future<DirectChatMessage?> sendDirectChatMediaMessage({
    required String threadId,
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required bool isVideo,
    String? replyToMessageId,
  }) async {
    final message = await _sendDirectChatMediaMessage(
      threadId: threadId,
      bytes: bytes,
      fileName: fileName,
      mimeType: mimeType,
      isVideo: isVideo,
      replyToMessageId: replyToMessageId,
    );
    await hydrate();
    return message;
  }

  Future<DirectChatMessage?> updateDirectChatMessage(
    String messageId,
    String body,
  ) async {
    final message = await _updateDirectChatMessage(messageId, body);
    await hydrate();
    return message;
  }

  Future<void> deleteDirectChatMessages(List<String> messageIds) async {
    await _deleteDirectChatMessages(messageIds);
    await hydrate();
  }

  void updateIndexedMessage(AppMessageIndexEntry updated) {
    _updateIndexedMessage(updated);
    _refresh();
  }

  void deleteIndexedMessage(String id) {
    _deleteIndexedMessage(id);
    _refresh();
  }

  Future<void> hydrate() async {
    await _getDirectThreads.load();
    _refresh();
  }

  void _refresh() {
    _directThreads = _getDirectThreads();
    _directChatUserCandidates = _getDirectChatUserCandidates();
    _indexedMessages = _getIndexedMessages();
    notifyListeners();
  }
}
