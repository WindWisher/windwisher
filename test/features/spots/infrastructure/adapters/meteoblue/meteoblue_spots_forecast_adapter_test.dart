import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/meteoblue/meteoblue_spots_forecast_adapter.dart';

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
  group('MeteoblueSpotsForecastAdapter', () {
    test('maps Meteoblue 15min + sea hourly payload into spot entries', () async {
      final requestedUrls = <String>[];
      final adapter = MeteoblueSpotsForecastAdapter(
        apiKey: 'test-key',
        fetchJson: (url) async {
          requestedUrls.add(url);
          return {
            'metadata': {'name': 'Oliva Puerto'},
            'data_xmin': {
              'time': [
                '2026-03-08 00:00',
                '2026-03-08 00:15',
                '2026-03-08 00:30',
                '2026-03-08 00:45',
                '2026-03-08 01:00',
                '2026-03-08 01:15',
                '2026-03-08 01:30',
                '2026-03-08 01:45',
                '2026-03-08 02:00',
                '2026-03-08 02:15',
                '2026-03-08 02:30',
                '2026-03-08 02:45',
                '2026-03-08 03:00',
              ],
              'windspeed': [14, 14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 18],
              'gust': [18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20, 20, 24],
              'winddirection': [
                95,
                95,
                95,
                95,
                100,
                100,
                100,
                100,
                105,
                105,
                105,
                105,
                110,
              ],
              'temperature': [
                18,
                18,
                18,
                18,
                18,
                18,
                18,
                18,
                19,
                19,
                19,
                19,
                20,
              ],
              'sealevelpressure': [
                1015,
                1015,
                1015,
                1015,
                1014,
                1014,
                1014,
                1014,
                1014,
                1014,
                1014,
                1014,
                1013,
              ],
              'totalcloudcover': [
                10,
                10,
                10,
                10,
                15,
                15,
                15,
                15,
                20,
                20,
                20,
                20,
                30,
              ],
              'precipitation': [
                0.0,
                0.0,
                0.0,
                0.0,
                0.1,
                0.1,
                0.1,
                0.1,
                0.1,
                0.1,
                0.1,
                0.1,
                0.3,
              ],
            },
            'data_1h': {
              'time': ['2026-03-08 00:00', '2026-03-08 03:00'],
              'seasurfacetemperature': [17.5, 17.9],
              'surfwave_height': [0.7, 1.0],
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
        provider: 'Meteoblue',
        model: 'Basic',
      );

      expect(result, hasLength(13));
      expect(result.first.windKnots, 14);
      expect(result.first.gustKnots, 18);
      expect(result.first.windDeg, 95);
      expect(result.first.cloudCoverPct, 10);
      expect(result.first.waterTempC, 18);
      expect(result.first.waveM, 0.7);
      expect(result[1].waterTempC, isNull);
      expect(result[1].waveM, isNull);
      expect(result.last.rainMm, 0.3);
      expect(
        requestedUrls.single,
        contains(
          'basic-15min_basic-day_current_clouds-15min_sea-1h_air-15min_wind-1h',
        ),
      );
      expect(requestedUrls.single, contains('apikey=test-key'));
      expect(requestedUrls.single, contains('lat=38.9348'));
      expect(requestedUrls.single, contains('lon=-0.0986'));
    });

    test('returns empty result when Meteoblue api key is missing', () async {
      final adapter = MeteoblueSpotsForecastAdapter(apiKey: '');

      final result = await adapter.getForecast(
        spot: _spot(name: 'Oliva Puerto', area: 'Valencia'),
        provider: 'Meteoblue',
        model: 'Basic',
      );

      expect(result, isEmpty);
    });

    test('supports top-level hourly payload without data_1h wrapper', () async {
      final adapter = MeteoblueSpotsForecastAdapter(
        apiKey: 'test-key',
        fetchJson: (url) async {
          return {
            'time': [
              '2026-03-08 00:00',
              '2026-03-08 01:00',
              '2026-03-08 02:00',
              '2026-03-08 03:00',
            ],
            'windspeed': [12, 13, 14, 15],
            'gust': [16, 17, 18, 19],
            'winddirection': [90, 100, 110, 120],
            'temperature': [19, 19, 20, 20],
            'precipitation': [0.0, 0.0, 0.0, 0.0],
          };
        },
      );

      final result = await adapter.getForecast(
        spot: _spot(name: 'Denia', area: 'Alicante'),
        provider: 'Meteoblue',
        model: 'Basic',
      );

      expect(result, hasLength(4));
      expect(result.first.pressureHpa, isNull);
      expect(result.first.waveM, isNull);
    });

    test(
      'keeps hourly gust only on exact hourly timestamps when 15min gust is absent',
      () async {
        final adapter = MeteoblueSpotsForecastAdapter(
          apiKey: 'test-key',
          fetchJson: (url) async {
            return {
              'data_xmin': {
                'time': [
                  '2026-03-08 00:00',
                  '2026-03-08 00:15',
                  '2026-03-08 00:30',
                  '2026-03-08 00:45',
                  '2026-03-08 01:00',
                  '2026-03-08 01:15',
                  '2026-03-08 01:30',
                  '2026-03-08 01:45',
                  '2026-03-08 02:00',
                  '2026-03-08 02:15',
                  '2026-03-08 02:30',
                  '2026-03-08 02:45',
                  '2026-03-08 03:00',
                ],
                'windspeed': [
                  14,
                  14,
                  14,
                  14,
                  15,
                  15,
                  15,
                  15,
                  16,
                  16,
                  16,
                  16,
                  18,
                ],
                'winddirection': [
                  95,
                  95,
                  95,
                  95,
                  100,
                  100,
                  100,
                  100,
                  105,
                  105,
                  105,
                  105,
                  110,
                ],
                'temperature': [
                  18,
                  18,
                  18,
                  18,
                  18,
                  18,
                  18,
                  18,
                  19,
                  19,
                  19,
                  19,
                  20,
                ],
                'precipitation': [
                  0.0,
                  0.0,
                  0.0,
                  0.0,
                  0.0,
                  0.0,
                  0.0,
                  0.0,
                  0.0,
                  0.0,
                  0.0,
                  0.0,
                  0.2,
                ],
              },
              'data_1h': {
                'time': ['2026-03-08 00:00', '2026-03-08 03:00'],
                'gust': [20, 26],
              },
            };
          },
        );

        final result = await adapter.getForecast(
          spot: _spot(name: 'Oliva Puerto', area: 'Valencia'),
          provider: 'Meteoblue',
          model: 'Basic',
        );

        expect(result, hasLength(13));
        expect(result.first.gustKnots, 20);
        expect(result[1].gustKnots, isNull);
        expect(result.last.gustKnots, 26);
      },
    );
  });
}
