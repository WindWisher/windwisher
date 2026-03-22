import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';

abstract class SpotsForecastPort {
  Future<List<SpotForecastEntry>> getForecast({
    required SpotItem spot,
    required String provider,
    required String model,
  });
}
