part of '../spots_page.dart';

class _SpotSuggestionsList extends StatelessWidget {
  const _SpotSuggestionsList({required this.spots, required this.onSelected});

  final List<_AvailableSpot> spots;
  final ValueChanged<_AvailableSpot> onSelected;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Card(
        margin: EdgeInsets.zero,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: spots.length,
          itemBuilder: (context, index) {
            final spot = spots[index];
            return ListTile(
              dense: true,
              leading: const Icon(Icons.location_on_outlined),
              title: Text(spot.name),
              subtitle: Text(spot.area),
              onTap: () => onSelected(spot),
            );
          },
        ),
      ),
    );
  }
}
