import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_catalog_port.dart';

class GetSpotsUseCase {
  const GetSpotsUseCase(this._port);

  final SpotsCatalogPort _port;

  List<SpotItem> call() {
    return _port.getSpots();
  }

  Future<List<SpotItem>> load() {
    return _port.hydrateSpots();
  }
}

class SaveSpotUseCase {
  const SaveSpotUseCase(this._port);

  final SpotsCatalogPort _port;

  void call(SpotItem spot) {
    _port.saveSpot(spot);
  }
}

class DeleteSpotByNameUseCase {
  const DeleteSpotByNameUseCase(this._port);

  final SpotsCatalogPort _port;

  void call(String name) {
    _port.deleteSpotByName(name);
  }
}
