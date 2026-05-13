part of '../../../spot_detail_page.dart';

class _LiveAlarmDirectionSelector extends StatelessWidget {
  const _LiveAlarmDirectionSelector({
    required this.options,
    required this.selectedDirections,
    required this.rotationForDirection,
    required this.onSelectAllToggled,
    required this.onDirectionToggled,
  });

  final List<String> options;
  final Set<String> selectedDirections;
  final double Function(String direction) rotationForDirection;
  final VoidCallback onSelectAllToggled;
  final void Function(String direction, bool selected) onDirectionToggled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direcciones activas',
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            FilterChip(
              label: const Text('Todas'),
              selected: selectedDirections.length == options.length,
              showCheckmark: false,
              onSelected: (_) => onSelectAllToggled(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            final rows = <List<String>>[
              options.sublist(0, 4),
              options.sublist(4, 8),
            ];
            return Column(
              children: rows
                  .map((row) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: row == rows.last ? 0 : AppSpacing.xs,
                      ),
                      child: Row(
                        children: row
                            .map((direction) {
                              final selected = selectedDirections.contains(
                                direction,
                              );
                              return Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: direction == row.last
                                        ? 0
                                        : AppSpacing.xs,
                                  ),
                                  child: _LiveAlarmDirectionChip(
                                    direction: direction,
                                    selected: selected,
                                    rotation: rotationForDirection(direction),
                                    onSelected: (value) =>
                                        onDirectionToggled(direction, value),
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                    );
                  })
                  .toList(growable: false),
            );
          },
        ),
      ],
    );
  }
}

class _LiveAlarmDirectionChip extends StatelessWidget {
  const _LiveAlarmDirectionChip({
    required this.direction,
    required this.selected,
    required this.rotation,
    required this.onSelected,
  });

  final String direction;
  final bool selected;
  final double rotation;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilterChip(
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      labelPadding: const EdgeInsets.symmetric(horizontal: 2),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: rotation,
              child: Icon(
                Icons.navigation_rounded,
                size: 14,
                color: selected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 3),
            Text(direction, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
