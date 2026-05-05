// ignore_for_file: invalid_use_of_protected_member

part of 'spots_page.dart';

extension _SpotsAddController on SpotsPageState {
  Future<void> _showAddSpotSheet() async {
    if (!_hasAdvancedSpotAccess && _officialSpotCount >= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Como usuario normal solo puedes guardar 2 spots oficiales.',
          ),
        ),
      );
      return;
    }

    final existingNames = _spots
        .map((spot) => spot.name.trim().toLowerCase())
        .toSet();

    final result = await showModalBottomSheet<_SpotItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _AddSpotSheet(
        existingSpotNames: existingNames,
        allowCustomMode: _canCreateCustomSpots,
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _spots.removeWhere(
        (spot) =>
            spot.name.trim().toLowerCase() == result.name.trim().toLowerCase(),
      );
      _spots.insert(0, result);
      _filter = _SpotFilter.all;
      _sort = _SpotSort.recent;
      _searchQuery = '';
      _searchController.clear();
      _spotsModule.saveSpot(result);
    });
    unawaited(_refreshSpotsAfterSave(result));
  }
}
