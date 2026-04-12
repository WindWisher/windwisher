import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class AppEquipmentDetailList extends StatelessWidget {
  const AppEquipmentDetailList({
    super.key,
    required this.lines,
    required this.emptyMessage,
  });

  final List<String> lines;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (lines.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          emptyMessage,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          _AppEquipmentDetailTile(line: lines[i]),
          if (i < lines.length - 1) const SizedBox(height: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _AppEquipmentDetailTile extends StatelessWidget {
  const _AppEquipmentDetailTile({required this.line});

  final String line;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final parts = line.split(':');
    final label = parts.isEmpty ? line.trim() : parts.first.trim();
    final value = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconForLabel(label),
              size: 18,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (value.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static IconData _iconForLabel(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('cometa')) return Icons.air_rounded;
    if (normalized.contains('tabla')) return Icons.surfing_rounded;
    if (normalized.contains('barra')) return Icons.linear_scale_rounded;
    if (normalized.contains('arnes')) return Icons.accessibility_new_rounded;
    if (normalized.contains('traje')) return Icons.waves_rounded;
    if (normalized.contains('casco')) return Icons.health_and_safety_rounded;
    if (normalized.contains('chaleco')) return Icons.shield_rounded;
    return Icons.checkroom_rounded;
  }
}
