import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/stats/profile_summary_overview_details_button.dart';

class ProfileSummaryOverviewCard extends StatelessWidget {
  const ProfileSummaryOverviewCard({
    super.key,
    required this.kpis,
    this.onDetailsPressed,
  });

  final ProfileKpiSnapshot kpis;
  final VoidCallback? onDetailsPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Estadisticas', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _ProfileSummaryOverviewRow(
              label: 'Sesiones totales',
              value: kpis.totalSessionsLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Horas en agua',
              value: kpis.waterHoursLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Ranking global',
              value: kpis.rankingLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Mes con mas sesiones',
              value: kpis.bestMonthLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Saltos registrados',
              value: kpis.totalJumpsLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Salto mas alto',
              value: kpis.highestJumpLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Hangtime maximo',
              value: kpis.maxHangtimeLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Velocidad maxima',
              value: kpis.maxSpeedLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Spot mas utilizado',
              value: kpis.mostUsedSpotLabel,
            ),
            if (onDetailsPressed != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ProfileSummaryOverviewDetailsButton(onPressed: onDetailsPressed!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileSummaryOverviewRow extends StatelessWidget {
  const _ProfileSummaryOverviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
