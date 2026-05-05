part of 'spots_page.dart';

List<_SpotItem> _filterAndSortSpots({
  required List<_SpotItem> spots,
  required String searchQuery,
  required _SpotFilter filter,
  required _SpotSort sort,
}) {
  final query = searchQuery.trim().toLowerCase();
  final filtered = spots.where((spot) {
    return _matchesSpotQuery(spot, query) && _matchesSpotFilter(spot, filter);
  }).toList();

  filtered.sort((a, b) => _compareSpots(a, b, sort));
  return filtered;
}

bool _matchesSpotQuery(_SpotItem spot, String query) {
  if (query.isEmpty) {
    return true;
  }
  return spot.name.toLowerCase().contains(query) ||
      spot.area.toLowerCase().contains(query);
}

bool _matchesSpotFilter(_SpotItem spot, _SpotFilter filter) {
  return switch (filter) {
    _SpotFilter.all => true,
    _SpotFilter.official => !spot.isCustom,
    _SpotFilter.custom => spot.isCustom,
  };
}

int _compareSpots(_SpotItem a, _SpotItem b, _SpotSort sort) {
  return switch (sort) {
    _SpotSort.recent => b.createdAt.compareTo(a.createdAt),
    _SpotSort.az => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    _SpotSort.za => b.name.toLowerCase().compareTo(a.name.toLowerCase()),
  };
}
