import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/config/env/local_env_store.dart';
import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_forecast_port.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class MeteosourceSpotsForecastAdapter implements SpotsForecastPort {
  MeteosourceSpotsForecastAdapter({
    HttpClient? httpClient,
    String? apiKey,
    Future<Map<String, dynamic>> Function(String url)? fetchJson,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient ?? HttpClient(),
       _apiKeyOverride = apiKey,
       _fetchJsonOverride = fetchJson,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  final HttpClient _httpClient;
  final String? _apiKeyOverride;
  final Future<Map<String, dynamic>> Function(String url)? _fetchJsonOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  @override
  Future<List<SpotForecastEntry>> getForecast({
    required SpotItem spot,
    required String provider,
    required String model,
  }) async {
    final apiKey = await _resolveApiKey();
    if (provider != 'Meteosource' ||
        (apiKey.isEmpty && _forecastProxyClient == null)) {
      return const <SpotForecastEntry>[];
    }

    final location = _resolveLocation(spot: spot);
    final json = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchMeteosourcePointForecast(
            latitude: location.lat,
            longitude: location.lon,
            sections: 'hourly',
          )
        : await _fetchJson(_forecastUrl(location, apiKey));
    final hourly = json['hourly'];
    if (hourly is! Map<String, dynamic>) {
      return const <SpotForecastEntry>[];
    }
    final data = hourly['data'];
    if (data is! List) {
      return const <SpotForecastEntry>[];
    }

    final results = <SpotForecastEntry>[];
    for (final item in data) {
      if (item is! Map<String, dynamic>) {
        continue;
      }
      final parsedTime = _parseTime(item['date']);
      final wind = item['wind'];
      final cloudCover = item['cloud_cover'];
      final precipitation = item['precipitation'];
      final temperature = _asNum(item['temperature']);
      final windSpeed = wind is Map<String, dynamic>
          ? _asNum(wind['speed'])
          : null;
      final windGusts = wind is Map<String, dynamic>
          ? _asNum(wind['gusts'])
          : null;
      final windAngle = wind is Map<String, dynamic>
          ? _asNum(wind['angle'])
          : null;

      if (parsedTime == null ||
          temperature == null ||
          windSpeed == null ||
          windAngle == null) {
        continue;
      }

      results.add(
        SpotForecastEntry(
          time: parsedTime,
          windKnots: _metersPerSecondToKnots(windSpeed.toDouble()).round(),
          gustKnots: windGusts == null
              ? null
              : _metersPerSecondToKnots(windGusts.toDouble()).round(),
          windDeg: windAngle.round(),
          airTempC: temperature.round(),
          pressureHpa: _asNum(item['pressure'])?.round(),
          cloudCoverPct: cloudCover is Map<String, dynamic>
              ? _asNum(cloudCover['total'])?.round()
              : null,
          rainMm: precipitation is Map<String, dynamic>
              ? _asNum(precipitation['total'])?.toDouble()
              : null,
        ),
      );
    }

    return results;
  }

  ({double lat, double lon}) _resolveLocation({required SpotItem spot}) {
    if (spot.latitude != null && spot.longitude != null) {
      return (lat: spot.latitude!, lon: spot.longitude!);
    }
    if (spot.area.toLowerCase().contains('denia')) {
      return (lat: 38.8404, lon: 0.1057);
    }
    if (spot.area.toLowerCase().contains('valencia')) {
      return (lat: 39.2763, lon: -0.2758);
    }
    return (lat: 38.9196, lon: -0.1192);
  }

  String _forecastUrl(({double lat, double lon}) location, String apiKey) {
    return 'https://www.meteosource.com/api/v1/free/point?lat=${location.lat}&lon=${location.lon}&sections=hourly&timezone=UTC&language=en&units=metric&key=$apiKey';
  }

  Future<String> _resolveApiKey() async {
    final override = _apiKeyOverride;
    if (override != null) {
      return override;
    }

    var resolved = EnvConfig.meteosourceApiKey;
    if (resolved.isNotEmpty) {
      return resolved;
    }

    await LocalEnvStore.initialize();
    resolved = EnvConfig.meteosourceApiKey;
    return resolved;
  }

  DateTime? _parseTime(dynamic source) {
    if (source is! String || source.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(source);
    } catch (_) {
      return null;
    }
  }

  num? _asNum(dynamic source) => source is num ? source : null;

  double _metersPerSecondToKnots(double value) => value * 1.94384;

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    final fetchJsonOverride = _fetchJsonOverride;
    if (fetchJsonOverride != null) {
      return fetchJsonOverride(url);
    }
    final request = await _httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Forecast request failed: ${response.statusCode} ${body.length > 240 ? body.substring(0, 240) : body}',
        uri: Uri.parse(url),
      );
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }
}
