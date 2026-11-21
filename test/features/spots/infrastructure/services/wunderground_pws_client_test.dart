import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/wunderground_api_key.dart';
import 'package:windwisher/features/spots/infrastructure/services/wunderground_pws_client.dart';

void main() {
  final cases =
      jsonDecode(
            File(
              'test/fixtures/wunderground_api_key_cases.json',
            ).readAsStringSync(),
          )
          as List;
  for (final item in cases.cast<Map<String, dynamic>>()) {
    test('key extraction: ${item['name']}', () {
      expect(
        extractWundergroundApiKey(item['html'] as String),
        item['expected'],
      );
    });
  }

  const observation =
      '{"observations":[{"stationID":"SYNTHETIC","obsTimeUtc":"2026-11-21T08:00:00Z","metric":{"windSpeed":18.52,"windGust":37.04,"windspeedAvg":18.52,"windgustHigh":37.04},"winddir":90,"winddirAvg":90}]}';
  test('explicit key bypasses dashboard and is not overwritten', () async {
    final client = WundergroundPwsClient(
      apiKey: '  ownWeatherKey123  ',
      fetchText: (uri) async {
        expect(uri.host, 'api.weather.com');
        expect(uri.queryParameters['apiKey'], 'ownWeatherKey123');
        return observation;
      },
    );
    final snapshot = await client.fetchCurrent(stationId: 'SYNTHETIC');
    expect(snapshot?.windKnots, closeTo(10, .001));
  });
  test('extracts weather configuration and caches it for history', () async {
    var dashboards = 0;
    final client = WundergroundPwsClient(
      apiKey: '',
      fetchText: (uri) async {
        if (uri.host == 'www.wunderground.com') {
          dashboards++;
          return 'https://weather.com/ads?apiKey=adKey123; const data = {"API_KEY":"weatherKey123","API_URL":"https://api.weather.com"};';
        }
        expect(uri.queryParameters['apiKey'], 'weatherKey123');
        return observation;
      },
    );
    expect(
      (await client.fetchCurrent(stationId: 'SYNTHETIC'))?.windKnots,
      closeTo(10, .001),
    );
    expect(
      await client.fetchOneDayHistory(stationId: 'SYNTHETIC'),
      hasLength(1),
    );
    expect(dashboards, 1);
  });
  test('ad-only dashboard never sends a weather API request', () async {
    final client = WundergroundPwsClient(
      apiKey: '',
      fetchText: (uri) async {
        expect(uri.host, 'www.wunderground.com');
        return 'https://weather.com/api/v1/mew/entity/ad_config?apiKey=adKey123';
      },
    );
    await expectLater(
      client.fetchCurrent(stationId: 'SYNTHETIC'),
      throwsFormatException,
    );
  });
  test(
    'empty observation payload remains no data, including history',
    () async {
      final client = WundergroundPwsClient(
        apiKey: 'ownWeatherKey123',
        fetchText: (_) async => '{}',
      );
      expect(await client.fetchCurrent(stationId: 'SYNTHETIC'), isNull);
      expect(await client.fetchOneDayHistory(stationId: 'SYNTHETIC'), isEmpty);
    },
  );
  test(
    'configured key failure does not silently fall back to another key',
    () async {
      var requests = 0;
      final client = WundergroundPwsClient(
        apiKey: 'ownWeatherKey123',
        fetchText: (uri) async {
          requests++;
          expect(uri.host, 'api.weather.com');
          throw const HttpException('upstream-http-401');
        },
      );
      await expectLater(
        client.fetchCurrent(stationId: 'SYNTHETIC'),
        throwsA(isA<HttpException>()),
      );
      expect(requests, 1);
    },
  );
}
