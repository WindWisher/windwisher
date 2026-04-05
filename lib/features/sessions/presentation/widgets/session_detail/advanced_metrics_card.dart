import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

class AdvancedMetricsCard extends StatefulWidget {
  const AdvancedMetricsCard({
    super.key,
    required this.groups,
  });

  final List<SessionKpiGroup> groups;

  @override
  State<AdvancedMetricsCard> createState() => _AdvancedMetricsCardState();
}

class _AdvancedMetricsCardState extends State<AdvancedMetricsCard> {
  String? _selectedGroupTitle;

  @override
  void initState() {
    super.initState();
    _selectedGroupTitle = widget.groups.isEmpty ? null : widget.groups.first.title;
  }

  @override
  void didUpdateWidget(covariant AdvancedMetricsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final groupTitles = widget.groups.map((group) => group.title).toSet();
    if (_selectedGroupTitle == null || !groupTitles.contains(_selectedGroupTitle)) {
      _selectedGroupTitle = widget.groups.isEmpty ? null : widget.groups.first.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final totalAvailableItems = widget.groups.fold<int>(
      0,
      (count, group) => count + group.items.where((item) => item.available).length,
    );
    final activeGroup = widget.groups
        .where((group) => group.title == _selectedGroupTitle)
        .firstOrNull;
    final availableItems = activeGroup == null
        ? const <SessionKpiItem>[]
        : activeGroup.items
              .where((item) => item.available)
              .toList(growable: false);
    final unavailableCount = activeGroup == null
        ? 0
        : activeGroup.items.length - availableItems.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mediciones avanzadas', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              totalAvailableItems == 0
                  ? 'Esta sesion no tiene todavia metricas avanzadas reales para mostrar.'
                  : 'Elige la familia de KPIs que quieres revisar para evitar una pantalla demasiado larga.',
              style: textTheme.bodySmall,
            ),
            if (totalAvailableItems == 0) ...[
              const SizedBox(height: AppSpacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Cuando esta sesion acumule metricas reales, apareceran aqui agrupadas por categoria.',
                  style: textTheme.bodySmall,
                ),
              ),
            ] else ...[
              const SizedBox(height: AppSpacing.sm),
              if (widget.groups.isEmpty)
              const Text('No hay mediciones disponibles en esta sesión.')
              else ...[
                _buildGroupDropdown(),
                const SizedBox(height: AppSpacing.sm),
                if (activeGroup != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                activeGroup.title,
                                style: textTheme.titleSmall,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                availableItems.length == 1
                                    ? '1 KPI disponible'
                                    : '${availableItems.length} KPIs',
                                style: textTheme.labelSmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        if (availableItems.isEmpty)
                          Text(
                            'No hay KPIs disponibles en esta categoria para esta sesion.',
                            style: textTheme.bodySmall,
                          )
                        else
                          ...availableItems.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.label,
                                      style: textTheme.bodyMedium,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Flexible(
                                    child: Text(
                                      item.value,
                                      textAlign: TextAlign.right,
                                      style: textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (unavailableCount > 0) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            unavailableCount == 1
                                ? '1 KPI oculto por no estar disponible en este dispositivo.'
                                : '$unavailableCount KPIs ocultos por no estar disponibles en este dispositivo.',
                            style: textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGroupDropdown() {
    final items = <DropdownMenuItem<String>>[];

    for (final group in widget.groups) {
      items.add(
        DropdownMenuItem<String>(
          value: group.title,
          child: Text(
            group.title,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    final selected = _selectedGroupTitle;
    final hasSelected =
        selected != null &&
        widget.groups.any((group) => group.title == selected);

    return DropdownButtonFormField<String>(
      initialValue: hasSelected ? selected : widget.groups.first.title,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Selector de KPIs',
        border: OutlineInputBorder(),
      ),
      items: items,
      onChanged: (value) {
        if (value == null) {
          return;
        }
        setState(() {
          _selectedGroupTitle = value;
        });
      },
    );
  }
}
