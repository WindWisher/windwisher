import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_message.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/dialog/direct_chat_dialog_sheets.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/dialog/direct_chat_dialog_utils.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_message_view_model.dart';

class DirectChatDialogController extends ChangeNotifier {
  DirectChatDialogController({
    required this.threadId,
    required Future<List<DirectChatMessage>> Function(String threadId)
    loadMessages,
    required Future<DirectChatMessage?> Function(
      String threadId,
      String body, {
      String? replyToMessageId,
    })
    sendMessage,
    required Stream<void> Function(String threadId) watchMessages,
    required Stream<bool> Function(String threadId) watchTyping,
    required Future<void> Function({
      required String threadId,
      required String participantLabel,
      required bool isTyping,
    })
    sendTypingState,
    required String participantLabel,
    required Future<DirectChatMessage?> Function({
      required String threadId,
      required List<int> bytes,
      required String fileName,
      required String mimeType,
      required bool isVideo,
      String? replyToMessageId,
    })
    sendMediaMessage,
    required Future<DirectChatMessage?> Function(String messageId, String body)
    updateMessage,
    required Future<void> Function(List<String> messageIds) deleteMessages,
    Future<void> Function()? onThreadChanged,
  }) : _loadMessages = loadMessages,
       _sendMessage = sendMessage,
       _watchMessages = watchMessages,
       _watchTyping = watchTyping,
       _sendTypingState = sendTypingState,
       _participantLabel = participantLabel,
       _sendMediaMessage = sendMediaMessage,
       _updateMessage = updateMessage,
       _deleteMessages = deleteMessages,
       _onThreadChanged = onThreadChanged;

  final String threadId;
  final Future<List<DirectChatMessage>> Function(String threadId) _loadMessages;
  final Future<DirectChatMessage?> Function(
    String threadId,
    String body, {
    String? replyToMessageId,
  })
  _sendMessage;
  final Stream<void> Function(String threadId) _watchMessages;
  final Stream<bool> Function(String threadId) _watchTyping;
  final Future<void> Function({
    required String threadId,
    required String participantLabel,
    required bool isTyping,
  })
  _sendTypingState;
  final String _participantLabel;
  final Future<DirectChatMessage?> Function({
    required String threadId,
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required bool isVideo,
    String? replyToMessageId,
  })
  _sendMediaMessage;
  final Future<DirectChatMessage?> Function(String messageId, String body)
  _updateMessage;
  final Future<void> Function(List<String> messageIds) _deleteMessages;
  final Future<void> Function()? _onThreadChanged;

  final TextEditingController composerController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  Timer? _autoRefreshTimer;
  StreamSubscription<void>? _messagesSubscription;
  StreamSubscription<bool>? _typingSubscription;
  Timer? _typingDebounceTimer;
  List<DirectChatMessageViewModel> _messages = <DirectChatMessageViewModel>[];
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isPickingMedia = false;
  String? _editingMessageId;
  String? _replyingMessageId;
  bool _isPeerTyping = false;
  bool _isTypingActive = false;

  List<DirectChatMessageViewModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  bool get isPickingMedia => _isPickingMedia;
  String? get editingMessageId => _editingMessageId;
  bool get isPeerTyping => _isPeerTyping;
  DirectChatMessageViewModel? get replyingTo =>
      resolveReplyingMessage(_messages, _replyingMessageId);

