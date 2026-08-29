import 'package:flutter/material.dart';

class ProfileSummaryPublicPreviewButton extends StatelessWidget {
  const ProfileSummaryPublicPreviewButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: 'Vista publica',
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.18),
        foregroundColor: Colors.white,
      ),
      icon: const Icon(Icons.visibility_outlined),
    );
  }
}
