import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/portus/portus_spots_forecast_adapter.dart';

SpotItem _spot({
  required String name,
  required String area,
  double? latitude,
  double? longitude,
}) {
  return SpotItem(
    name: name,
    area: area,
    isCustom: false,
    createdAt: DateTime(2026, 4, 29),
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  group('PortusSpotsForecastAdapter', () {
    test(
      'maps nearest Portus atmosphere point into hourly wind entries',
      () async {
        final requestedUrls = <String>[];
        final adapter = PortusSpotsForecastAdapter(
          fetchJson: (url) async {
            requestedUrls.add(url);
            if (url.contains('/puntosMalla/portus/pred/Atmosfera')) {
              return [
                {'id': 'far-point', 'latitud': 41.0, 'longitud': 2.0},
                {'id': 'near-point', 'latitud': 38.935, 'longitud': -0.099},
              ];
            }
            return [
              [1777381200.0, 5.2, 251.0],
              [1777384800.0, 6.1, 260.0],
            ];
          },
        );

        final result = await adapter.getForecast(
          spot: _spot(
            name: 'Oliva Puerto',
            area: 'Valencia',
            latitude: 38.9348,
            longitude: -0.0986,
          ),
          provider: 'Portus',
          model: 'Atmosfera',
        );

        expect(result, hasLength(2));
        expect(result.first.windKnots, 10);
        expect(result.first.windDeg, 71);
        expect(result.first.airTempC, isNull);
        expect(result.first.gustKnots, isNull);
        expect(
          requestedUrls.first,
          contains('/puntosMalla/portus/pred/Atmosfera'),
        );
        expect(requestedUrls.last, contains('code=near-point'));
        expect(
          requestedUrls.last,
          contains('fields=Datetime,WindSpeed,WindDir180'),
        );
      },
    );

    test('returns empty result for non Portus providers', () async {
      final adapter = PortusSpotsForecastAdapter(
        fetchJson: (_) async => fail('Portus should not be called.'),
      );

      final result = await adapter.getForecast(
        spot: _spot(name: 'Oliva Puerto', area: 'Valencia'),
        provider: 'Open-Meteo',
        model: 'Best match',
      );

      expect(result, isEmpty);
    });
  });
}
