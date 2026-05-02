import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class SpotChatBubble extends StatelessWidget {
  const SpotChatBubble({
    super.key,
    required this.isMine,
    required this.authorDisplayName,
    required this.relativeTimeLabel,
    required this.message,
    required this.attachments,
    this.parentAuthor,
    this.parentMessage,
  });

  final bool isMine;
  final String authorDisplayName;
  final String relativeTimeLabel;
  final String message;
  final Widget attachments;
  final String? parentAuthor;
  final String? parentMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bubbleColor = isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final bubbleTextColor = isMine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final quotedMessage = parentMessage?.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isMine ? 20 : 6),
          bottomRight: Radius.circular(isMine ? 6 : 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$authorDisplayName · $relativeTimeLabel',
                  style: textTheme.bodySmall?.copyWith(
                    color: isMine
                        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.72)
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          if (quotedMessage != null && quotedMessage.isNotEmpty) ...[
            const SizedBox(height: 4),
            _QuotedSpotChatMessage(
              author: parentAuthor ?? '',
              message: quotedMessage,
            ),
          ],
          if (message.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              message,
              style: textTheme.bodyMedium?.copyWith(color: bubbleTextColor),
            ),
          ],
          attachments,
        ],
      ),
    );
  }
}

class _QuotedSpotChatMessage extends StatelessWidget {
  const _QuotedSpotChatMessage({required this.author, required this.message});

  final String author;
  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            author,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
