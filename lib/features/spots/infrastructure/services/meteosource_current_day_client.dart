import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/config/env/local_env_store.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class MeteosourceCurrentDaySnapshot {
  const MeteosourceCurrentDaySnapshot({
    required this.current,
    required this.days,
  });

  final MeteosourceCurrentData? current;
  final List<MeteosourceDayData> days;
}

class MeteosourceCurrentData {
  const MeteosourceCurrentData({
    this.temperatureC,
    this.windKnots,
    this.windDeg,
    this.cloudCoverPct,
    this.rainMm,
    this.summary,
  });

  final double? temperatureC;
  final double? windKnots;
  final int? windDeg;
  final int? cloudCoverPct;
  final double? rainMm;
  final String? summary;
}

class MeteosourceDayData {
  const MeteosourceDayData({
    required this.date,
    this.tempMinC,
    this.tempMaxC,
    this.windMeanKnots,
    this.precipitationMm,
    this.summary,
  });

  final DateTime? date;
  final double? tempMinC;
  final double? tempMaxC;
  final double? windMeanKnots;
  final double? precipitationMm;
  final String? summary;
}

class MeteosourceCurrentDayClient {
  MeteosourceCurrentDayClient({
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

  Future<MeteosourceCurrentDaySnapshot> fetchSnapshot({
    required SpotItem spot,
  }) async {
    final apiKey = await _resolveApiKey();
    if (apiKey.isEmpty && _forecastProxyClient == null) {
      return const MeteosourceCurrentDaySnapshot(
        current: null,
        days: <MeteosourceDayData>[],
      );
    }

    final location = _resolveLocation(spot: spot);
    final json = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchMeteosourcePointForecast(
            latitude: location.lat,
            longitude: location.lon,
            sections: 'current,daily',
          )
        : await _fetchJson(_buildUrl(location, apiKey));
    return MeteosourceCurrentDaySnapshot(
      current: _parseCurrent(json['current']),
      days: _parseDays(json['daily']),
    );
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

  String _buildUrl(({double lat, double lon}) location, String apiKey) {
    return 'https://www.meteosource.com/api/v1/free/point?lat=${location.lat}&lon=${location.lon}&sections=current,daily&timezone=UTC&language=en&units=metric&key=$apiKey';
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

  MeteosourceCurrentData? _parseCurrent(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    final wind = source['wind'];
    final precipitation = source['precipitation'];
    return MeteosourceCurrentData(
      temperatureC: (source['temperature'] as num?)?.toDouble(),
      windKnots: wind is Map<String, dynamic>
          ? _metersPerSecondToKnots((wind['speed'] as num?)?.toDouble())
          : null,
      windDeg: wind is Map<String, dynamic>
          ? (wind['angle'] as num?)?.round()
          : null,
      cloudCoverPct: (source['cloud_cover'] as num?)?.round(),
      rainMm: precipitation is Map<String, dynamic>
          ? (precipitation['total'] as num?)?.toDouble()
          : null,
      summary: source['summary'] as String?,
    );
  }

  List<MeteosourceDayData> _parseDays(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return const <MeteosourceDayData>[];
    }
    final data = source['data'];
    if (data is! List) {
      return const <MeteosourceDayData>[];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final allDay = item['all_day'];
          final wind = allDay is Map<String, dynamic> ? allDay['wind'] : null;
          final precipitation = allDay is Map<String, dynamic>
              ? allDay['precipitation']
              : null;
          return MeteosourceDayData(
            date: _parseDate(item['day']),
            tempMinC: allDay is Map<String, dynamic>
                ? (allDay['temperature_min'] as num?)?.toDouble()
                : null,
            tempMaxC: allDay is Map<String, dynamic>
                ? (allDay['temperature_max'] as num?)?.toDouble()
                : null,
            windMeanKnots: wind is Map<String, dynamic>
                ? _metersPerSecondToKnots((wind['speed'] as num?)?.toDouble())
                : null,
            precipitationMm: precipitation is Map<String, dynamic>
                ? (precipitation['total'] as num?)?.toDouble()
                : null,
            summary: item['summary'] as String?,
          );
        })
        .toList(growable: false);
  }

  DateTime? _parseDate(dynamic source) {
    if (source is! String || source.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(source);
    } catch (_) {
      return null;
    }
  }

  double? _metersPerSecondToKnots(double? value) {
    if (value == null) {
      return null;
    }
    return value * 1.94384;
  }

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
