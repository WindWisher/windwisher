part of '../../../spot_detail_page.dart';

class _LiveHistoryRangeControls extends StatelessWidget {
  const _LiveHistoryRangeControls({
    required this.usesFixedWindow,
    required this.coverageLabel,
    required this.availableRanges,
    required this.selectedRange,
    required this.showBucketSelector,
    required this.bucketOptions,
    required this.selectedBucketOption,
    required this.onRangeChanged,
    required this.onBucketChanged,
  });

  final bool usesFixedWindow;
  final String coverageLabel;
  final List<_HistoryRange> availableRanges;
  final _HistoryRange selectedRange;
  final bool showBucketSelector;
  final List<_HistoricalBucketOption> bucketOptions;
  final _HistoricalBucketOption selectedBucketOption;
  final ValueChanged<_HistoryRange> onRangeChanged;
  final ValueChanged<_HistoricalBucketOption> onBucketChanged;

  @override
  Widget build(BuildContext context) {
    if (usesFixedWindow) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          coverageLabel,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<_HistoryRange>(
            segments: availableRanges
                .map(
                  (range) => ButtonSegment<_HistoryRange>(
                    value: range,
                    label: Text(_historyRangeLabel(range)),
                  ),
                )
                .toList(growable: false),
            selected: {selectedRange},
            onSelectionChanged: (value) => onRangeChanged(value.first),
          ),
        ),
        if (showBucketSelector) ...[
          const SizedBox(height: AppSpacing.xs),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SegmentedButton<_HistoricalBucketOption>(
              segments: bucketOptions
                  .map(
                    (option) => ButtonSegment<_HistoricalBucketOption>(
                      value: option,
                      label: Text(_historicalBucketOptionLabel(option)),
                    ),
                  )
                  .toList(growable: false),
              selected: {selectedBucketOption},
              onSelectionChanged: (value) => onBucketChanged(value.first),
            ),
          ),
        ],
      ],
    );
  }
}
