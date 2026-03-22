import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_forecast_port.dart';

class GetSpotForecastUseCase {
  const GetSpotForecastUseCase(this._port);

  final SpotsForecastPort _port;

  Future<List<SpotForecastEntry>> call({
    required SpotItem spot,
    required String provider,
    required String model,
  }) {
    return _port.getForecast(spot: spot, provider: provider, model: model);
  }
}
