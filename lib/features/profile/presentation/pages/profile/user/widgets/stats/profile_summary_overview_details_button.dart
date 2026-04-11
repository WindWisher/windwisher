import 'package:flutter/material.dart';

class ProfileSummaryOverviewDetailsButton extends StatelessWidget {
  const ProfileSummaryOverviewDetailsButton({
    super.key,
    required this.onPressed,
  });

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
