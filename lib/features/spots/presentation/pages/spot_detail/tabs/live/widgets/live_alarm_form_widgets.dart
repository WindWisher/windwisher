part of '../../../spot_detail_page.dart';

class _LiveAlarmsHeader extends StatelessWidget {
  const _LiveAlarmsHeader({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.9),
            colorScheme.secondaryContainer.withValues(alpha: 0.75),
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
            child: Icon(
              Icons.notifications_active_rounded,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alarmas personalizadas',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enabled
                      ? 'Spot activo para alertas'
                      : 'Spot desactivado para alertas',
                  style: textTheme.bodySmall?.copyWith(
                    color: enabled
                        ? const Color(0xFF2E7D32)
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LiveNewAlarmCard extends StatelessWidget {
  const _LiveNewAlarmCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Nueva alarma',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _LiveAlarmStationDropdown extends StatelessWidget {
  const _LiveAlarmStationDropdown({
    required this.stationKeys,
    required this.selectedStationKey,
    required this.stationLabelForKey,
    required this.onChanged,
  });

  final List<String> stationKeys;
  final String selectedStationKey;
  final String Function(String stationKey) stationLabelForKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedStationKey,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Estacion meteorologica',
        border: OutlineInputBorder(),
      ),
      items: stationKeys
          .map(
            (station) => DropdownMenuItem(
              value: station,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  stationLabelForKey(station),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) {
        return stationKeys
            .map(
              (station) => Text(
                stationLabelForKey(station),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
            .toList();
      },
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _LiveAlarmTimeRangeButtons extends StatelessWidget {
  const _LiveAlarmTimeRangeButtons({
    required this.startLabel,
    required this.endLabel,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final String startLabel;
  final String endLabel;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LiveAlarmTimeButton(
            label: 'Desde',
            value: startLabel,
            onPressed: onPickStart,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _LiveAlarmTimeButton(
            label: 'Hasta',
            value: endLabel,
            onPressed: onPickEnd,
          ),
        ),
      ],
    );
  }
}

class _LiveAlarmTimeButton extends StatelessWidget {
  const _LiveAlarmTimeButton({
    required this.label,
    required this.value,
    required this.onPressed,
  });

  final String label;
  final String value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.schedule_rounded),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(label), Text(value)],
      ),
    );
  }
}

class _LiveAlarmWindRangeSelector extends StatelessWidget {
  const _LiveAlarmWindRangeSelector({
    required this.windRange,
    required this.rangeLabel,
    required this.startLabel,
    required this.endLabel,
    required this.onChanged,
  });

  final RangeValues windRange;
  final String rangeLabel;
  final String startLabel;
  final String endLabel;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Rango de viento · $rangeLabel',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        RangeSlider(
          min: 4,
          max: 40,
          divisions: 36,
          values: windRange,
          labels: RangeLabels(startLabel, endLabel),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

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

class _LiveAlarmRepeatControls extends StatelessWidget {
  const _LiveAlarmRepeatControls({
    required this.repeatWindow,
    required this.maxRepeats,
    required this.onRepeatWindowChanged,
    required this.onMaxRepeatsChanged,
  });

  final AlarmRepeatWindow repeatWindow;
  final int maxRepeats;
  final ValueChanged<AlarmRepeatWindow> onRepeatWindowChanged;
  final ValueChanged<int> onMaxRepeatsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<AlarmRepeatWindow>(
          initialValue: repeatWindow,
          decoration: const InputDecoration(
            labelText: 'Repetir cada',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: AlarmRepeatWindow.min1,
              child: Text('1 min'),
            ),
            DropdownMenuItem(
              value: AlarmRepeatWindow.min5,
              child: Text('5 min'),
            ),
            DropdownMenuItem(
              value: AlarmRepeatWindow.min10,
              child: Text('10 min'),
            ),
            DropdownMenuItem(
              value: AlarmRepeatWindow.min15,
              child: Text('15 min'),
            ),
            DropdownMenuItem(
              value: AlarmRepeatWindow.min30,
              child: Text('30 min'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onRepeatWindowChanged(value);
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<int>(
          initialValue: maxRepeats,
          decoration: const InputDecoration(
            labelText: 'Maximo de avisos seguidos',
            border: OutlineInputBorder(),
          ),
          items: List.generate(6, (index) {
            final value = index + 1;
            return DropdownMenuItem<int>(
              value: value,
              child: Text('$value aviso${value == 1 ? '' : 's'}'),
            );
          }),
          onChanged: (value) {
            if (value != null) {
              onMaxRepeatsChanged(value);
            }
          },
        ),
      ],
    );
  }
}

class _LiveAlarmSaveButton extends StatelessWidget {
  const _LiveAlarmSaveButton({
    required this.isEditing,
    required this.onPressed,
  });

  final bool isEditing;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.alarm_add_rounded),
        label: Text(isEditing ? 'Guardar cambios' : 'Guardar alarma'),
      ),
    );
  }
}
