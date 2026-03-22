import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_catalog_port.dart';

class InMemorySpotsCatalogAdapter implements SpotsCatalogPort {
  static final List<SpotItem> _spots = [];

  @override
  List<SpotItem> getSpots() {
    return List<SpotItem>.unmodifiable(_spots);
  }

  @override
  Future<List<SpotItem>> hydrateSpots() async {
    return getSpots();
  }

  @override
  void saveSpot(SpotItem spot) {
    final index = _spots.indexWhere(
      (entry) =>
          entry.name.trim().toLowerCase() == spot.name.trim().toLowerCase(),
    );
    if (index >= 0) {
      _spots[index] = spot;
      return;
    }
    _spots.add(spot);
  }

  @override
  void deleteSpotByName(String name) {
    final normalized = name.trim().toLowerCase();
    _spots.removeWhere(
      (entry) => entry.name.trim().toLowerCase() == normalized,
    );
  }
}
