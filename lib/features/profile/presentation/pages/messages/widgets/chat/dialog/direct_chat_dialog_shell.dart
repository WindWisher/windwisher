import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/composer/direct_chat_composer.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_feed.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/header/direct_chat_header_card.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_message_view_model.dart';

class DirectChatDialogShell extends StatelessWidget {
  const DirectChatDialogShell({
    super.key,
    required this.participant,
    required this.participantInitials,
    required this.participantAvatarPath,
    required this.messages,
    required this.scrollController,
    required this.isLoading,
    required this.editingMessageId,
    required this.isSubmitting,
    required this.isPickingMedia,
    required this.composerController,
    required this.replyingTo,
    required this.onRefresh,
    required this.onManageMessage,
    required this.onReplyMessage,
    required this.formatHour,
    required this.onClose,
    required this.onSubmitted,
    required this.onAttachMedia,
    required this.onCancelEditing,
    required this.onCancelReply,
  });

  final String participant;
  final String participantInitials;
  final String? participantAvatarPath;
  final List<DirectChatMessageViewModel> messages;
  final ScrollController scrollController;
  final bool isLoading;
  final String? editingMessageId;
  final bool isSubmitting;
  final bool isPickingMedia;
  final TextEditingController composerController;
  final DirectChatMessageViewModel? replyingTo;
  final Future<void> Function({bool initialLoad, bool silent}) onRefresh;
  final Future<void> Function(DirectChatMessageViewModel message)
  onManageMessage;
  final void Function(DirectChatMessageViewModel message) onReplyMessage;
  final String Function(DateTime timestamp) formatHour;
  final VoidCallback onClose;
  final VoidCallback onSubmitted;
  final Future<void> Function() onAttachMedia;
  final VoidCallback onCancelEditing;
  final VoidCallback onCancelReply;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920, maxHeight: 820),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                DirectChatHeaderCard(
                  participant: participant,
                  participantInitials: participantInitials,
                  avatarPath: participantAvatarPath,
                  statusText: null,
                  onClose: onClose,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: DirectChatFeed(
                    isLoading: isLoading,
                    messages: messages,
                    scrollController: scrollController,
                    onRefresh: onRefresh,
                    participantLabel: participant,
                    participantInitials: participantInitials,
                    participantAvatarPath: participantAvatarPath,
                    editingMessageId: editingMessageId,
                    onManageMessage: onManageMessage,
                    onReplyMessage: onReplyMessage,
                    formatHour: formatHour,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                DirectChatComposer(
                  controller: composerController,
                  isSubmitting: isSubmitting,
                  isPickingMedia: isPickingMedia,
                  isEditing: editingMessageId != null,
                  onSubmitted: onSubmitted,
                  onAttachMedia: onAttachMedia,
                  onCancelEditing: onCancelEditing,
                  replyingTo: replyingTo,
                  replyParticipantLabel: participant,
                  onCancelReply: onCancelReply,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
