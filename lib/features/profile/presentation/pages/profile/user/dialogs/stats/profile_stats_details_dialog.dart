import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/stats/kpi/profile_kpi_catalog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/stats/kpi/profile_stats_category_selector.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/stats/kpi/profile_stats_kpi_section_card.dart';

class ProfileStatsDetailsDialog extends StatefulWidget {
  final ProfileKpiSnapshot kpis;

  const ProfileStatsDetailsDialog({super.key, required this.kpis});

  @override
  State<ProfileStatsDetailsDialog> createState() =>
      _ProfileStatsDetailsDialogState();
}

class _ProfileStatsDetailsDialogState extends State<ProfileStatsDetailsDialog> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final dialogData = ProfileKpiCatalog.build(widget.kpis);
    final sections = dialogData.sections;
    final selectedIndex = sections.isEmpty
        ? 0
        : _selectedIndex.clamp(0, sections.length - 1);
    final selectedSection = sections.isEmpty ? null : sections[selectedIndex];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalle estadisticas del perfil',
                          style: textTheme.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Resumen extendido del perfil, combinado desde sesiones y comunidad.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              if (sections.isNotEmpty) ...[
                ProfileStatsCategorySelector(
                  sections: sections,
                  selectedIndex: selectedIndex,
                  onSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedSection != null)
                        ProfileStatsKpiSectionCard(section: selectedSection)
                      else
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Text(
                              'Todavia no hay estadisticas disponibles en esta vista.',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
