import 'package:flutter/material.dart';

class ProfileSummaryAvatar extends StatelessWidget {
  const ProfileSummaryAvatar({
    super.key,
    required this.avatarImage,
    required this.hasAvatarImage,
  });

  final ImageProvider<Object>? avatarImage;
  final bool hasAvatarImage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 38,
        backgroundColor: colorScheme.primary,
        backgroundImage: avatarImage,
        child: !hasAvatarImage
            ? const Icon(Icons.person, size: 38, color: Colors.white)
            : null,
      ),
    );
  }
}
