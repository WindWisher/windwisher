import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/meteostat/meteostat_spots_forecast_adapter.dart';

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

String _timePlusHoursUtc(int deltaHours) {
  final now = DateTime.now().toUtc();
  final value = DateTime.utc(
    now.year,
    now.month,
    now.day,
    now.hour,
  ).add(Duration(hours: deltaHours));
  String two(int input) => input.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:00:00';
}

String _dateOnlyUtcPlusDays(int deltaDays) {
  final now = DateTime.now().toUtc();
  final value = DateTime.utc(
    now.year,
    now.month,
    now.day,
  ).add(Duration(days: deltaDays));
  String two(int input) => input.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
}

void main() {
  group('MeteostatSpotsForecastAdapter', () {
    test('maps Meteostat hourly payload into spot entries', () async {
      final requestedUrls = <String>[];
      final adapter = MeteostatSpotsForecastAdapter(
        rapidApiKey: 'test-key',
        rapidApiHost: 'meteostat.p.rapidapi.com',
        fetchJson: (url) async {
          requestedUrls.add(url);
          return {
            'meta': {'generated': '2026-03-08 16:07:45'},
            'data': [
              {
                'time': _timePlusHoursUtc(1),
                'temp': 15.2,
                'prcp': 0.4,
                'wdir': 112,
                'wspd': 18.5,
                'wpgt': 26.0,
                'pres': 1016.4,
              },
              {
                'time': _timePlusHoursUtc(2),
                'temp': 14.8,
                'prcp': 0.0,
                'wdir': 118,
                'wspd': 20.4,
                'wpgt': 29.6,
                'pres': 1015.8,
              },
            ],
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
        provider: 'Meteostat',
        model: 'Hourly',
      );

      expect(result, hasLength(2));
      expect(result.first.windKnots, 10);
      expect(result.first.gustKnots, 14);
      expect(result.first.windDeg, 112);
      expect(result.first.airTempC, 15);
      expect(result.first.pressureHpa, 1016);
      expect(result.first.rainMm, 0.4);
      expect(result.first.waterTempC, isNull);
      expect(result.first.waveM, isNull);
      expect(requestedUrls.single, contains('/point/hourly'));
      expect(requestedUrls.single, contains('lat=38.9348'));
      expect(requestedUrls.single, contains('lon=-0.0986'));
      expect(
        requestedUrls.single,
        contains('start=${_dateOnlyUtcPlusDays(0)}'),
      );
      expect(requestedUrls.single, contains('end=${_dateOnlyUtcPlusDays(7)}'));
      expect(requestedUrls.single, contains('tz=UTC'));
      expect(requestedUrls.single, contains('units=metric'));
    });

    test('returns empty result when Meteostat key is missing', () async {
      final adapter = MeteostatSpotsForecastAdapter(rapidApiKey: '');

      final result = await adapter.getForecast(
        spot: _spot(name: 'Oliva Puerto', area: 'Valencia'),
        provider: 'Meteostat',
        model: 'Hourly',
      );

      expect(result, isEmpty);
    });

    test('skips malformed or already past records', () async {
      final adapter = MeteostatSpotsForecastAdapter(
        rapidApiKey: 'test-key',
        rapidApiHost: 'meteostat.p.rapidapi.com',
        fetchJson: (url) async {
          return {
            'data': [
              {'time': 'invalid-time', 'temp': 15.2, 'wdir': 112, 'wspd': 18.5},
              {
                'time': _timePlusHoursUtc(-2),
                'temp': 14.0,
                'wdir': 100,
                'wspd': 12.0,
              },
              {
                'time': _timePlusHoursUtc(1),
                'temp': 13.5,
                'wdir': 98,
                'wspd': 16.7,
              },
            ],
          };
        },
      );

      final result = await adapter.getForecast(
        spot: _spot(name: 'Denia', area: 'Alicante'),
        provider: 'Meteostat',
        model: 'Hourly',
      );

      expect(result, hasLength(1));
      expect(result.single.windKnots, 9);
      expect(result.single.airTempC, 14);
    });
  });
}
