import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/config/env/local_env_store.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class MeteostatDaySnapshot {
  const MeteostatDaySnapshot({required this.days});

  final List<MeteostatDayData> days;
}

class MeteostatDayData {
  const MeteostatDayData({
    required this.date,
    this.tempAvgC,
    this.tempMinC,
    this.tempMaxC,
    this.windMeanKnots,
    this.gustKnots,
    this.pressureHpa,
    this.precipitationMm,
    this.sunshineMinutes,
  });

  final DateTime? date;
  final double? tempAvgC;
  final double? tempMinC;
  final double? tempMaxC;
  final double? windMeanKnots;
  final double? gustKnots;
  final double? pressureHpa;
  final double? precipitationMm;
  final int? sunshineMinutes;
}

class MeteostatDayClient {
  MeteostatDayClient({
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

  Future<MeteostatDaySnapshot> fetchSnapshot({required SpotItem spot}) async {
    final proxyClient = _forecastProxyClient;
    final rapidApiKey = proxyClient == null ? await _resolveRapidApiKey() : '';
    final rapidApiHost = proxyClient == null
        ? await _resolveRapidApiHost()
        : '';
    if (proxyClient == null &&
        (rapidApiKey.isEmpty || rapidApiHost.isEmpty)) {
      return const MeteostatDaySnapshot(days: <MeteostatDayData>[]);
    }

    final location = _resolveLocation(spot: spot);
    final range = _buildDateRange();
    final json = proxyClient != null
        ? await proxyClient.fetchMeteostatPointDaily(
            latitude: location.lat,
            longitude: location.lon,
            startDate: range.startDate,
            endDate: range.endDate,
          )
        : await _fetchJson(
            _buildUrl(location),
            rapidApiKey,
            rapidApiHost,
          );
    final data = json['data'];
    if (data is! List) {
      return await _buildSnapshotFromHourlyFallback(
        spot: spot,
        proxyClient: proxyClient,
        rapidApiKey: rapidApiKey,
        rapidApiHost: rapidApiHost,
      );
    }

    final days = data
        .whereType<Map<String, dynamic>>()
        .map((item) {
          return MeteostatDayData(
            date: _parseDateTime(item['date']),
            tempAvgC: _asNum(item['tavg'])?.toDouble(),
            tempMinC: _asNum(item['tmin'])?.toDouble(),
            tempMaxC: _asNum(item['tmax'])?.toDouble(),
            windMeanKnots: _kmhToKnots(_asNum(item['wspd'])?.toDouble()),
            gustKnots: _kmhToKnots(_asNum(item['wpgt'])?.toDouble()),
            pressureHpa: _asNum(item['pres'])?.toDouble(),
            precipitationMm: _asNum(item['prcp'])?.toDouble(),
            sunshineMinutes: _asNum(item['tsun'])?.round(),
          );
        })
        .toList(growable: false);

    if (days.isEmpty) {
      return await _buildSnapshotFromHourlyFallback(
        spot: spot,
        proxyClient: proxyClient,
        rapidApiKey: rapidApiKey,
        rapidApiHost: rapidApiHost,
      );
    }

    return MeteostatDaySnapshot(days: days);
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
    return 'https://meteostat.p.rapidapi.com/point/daily?lat=${location.lat}&lon=${location.lon}&start=${range.startDate}&end=${range.endDate}&units=metric&model=true';
  }

  ({String startDate, String endDate}) _buildDateRange() {
    final start = DateTime.now().toUtc();
    final startDate = DateTime.utc(start.year, start.month, start.day);
    final endDate = startDate.add(const Duration(days: 6));
    return (
      startDate: _formatDate(startDate),
      endDate: _formatDate(endDate),
    );
  }

  Future<MeteostatDaySnapshot> _buildSnapshotFromHourlyFallback({
    required SpotItem spot,
    required SupabaseForecastProxyClient? proxyClient,
    required String rapidApiKey,
    required String rapidApiHost,
  }) async {
    final location = _resolveLocation(spot: spot);
    final range = _buildDateRange();
    final json = proxyClient != null
        ? await proxyClient.fetchMeteostatPointHourly(
            latitude: location.lat,
            longitude: location.lon,
            startDate: range.startDate,
            endDate: range.endDate,
          )
        : await _fetchJson(
            _buildHourlyUrl(location),
            rapidApiKey,
            rapidApiHost,
          );
    final data = json['data'];
    if (data is! List) {
      return const MeteostatDaySnapshot(days: <MeteostatDayData>[]);
    }

    final grouped = <DateTime, List<Map<String, dynamic>>>{};
    for (final item in data.whereType<Map<String, dynamic>>()) {
      final time = _parseDateTime(item['time']);
      if (time == null) {
        continue;
      }
      final day = DateTime.utc(time.year, time.month, time.day);
      grouped.putIfAbsent(day, () => <Map<String, dynamic>>[]).add(item);
    }

    final days = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return MeteostatDaySnapshot(
      days: days
          .map((entry) => _aggregateHourlyDay(entry.key, entry.value))
          .toList(growable: false),
    );
  }

  MeteostatDayData _aggregateHourlyDay(
    DateTime day,
    List<Map<String, dynamic>> items,
  ) {
    final temps = <double>[];
    final winds = <double>[];
    final gusts = <double>[];
    final pressures = <double>[];
    var precipitation = 0.0;

    for (final item in items) {
      final temp = _asNum(item['temp'])?.toDouble();
      if (temp != null) {
        temps.add(temp);
      }
      final wind = _asNum(item['wspd'])?.toDouble();
      if (wind != null) {
        winds.add(_kmhToKnots(wind) ?? wind);
      }
      final gust = _asNum(item['wpgt'])?.toDouble();
      if (gust != null) {
        gusts.add(_kmhToKnots(gust) ?? gust);
      }
      final pressure = _asNum(item['pres'])?.toDouble();
      if (pressure != null) {
        pressures.add(pressure);
      }
      final rain = _asNum(item['prcp'])?.toDouble();
      if (rain != null) {
        precipitation += rain;
      }
    }

    return MeteostatDayData(
      date: day,
      tempAvgC: _average(temps),
      tempMinC: temps.isEmpty ? null : temps.reduce((a, b) => a < b ? a : b),
      tempMaxC: temps.isEmpty ? null : temps.reduce((a, b) => a > b ? a : b),
      windMeanKnots: _average(winds),
      gustKnots: gusts.isEmpty ? null : gusts.reduce((a, b) => a > b ? a : b),
      pressureHpa: _average(pressures),
      precipitationMm: precipitation == 0 ? 0 : precipitation,
      sunshineMinutes: null,
    );
  }

  String _buildHourlyUrl(({double lat, double lon}) location) {
    final range = _buildDateRange();
    return 'https://meteostat.p.rapidapi.com/point/hourly?lat=${location.lat}&lon=${location.lon}&start=${range.startDate}&end=${range.endDate}&tz=UTC&units=metric&model=true';
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
      return DateTime.parse(source.replaceFirst(' ', 'T')).toUtc();
    } catch (_) {
      return null;
    }
  }

  num? _asNum(dynamic source) => source is num ? source : null;

  double? _kmhToKnots(double? value) {
    if (value == null) {
      return null;
    }
    return value / 1.852;
  }

  double? _average(List<double> values) {
    if (values.isEmpty) {
      return null;
    }
    return values.reduce((a, b) => a + b) / values.length;
  }

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
