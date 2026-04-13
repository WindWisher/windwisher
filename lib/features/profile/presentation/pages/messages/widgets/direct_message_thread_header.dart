import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';

class DirectMessageThreadHeader extends StatelessWidget {
  const DirectMessageThreadHeader({
    super.key,
    required this.thread,
    required this.textTheme,
    required this.formatTimestamp,
  });

  final DirectMessageThread thread;
  final TextTheme textTheme;
  final String Function(DateTime timestamp) formatTimestamp;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarImage = _avatarImageProvider(thread.participantAvatarPath);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
          backgroundImage: avatarImage,
          child: avatarImage == null
              ? Text(
                  thread.participant.isNotEmpty
                      ? thread.participant.characters.first.toUpperCase()
                      : '?',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
      ],
    );
  }

  ImageProvider<Object>? _avatarImageProvider(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }
    final trimmedPath = path.trim();
    final uri = Uri.tryParse(trimmedPath);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(trimmedPath);
    }
    if (!kIsWeb) {
      return FileImage(File(trimmedPath));
    }
    return null;
  }
}
