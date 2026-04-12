import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/details/profile_gear_usage_dialog_data.dart';

class ProfileGearUsageSectionCard extends StatelessWidget {
  const ProfileGearUsageSectionCard({super.key, required this.section});

  final ProfileGearUsageSectionData section;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.title, style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              section.description,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            section.child,
          ],
        ),
      ),
    );
  }
}
