import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/services/aemet_text_normalizer.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

const kAemetBeachForecastModel = 'Prediccion de playa';

String buildAemetBeachForecastModelLabel({
  required String beachCode,
  String? beachName,
}) {
  final resolvedName = (beachName == null || beachName.trim().isEmpty)
      ? beachCode
      : beachName.trim();
  return '$kAemetBeachForecastModel ($resolvedName)';
}

bool isAemetBeachForecastModelLabel(String model) {
  return model == kAemetBeachForecastModel ||
      model.startsWith('$kAemetBeachForecastModel (');
}

String? extractAemetBeachCodeFromModel({
  required String model,
  required SpotItem spot,
}) {
  if (!isAemetBeachForecastModelLabel(model)) {
    return null;
  }
  if (model == kAemetBeachForecastModel) {
    final codes = spot.resolvedAemetBeachCodes;
    return codes.isEmpty ? null : codes.first;
  }
  final label = model
      .replaceFirst('$kAemetBeachForecastModel (', '')
      .replaceFirst(')', '')
      .trim();
  for (final code in spot.resolvedAemetBeachCodes) {
    if (getAemetBeachDisplayName(beachCode: code).toLowerCase() ==
        label.toLowerCase()) {
      return code;
    }
  }
  return null;
}

String getAemetBeachDisplayName({required String beachCode}) {
  switch (beachCode) {
    case '0301808':
      return 'La Roda';
    case '0306301':
      return 'Les Deveses';
    case '0306308':
      return 'Les Boves / Les Marines';
    case '0304709':
      return 'Arenal/Bol';
    case '0313909':
      return 'Paradis';
    case '0312108':
      return 'Tamarit';
    case '0301401':
      return 'Sant Joan / San Juan';
    case '0305013':
      return 'Carrer la Mar';
    case '4625004':
      return 'La Devesa';
    case '4625001':
      return 'Playa de Levante / Malvarrosa';
    case '1103506':
      return 'Los Lances';
    case '4610502':
      return 'El Dossel';
    case '4618102':
      return 'Pau-Pi';
    case '4618103':
      return "l'Aigua Blanca";
    case '4619501':
      return 'Piles';
    case '4613102':
      return 'Norte de Gandia';
    default:
      return beachCode;
  }
}

List<String> getAemetBeachForecastModelsForSpot(SpotItem spot) {
  return spot.resolvedAemetBeachCodes
      .map(
        (code) => buildAemetBeachForecastModelLabel(
          beachCode: code,
          beachName: getAemetBeachDisplayName(beachCode: code),
        ),
      )
      .toList(growable: false);
}

class AemetBeachForecastData {
  const AemetBeachForecastData({
    required this.beachName,
    required this.beachId,
    required this.issuedAt,
    required this.days,
  });

  final String beachName;
  final int? beachId;
  final DateTime? issuedAt;
  final List<AemetBeachForecastDay> days;
}

class AemetBeachForecastDay {
  const AemetBeachForecastDay({
    required this.date,
    required this.skyMorning,
    required this.skyAfternoon,
    required this.windMorning,
    required this.windAfternoon,
    required this.waveMorning,
    required this.waveAfternoon,
    required this.maxTempC,
    required this.waterTempC,
    required this.thermalSensation,
    required this.uvMax,
  });

  final DateTime? date;
  final String skyMorning;
  final String skyAfternoon;
  final String windMorning;
  final String windAfternoon;
  final String waveMorning;
  final String waveAfternoon;
  final int? maxTempC;
  final int? waterTempC;
  final String thermalSensation;
  final int? uvMax;
}

class AemetBeachForecastClient {
  static final Map<String, _CachedBeachForecast> _forecastCache =
      <String, _CachedBeachForecast>{};
  static final Map<String, DateTime> _rateLimitCooldowns = <String, DateTime>{};
  static const Duration _cacheTtl = Duration(minutes: 10);
  static const Duration _rateLimitCooldown = Duration(minutes: 1);

