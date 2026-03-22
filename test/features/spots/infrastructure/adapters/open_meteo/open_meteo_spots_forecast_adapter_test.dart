import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/open_meteo/open_meteo_spots_forecast_adapter.dart';

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
    createdAt: DateTime(2026, 3, 7),
    latitude: latitude,
    longitude: longitude,
  );
}

void main() {
  group('OpenMeteoSpotsForecastAdapter', () {
    test('maps Open-Meteo forecast for Oliva Puerto', () async {
      final requestedUrls = <String>[];
      final adapter = OpenMeteoSpotsForecastAdapter(
        fetchJson: (url) async {
          requestedUrls.add(url);
          if (url.contains('marine-api.open-meteo.com')) {
            return {
              'hourly': {
                'time': ['2026-03-07T00:00', '2026-03-07T03:00'],
                'sea_surface_temperature': [17.8, 18.2],
                'wave_height': [0.7, 0.9],
              },
            };
          }

          return {
            'hourly': {
              'time': [
                '2026-03-07T00:00',
                '2026-03-07T01:00',
                '2026-03-07T02:00',
                '2026-03-07T03:00',
              ],
              'wind_speed_10m': [18.52, 20.0, 21.0, 22.224],
              'wind_gusts_10m': [27.78, 28.0, 29.0, 33.336],
              'wind_direction_10m': [90, 95, 100, 105],
              'temperature_2m': [19, 20, 20, 21],
              'pressure_msl': [1014, 1013, 1013, 1012],
              'cloud_cover': [12, 20, 24, 35],
              'precipitation': [0.0, 0.1, 0.1, 0.2],
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
        provider: 'Open-Meteo',
        model: 'GFS',
      );

      expect(result, hasLength(2));
      expect(result.first.windKnots, 10);
      expect(result.first.waterTempC, 18);
      expect(result.last.gustKnots, 18);
      expect(result.last.rainMm, 0.2);
      expect(requestedUrls.first, contains('latitude=38.9348'));
      expect(requestedUrls.first, contains('longitude=-0.0986'));
    });

    test(
      'maps Open-Meteo Best match model to default provider selection',
      () async {
        final requestedUrls = <String>[];
        final adapter = OpenMeteoSpotsForecastAdapter(
          fetchJson: (url) async {
            requestedUrls.add(url);
            if (url.contains('marine-api.open-meteo.com')) {
              return {
                'hourly': {
                  'time': ['2026-03-07T00:00'],
                  'sea_surface_temperature': [17.8],
                  'wave_height': [0.7],
                },
              };
            }

            return {
              'hourly': {
                'time': ['2026-03-07T00:00'],
                'wind_speed_10m': [18.52],
                'wind_gusts_10m': [27.78],
                'wind_direction_10m': [90],
                'temperature_2m': [19],
                'pressure_msl': [1014],
                'cloud_cover': [12],
                'precipitation': [0.0],
              },
            };
          },
        );

        await adapter.getForecast(
          spot: _spot(
            name: 'Oliva Puerto',
            area: 'Valencia',
            latitude: 38.9348,
            longitude: -0.0986,
          ),
          provider: 'Open-Meteo',
          model: 'Best match',
        );

        expect(requestedUrls.first, isNot(contains('models=')));
      },
    );

    test('maps Open-Meteo model variants correctly', () async {
      final requestedUrls = <String>[];
      final adapter = OpenMeteoSpotsForecastAdapter(
        fetchJson: (url) async {
          requestedUrls.add(url);
          if (url.contains('marine-api.open-meteo.com')) {
            return {
              'hourly': {
                'time': ['2026-03-07T00:00'],
                'sea_surface_temperature': [17.8],
                'wave_height': [0.7],
              },
            };
          }

          return {
            'hourly': {
              'time': ['2026-03-07T00:00'],
              'wind_speed_10m': [18.52],
              'wind_gusts_10m': [27.78],
              'wind_direction_10m': [90],
              'temperature_2m': [19],
              'pressure_msl': [1014],
              'cloud_cover': [12],
              'precipitation': [0.0],
            },
          };
        },
      );

      await adapter.getForecast(
        spot: _spot(
          name: 'Oliva Puerto',
          area: 'Valencia',
          latitude: 38.9348,
          longitude: -0.0986,
        ),
        provider: 'Open-Meteo',
        model: 'AROME France',
      );
      await adapter.getForecast(
        spot: _spot(
          name: 'Oliva Puerto',
          area: 'Valencia',
          latitude: 38.9348,
          longitude: -0.0986,
        ),
        provider: 'Open-Meteo',
        model: 'AROME Seamless',
      );
      await adapter.getForecast(
        spot: _spot(
          name: 'Oliva Puerto',
          area: 'Valencia',
          latitude: 38.9348,
          longitude: -0.0986,
        ),
        provider: 'Open-Meteo',
        model: 'ARPEGE Europe',
      );
      await adapter.getForecast(
        spot: _spot(
          name: 'Oliva Puerto',
          area: 'Valencia',
          latitude: 38.9348,
          longitude: -0.0986,
        ),
        provider: 'Open-Meteo',
        model: 'ARPEGE Seamless',
      );
      await adapter.getForecast(
        spot: _spot(
          name: 'Oliva Puerto',
          area: 'Valencia',
          latitude: 38.9348,
          longitude: -0.0986,
        ),
        provider: 'Open-Meteo',
        model: 'ARPEGE World',
      );

      expect(requestedUrls[0], contains('models=meteofrance_arome_france'));
      expect(requestedUrls[2], contains('models=meteofrance_arome_seamless'));
      expect(requestedUrls[4], contains('models=meteofrance_arpege_europe'));
      expect(requestedUrls[6], contains('models=meteofrance_seamless'));
      expect(requestedUrls[8], contains('models=meteofrance_arpege_world'));
    });

    test(
      'skips Open-Meteo slots with null values instead of crashing',
      () async {
        final adapter = OpenMeteoSpotsForecastAdapter(
          fetchJson: (url) async {
            if (url.contains('marine-api.open-meteo.com')) {
              return {
                'hourly': {
                  'time': ['2026-03-07T00:00', '2026-03-07T03:00'],
                  'sea_surface_temperature': [null, 18.2],
                  'wave_height': [0.7, 0.9],
                },
              };
            }

            return {
              'hourly': {
                'time': [
                  '2026-03-07T00:00',
                  '2026-03-07T01:00',
                  '2026-03-07T02:00',
                  '2026-03-07T03:00',
                ],
                'wind_speed_10m': [18.52, 20.0, 21.0, 22.224],
                'wind_gusts_10m': [27.78, 28.0, 29.0, 33.336],
                'wind_direction_10m': [90, 95, 100, 105],
                'temperature_2m': [19, 20, 20, 21],
                'pressure_msl': [1014, 1013, 1013, 1012],
                'cloud_cover': [12, 20, 24, 35],
                'precipitation': [0.0, 0.1, 0.1, 0.2],
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
          provider: 'Open-Meteo',
          model: 'GFS',
        );

        expect(result, hasLength(1));
        expect(result.first.time, DateTime.parse('2026-03-07T03:00'));
      },
    );
  });
}
