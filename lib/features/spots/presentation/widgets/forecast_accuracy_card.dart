import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/spots/presentation/widgets/forecast_accuracy_info_dialog.dart';

class ForecastAccuracyCard extends StatelessWidget {
  const ForecastAccuracyCard({
    super.key,
    required this.totalPercentage,
    required this.windPercentage,
    required this.directionPercentage,
    this.meanAbsoluteErrorKnots,
  });

  final int? totalPercentage;
  final int? windPercentage;
  final int? directionPercentage;
  final double? meanAbsoluteErrorKnots;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.42),
            Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    showDialog<void>(
                      context: context,
                      builder: (dialogContext) =>
                          const ForecastAccuracyInfoDialog(),
                    );
                  },
                  child: Ink(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.82),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.track_changes_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Precision de Modelo Forecast',
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Comparativa entre forecast historico y viento real de la estacion',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _ForecastAccuracyChip(
                label: '',
                percentage: totalPercentage,
                emphasized: true,
              ),
              if (meanAbsoluteErrorKnots != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'Error medio ${meanAbsoluteErrorKnots!.toStringAsFixed(1)} kt',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _ForecastAccuracyChip(label: 'Viento', percentage: windPercentage),
              _ForecastAccuracyChip(
                label: 'Direccion',
                percentage: directionPercentage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ForecastAccuracyChip extends StatelessWidget {
  const _ForecastAccuracyChip({
    required this.label,
    required this.percentage,
    this.emphasized = false,
  });

  final String label;
  final int? percentage;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final effectivePercentage = percentage ?? 0;
    final color = _forecastAccuracyColor(context, effectivePercentage);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: emphasized ? AppSpacing.md : AppSpacing.sm,
        vertical: emphasized ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: emphasized ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label.isEmpty
            ? _formatAccuracyPercent(percentage)
            : '$label ${_formatAccuracyPercent(percentage)}',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: emphasized ? 13.5 : null,
        ),
      ),
    );
  }
}

Color _forecastAccuracyColor(BuildContext context, int percentage) {
  if (percentage > 80) {
    return const Color(0xFF1B5E20);
  }
  if (percentage >= 70) {
    return const Color(0xFF2E7D32);
  }
  if (percentage >= 60) {
    return const Color(0xFFF9A825);
  }
  if (percentage >= 50) {
    return const Color(0xFFEF6C00);
  }
  if (percentage >= 40) {
    return const Color(0xFFC62828);
  }
  return Theme.of(context).colorScheme.error;
}

String _formatAccuracyPercent(int? percentage) {
  if (percentage == null) {
    return '--';
  }
  return '$percentage%';
}
