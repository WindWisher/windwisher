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
        allowCustomMode: false,
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
      _sort = _SpotSort.manual;
      _searchQuery = '';
      _searchController.clear();
      _syncManualOrderFromSpots();
      _spotsModule.saveSpot(result);
    });
    unawaited(_refreshSpotsAfterSave(result));
  }

  bool _isSpotSaved(_SpotItem spot) {
    final normalizedName = spot.name.trim().toLowerCase();
    return _spots.any(
      (savedSpot) => savedSpot.name.trim().toLowerCase() == normalizedName,
    );
  }

  void _addCatalogSpotFromMap(_SpotItem catalogSpot) {
    if (_isSpotSaved(catalogSpot)) {
      return;
    }
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

    final savedSpot = _SpotItem(
      name: catalogSpot.name,
      area: catalogSpot.area,
      isCustom: false,
      createdAt: DateTime.now(),
      latitude: catalogSpot.latitude,
      longitude: catalogSpot.longitude,
      aemetMunicipalityCode: catalogSpot.aemetMunicipalityCode,
      aemetBeachCode: catalogSpot.aemetBeachCode,
      aemetBeachCodes: catalogSpot.aemetBeachCodes,
      capabilities: catalogSpot.capabilities,
    );

    setState(() {
      _spots.insert(0, savedSpot);
      _sort = _SpotSort.manual;
      _syncManualOrderFromSpots();
      _spotsModule.saveSpot(savedSpot);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${savedSpot.name} agregado a Mis spots.')),
    );
    unawaited(_refreshSpotsAfterSave(savedSpot));
  }
}
