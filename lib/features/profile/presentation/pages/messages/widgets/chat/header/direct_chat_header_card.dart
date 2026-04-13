import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class DirectChatHeaderCard extends StatelessWidget {
  const DirectChatHeaderCard({
    super.key,
    required this.participant,
    required this.participantInitials,
    this.avatarPath,
    this.statusText,
    required this.onClose,
  });

  final String participant;
  final String participantInitials;
  final String? avatarPath;
  final String? statusText;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasStatus = statusText != null && statusText!.trim().isNotEmpty;
    final avatarImage = _avatarImageProvider(avatarPath);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 21,
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.onPrimaryContainer,
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? Text(
                    participantInitials,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (hasStatus)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      statusText!.trim(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cerrar chat',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
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