  void initialize() {
    hydrateMessages(initialLoad: true);
    _startRealtimeWatch();
    _startTypingWatch();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingDebounceTimer?.cancel();
    unawaited(_emitTyping(false));
    composerController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void _startRealtimeWatch() {
    _messagesSubscription?.cancel();
    _messagesSubscription = _watchMessages(threadId).listen((_) {
      unawaited(hydrateMessages(silent: true));
    });
  }

  void _startTypingWatch() {
    _typingSubscription?.cancel();
    _typingSubscription = _watchTyping(threadId).listen((isTyping) {
      _isPeerTyping = isTyping;
      notifyListeners();
    });
  }

  void onComposerChanged(String value) {
    final nextTyping = value.trim().isNotEmpty;
    if (nextTyping != _isTypingActive) {
      _isTypingActive = nextTyping;
      unawaited(_emitTyping(nextTyping));
    }
    _typingDebounceTimer?.cancel();
    if (!nextTyping) {
      return;
    }
    _typingDebounceTimer = Timer(const Duration(seconds: 2), () {
      _isTypingActive = false;
      unawaited(_emitTyping(false));
    });
  }

  Future<void> _emitTyping(bool isTyping) async {
    try {
      await _sendTypingState(
        threadId: threadId,
        participantLabel: _participantLabel,
        isTyping: isTyping,
      );
    } catch (_) {}
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      unawaited(hydrateMessages(silent: true));
    });
  }

  Future<void> hydrateMessages({
    bool initialLoad = false,
    bool silent = false,
  }) async {
    if (_isSubmitting) {
      return;
    }
    if (!silent && initialLoad) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final loaded = await _loadMessages(threadId);
      _messages = loaded
          .map(DirectChatMessageViewModel.fromEntity)
          .toList(growable: false);
      _isLoading = false;
      if (initialLoad) {
        _replyingMessageId = null;
      }
      notifyListeners();
      if (initialLoad) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (error) {
      _isLoading = false;
      notifyListeners();
      if (!silent) {
        rethrow;
      }
    }
  }

  Future<void> sendOrSaveMessage(BuildContext context) async {
    final text = composerController.text.trim();
    if (text.isEmpty || _isSubmitting) {
      return;
    }

    final editingId = _editingMessageId;
    final replyToMessageId = editingId == null ? _replyingMessageId : null;
    final repliedMessage = editingId == null
        ? resolveReplyingMessage(_messages, _replyingMessageId)
        : null;
    _isSubmitting = true;
    notifyListeners();

    try {
      if (editingId == null) {
        final message = await _sendMessage(
          threadId,
          text,
          replyToMessageId: replyToMessageId,
        );
        if (message != null) {
          _messages = [
            ..._messages,
            applyReplyContext(
              DirectChatMessageViewModel.fromEntity(message),
              repliedMessage,
            ),
          ];
          _replyingMessageId = null;
          composerController.clear();
          _typingDebounceTimer?.cancel();
          _isTypingActive = false;
          unawaited(_emitTyping(false));
          notifyListeners();
          await _notifyThreadChanged();
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _scrollToBottom(),
          );
        }
      } else {
        final updated = await _updateMessage(editingId, text);
        if (updated != null) {
          _messages = _messages
              .map((message) {
                if (message.id != editingId) {
                  return message;
                }
                return DirectChatMessageViewModel.fromEntity(updated);
              })
              .toList(growable: false);
          _editingMessageId = null;
          composerController.clear();
          _typingDebounceTimer?.cancel();
          _isTypingActive = false;
          unawaited(_emitTyping(false));
          notifyListeners();
          await _notifyThreadChanged();
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              editingId == null
                  ? 'No se pudo enviar el mensaje: $error'
                  : 'No se pudo actualizar el mensaje: $error',
            ),
          ),
        );
      }
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void cancelEditing() {
    _editingMessageId = null;
    composerController.clear();
    notifyListeners();
  }

  void startReplying(DirectChatMessageViewModel message) {
    _editingMessageId = null;
    _replyingMessageId = message.id;
    notifyListeners();
  }

  void cancelReplying() {
    _replyingMessageId = null;
    notifyListeners();
  }

  Future<void> showMessageActions(
    BuildContext context,
    DirectChatMessageViewModel message,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (!message.isMine) {
      return;
    }

    final action = await showDirectChatMessageActionsSheet(context, message);
    if (action == null) {
      return;
    }

    if (action == 'edit') {
      _editingMessageId = message.id;
      _replyingMessageId = null;
      composerController.text = message.content;
      notifyListeners();
      return;
    }

    if (action == 'delete') {
      await _deleteMessage(messenger, message);
    }
  }

  Future<void> showAttachMediaOptions(BuildContext context) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final selection = await showDirectChatAttachmentSheet(context);
    if (selection == null) {
      return;
    }
    await _pickAndSendMedia(
      messenger,
      isVideo: selection == DirectChatMessageTypeView.video,
    );
  }

  Future<void> _deleteMessage(
    ScaffoldMessengerState? messenger,
    DirectChatMessageViewModel message,
  ) async {
    if (_isSubmitting) {
      return;
    }
    _isSubmitting = true;
    notifyListeners();
    try {
      await _deleteMessages([message.id]);
      _messages = _messages
          .where((item) => item.id != message.id)
          .toList(growable: false);
      if (_editingMessageId == message.id) {
        _editingMessageId = null;
        composerController.clear();
      }
      if (_replyingMessageId == message.id) {
        _replyingMessageId = null;
      }
      notifyListeners();
      await _notifyThreadChanged();
    } catch (error) {
      messenger?.showSnackBar(
        SnackBar(content: Text('No se pudo eliminar el mensaje: $error')),
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> _pickAndSendMedia(
    ScaffoldMessengerState? messenger, {
    required bool isVideo,
  }) async {
    if (_isPickingMedia) {
      return;
    }

    _isPickingMedia = true;
    notifyListeners();

    try {
      final XFile? picked = isVideo
          ? await _imagePicker.pickVideo(source: ImageSource.gallery)
          : await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        return;
      }

      final message = await _sendMediaMessage(
        threadId: threadId,
        bytes: await picked.readAsBytes(),
        fileName: picked.name,
        mimeType: directChatMimeTypeForFile(picked.name, isVideo: isVideo),
        isVideo: isVideo,
        replyToMessageId: _replyingMessageId,
      );
      final repliedMessage = resolveReplyingMessage(
        _messages,
        _replyingMessageId,
      );
      if (message != null) {
        _messages = [
          ..._messages,
          applyReplyContext(
            DirectChatMessageViewModel.fromEntity(message),
            repliedMessage,
          ),
        ];
        _replyingMessageId = null;
        notifyListeners();
        await _notifyThreadChanged();
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              isVideo ? 'Vídeo enviado al chat.' : 'Foto enviada al chat.',
            ),
          ),
        );
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (error) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text('No se pudo adjuntar el archivo de la galería: $error'),
        ),
      );
    } finally {
      _isPickingMedia = false;
      notifyListeners();
    }
  }


  Future<void> _notifyThreadChanged() async {
    final callback = _onThreadChanged;
    if (callback == null) {
      return;
    }
    try {
      await callback();
    } catch (_) {}
  }

  void _scrollToBottom() {
    if (!scrollController.hasClients) {
      return;
    }
    scrollController.animateTo(
      scrollController.position.maxScrollExtent + 120,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }
}
