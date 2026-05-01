import 'dart:io';

import 'package:flutter/material.dart';

class SpotChatAvatar extends StatelessWidget {
  const SpotChatAvatar({
    super.key,
    required this.authorUsername,
    required this.authorDisplayName,
    this.localAvatarPath,
  });

  final String authorUsername;
  final String authorDisplayName;
  final String? localAvatarPath;

  @override
  Widget build(BuildContext context) {
    final hasLocalAvatar =
        localAvatarPath != null && localAvatarPath!.trim().isNotEmpty;
    return CircleAvatar(
      radius: 14,
      backgroundColor: _avatarColor(authorUsername),
      backgroundImage: hasLocalAvatar
          ? FileImage(File(localAvatarPath!))
          : null,
      child: hasLocalAvatar
          ? null
          : Text(
              _avatarInitials(authorDisplayName),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  String _avatarInitials(String displayName) {
    final parts = displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) {
      return 'R';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  Color _avatarColor(String seed) {
    final hash = seed.runes.fold<int>(0, (value, rune) => value * 31 + rune);
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.42, 0.58).toColor();
  }
}
