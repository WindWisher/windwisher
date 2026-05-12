part of '../../../spot_detail_page.dart';

class _LiveStationActionsRow extends StatelessWidget {
  const _LiveStationActionsRow({
    required this.station,
    required this.onShowMap,
  });

  final _NearbyStation station;
  final ValueChanged<_NearbyStation> onShowMap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        TextButton.icon(
          onPressed: () => onShowMap(station),
          icon: const Icon(Icons.map_outlined),
          label: const Text('Ver estacion en el mapa'),
        ),
      ],
    );
  }
}
