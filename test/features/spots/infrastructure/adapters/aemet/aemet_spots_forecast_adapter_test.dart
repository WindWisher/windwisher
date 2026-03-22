import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/aemet/aemet_spots_forecast_adapter.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/local/local_file_spots_forecast_cache_store.dart';

SpotItem _spot({
  required String name,
  required String area,
  String? aemetMunicipalityCode,
}) {
  return SpotItem(
    name: name,
    area: area,
    isCustom: false,
    createdAt: DateTime(2026, 3, 7),
    aemetMunicipalityCode: aemetMunicipalityCode,
  );
}

void main() {
  group('AemetSpotsForecastAdapter', () {
    test(
      'maps AEMET forecast for Oliva Puerto using municipality alias',
      () async {
        final requestedUrls = <String>[];
        final adapter = AemetSpotsForecastAdapter(
          apiKey: 'test-key',
          cacheStore: _MemoryForecastCacheStore(),
          fetchJson: (url) async {
            requestedUrls.add(url);
            return {'datos': 'https://mock.aemet.local/data.json'};
          },
          fetchJsonList: (url) async {
            requestedUrls.add(url);
            return [
              {
                'prediccion': {
                  'dia': [
                    {
                      'fecha': '2026-03-07T00:00:00',
                      'temperatura': [
                        {'periodo': '0', 'value': '18'},
                        {'periodo': '3', 'value': '19'},
                      ],
                      'precipitacion': [
                        {'periodo': '0', 'value': '0'},
                        {'periodo': '3', 'value': '0.4'},
                      ],
                      'estadoCielo': [
                        {'periodo': '0', 'descripcion': 'Despejado'},
                        {'periodo': '3', 'descripcion': 'Intervalos nubosos'},
                      ],
                      'vientoAndRachaMax': [
                        {
                          'periodo': '0',
                          'velocidad': ['20'],
                          'direccion': ['E'],
                        },
                        {'value': '30'},
                        {
                          'periodo': '3',
                          'velocidad': ['24'],
                          'direccion': ['SE'],
                        },
                        {'value': '36'},
                      ],
                    },
                  ],
                },
              },
            ];
          },
        );

        final result = await adapter.getForecast(
          spot: _spot(
            name: 'Oliva Puerto',
            area: 'Valencia',
            aemetMunicipalityCode: '46181',
          ),
          provider: 'AEMET',
          model: 'Prediccion municipal',
        );

        expect(result, hasLength(2));
        expect(
          requestedUrls.first,
          contains('/municipio/horaria/46181/?api_key=test-key'),
        );
        expect(requestedUrls.last, 'https://mock.aemet.local/data.json');
        expect(result.first.windKnots, 11);
        expect(result.first.gustKnots, 16);
        expect(result.first.windDeg, 90);
        expect(result.first.cloudCoverPct, 0);
        expect(result.first.waterTempC, isNull);
        expect(result.first.pressureHpa, isNull);
        expect(result.first.waveM, isNull);
        expect(result.last.windKnots, 13);
        expect(result.last.gustKnots, 19);
        expect(result.last.windDeg, 135);
        expect(result.last.rainMm, 0.4);
      },
    );

    test('returns empty AEMET forecast when api key is missing', () async {
      final adapter = AemetSpotsForecastAdapter(
        apiKey: '',
        cacheStore: _MemoryForecastCacheStore(),
      );

      final result = await adapter.getForecast(
        spot: _spot(name: 'Oliva Puerto', area: 'Valencia'),
        provider: 'AEMET',
        model: 'Prediccion municipal',
      );

      expect(result, isEmpty);
    });

    test('reuses cached AEMET forecast while cache is fresh', () async {
      var indexCalls = 0;
      var dataCalls = 0;
      final adapter = AemetSpotsForecastAdapter(
        apiKey: 'test-key',
        cacheStore: _MemoryForecastCacheStore(),
        fetchJson: (url) async {
          indexCalls++;
          return {'datos': 'https://mock.aemet.local/data.json'};
        },
        fetchJsonList: (url) async {
          dataCalls++;
          return [
            {
              'prediccion': {
                'dia': [
                  {
                    'fecha': '2026-03-07T00:00:00',
                    'temperatura': [
                      {'periodo': '0', 'value': '18'},
                    ],
                    'precipitacion': [
                      {'periodo': '0', 'value': '0'},
                    ],
                    'estadoCielo': [
                      {'periodo': '0', 'descripcion': 'Despejado'},
                    ],
                    'vientoAndRachaMax': [
                      {
                        'periodo': '0',
                        'velocidad': ['20'],
                        'direccion': ['E'],
                      },
                      {'value': '30'},
                    ],
                  },
                ],
              },
            },
          ];
        },
      );

      final first = await adapter.getForecast(
        spot: _spot(
          name: 'Piles',
          area: 'Valencia',
          aemetMunicipalityCode: '46197',
        ),
        provider: 'AEMET',
        model: 'Prediccion municipal',
      );
      final second = await adapter.getForecast(
        spot: _spot(
          name: 'Piles',
          area: 'Valencia',
          aemetMunicipalityCode: '46197',
        ),
        provider: 'AEMET',
        model: 'Prediccion municipal',
      );

      expect(first, isNotEmpty);
      expect(second, isNotEmpty);
      expect(indexCalls, 1);
      expect(dataCalls, 1);
    });

    test('uses persisted stale AEMET cache when rate limited', () async {
      final cacheStore = _MemoryForecastCacheStore(
        seed: {
          'AEMET|cullera|valencia': _CacheSnapshot(
            createdAt: DateTime.now().subtract(const Duration(hours: 12)),
            entries: [
              SpotForecastEntry(
                time: DateTime(2026, 3, 7),
                windKnots: 9,
                gustKnots: 14,
                windDeg: 90,
                airTempC: 18,
                waterTempC: 17,
                pressureHpa: 1014,
                cloudCoverPct: 30,
                waveM: 0.8,
                rainMm: 0,
              ),
            ],
          ),
        },
      );

      final adapter = AemetSpotsForecastAdapter(
        apiKey: 'test-key',
        cacheStore: cacheStore,
        fetchJson: (url) async {
          throw HttpException('Forecast request failed: 429');
        },
      );

      final result = await adapter.getForecast(
        spot: _spot(
          name: 'Cullera',
          area: 'Valencia',
          aemetMunicipalityCode: '46105',
        ),
        provider: 'AEMET',
        model: 'Prediccion municipal',
      );

      expect(result, hasLength(1));
      expect(result.first.windKnots, 9);
    });
  });
}

class _MemoryForecastCacheStore implements SpotsForecastCacheStore {
  _MemoryForecastCacheStore({Map<String, _CacheSnapshot>? seed})
    : _entries = seed ?? <String, _CacheSnapshot>{};

  final Map<String, _CacheSnapshot> _entries;

  @override
  List<SpotForecastEntry>? read({
    required String key,
    required Duration maxAge,
  }) {
    final snapshot = _entries[key];
    if (snapshot == null) {
      return null;
    }
    if (DateTime.now().difference(snapshot.createdAt) > maxAge) {
      return null;
    }
    return List<SpotForecastEntry>.from(snapshot.entries);
  }

  @override
  void write({required String key, required List<SpotForecastEntry> entries}) {
    _entries[key] = _CacheSnapshot(
      createdAt: DateTime.now(),
      entries: List<SpotForecastEntry>.from(entries),
    );
  }
}

class _CacheSnapshot {
  const _CacheSnapshot({required this.createdAt, required this.entries});

  final DateTime createdAt;
  final List<SpotForecastEntry> entries;
}
