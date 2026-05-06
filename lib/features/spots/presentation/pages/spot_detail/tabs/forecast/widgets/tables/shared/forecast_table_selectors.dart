part of '../../../../../spot_detail_page.dart';

class _ForecastRangeSelector extends StatelessWidget {
  const _ForecastRangeSelector({
    required this.ranges,
    required this.selectedRange,
    required this.onRangeChanged,
  });

  final List<_ForecastRange> ranges;
  final _ForecastRange selectedRange;
  final ValueChanged<_ForecastRange> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    return _ForecastSegmentedSelector<_ForecastRange>(
      values: ranges,
      selectedValue: selectedRange,
      labelFor: (range) => range.label,
      onChanged: onRangeChanged,
    );
  }
}

class _ForecastResolutionSelector extends StatelessWidget {
  const _ForecastResolutionSelector({
    required this.resolutions,
    required this.selectedResolution,
    required this.onResolutionChanged,
  });

  final List<_ForecastResolution> resolutions;
  final _ForecastResolution selectedResolution;
  final ValueChanged<_ForecastResolution>? onResolutionChanged;

  @override
  Widget build(BuildContext context) {
    return _ForecastSegmentedSelector<_ForecastResolution>(
      values: resolutions,
      selectedValue: selectedResolution,
      labelFor: (resolution) => resolution.label,
      onChanged: onResolutionChanged,
    );
  }
}

class _ForecastSegmentedSelector<T> extends StatelessWidget {
  const _ForecastSegmentedSelector({
    required this.values,
    required this.selectedValue,
    required this.labelFor,
    required this.onChanged,
  });

  final List<T> values;
  final T selectedValue;
  final String Function(T value) labelFor;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          side: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.35),
          ),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          foregroundColor: Theme.of(context).colorScheme.primary,
          selectedForegroundColor: Colors.white,
          selectedBackgroundColor: Theme.of(context).colorScheme.primary,
        ),
        segments: values
            .map(
              (value) =>
                  ButtonSegment<T>(value: value, label: Text(labelFor(value))),
            )
            .toList(),
        selected: {selectedValue},
        onSelectionChanged: onChanged == null
            ? null
            : (value) {
                onChanged?.call(value.first);
              },
      ),
    );
  }
}
