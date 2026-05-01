import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class SpotChatHeader extends StatelessWidget {
  const SpotChatHeader({
    super.key,
    required this.spotName,
    required this.spotArea,
    required this.onlineCount,
    required this.typingUsers,
  });

  final String spotName;
  final String spotArea;
  final int onlineCount;
  final Iterable<String> typingUsers;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.chat_bubble_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chat del spot', style: textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  '$spotName · $spotArea',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (onlineCount > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    onlineCount == 1
                        ? '1 persona dentro del chat'
                        : '$onlineCount personas dentro del chat',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                if (typingUsers.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    typingUsers.length == 1
                        ? '${typingUsers.first} esta escribiendo...'
                        : 'Varias personas estan escribiendo...',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
