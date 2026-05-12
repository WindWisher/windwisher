part of '../../../spot_detail_page.dart';

class _LiveWindUnitSelector extends StatelessWidget {
  const _LiveWindUnitSelector({
    required this.selectedUnit,
    required this.onChanged,
  });

  final _WindSpeedUnit selectedUnit;
  final ValueChanged<_WindSpeedUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_WindSpeedUnit>(
      segments: const [
        ButtonSegment(value: _WindSpeedUnit.knots, label: Text('kt')),
        ButtonSegment(value: _WindSpeedUnit.kmh, label: Text('km/h')),
        ButtonSegment(value: _WindSpeedUnit.mph, label: Text('mph')),
        ButtonSegment(value: _WindSpeedUnit.beaufort, label: Text('Bft')),
      ],
      selected: {selectedUnit},
      onSelectionChanged: (value) => onChanged(value.first),
    );
  }
}
