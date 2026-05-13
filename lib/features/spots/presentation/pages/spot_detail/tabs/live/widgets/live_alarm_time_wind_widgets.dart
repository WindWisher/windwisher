part of '../../../spot_detail_page.dart';

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
