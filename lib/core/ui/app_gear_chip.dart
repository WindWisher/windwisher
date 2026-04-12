import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class AppGearChip extends StatelessWidget {
  const AppGearChip({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.checkroom_rounded,
    this.trailing,
    this.maxLabelWidth = 180,
    this.compact = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;
  final Widget? trailing;
  final double maxLabelWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onPressed,
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? AppSpacing.sm : AppSpacing.sm,
            vertical: compact ? AppSpacing.xs : 10,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: colorScheme.onPrimaryContainer),
              const SizedBox(width: AppSpacing.xs),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxLabelWidth),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.xs),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
