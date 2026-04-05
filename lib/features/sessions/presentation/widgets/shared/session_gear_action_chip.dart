import 'package:flutter/material.dart';

class SessionGearActionChip extends StatelessWidget {
  const SessionGearActionChip({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.checkroom_rounded, size: 16),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
