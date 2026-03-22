import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/meteosource/meteosource_spots_forecast_adapter.dart';

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
    createdAt: DateTime(2026, 3, 8),
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  group('MeteosourceSpotsForecastAdapter', () {
    test('maps hourly Meteosource payload into spot entries', () async {
      final requestedUrls = <String>[];
      final adapter = MeteosourceSpotsForecastAdapter(
        apiKey: 'test-key',
        fetchJson: (url) async {
          requestedUrls.add(url);
          return {
            'hourly': {
              'data': [
                {
                  'date': '2026-03-08T00:00:00',
                  'temperature': 18.2,
                  'wind': {'speed': 6.0, 'gusts': 8.2, 'angle': 105},
                  'cloud_cover': {'total': 32},
                  'pressure': 1014,
                  'precipitation': {'total': 0.4, 'type': 'rain'},
                },
                {
                  'date': '2026-03-08T01:00:00',
                  'temperature': 17.8,
                  'wind': {'speed': 5.4, 'angle': 112},
                  'cloud_cover': {'total': 44},
                  'precipitation': {'total': 0.0, 'type': 'none'},
                },
              ],
            },
          };
        },
      );

      final result = await adapter.getForecast(
        spot: _spot(
          name: 'Oliva Puerto',
          area: 'Valencia',
          latitude: 38.9348,
          longitude: -0.0986,
        ),
        provider: 'Meteosource',
        model: 'Hourly',
      );

      expect(result, hasLength(2));
      expect(result.first.windKnots, 12);
      expect(result.first.gustKnots, 16);
      expect(result.first.windDeg, 105);
      expect(result.first.airTempC, 18);
      expect(result.first.pressureHpa, 1014);
      expect(result.first.cloudCoverPct, 32);
      expect(result.first.rainMm, 0.4);
      expect(result.first.waterTempC, isNull);
      expect(result.first.waveM, isNull);
      expect(result.last.gustKnots, isNull);
      expect(requestedUrls.single, contains('/api/v1/free/point'));
      expect(requestedUrls.single, contains('key=test-key'));
      expect(requestedUrls.single, contains('sections=hourly'));
      expect(requestedUrls.single, contains('lat=38.9348'));
      expect(requestedUrls.single, contains('lon=-0.0986'));
    });

    test('returns empty result when Meteosource api key is missing', () async {
      final adapter = MeteosourceSpotsForecastAdapter(apiKey: '');

      final result = await adapter.getForecast(
        spot: _spot(name: 'Oliva Puerto', area: 'Valencia'),
        provider: 'Meteosource',
        model: 'Hourly',
      );

      expect(result, isEmpty);
    });

    test('skips malformed hourly records and keeps valid ones', () async {
      final adapter = MeteosourceSpotsForecastAdapter(
        apiKey: 'test-key',
        fetchJson: (url) async {
          return {
            'hourly': {
              'data': [
                {
                  'date': 'invalid-date',
                  'temperature': 18,
                  'wind': {'speed': 4.0, 'angle': 90},
                },
                {
                  'date': '2026-03-08T02:00:00',
                  'temperature': 19,
                  'wind': {'speed': 4.5, 'angle': 95},
                },
              ],
            },
          };
        },
      );

      final result = await adapter.getForecast(
        spot: _spot(name: 'Denia', area: 'Alicante'),
        provider: 'Meteosource',
        model: 'Hourly',
      );

      expect(result, hasLength(1));
      expect(result.single.windKnots, 9);
      expect(result.single.airTempC, 19);
    });
  });
}
