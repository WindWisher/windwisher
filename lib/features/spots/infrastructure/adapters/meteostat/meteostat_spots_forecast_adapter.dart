import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/config/env/local_env_store.dart';
import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_forecast_port.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class MeteostatSpotsForecastAdapter implements SpotsForecastPort {
  MeteostatSpotsForecastAdapter({
    HttpClient? httpClient,
    String? rapidApiKey,
    String? rapidApiHost,
    Future<Map<String, dynamic>> Function(String url)? fetchJson,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient,
       _rapidApiKeyOverride = rapidApiKey,
       _rapidApiHostOverride = rapidApiHost,
       _fetchJsonOverride = fetchJson,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  final HttpClient? _httpClient;
  final String? _rapidApiKeyOverride;
  final String? _rapidApiHostOverride;
  final Future<Map<String, dynamic>> Function(String url)? _fetchJsonOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  @override
  Future<List<SpotForecastEntry>> getForecast({
    required SpotItem spot,
    required String provider,
    required String model,
  }) async {
    if (provider != 'Meteostat' || model != 'Hourly') {
      return const <SpotForecastEntry>[];
    }

    final proxyClient = _forecastProxyClient;
    final rapidApiKey = proxyClient == null ? await _resolveRapidApiKey() : '';
    final rapidApiHost = proxyClient == null
        ? await _resolveRapidApiHost()
        : '';
    if (proxyClient == null && (rapidApiKey.isEmpty || rapidApiHost.isEmpty)) {
      return const <SpotForecastEntry>[];
    }

    final location = _resolveLocation(spot: spot);
    final range = _buildDateRange();
    final json = proxyClient != null
        ? await proxyClient.fetchMeteostatPointHourly(
            latitude: location.lat,
            longitude: location.lon,
            startDate: range.startDate,
            endDate: range.endDate,
          )
        : await _fetchJson(_buildUrl(location), rapidApiKey, rapidApiHost);
    final data = json['data'];
    if (data is! List) {
      return const <SpotForecastEntry>[];
    }

    final nowUtc = DateTime.now().toUtc();
    final startHourUtc = DateTime.utc(
      nowUtc.year,
      nowUtc.month,
      nowUtc.day,
      nowUtc.hour,
    );

    return data
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final time = _parseDateTime(item['time']);
          final windSpeed = _asNum(item['wspd']);
          final windGust = _asNum(item['wpgt']);
          final windDirection = _asNum(item['wdir']);
          final airTemp = _asNum(item['temp']);

          if (time == null ||
              time.isBefore(startHourUtc) ||
              windSpeed == null ||
              windDirection == null ||
              airTemp == null) {
            return null;
          }

          return SpotForecastEntry(
            time: time,
            windKnots: _kmhToKnots(windSpeed.toDouble()).round(),
            gustKnots: windGust == null
                ? null
                : _kmhToKnots(windGust.toDouble()).round(),
            windDeg: windDirection.round(),
            airTempC: airTemp.round(),
            pressureHpa: _asNum(item['pres'])?.round(),
            cloudCoverPct: null,
            rainMm: _asNum(item['prcp'])?.toDouble(),
          );
        })
        .whereType<SpotForecastEntry>()
        .toList(growable: false);
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

  String _buildUrl(({double lat, double lon}) location) {
    final range = _buildDateRange();
    return 'https://meteostat.p.rapidapi.com/point/hourly?lat=${location.lat}&lon=${location.lon}&start=${range.startDate}&end=${range.endDate}&tz=UTC&units=metric&model=true';
  }

  ({String startDate, String endDate}) _buildDateRange() {
    final nowUtc = DateTime.now().toUtc();
    final start = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);
    final end = start.add(const Duration(days: 7));
    return (startDate: _formatDate(start), endDate: _formatDate(end));
  }

  Future<String> _resolveRapidApiKey() async {
    final override = _rapidApiKeyOverride;
    if (override != null) {
      return override;
    }

    var resolved = EnvConfig.meteostatRapidApiKey;
    if (resolved.isNotEmpty) {
      return resolved;
    }

    await LocalEnvStore.initialize();
    resolved = EnvConfig.meteostatRapidApiKey;
    return resolved;
  }

  Future<String> _resolveRapidApiHost() async {
    final override = _rapidApiHostOverride;
    if (override != null && override.isNotEmpty) {
      return override;
    }

    var resolved = EnvConfig.meteostatRapidApiHost;
    if (resolved.isNotEmpty) {
      return resolved;
    }

    await LocalEnvStore.initialize();
    resolved = EnvConfig.meteostatRapidApiHost;
    return resolved;
  }

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime? _parseDateTime(dynamic source) {
    if (source is! String || source.isEmpty) {
      return null;
    }
    try {
      final parsed = DateTime.parse(source.replaceFirst(' ', 'T'));
      if (parsed.isUtc) {
        return parsed;
      }
      return DateTime.utc(
        parsed.year,
        parsed.month,
        parsed.day,
        parsed.hour,
        parsed.minute,
        parsed.second,
        parsed.millisecond,
        parsed.microsecond,
      );
    } catch (_) {
      return null;
    }
  }

  num? _asNum(dynamic source) => source is num ? source : null;

  double _kmhToKnots(double kmh) => kmh / 1.852;

  Future<Map<String, dynamic>> _fetchJson(
    String url,
    String rapidApiKey,
    String rapidApiHost,
  ) async {
    final fetchJsonOverride = _fetchJsonOverride;
    if (fetchJsonOverride != null) {
      return fetchJsonOverride(url);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Meteostat direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();

    final request = await httpClient.getUrl(Uri.parse(url));
    request.headers.set('x-rapidapi-host', rapidApiHost);
    request.headers.set('x-rapidapi-key', rapidApiKey);
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
