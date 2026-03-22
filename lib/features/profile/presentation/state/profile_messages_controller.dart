import 'package:flutter/foundation.dart';
import 'package:windwisher/features/profile/application/use_cases/profile_messages_use_cases.dart';
import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';

class ProfileMessagesController extends ChangeNotifier {
  ProfileMessagesController({
    required GetDirectMessageThreadsUseCase getDirectThreads,
    required GetIndexedMessagesUseCase getIndexedMessages,
    required ToggleMuteDirectThreadUseCase toggleMuteDirectThread,
    required BlockDirectThreadUseCase blockDirectThread,
    required DeleteDirectThreadUseCase deleteDirectThread,
    required UpdateIndexedMessageUseCase updateIndexedMessage,
    required DeleteIndexedMessageUseCase deleteIndexedMessage,
  }) : _getDirectThreads = getDirectThreads,
       _getIndexedMessages = getIndexedMessages,
       _toggleMuteDirectThread = toggleMuteDirectThread,
       _blockDirectThread = blockDirectThread,
       _deleteDirectThread = deleteDirectThread,
       _updateIndexedMessage = updateIndexedMessage,
       _deleteIndexedMessage = deleteIndexedMessage {
    _refresh();
  }

  final GetDirectMessageThreadsUseCase _getDirectThreads;
  final GetIndexedMessagesUseCase _getIndexedMessages;
  final ToggleMuteDirectThreadUseCase _toggleMuteDirectThread;
  final BlockDirectThreadUseCase _blockDirectThread;
  final DeleteDirectThreadUseCase _deleteDirectThread;
  final UpdateIndexedMessageUseCase _updateIndexedMessage;
  final DeleteIndexedMessageUseCase _deleteIndexedMessage;

  List<DirectMessageThread> _directThreads = const [];
  List<AppMessageIndexEntry> _indexedMessages = const [];
  int _selectedMessagesViewIndex = 0;
  String _messageSearchQuery = '';

  List<DirectMessageThread> get directThreads => _directThreads;

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

  bool blockDirectThread(String threadId) {
    final changed = _blockDirectThread(threadId);
    _refresh();
    return changed;
  }

  void deleteDirectThread(String threadId) {
    _deleteDirectThread(threadId);
    _refresh();
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
    _indexedMessages = _getIndexedMessages();
    notifyListeners();
  }
}
