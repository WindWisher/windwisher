import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/stats/kpi/profile_kpi_catalog.dart';

class ProfileStatsCurrentContextCard extends StatelessWidget {
  const ProfileStatsCurrentContextCard({
    super.key,
    required this.contextRows,
    required this.isExpanded,
    required this.onExpansionChanged,
  });

  final List<ProfileDetailRowData> contextRows;
  final bool isExpanded;
  final ValueChanged<bool> onExpansionChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          initiallyExpanded: isExpanded,
          onExpansionChanged: onExpansionChanged,
          title: Text('Contexto actual', style: textTheme.titleMedium),
          subtitle: Text(
            'Datos de apoyo del perfil fuera del bloque principal de KPIs.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          children: [
            for (final row in contextRows) _ProfileStatsRow(item: row),
          ],
        ),
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow({required this.item});

  final ProfileDetailRowData item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(item.label)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              item.value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item.hydrated
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
