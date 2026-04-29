import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_forecast_port.dart';

class CompositeSpotsForecastAdapter implements SpotsForecastPort {
  const CompositeSpotsForecastAdapter({
    required SpotsForecastPort openMeteoAdapter,
    required SpotsForecastPort aemetAdapter,
    required SpotsForecastPort meteoblueAdapter,
    required SpotsForecastPort meteosourceAdapter,
    required SpotsForecastPort meteostatAdapter,
    required SpotsForecastPort portusAdapter,
  }) : _openMeteoAdapter = openMeteoAdapter,
       _aemetAdapter = aemetAdapter,
       _meteoblueAdapter = meteoblueAdapter,
       _meteosourceAdapter = meteosourceAdapter,
       _meteostatAdapter = meteostatAdapter,
       _portusAdapter = portusAdapter;

  final SpotsForecastPort _openMeteoAdapter;
  final SpotsForecastPort _aemetAdapter;
  final SpotsForecastPort _meteoblueAdapter;
  final SpotsForecastPort _meteosourceAdapter;
  final SpotsForecastPort _meteostatAdapter;
  final SpotsForecastPort _portusAdapter;

  @override
  Future<List<SpotForecastEntry>> getForecast({
    required SpotItem spot,
    required String provider,
    required String model,
  }) {
    switch (provider) {
      case 'AEMET':
        if (model == 'Portus Atmosfera') {
          return _portusAdapter.getForecast(
            spot: spot,
            provider: 'Portus',
            model: model,
          );
        }
        return _aemetAdapter.getForecast(
          spot: spot,
          provider: provider,
          model: model,
        );
      case 'Open-Meteo':
        return _openMeteoAdapter.getForecast(
          spot: spot,
          provider: provider,
          model: model,
        );
      case 'Meteoblue':
        return _meteoblueAdapter.getForecast(
          spot: spot,
          provider: provider,
          model: model,
        );
      case 'Meteosource':
        return _meteosourceAdapter.getForecast(
          spot: spot,
          provider: provider,
          model: model,
        );
      case 'Meteostat':
        return _meteostatAdapter.getForecast(
          spot: spot,
          provider: provider,
          model: model,
        );
      default:
        return Future.value(const <SpotForecastEntry>[]);
    }
  }
}
