part of '../spots_page.dart';

class _SpotFilterChips extends StatelessWidget {
  const _SpotFilterChips({
    required this.selectedFilter,
    required this.onSelected,
  });

  final _SpotFilter selectedFilter;
  final ValueChanged<_SpotFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return _SpotChoiceChipRow<_SpotFilter>(
      chips: const [
        _SpotChoiceChipData(
          key: Key('spots-filter-all'),
          label: 'Todos',
          value: _SpotFilter.all,
        ),
        _SpotChoiceChipData(
          key: Key('spots-filter-official'),
          label: 'Oficiales',
          value: _SpotFilter.official,
        ),
        _SpotChoiceChipData(
          key: Key('spots-filter-custom'),
          label: 'Custom',
          value: _SpotFilter.custom,
        ),
      ],
      selectedValue: selectedFilter,
      onSelected: onSelected,
    );
  }
}

class _SpotSortChips extends StatelessWidget {
  const _SpotSortChips({required this.selectedSort, required this.onSelected});

  final _SpotSort selectedSort;
  final ValueChanged<_SpotSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return _SpotChoiceChipRow<_SpotSort>(
      chips: const [
        _SpotChoiceChipData(
          key: Key('spots-sort-manual'),
          label: 'Manual',
          value: _SpotSort.manual,
        ),
        _SpotChoiceChipData(
          key: Key('spots-sort-recent'),
          label: 'Recientes',
          value: _SpotSort.recent,
        ),
        _SpotChoiceChipData(
          key: Key('spots-sort-az'),
          label: 'A-Z',
          value: _SpotSort.az,
        ),
        _SpotChoiceChipData(
          key: Key('spots-sort-za'),
          label: 'Z-A',
          value: _SpotSort.za,
        ),
      ],
      selectedValue: selectedSort,
      onSelected: onSelected,
    );
  }
}

class _SpotChoiceChipRow<T> extends StatelessWidget {
  const _SpotChoiceChipRow({
    required this.chips,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<_SpotChoiceChipData<T>> chips;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < chips.length; index++) ...[
            if (index > 0) const SizedBox(width: AppSpacing.xs),
            ChoiceChip(
              key: chips[index].key,
              label: Text(chips[index].label),
              selected: selectedValue == chips[index].value,
              onSelected: (_) => onSelected(chips[index].value),
            ),
          ],
        ],
      ),
    );
  }
}

class _SpotChoiceChipData<T> {
  const _SpotChoiceChipData({
    required this.key,
    required this.label,
    required this.value,
  });

  final Key key;
  final String label;
  final T value;
}
