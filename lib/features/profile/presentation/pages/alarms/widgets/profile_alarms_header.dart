import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class ProfileAlarmsHeader extends StatelessWidget {
  const ProfileAlarmsHeader({
    super.key,
    required this.globalEnabled,
    required this.onChanged,
  });

  final bool globalEnabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.72),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.alarm_add_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alarmas',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  globalEnabled
                      ? 'Alarmas globales activas'
                      : 'Alarmas globales desactivadas',
                  style: textTheme.bodySmall?.copyWith(
                    color: globalEnabled
                        ? const Color(0xFF2E7D32)
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: globalEnabled, onChanged: onChanged),
        ],
      ),
    );
  }
}
