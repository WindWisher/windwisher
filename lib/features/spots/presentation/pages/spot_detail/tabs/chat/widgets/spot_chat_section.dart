import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class SpotChatSection extends StatelessWidget {
  const SpotChatSection({
    super.key,
    required this.header,
    required this.feed,
    required this.composer,
    this.composerKey,
  });

  final Widget header;
  final Widget feed;
  final Widget composer;
  final Key? composerKey;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: AppSpacing.sm),
          feed,
          Container(
            key: composerKey,
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              0,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [composer],
            ),
          ),
        ],
      ),
    );
  }
}
