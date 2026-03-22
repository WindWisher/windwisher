import 'package:windwisher/features/spots/domain/entities/spot_item.dart';

abstract class SpotsCatalogPort {
  List<SpotItem> getSpots();

  Future<List<SpotItem>> hydrateSpots();

  void saveSpot(SpotItem spot);

  void deleteSpotByName(String name);
}
