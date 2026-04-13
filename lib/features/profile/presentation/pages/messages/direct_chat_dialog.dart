import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_message.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/dialog/direct_chat_dialog_controller.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/dialog/direct_chat_dialog_shell.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/dialog/direct_chat_dialog_utils.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_message_view_model.dart';

class DirectChatDialog extends StatefulWidget {
  const DirectChatDialog({
    super.key,
    required this.threadId,
    required this.participant,
    this.participantAvatarPath,
    required this.loadMessages,
    required this.sendMessage,
    required this.sendMediaMessage,
    required this.updateMessage,
    required this.deleteMessages,
  });

  final String threadId;
  final String participant;
  final String? participantAvatarPath;
  final Future<List<DirectChatMessage>> Function(String threadId) loadMessages;
  final Future<DirectChatMessage?> Function(
    String threadId,
    String body, {
    String? replyToMessageId,
  }) sendMessage;
  final Future<DirectChatMessage?> Function({
    required String threadId,
    required List<int> bytes,
    required String fileName,
    required String mimeType,
    required bool isVideo,
    String? replyToMessageId,
  }) sendMediaMessage;
  final Future<DirectChatMessage?> Function(String messageId, String body)
  updateMessage;
  final Future<void> Function(List<String> messageIds) deleteMessages;

  @override
  State<DirectChatDialog> createState() => _DirectChatDialogState();
}

class _DirectChatDialogState extends State<DirectChatDialog> {
  late final DirectChatDialogController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DirectChatDialogController(
      threadId: widget.threadId,
      loadMessages: widget.loadMessages,
      sendMessage: widget.sendMessage,
      sendMediaMessage: widget.sendMediaMessage,
      updateMessage: widget.updateMessage,
      deleteMessages: widget.deleteMessages,
    )..initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final participantInitials = directChatParticipantInitials(widget.participant);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return DirectChatDialogShell(
          participant: widget.participant,
          participantInitials: participantInitials,
          participantAvatarPath: widget.participantAvatarPath,
          messages: List<DirectChatMessageViewModel>.of(_controller.messages),
          scrollController: _controller.scrollController,
          isLoading: _controller.isLoading,
          editingMessageId: _controller.editingMessageId,
          isSubmitting: _controller.isSubmitting,
          isPickingMedia: _controller.isPickingMedia,
          composerController: _controller.composerController,
          replyingTo: _controller.replyingTo,
          onRefresh: _controller.hydrateMessages,
          onManageMessage: (message) => _controller.showMessageActions(context, message),
          onReplyMessage: _controller.startReplying,
          formatHour: formatDirectChatHour,
          onClose: () => Navigator.of(context).pop(),
          onSubmitted: () => _controller.sendOrSaveMessage(context),
          onAttachMedia: () => _controller.showAttachMediaOptions(context),
          onCancelEditing: _controller.cancelEditing,
          onCancelReply: _controller.cancelReplying,
        );
      },
    );
  }
}
