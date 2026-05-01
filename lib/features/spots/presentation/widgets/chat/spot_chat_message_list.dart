import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/spots/presentation/widgets/chat/spot_chat_attachment_lists.dart';
import 'package:windwisher/features/spots/presentation/widgets/chat/spot_chat_avatar.dart';
import 'package:windwisher/features/spots/presentation/widgets/chat/spot_chat_bubble.dart';
import 'package:windwisher/features/spots/presentation/widgets/chat/spot_chat_entry.dart';
import 'package:windwisher/features/spots/presentation/widgets/chat/spot_chat_swipe_reply_wrapper.dart';

class SpotChatMessageList extends StatelessWidget {
  const SpotChatMessageList({
    super.key,
    required this.entries,
    required this.lastMessageKey,
    required this.currentUserAvatarLocalPath,
    required this.relativeTimeLabel,
    required this.canManageEntry,
    required this.onReply,
    required this.onManage,
  });

  final List<SpotChatEntry> entries;
  final GlobalKey lastMessageKey;
  final String? currentUserAvatarLocalPath;
  final String Function(DateTime createdAt) relativeTimeLabel;
  final bool Function(SpotChatEntry entry) canManageEntry;
  final ValueChanged<SpotChatEntry> onReply;
  final ValueChanged<SpotChatEntry> onManage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (var index = 0; index < entries.length; index += 1)
          Padding(
            key: index == entries.length - 1 ? lastMessageKey : null,
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SpotChatMessageRow(
              entry: entries[index],
              currentUserAvatarLocalPath: currentUserAvatarLocalPath,
              relativeTimeLabel: relativeTimeLabel,
              canManageEntry: canManageEntry,
              onReply: onReply,
              onManage: onManage,
              colorScheme: colorScheme,
            ),
          ),
      ],
    );
  }
}

class _SpotChatMessageRow extends StatelessWidget {
  const _SpotChatMessageRow({
    required this.entry,
    required this.currentUserAvatarLocalPath,
    required this.relativeTimeLabel,
    required this.canManageEntry,
    required this.onReply,
    required this.onManage,
    required this.colorScheme,
  });

  final SpotChatEntry entry;
  final String? currentUserAvatarLocalPath;
  final String Function(DateTime createdAt) relativeTimeLabel;
  final bool Function(SpotChatEntry entry) canManageEntry;
  final ValueChanged<SpotChatEntry> onReply;
  final ValueChanged<SpotChatEntry> onManage;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: entry.isMine
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!entry.isMine) ...[
          _SpotChatMiniAvatar(
            entry: entry,
            currentUserAvatarLocalPath: currentUserAvatarLocalPath,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Flexible(
          child: Align(
            alignment: entry.isMine
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: SpotChatSwipeReplyWrapper(
                accentColor: entry.isMine
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.primary,
                manageColor: colorScheme.error,
                onReplyTriggered: () => onReply(entry),
                onManageTriggered: canManageEntry(entry)
                    ? () => onManage(entry)
                    : null,
                child: SpotChatBubble(
                  isMine: entry.isMine,
                  authorDisplayName: entry.authorDisplayName,
                  relativeTimeLabel: relativeTimeLabel(entry.createdAt),
                  message: entry.message,
                  parentAuthor: entry.parentAuthor,
                  parentMessage: entry.parentMessage,
                  attachments: SpotSocialAttachmentsList(
                    attachments: entry.attachments,
                    compact: entry.isReply,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (entry.isMine) ...[
          const SizedBox(width: AppSpacing.xs),
          _SpotChatMiniAvatar(
            entry: entry,
            currentUserAvatarLocalPath: currentUserAvatarLocalPath,
          ),
        ],
      ],
    );
  }
}

class _SpotChatMiniAvatar extends StatelessWidget {
  const _SpotChatMiniAvatar({
    required this.entry,
    required this.currentUserAvatarLocalPath,
  });

  final SpotChatEntry entry;
  final String? currentUserAvatarLocalPath;

  @override
  Widget build(BuildContext context) {
    return SpotChatAvatar(
      authorUsername: entry.authorUsername,
      authorDisplayName: entry.authorDisplayName,
      localAvatarPath: entry.isMine && !kIsWeb
          ? currentUserAvatarLocalPath
          : null,
    );
  }
}
