import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_forecast_port.dart';
import 'package:windwisher/features/spots/infrastructure/adapters/local/local_file_spots_forecast_cache_store.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class AemetSpotsForecastAdapter implements SpotsForecastPort {
  static final Map<String, _CachedForecast> _forecastCache =
      <String, _CachedForecast>{};
  static final Map<String, DateTime> _rateLimitCooldowns = <String, DateTime>{};
  static const Duration _cacheTtl = Duration(minutes: 10);
  static const Duration _persistentCacheTtl = Duration(hours: 6);
  static const Duration _rateLimitCooldown = Duration(minutes: 1);

  AemetSpotsForecastAdapter({
    HttpClient? httpClient,
    String? apiKey,
    Future<Map<String, dynamic>> Function(String url)? fetchJson,
    Future<List<Map<String, dynamic>>> Function(String url)? fetchJsonList,
    SpotsForecastCacheStore? cacheStore,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient,
       _apiKey = apiKey ?? EnvConfig.aemetOpenDataApiKey,
       _fetchJsonOverride = fetchJson,
       _fetchJsonListOverride = fetchJsonList,
       _cacheStore = cacheStore ?? LocalFileSpotsForecastCacheStore(),
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  final HttpClient? _httpClient;
  final String _apiKey;
  final Future<Map<String, dynamic>> Function(String url)? _fetchJsonOverride;
  final Future<List<Map<String, dynamic>>> Function(String url)?
  _fetchJsonListOverride;
  final SpotsForecastCacheStore _cacheStore;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  @override
  Future<List<SpotForecastEntry>> getForecast({
    required SpotItem spot,
    required String provider,
    required String model,
  }) async {
    if (provider != 'AEMET') {
      return const <SpotForecastEntry>[];
    }
    if (_apiKey.isEmpty && _forecastProxyClient == null) {
      return const <SpotForecastEntry>[];
    }

    final cacheKey =
        'AEMET|${spot.name.trim().toLowerCase()}|${spot.area.trim().toLowerCase()}';
    final cached = _cachedForecast(cacheKey, _cacheTtl);
    if (cached != null) {
      return cached;
    }

    if (_isInRateLimitCooldown(cacheKey)) {
      final stale = _readStaleCache(cacheKey);
      if (stale != null && stale.isNotEmpty) {
        return stale;
      }
      throw HttpException('Forecast request failed: 429 cooldown-active');
    }

    final persisted = _cacheStore.read(
      key: cacheKey,
      maxAge: _persistentCacheTtl,
    );
    if (persisted != null && persisted.isNotEmpty) {
      _forecastCache[cacheKey] = _CachedForecast(
        createdAt: DateTime.now(),
        entries: persisted,
      );
      return persisted;
    }

    final municipalityCode = _resolveAemetMunicipalityCode(spot: spot);
    try {
      final data = _forecastProxyClient != null
          ? await _forecastProxyClient.fetchAemetMunicipalForecast(
              municipalityCode: municipalityCode,
            )
          : await _fetchMunicipalPayload(municipalityCode);
      if (data.isEmpty) {
        return const <SpotForecastEntry>[];
      }

      final results = _mapAemetData(data);
      if (results.isNotEmpty) {
        _forecastCache[cacheKey] = _CachedForecast(
          createdAt: DateTime.now(),
          entries: results,
        );
        _cacheStore.write(key: cacheKey, entries: results);
      }
      return results;
    } on HttpException catch (error) {
      if ('$error'.contains('429')) {
        _rateLimitCooldowns[cacheKey] = DateTime.now().add(_rateLimitCooldown);
      }
      final staleCache = _readStaleCache(cacheKey);
      if (staleCache != null && staleCache.isNotEmpty) {
        _forecastCache[cacheKey] = _CachedForecast(
          createdAt: DateTime.now(),
          entries: staleCache,
        );
        return staleCache;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchMunicipalPayload(
    String municipalityCode,
  ) async {
    final indexJson = await _fetchJson(
      'https://opendata.aemet.es/opendata/api/prediccion/especifica/municipio/horaria/$municipalityCode/?api_key=$_apiKey',
    );
    final dataUrl = indexJson['datos'] as String?;
    if (dataUrl == null || dataUrl.isEmpty) {
      return const <Map<String, dynamic>>[];
    }
    return _fetchJsonList(dataUrl);
  }

  bool _isInRateLimitCooldown(String key) {
    final expiresAt = _rateLimitCooldowns[key];
    if (expiresAt == null) {
      return false;
    }
    if (DateTime.now().isAfter(expiresAt)) {
      _rateLimitCooldowns.remove(key);
      return false;
    }
    return true;
  }

  List<SpotForecastEntry>? _readStaleCache(String key) {
    return _cacheStore.read(key: key, maxAge: const Duration(days: 3));
  }

  List<SpotForecastEntry>? _cachedForecast(String key, Duration ttl) {
    final cached = _forecastCache[key];
    if (cached == null) {
      return null;
    }
    if (DateTime.now().difference(cached.createdAt) > ttl) {
      _forecastCache.remove(key);
      return null;
    }
    return cached.entries;
  }

  String _resolveAemetMunicipalityCode({required SpotItem spot}) {
    if (spot.aemetMunicipalityCode != null &&
        spot.aemetMunicipalityCode!.isNotEmpty) {
      return spot.aemetMunicipalityCode!;
    }
    if (spot.area.toLowerCase().contains('denia')) {
      return '03063';
    }
    return '46181';
  }

  List<SpotForecastEntry> _mapAemetData(List<Map<String, dynamic>> data) {
    final root = data.first;
    final prediction = root['prediccion'] as Map<String, dynamic>?;
    final days = (prediction?['dia'] as List<dynamic>? ?? const []);
    final results = <SpotForecastEntry>[];

    for (final dayEntry in days.cast<Map<String, dynamic>>()) {
      final baseDate = DateTime.tryParse(dayEntry['fecha']?.toString() ?? '');
      if (baseDate == null) {
        continue;
      }

      final temperatureByHour = _aemetNumericByHour(dayEntry['temperatura']);
      final rainByHour = _aemetDoubleByHour(dayEntry['precipitacion']);
      final cloudByHour = _aemetCloudByHour(dayEntry['estadoCielo']);
      final windByHour = _aemetWindByHour(dayEntry['vientoAndRachaMax']);

      for (var hour = 0; hour < 24; hour += 3) {
        final temp = temperatureByHour[hour];
        final wind = windByHour[hour];
        if (temp == null || wind == null) {
          continue;
        }

        results.add(
          SpotForecastEntry(
            time: DateTime(baseDate.year, baseDate.month, baseDate.day, hour),
            windKnots: _kmhToKnots(wind.speedKmh.toDouble()).round(),
            gustKnots: _kmhToKnots(wind.gustKmh.toDouble()).round(),
            windDeg: wind.degrees,
            airTempC: temp,
            waterTempC: null,
            pressureHpa: null,
            cloudCoverPct: cloudByHour[hour],
            waveM: null,
            rainMm: rainByHour[hour],
          ),
        );
      }
    }

    return results;
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    final fetchJsonOverride = _fetchJsonOverride;
    if (fetchJsonOverride != null) {
      return fetchJsonOverride(url);
    }
    if (kIsWeb) {
      throw UnsupportedError('AEMET direct HttpClient is not available on web.');
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set('api_key', _apiKey);
    request.headers.set(HttpHeaders.userAgentHeader, 'WindWisher/1.0');
    final response = await request.close();
    final bytes = await response.fold<List<int>>(
      <int>[],
      (buffer, chunk) => buffer..addAll(chunk),
    );
    final body = _decodeResponseBody(bytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Forecast request failed: ${response.statusCode} ${body.length > 240 ? body.substring(0, 240) : body}',
        uri: Uri.parse(url),
      );
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _fetchJsonList(String url) async {
    final fetchJsonListOverride = _fetchJsonListOverride;
    if (fetchJsonListOverride != null) {
      return fetchJsonListOverride(url);
    }
    if (kIsWeb) {
      throw UnsupportedError('AEMET direct HttpClient is not available on web.');
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    request.headers.set(HttpHeaders.userAgentHeader, 'WindWisher/1.0');
    final response = await request.close();
    final bytes = await response.fold<List<int>>(
      <int>[],
      (buffer, chunk) => buffer..addAll(chunk),
    );
    final body = _decodeResponseBody(bytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Forecast request failed: ${response.statusCode} ${body.length > 240 ? body.substring(0, 240) : body}',
        uri: Uri.parse(url),
      );
    }
    final decoded = jsonDecode(body) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  Map<int, int> _aemetNumericByHour(dynamic source) {
    final values = <int, int>{};
    if (source is! List) {
      return values;
    }
    for (final item in source.cast<Map<String, dynamic>>()) {
      final hour = int.tryParse(item['periodo']?.toString() ?? '');
      final value = int.tryParse(item['value']?.toString() ?? '');
      if (hour != null && value != null) {
        values[hour] = value;
      }
    }
    return values;
  }

  Map<int, double> _aemetDoubleByHour(dynamic source) {
    final values = <int, double>{};
    if (source is! List) {
      return values;
    }
    for (final item in source.cast<Map<String, dynamic>>()) {
      final hour = int.tryParse(item['periodo']?.toString() ?? '');
      final value = double.tryParse(item['value']?.toString() ?? '');
      if (hour != null && value != null) {
        values[hour] = value;
      }
    }
    return values;
  }

  Map<int, int> _aemetCloudByHour(dynamic source) {
    final values = <int, int>{};
    if (source is! List) {
      return values;
    }
    for (final item in source.cast<Map<String, dynamic>>()) {
      final hour = int.tryParse(item['periodo']?.toString() ?? '');
      final description = item['descripcion']?.toString().toLowerCase() ?? '';
      if (hour == null) {
        continue;
      }
      values[hour] = switch (description) {
        final d when d.contains('despejado') => 0,
        final d when d.contains('poco nuboso') => 20,
        final d when d.contains('intervalos nubosos') => 45,
        final d when d.contains('nuboso') => 70,
        final d when d.contains('cubierto') => 95,
        _ => 50,
      };
    }
    return values;
  }

  Map<int, ({int speedKmh, int gustKmh, int degrees})> _aemetWindByHour(
    dynamic source,
  ) {
    final values = <int, ({int speedKmh, int gustKmh, int degrees})>{};
    if (source is! List) {
      return values;
    }

    for (var i = 0; i < source.length; i += 2) {
      final wind = source[i] as Map<String, dynamic>;
      final gust = i + 1 < source.length
          ? source[i + 1] as Map<String, dynamic>
          : null;
      final hour = int.tryParse(wind['periodo']?.toString() ?? '');
      final velocityList = (wind['velocidad'] as List<dynamic>? ?? const []);
      final directionList = (wind['direccion'] as List<dynamic>? ?? const []);
      final velocity = velocityList.isEmpty
          ? null
          : int.tryParse(velocityList.first.toString());
      final direction = directionList.isEmpty
          ? null
          : directionList.first.toString();
      final gustValue = int.tryParse(gust?['value']?.toString() ?? '');
      if (hour == null || velocity == null || direction == null) {
        continue;
      }
      values[hour] = (
        speedKmh: velocity,
        gustKmh: gustValue ?? velocity + 10,
        degrees: _directionToDegrees(direction),
      );
    }

    return values;
  }

  int _kmhToKnots(double kmh) => (kmh / 1.852).round();

  int _directionToDegrees(String direction) {
    const map = <String, int>{
      'N': 0,
      'NE': 45,
      'E': 90,
      'SE': 135,
      'S': 180,
      'SW': 225,
      'W': 270,
      'NW': 315,
      'C': 0,
    };
    return map[direction.toUpperCase()] ?? 0;
  }

  String _decodeResponseBody(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes);
    }
  }
}

class _CachedForecast {
  const _CachedForecast({required this.createdAt, required this.entries});

  final DateTime createdAt;
  final List<SpotForecastEntry> entries;
}
