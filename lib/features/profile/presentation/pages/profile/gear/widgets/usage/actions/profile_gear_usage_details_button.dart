import 'package:flutter/material.dart';

class ProfileGearUsageDetailsButton extends StatelessWidget {
  const ProfileGearUsageDetailsButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.insights_outlined),
        label: const Text('Detalles'),
      ),
    );
  }
}
