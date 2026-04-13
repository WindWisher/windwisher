import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_bubble.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_message_view_model.dart';

class DirectChatFeed extends StatelessWidget {
  const DirectChatFeed({
    super.key,
    required this.isLoading,
    required this.messages,
    required this.scrollController,
    required this.onRefresh,
    required this.participantLabel,
    required this.participantInitials,
    this.participantAvatarPath,
    required this.editingMessageId,
    required this.onManageMessage,
    required this.onReplyMessage,
    required this.formatHour,
  });

  final bool isLoading;
  final List<DirectChatMessageViewModel> messages;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final String participantLabel;
  final String participantInitials;
  final String? participantAvatarPath;
  final String? editingMessageId;
  final void Function(DirectChatMessageViewModel message) onManageMessage;
  final void Function(DirectChatMessageViewModel message) onReplyMessage;
  final String Function(DateTime value) formatHour;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      'Aún no hay mensajes en este chat.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: RefreshIndicator(
                    onRefresh: onRefresh,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        if (index >= messages.length) {
                          return const SizedBox.shrink();
                        }
                        final message = messages[index];
                        final isSelectedForEdit = editingMessageId == message.id;
                        return DirectChatSwipeMessageWrapper(
                          accentColor: colorScheme.tertiary,
                          manageColor: colorScheme.primary,
                          onReplyTriggered: () => onReplyMessage(message),
                          onManageTriggered: message.isMine
                              ? () => onManageMessage(message)
                              : null,
                          child: DirectChatBubble(
                            message: message,
                            textTheme: textTheme,
                            colorScheme: colorScheme,
                            timeLabel: formatHour(message.sentAt),
                            participantLabel: participantLabel,
                            participantInitials: participantInitials,
                            participantAvatarPath: participantAvatarPath,
                            isSelectedForEdit: isSelectedForEdit,
                            onTap: null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}

class DirectChatSwipeMessageWrapper extends StatefulWidget {
  const DirectChatSwipeMessageWrapper({
    super.key,
    required this.child,
    required this.onReplyTriggered,
    required this.accentColor,
    required this.manageColor,
    this.onManageTriggered,
  });

  final Widget child;
  final VoidCallback onReplyTriggered;
  final Color accentColor;
  final Color manageColor;
  final VoidCallback? onManageTriggered;

  @override
  State<DirectChatSwipeMessageWrapper> createState() =>
      _DirectChatSwipeMessageWrapperState();
}

class _DirectChatSwipeMessageWrapperState
    extends State<DirectChatSwipeMessageWrapper> {
  static const double _maxReveal = 72;
  static const double _triggerThreshold = 44;

  double _dragOffset = 0;
  _SwipeMessageAction? _triggeredAction;
  _SwipeMessageAction? _crossedThresholdAction;

  @override
  Widget build(BuildContext context) {
    final leftRevealProgress = (-_dragOffset / _maxReveal).clamp(0.0, 1.0);
    final rightRevealProgress = (_dragOffset / _maxReveal).clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) {
        _triggeredAction = null;
        _crossedThresholdAction = null;
      },
      onHorizontalDragUpdate: (details) {
        final nextOffset = (_dragOffset + details.delta.dx).clamp(
          -_maxReveal,
          widget.onManageTriggered == null ? 0.0 : _maxReveal,
        );
        if (nextOffset == _dragOffset) {
          return;
        }
        final crossedThresholdAction = nextOffset <= -_triggerThreshold
            ? _SwipeMessageAction.reply
            : (nextOffset >= _triggerThreshold && widget.onManageTriggered != null)
                ? _SwipeMessageAction.manage
                : null;
        if (crossedThresholdAction != null &&
            crossedThresholdAction != _crossedThresholdAction) {
          _crossedThresholdAction = crossedThresholdAction;
          HapticFeedback.selectionClick();
        } else if (crossedThresholdAction == null &&
            _crossedThresholdAction != null) {
          _crossedThresholdAction = null;
        }
        setState(() {
          _dragOffset = nextOffset;
        });
      },
      onHorizontalDragEnd: (_) {
        if (_triggeredAction == null && _dragOffset <= -_triggerThreshold) {
          _triggeredAction = _SwipeMessageAction.reply;
          widget.onReplyTriggered();
        } else if (_triggeredAction == null &&
            _dragOffset >= _triggerThreshold &&
            widget.onManageTriggered != null) {
          _triggeredAction = _SwipeMessageAction.manage;
          widget.onManageTriggered!.call();
        }
        setState(() {
          _dragOffset = 0;
        });
        _crossedThresholdAction = null;
      },
      onHorizontalDragCancel: () {
        setState(() {
          _dragOffset = 0;
        });
        _crossedThresholdAction = null;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.onManageTriggered != null)
            Positioned(
              left: AppSpacing.sm,
              child: Opacity(
                opacity: rightRevealProgress,
                child: Transform.scale(
                  scale: 0.8 + (rightRevealProgress * 0.28),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: widget.manageColor.withValues(alpha: 0.88),
                  ),
                ),
              ),
            ),
          Positioned(
            right: AppSpacing.sm,
            child: Opacity(
              opacity: leftRevealProgress,
              child: Transform.scale(
                scale: 0.8 + (leftRevealProgress * 0.28),
                child: Icon(
                  Icons.reply_rounded,
                  color: widget.accentColor.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

enum _SwipeMessageAction { reply, manage }
