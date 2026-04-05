import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class MetricKpiTile extends StatelessWidget {
  const MetricKpiTile({
    super.key,
    this.width,
    required this.label,
    required this.value,
    required this.icon,
  });

  final double? width;
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: width ?? 160,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 4),
          Text(label, style: textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value, style: textTheme.titleSmall),
        ],
      ),
    );
  }
}
