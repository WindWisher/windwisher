import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';

class ProfileSummaryOverviewCard extends StatelessWidget {
  const ProfileSummaryOverviewCard({
    super.key,
    required this.kpis,
    required this.onDetailsPressed,
  });

  final ProfileKpiSnapshot kpis;
  final VoidCallback onDetailsPressed;

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
              label: 'Saltos registrados',
              value: kpis.totalJumpsLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Salto mas alto',
              value: kpis.highestJumpLabel,
            ),
            _ProfileSummaryOverviewRow(
              label: 'Mejor spot',
              value: kpis.bestSpotLabel,
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: OutlinedButton.icon(
                onPressed: onDetailsPressed,
                icon: const Icon(Icons.insights_outlined),
                label: const Text('Detalles'),
              ),
            ),
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
