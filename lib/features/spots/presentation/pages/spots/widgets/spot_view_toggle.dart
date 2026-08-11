part of '../spots_page.dart';

class _SpotViewToggle extends StatelessWidget {
  const _SpotViewToggle({required this.selectedView, required this.onSelected});

  final _SpotsViewMode selectedView;
  final ValueChanged<_SpotsViewMode> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<_SpotsViewMode>(
        key: const Key('spots-view-toggle'),
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: _SpotsViewMode.list,
            icon: Icon(Icons.view_agenda_outlined),
            label: Text('Lista'),
          ),
          ButtonSegment(
            value: _SpotsViewMode.map,
            icon: Icon(Icons.public_outlined),
            label: Text('Mapa'),
          ),
        ],
        selected: {selectedView},
        onSelectionChanged: (selection) => onSelected(selection.first),
      ),
    );
  }
}
