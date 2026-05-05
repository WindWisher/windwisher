part of 'spots_page.dart';

const int _maxSpotSuggestions = 5;

bool _shouldClearSelectedOfficialSpot({
  required _AvailableSpot? selectedOfficialSpot,
  required String query,
}) {
  return selectedOfficialSpot != null &&
      selectedOfficialSpot.name.toLowerCase() != query;
}

List<_AvailableSpot> _findAvailableSpotSuggestions({
  required String query,
  required Set<String> existingSpotNames,
}) {
  return _availableSpots
      .where(
        (spot) =>
            spot.name.toLowerCase().contains(query) &&
            !existingSpotNames.contains(spot.name.toLowerCase()),
      )
      .take(_maxSpotSuggestions)
      .toList();
}
