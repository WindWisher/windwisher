import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/direct_message_actions_row.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/direct_message_status_badges.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/direct_message_thread_header.dart';

enum DirectMessageAction { toggleMute, block, delete }

class DirectMessageManagerTile extends StatelessWidget {
  const DirectMessageManagerTile({
    super.key,
    required this.thread,
    required this.textTheme,
    required this.onOpenChat,
    required this.onToggleMute,
    required this.onBlock,
    required this.onDelete,
    required this.formatTimestamp,
    this.isLast = false,
  });

  final DirectMessageThread thread;
  final TextTheme textTheme;
  final ValueChanged<DirectMessageThread> onOpenChat;
  final ValueChanged<String> onToggleMute;
  final Future<void> Function(String id, String participant) onBlock;
  final Future<void> Function(String id, String participant) onDelete;
  final String Function(DateTime timestamp) formatTimestamp;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onOpenChat(thread),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DirectMessageThreadHeader(
                thread: thread,
                textTheme: textTheme,
                formatTimestamp: formatTimestamp,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.participant,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: thread.unreadCount > 0
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          formatTimestamp(thread.lastActivity),
                          style: textTheme.labelSmall?.copyWith(
                            color: thread.unreadCount > 0
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            thread.preview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: thread.unreadCount > 0
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        DirectMessageActionsRow(
                          thread: thread,
                          onOpenChat: onOpenChat,
                          onToggleMute: onToggleMute,
                          onBlock: onBlock,
                          onDelete: onDelete,
                        ),
                      ],
                    ),
                    if (thread.isMuted || thread.isBlocked) ...[
                      const SizedBox(height: 4),
                      DirectMessageStatusBadges(
                        thread: thread,
                        textTheme: textTheme,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
