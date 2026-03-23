import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

const kAemetCoastalForecastModel = 'Maritima costera';

class AemetCoastalForecastData {
  const AemetCoastalForecastData({
    required this.bulletinName,
    required this.issuedAt,
    required this.validFrom,
    required this.validTo,
    required this.noticeText,
    required this.situationText,
    required this.trendText,
    required this.zones,
  });

  final String bulletinName;
  final DateTime? issuedAt;
  final DateTime? validFrom;
  final DateTime? validTo;
  final String noticeText;
  final String situationText;
  final String trendText;
  final List<AemetCoastalForecastZone> zones;
}

class AemetCoastalForecastZone {
  const AemetCoastalForecastZone({
    required this.name,
    required this.text,
    this.id,
  });

  final String name;
  final String text;
  final int? id;
}

class AemetCoastalForecastClient {
  static final Map<String, _CachedCoastalForecast> _forecastCache =
      <String, _CachedCoastalForecast>{};
  static final Map<String, DateTime> _rateLimitCooldowns = <String, DateTime>{};
  static const Duration _cacheTtl = Duration(minutes: 10);
  static const Duration _rateLimitCooldown = Duration(minutes: 1);

  AemetCoastalForecastClient({
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

  Future<AemetCoastalForecastData> fetchForecast({
    required SpotItem spot,
  }) async {
    if (_apiKey.isEmpty && _forecastProxyClient == null) {
      throw const AemetCoastalForecastException('missing-api-key');
    }

    final coastalCode = getAemetCoastalAreaCode(area: spot.area);
    if (coastalCode == null) {
      throw AemetCoastalForecastException('unsupported-area:${spot.area}');
    }

    final cacheKey =
        'AEMET-COSTERA|$coastalCode|${_preferredZoneKeyword(spot: spot) ?? ''}';
    final cached = _readFreshCache(cacheKey);
    if (cached != null) {
      return cached;
    }
    if (_isInRateLimitCooldown(cacheKey)) {
      final stale = _readAnyCache(cacheKey);
      if (stale != null) {
        return stale;
      }
      throw const AemetCoastalForecastException('http-429:cooldown-active');
    }

    try {
      final payload = _forecastProxyClient != null
          ? await _forecastProxyClient.fetchAemetCoastalForecast(
              coastalCode: coastalCode,
            )
          : await _fetchRemotePayload(coastalCode);
      if (payload.isEmpty) {
        throw const AemetCoastalForecastException('empty-payload');
      }

      final root = payload.first;
      final prediction = root['prediccion'] as Map<String, dynamic>?;
      final zonesRaw = prediction?['zona'] as List<dynamic>?;
      final preferredKeyword = _preferredZoneKeyword(spot: spot);
      final zones = <AemetCoastalForecastZone>[];

      for (final zoneRaw in zonesRaw ?? const <dynamic>[]) {
        if (zoneRaw is! Map<String, dynamic>) {
          continue;
        }
        final subzones = zoneRaw['subzona'] as List<dynamic>?;
        for (final subzoneRaw in subzones ?? const <dynamic>[]) {
          if (subzoneRaw is! Map<String, dynamic>) {
            continue;
          }
          final zone = AemetCoastalForecastZone(
            id: (subzoneRaw['id'] as num?)?.round(),
            name: (subzoneRaw['nombre'] as String?)?.trim().isNotEmpty == true
                ? (subzoneRaw['nombre'] as String).trim()
                : 'Zona costera',
            text: (subzoneRaw['texto'] as String?)?.trim().isNotEmpty == true
                ? (subzoneRaw['texto'] as String).trim()
                : 'Sin detalle textual disponible.',
          );
          zones.add(zone);
        }
      }

      final filteredZones = preferredKeyword == null
          ? zones
          : zones
                .where(
                  (zone) => zone.name.toLowerCase().contains(preferredKeyword),
                )
                .toList(growable: false);

      final result = AemetCoastalForecastData(
        bulletinName: (root['nombre'] as String?)?.trim().isNotEmpty == true
            ? (root['nombre'] as String).trim()
            : 'Boletin meteorologico y marino costero',
        issuedAt: _parseDateTime(
          (root['origen'] as Map<String, dynamic>?)?['elaborado'],
        ),
        validFrom: _parseDateTime(prediction?['inicio']),
        validTo: _parseDateTime(prediction?['fin']),
        noticeText: _readText(
          (root['aviso'] as Map<String, dynamic>?)?['texto'],
        ),
        situationText: _readText(
          (root['situacion'] as Map<String, dynamic>?)?['texto'],
        ),
        trendText: _readText(
          (root['tendencia'] as Map<String, dynamic>?)?['texto'],
        ),
        zones: filteredZones.isNotEmpty ? filteredZones : zones,
      );
      _forecastCache[cacheKey] = _CachedCoastalForecast(
        createdAt: DateTime.now(),
        data: result,
      );
      return result;
    } on AemetCoastalForecastException catch (error) {
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

  Future<List<Map<String, dynamic>>> _fetchRemotePayload(String coastalCode) async {
    final envelope = await _fetchJson(
      'https://opendata.aemet.es/opendata/api/prediccion/maritima/costera/costa/$coastalCode/?api_key=$_apiKey',
    );
    final dataUrl = envelope['datos'];
    if (dataUrl is! String || dataUrl.isEmpty) {
      throw const AemetCoastalForecastException('missing-datos-url');
    }
    return _fetchJsonList(dataUrl);
  }

  AemetCoastalForecastData? _readFreshCache(String key) {
    final cached = _forecastCache[key];
    if (cached == null) {
      return null;
    }
    if (DateTime.now().difference(cached.createdAt) > _cacheTtl) {
      return null;
    }
    return cached.data;
  }

  AemetCoastalForecastData? _readAnyCache(String key) {
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

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    if (_fetchJsonOverride != null) {
      return _fetchJsonOverride(url);
    }
    final response = await _fetchText(url);
    final decoded = jsonDecode(response);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const AemetCoastalForecastException('invalid-json-object');
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
    throw const AemetCoastalForecastException('invalid-json-list');
  }

  Future<String> _fetchText(String url) async {
    if (kIsWeb) {
      throw const AemetCoastalForecastException('unsupported-web-http-client');
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
      throw AemetCoastalForecastException('http-${response.statusCode}:$body');
    }
    return body;
  }
}

class AemetCoastalForecastException implements Exception {
  const AemetCoastalForecastException(this.message);

  final String message;

  @override
  String toString() => message;
}

String? getAemetCoastalAreaCode({required String area}) {
  final normalized = area.trim().toLowerCase();
  if (normalized.contains('castell') ||
      normalized.contains('valencia') ||
      normalized.contains('alicante') ||
      normalized.contains('murcia')) {
    return '46';
  }
  return null;
}

String? getAemetCoastalZoneKeyword({required SpotItem spot}) {
  final normalizedSpot = spot.name.trim().toLowerCase();
  final normalizedArea = spot.area.trim().toLowerCase();
  if (normalizedSpot.contains('mar menor') ||
      normalizedArea.contains('mar menor')) {
    return 'mar menor';
  }
  if (normalizedArea.contains('castell')) {
    return 'castell';
  }
  if (normalizedArea.contains('valencia')) {
    return 'valencia';
  }
  if (normalizedArea.contains('alicante')) {
    return 'alicante';
  }
  if (normalizedArea.contains('murcia')) {
    return 'murcia';
  }
  return null;
}

String? _preferredZoneKeyword({required SpotItem spot}) {
  return getAemetCoastalZoneKeyword(spot: spot);
}

DateTime? _parseDateTime(dynamic value) {
  if (value is! String || value.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(value);
}

String _readText(dynamic value) {
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return 'Sin informacion disponible.';
}

String _decodeResponseBody(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}

class _CachedCoastalForecast {
  const _CachedCoastalForecast({required this.createdAt, required this.data});

  final DateTime createdAt;
  final AemetCoastalForecastData data;
}