  AemetBeachForecastClient({
    HttpClient? httpClient,
    String? apiKey,
    Future<Map<String, dynamic>> Function(String url)? fetchJson,
    Future<List<Map<String, dynamic>>> Function(String url)? fetchJsonList,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient,
       _apiKey = apiKey ?? EnvConfig.aemetOpenDataApiKey,
       _fetchJsonOverride = fetchJson,
       _fetchJsonListOverride = fetchJsonList,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  final HttpClient? _httpClient;
  final String _apiKey;
  final Future<Map<String, dynamic>> Function(String url)? _fetchJsonOverride;
  final Future<List<Map<String, dynamic>>> Function(String url)?
  _fetchJsonListOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  Future<List<AemetBeachForecastData>> fetchForecasts({
    required SpotItem spot,
    List<String>? beachCodes,
  }) async {
    if (_apiKey.isEmpty && _forecastProxyClient == null) {
      throw const AemetBeachForecastException('missing-api-key');
    }
    final resolvedBeachCodes = beachCodes ?? _resolveBeachCodes(spot: spot);
    if (resolvedBeachCodes.isEmpty) {
      throw AemetBeachForecastException('unsupported-spot:${spot.name}');
    }

    final results = <AemetBeachForecastData>[];
    AemetBeachForecastException? lastError;
    for (final beachCode in resolvedBeachCodes) {
      try {
        results.add(
          await _fetchForecastForCode(spot: spot, beachCode: beachCode),
        );
      } on AemetBeachForecastException catch (error) {
        lastError = error;
      }
    }
    if (results.isNotEmpty) {
      return results;
    }
    throw lastError ??
        AemetBeachForecastException('unsupported-spot:${spot.name}');
  }

  Future<AemetBeachForecastData> fetchForecast({required SpotItem spot}) async {
    final results = await fetchForecasts(spot: spot);
    return results.first;
  }

  Future<AemetBeachForecastData> _fetchForecastForCode({
    required SpotItem spot,
    required String beachCode,
  }) async {
    final cacheKey = 'AEMET-PLAYA|$beachCode';
    final cached = _readFreshCache(cacheKey);
    if (cached != null) {
      return cached;
    }
    if (_isInRateLimitCooldown(cacheKey)) {
      final stale = _readAnyCache(cacheKey);
      if (stale != null) {
        return stale;
      }
      throw const AemetBeachForecastException('http-429:cooldown-active');
    }

    try {
      final payload = _forecastProxyClient != null
          ? await _forecastProxyClient.fetchAemetBeachForecast(
              beachCode: beachCode,
            )
          : await _fetchRemotePayload(beachCode);
      if (payload.isEmpty) {
        throw const AemetBeachForecastException('empty-payload');
      }

      final root = payload.first;
      final prediction = root['prediccion'] as Map<String, dynamic>?;
      final daysRaw = prediction?['dia'] as List<dynamic>? ?? const <dynamic>[];
      final days = daysRaw
          .whereType<Map<String, dynamic>>()
          .map(_mapDay)
          .toList(growable: false);

      final result = AemetBeachForecastData(
        beachName: normalizeAemetText(root['nombre'], fallback: spot.name),
        beachId: (root['id'] as num?)?.round(),
        issuedAt: _parseDateTime(root['elaborado']),
        days: days,
      );
      _forecastCache[cacheKey] = _CachedBeachForecast(
        createdAt: DateTime.now(),
        data: result,
      );
      return result;
    } on AemetBeachForecastException catch (error) {
      if ('$error'.contains('429')) {
        _rateLimitCooldowns[cacheKey] = DateTime.now().add(_rateLimitCooldown);
      }
      final stale = _readAnyCache(cacheKey);
      if (stale != null) {
        return stale;
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchRemotePayload(
    String beachCode,
  ) async {
    final envelope = await _fetchJson(
      'https://opendata.aemet.es/opendata/api/prediccion/especifica/playa/$beachCode/?api_key=$_apiKey',
    );
    final dataUrl = envelope['datos'];
    if (dataUrl is! String || dataUrl.isEmpty) {
      throw const AemetBeachForecastException('missing-datos-url');
    }
    return _fetchJsonList(dataUrl);
  }

  AemetBeachForecastData? _readFreshCache(String key) {
    final cached = _forecastCache[key];
    if (cached == null) {
      return null;
    }
    if (DateTime.now().difference(cached.createdAt) > _cacheTtl) {
      return null;
    }
    return cached.data;
  }

  AemetBeachForecastData? _readAnyCache(String key) {
    return _forecastCache[key]?.data;
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

  AemetBeachForecastDay _mapDay(Map<String, dynamic> raw) {
    final sky = raw['estadoCielo'] as Map<String, dynamic>?;
    final wind = raw['viento'] as Map<String, dynamic>?;
    final wave = raw['oleaje'] as Map<String, dynamic>?;
    final sensation =
        (raw['sTermica'] as Map<String, dynamic>?) ??
        (raw['stermica'] as Map<String, dynamic>?);
    final maxTemp =
        (raw['tMaxima'] as Map<String, dynamic>?) ??
        (raw['tmaxima'] as Map<String, dynamic>?);
    final waterTemp =
        (raw['tAgua'] as Map<String, dynamic>?) ??
        (raw['tagua'] as Map<String, dynamic>?);
    final uv = raw['uvMax'] as Map<String, dynamic>?;

    return AemetBeachForecastDay(
      date: _parseAemetCompactDate(raw['fecha']),
      skyMorning: _readText(sky?['descripcion1']),
      skyAfternoon: _readText(sky?['descripcion2']),
      windMorning: _readText(wind?['descripcion1']),
      windAfternoon: _readText(wind?['descripcion2']),
      waveMorning: _readText(wave?['descripcion1']),
      waveAfternoon: _readText(wave?['descripcion2']),
      maxTempC: _readInt(maxTemp?['valor1']),
      waterTempC: _readInt(waterTemp?['valor1']),
      thermalSensation: _readText(sensation?['descripcion1']),
      uvMax: _readInt(uv?['valor1']),
    );
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    if (_fetchJsonOverride != null) {
      return _fetchJsonOverride(url);
    }
    final response = await _fetchText(url);
    final decoded = jsonDecode(response);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const AemetBeachForecastException('invalid-json-object');
  }

  Future<List<Map<String, dynamic>>> _fetchJsonList(String url) async {
    if (_fetchJsonListOverride != null) {
      return _fetchJsonListOverride(url);
    }
    final response = await _fetchText(url);
    final decoded = jsonDecode(response);
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    throw const AemetBeachForecastException('invalid-json-list');
  }

  Future<String> _fetchText(String url) async {
    if (kIsWeb) {
      throw const AemetBeachForecastException('unsupported-web-http-client');
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (url.contains('/opendata/api/')) {
      request.headers.set('api_key', _apiKey);
    }
    request.headers.set(HttpHeaders.userAgentHeader, 'WindWisher/1.0');
    final response = await request.close();
    final bytes = await response.fold<List<int>>(
      <int>[],
      (buffer, chunk) => buffer..addAll(chunk),
    );
    final body = _decodeResponseBody(bytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AemetBeachForecastException('http-${response.statusCode}:$body');
    }
    return body;
  }

  List<String> _resolveBeachCodes({required SpotItem spot}) {
    final codes = spot.resolvedAemetBeachCodes;
    if (codes.isNotEmpty) {
      return codes;
    }
    final normalized = spot.name.trim().toLowerCase();
    if (normalized == 'oliva puerto') {
      return const ['4618102'];
    }
    return const <String>[];
  }
}

class AemetBeachForecastException implements Exception {
  const AemetBeachForecastException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _CachedBeachForecast {
  const _CachedBeachForecast({required this.createdAt, required this.data});

  final DateTime createdAt;
  final AemetBeachForecastData data;
}

DateTime? _parseDateTime(dynamic value) {
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

DateTime? _parseAemetCompactDate(dynamic value) {
  final raw = value?.toString() ?? '';
  if (raw.length != 8) {
    return null;
  }
  final year = int.tryParse(raw.substring(0, 4));
  final month = int.tryParse(raw.substring(4, 6));
  final day = int.tryParse(raw.substring(6, 8));
  if (year == null || month == null || day == null) {
    return null;
  }
  return DateTime(year, month, day);
}

String _readText(dynamic value) {
  return normalizeAemetText(value);
}

int? _readInt(dynamic value) {
  if (value is num) {
    return value.round();
  }
  return int.tryParse(value?.toString() ?? '');
}

String _decodeResponseBody(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}
