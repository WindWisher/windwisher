import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/application/services/spot_forecast_model_order.dart';

void main() {
  group('spot forecast model order', () {
    test(
      'excludes Portus when the spot does not support maritime forecast',
      () {
        final models = getSpotForecastModels(
          spotName: 'Pantano de Alarcón - Playa Manchamar',
          spotArea: 'Cuenca',
          provider: 'AEMET',
          supportsPortusForecast: false,
        );

        expect(models, contains(kAemetMunicipalForecastModel));
        expect(models, isNot(contains(kAemetPortusAtmosphereForecastModel)));
      },
    );

    test('uses municipal AEMET as fallback when Portus is unsupported', () {
      final model = getSpotDefaultForecastModel(
        spotName: 'Pantano de Alarcón - Playa Manchamar',
        spotArea: 'Cuenca',
        provider: 'AEMET',
        supportsPortusForecast: false,
      );

      expect(model, kAemetMunicipalForecastModel);
    });

    test('keeps Portus available by default for existing coastal spots', () {
      final models = getSpotForecastModels(
        spotName: 'Oliva Canal - Platja dels Gorgs',
        spotArea: 'Oliva',
        provider: 'AEMET',
      );

      expect(models, contains(kAemetPortusAtmosphereForecastModel));
    });

    test('uses the embedded widget model for Windy.app', () {
      final models = getSpotForecastModels(
        spotName: 'Oliva Canal - Platja dels Gorgs',
        provider: 'Windy.app',
      );

      expect(models, const ['Widget']);
      expect(
        getSpotDefaultForecastModel(
          spotName: 'Oliva Canal - Platja dels Gorgs',
          provider: 'Windy.app',
        ),
        'Widget',
      );
    });
  });
}
