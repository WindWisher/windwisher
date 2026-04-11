import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class ProfileGearSetupsEmptyState extends StatelessWidget {
  const ProfileGearSetupsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Aun no has guardado ninguna equipacion.',
        textAlign: TextAlign.center,
      ),
    );
  }
}
