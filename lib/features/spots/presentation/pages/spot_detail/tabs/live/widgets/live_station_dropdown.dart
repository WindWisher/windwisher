part of '../../../spot_detail_page.dart';

class _LiveStationDropdown extends StatelessWidget {
  const _LiveStationDropdown({
    required this.stations,
    required this.selectedStationKey,
    required this.stationKeyOf,
    required this.stationLabelOf,
    required this.onChanged,
  });

  final List<_NearbyStation> stations;
  final String selectedStationKey;
  final String Function(_NearbyStation station) stationKeyOf;
  final String Function(_NearbyStation station) stationLabelOf;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedStationKey,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Estacion meteorologica cercana',
        border: OutlineInputBorder(),
      ),
      items: stations.map((station) {
        return DropdownMenuItem<String>(
          value: stationKeyOf(station),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              stationLabelOf(station),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      }).toList(),
      selectedItemBuilder: (context) {
        return stations
            .map(
              (station) => Text(
                stationLabelOf(station),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
            .toList();
      },
      onChanged: (value) {
        if (value == null) {
          return;
        }
        onChanged(value);
      },
    );
  }
}
