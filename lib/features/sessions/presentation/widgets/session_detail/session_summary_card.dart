import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';
import 'package:windwisher/features/sessions/presentation/widgets/session_detail/metric_kpi_tile.dart';

class SessionSummaryCard extends StatelessWidget {
  const SessionSummaryCard({
    super.key,
    required this.insights,
    required this.durationLabel,
  });

  final SessionInsightData insights;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final summaryItems = <_SessionSummaryItem>[
      if (insights.maxJumpHeightMeters != null)
        _SessionSummaryItem(
          label: 'Salto mas alto',
          value: '${insights.maxJumpHeightMeters!.toStringAsFixed(1)} m',
          icon: Icons.vertical_align_top_rounded,
        ),
      if (insights.jumpsCount != null)
        _SessionSummaryItem(
          label: 'Saltos',
          value: '${insights.jumpsCount}',
          icon: Icons.waves_rounded,
        ),
      if (insights.maxHangtimeSeconds != null)
        _SessionSummaryItem(
          label: 'Hangtime maximo',
          value: '${insights.maxHangtimeSeconds!.toStringAsFixed(1)} s',
          icon: Icons.timer_rounded,
        ),
      _SessionSummaryItem(
        label: 'Duracion sesion',
        value: durationLabel,
        icon: Icons.av_timer_rounded,
      ),
      if (insights.maxSpeedKnots != null)
        _SessionSummaryItem(
          label: 'Velocidad max',
          value: '${insights.maxSpeedKnots!.toStringAsFixed(1)} kt',
          icon: Icons.speed_rounded,
        ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen post-sesion', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth = (constraints.maxWidth - AppSpacing.xs) / 2;
                return Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: summaryItems
                      .map(
                        (item) => MetricKpiTile(
                          width: tileWidth,
                          label: item.label,
                          value: item.value,
                          icon: item.icon,
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionSummaryItem {
  const _SessionSummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}
