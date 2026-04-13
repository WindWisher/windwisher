import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';

class DirectMessageStatusBadges extends StatelessWidget {
  const DirectMessageStatusBadges({
    super.key,
    required this.thread,
    required this.textTheme,
  });

  final DirectMessageThread thread;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final parts = <String>[
      if (thread.isMuted) 'Silenciado',
      if (thread.isBlocked) 'Bloqueado',
    ];

    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      parts.join(' · '),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.78),
      ),
    );
  }
}
