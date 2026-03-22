import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class AemetObservationStationSnapshot {
  const AemetObservationStationSnapshot({
    required this.stationId,
    required this.stationName,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.observedAt,
    required this.windKnots,
    required this.windDirectionDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.rainMm,
  });

  final String stationId;
  final String stationName;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final DateTime? observedAt;
  final double? windKnots;
  final int? windDirectionDeg;
  final double? gustKnots;
  final double? tempC;
  final double? pressureHpa;
  final int? humidityPct;
  final double? rainMm;
}

class AemetObservationClient {
  static final Map<String, _CachedObservationList> _cache =
      <String, _CachedObservationList>{};
  static const Duration _cacheTtl = Duration(minutes: 10);

  AemetObservationClient({
    HttpClient? httpClient,
    String? apiKey,
    Future<Map<String, dynamic>> Function(String url)? fetchJson,
    Future<List<Map<String, dynamic>>> Function(String url)? fetchJsonList,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient ?? HttpClient(),
       _apiKey = apiKey ?? EnvConfig.aemetOpenDataApiKey,
       _fetchJsonOverride = fetchJson,
       _fetchJsonListOverride = fetchJsonList,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  final HttpClient _httpClient;
  final String _apiKey;
  final Future<Map<String, dynamic>> Function(String url)? _fetchJsonOverride;
  final Future<List<Map<String, dynamic>>> Function(String url)?
  _fetchJsonListOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  Future<List<AemetObservationStationSnapshot>> fetchNearestStations({
    required double latitude,
    required double longitude,
    int limit = 5,
    double maxDistanceKm = 60,
    String? preferredStationId,
  }) async {
    if (_apiKey.isEmpty && _forecastProxyClient == null) {
      throw const AemetObservationException('missing-api-key');
    }

    final rawStations = await _fetchLatestObservations();
    final stations =
        rawStations
            .map(
              (raw) =>
                  _mapStation(raw, latitude: latitude, longitude: longitude),
            )
            .whereType<AemetObservationStationSnapshot>()
            .where((station) => station.distanceKm <= maxDistanceKm)
            .toList(growable: false)
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    if (preferredStationId == null || preferredStationId.isEmpty) {
      return stations.take(limit).toList(growable: false);
    }

    final preferredIndex = stations.indexWhere(
      (station) => station.stationId == preferredStationId,
    );
    if (preferredIndex == -1) {
      return stations.take(limit).toList(growable: false);
    }

    final preferred = stations[preferredIndex];
    final reordered = <AemetObservationStationSnapshot>[preferred];
    for (final station in stations) {
      if (station.stationId == preferredStationId) {
        continue;
      }
      reordered.add(station);
      if (reordered.length >= limit) {
        break;
      }
    }
    return reordered;
  }

  Future<AemetObservationStationSnapshot?> fetchStationObservation({
    required String stationId,
    double? referenceLatitude,
    double? referenceLongitude,
  }) async {
    if (_apiKey.isEmpty && _forecastProxyClient == null) {
      throw const AemetObservationException('missing-api-key');
    }
    final payload = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchAemetStationObservation(
            stationId: stationId,
          )
        : await _fetchStationObservationPayload(stationId);
    if (payload.isEmpty) {
      return null;
    }

    final raw = payload.first;
    final lat =
        referenceLatitude ?? _readCoordinate(raw['lat'], isLatitude: true);
    final lon =
        referenceLongitude ?? _readCoordinate(raw['lon'], isLatitude: false);
    if (lat == null || lon == null) {
      return null;
    }
    return _mapStation(
      raw,
      latitude: referenceLatitude ?? lat,
      longitude: referenceLongitude ?? lon,
    );
  }

  Future<List<AemetObservationStationSnapshot>> fetchStationObservations({
    required String stationId,
    double? referenceLatitude,
    double? referenceLongitude,
  }) async {
    if (_apiKey.isEmpty && _forecastProxyClient == null) {
      throw const AemetObservationException('missing-api-key');
    }
    final payload = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchAemetStationObservation(
            stationId: stationId,
          )
        : await _fetchStationObservationPayload(stationId);
    if (payload.isEmpty) {
      return const <AemetObservationStationSnapshot>[];
    }

    double? lat = referenceLatitude;
    double? lon = referenceLongitude;
    for (final raw in payload) {
      lat ??= _readCoordinate(raw['lat'], isLatitude: true);
      lon ??= _readCoordinate(raw['lon'], isLatitude: false);
      if (lat != null && lon != null) {
        break;
      }
    }
    if (lat == null || lon == null) {
      return const <AemetObservationStationSnapshot>[];
    }

    final snapshots = payload
        .map(
          (raw) => _mapStation(
            raw,
            latitude: lat!,
            longitude: lon!,
          ),
        )
        .whereType<AemetObservationStationSnapshot>()
        .toList(growable: false);
    snapshots.sort((a, b) {
      final observedAtA = a.observedAt;
      final observedAtB = b.observedAt;
      if (observedAtA == null && observedAtB == null) {
        return 0;
      }
      if (observedAtA == null) {
        return 1;
      }
      if (observedAtB == null) {
        return -1;
      }
      return observedAtA.compareTo(observedAtB);
    });
    return snapshots;
  }

  Future<List<Map<String, dynamic>>> _fetchLatestObservations() async {
    const cacheKey = 'AEMET-OBS-LATEST';
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.createdAt) <= _cacheTtl) {
      return cached.payload;
    }

    final payload = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchAemetLatestObservations()
        : await _fetchLatestObservationsPayload();
    _cache[cacheKey] = _CachedObservationList(
      createdAt: DateTime.now(),
      payload: payload,
    );
    return payload;
  }

  Future<List<Map<String, dynamic>>> _fetchStationObservationPayload(
    String stationId,
  ) async {
    final envelope = await _fetchJson(
      'https://opendata.aemet.es/opendata/api/observacion/convencional/datos/estacion/$stationId/?api_key=$_apiKey',
    );
    final dataUrl = envelope['datos'];
    if (dataUrl is! String || dataUrl.isEmpty) {
      throw const AemetObservationException('missing-datos-url');
    }
    return _fetchJsonList(dataUrl);
  }

  Future<List<Map<String, dynamic>>> _fetchLatestObservationsPayload() async {
    final envelope = await _fetchJson(
      'https://opendata.aemet.es/opendata/api/observacion/convencional/todas/?api_key=$_apiKey',
    );
    final dataUrl = envelope['datos'];
    if (dataUrl is! String || dataUrl.isEmpty) {
      throw const AemetObservationException('missing-datos-url');
    }
    return _fetchJsonList(dataUrl);
  }

  AemetObservationStationSnapshot? _mapStation(
    Map<String, dynamic> raw, {
    required double latitude,
    required double longitude,
  }) {
    final stationId = (raw['idema'] as String?)?.trim();
    final stationName = (raw['ubi'] as String?)?.trim();
    final stationLat = _readCoordinate(raw['lat'], isLatitude: true);
    final stationLon = _readCoordinate(raw['lon'], isLatitude: false);
    if (stationId == null ||
        stationId.isEmpty ||
        stationName == null ||
        stationName.isEmpty ||
        stationLat == null ||
        stationLon == null) {
      return null;
    }

    return AemetObservationStationSnapshot(
      stationId: stationId,
      stationName: stationName,
      latitude: stationLat,
      longitude: stationLon,
      distanceKm: _distanceKm(
        latitudeA: latitude,
        longitudeA: longitude,
        latitudeB: stationLat,
        longitudeB: stationLon,
      ),
      observedAt: _parseDateTime(raw['fint']),
      windKnots: _msToKnots(_readDouble(raw['vv'])),
      windDirectionDeg: _readInt(raw['dv']),
      gustKnots: _msToKnots(_readDouble(raw['vmax'])),
      tempC: _readDouble(raw['ta']),
      pressureHpa: _readDouble(raw['pres']),
      humidityPct: _readInt(raw['hr']),
      rainMm: _readDouble(raw['prec']),
    );
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    if (_fetchJsonOverride != null) {
      return _fetchJsonOverride(url);
    }
    final response = await _fetchText(_normalizeUrl(url));
    final decoded = jsonDecode(response);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const AemetObservationException('invalid-json-object');
  }

  Future<List<Map<String, dynamic>>> _fetchJsonList(String url) async {
    if (_fetchJsonListOverride != null) {
      return _fetchJsonListOverride(url);
    }
    final response = await _fetchText(_normalizeUrl(url));
    final decoded = jsonDecode(response);
    if (decoded is List) {
      return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    throw const AemetObservationException('invalid-json-list');
  }

  Future<String> _fetchText(String url) async {
    Future<String> attemptFetch() async {
      final request = await _httpClient.getUrl(Uri.parse(url));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.connectionHeader, 'close');
      if (url.contains('/opendata/api/')) {
        request.headers.set('api_key', _apiKey);
      }
      request.headers.set(HttpHeaders.userAgentHeader, 'MeteoKite/2.0');
      final response = await request.close();
      final bytes = await response.fold<List<int>>(
        <int>[],
        (buffer, chunk) => buffer..addAll(chunk),
      );
      final body = _decodeResponseBody(response: response, bytes: bytes);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw AemetObservationException('http-${response.statusCode}:$body');
      }
      return body;
    }

    try {
      return await attemptFetch();
    } on SocketException catch (error) {
      try {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return await attemptFetch();
      } on SocketException {
        throw AemetObservationException('network-error:${error.message}');
      } on HttpException catch (retryError) {
        throw AemetObservationException('http-exception:${retryError.message}');
      }
    } on HttpException catch (error) {
      try {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        return await attemptFetch();
      } on HttpException {
        throw AemetObservationException('http-exception:${error.message}');
      } on SocketException catch (retryError) {
        throw AemetObservationException('network-error:${retryError.message}');
      }
    }
  }

  String _normalizeUrl(String url) {
    if (url.startsWith('http://')) {
      return 'https://${url.substring(7)}';
    }
    return url;
  }

  String _decodeResponseBody({
    required HttpClientResponse response,
    required List<int> bytes,
  }) {
    final charset = response.headers.contentType?.charset?.toLowerCase();
    if (charset == 'iso-8859-15' || charset == 'latin9') {
      return latin1.decode(bytes);
    }
    try {
      return utf8.decode(bytes);
    } on FormatException {
      return latin1.decode(bytes);
    }
  }

  DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }
    final normalized = value.replaceFirstMapped(
      RegExp(r'([+-]\d{2})(\d{2})$'),
      (match) => '${match.group(1)}:${match.group(2)}',
    );
    return DateTime.tryParse(normalized)?.toLocal();
  }

  double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }

  double? _readCoordinate(Object? value, {required bool isLatitude}) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final dmsValue = _parseDmsCoordinate(trimmed);
    if (dmsValue != null) {
      return dmsValue;
    }
    final suffix = trimmed.substring(trimmed.length - 1).toUpperCase();
    final hasHemisphere =
        suffix == 'N' || suffix == 'S' || suffix == 'E' || suffix == 'W';
    final numericPart = hasHemisphere
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
    final parsed = double.tryParse(numericPart.replaceAll(',', '.'));
    if (parsed == null) {
      return null;
    }
    if (!hasHemisphere) {
      return parsed;
    }
    final isNegative = suffix == 'S' || suffix == 'W';
    return isNegative ? -parsed : parsed;
  }

  double? _parseDmsCoordinate(String value) {
    final normalized = value
        .replaceAll('º', '°')
        .replaceAll('’', "'")
        .replaceAll('″', '"')
        .trim();
    final match = RegExp(
      r"^(\d{1,3})\s*°\s*(\d{1,3})\s*[\'\u2019]\s*(\d{1,3})\s*\x22\s*([NSEW])$",
    ).firstMatch(normalized);
    if (match == null) {
      return null;
    }
    final degrees = int.tryParse(match.group(1) ?? '');
    final minutes = int.tryParse(match.group(2) ?? '');
    final seconds = int.tryParse(match.group(3) ?? '');
    final hemisphere = match.group(4);
    if (degrees == null || minutes == null || seconds == null) {
      return null;
    }
    final decimal = degrees + (minutes / 60) + (seconds / 3600);
    if (hemisphere == 'S' || hemisphere == 'W') {
      return -decimal;
    }
    return decimal;
  }

  int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.round();
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  double? _msToKnots(double? value) {
    if (value == null) {
      return null;
    }
    return value * 1.943844;
  }

  double _distanceKm({
    required double latitudeA,
    required double longitudeA,
    required double latitudeB,
    required double longitudeB,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(latitudeB - latitudeA);
    final dLon = _toRadians(longitudeB - longitudeA);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitudeA)) *
            math.cos(_toRadians(latitudeB)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double value) => value * (math.pi / 180);
}

class AemetObservationException implements Exception {
  const AemetObservationException(this.message);

  final String message;

  @override
  String toString() => 'AemetObservationException($message)';
}

class _CachedObservationList {
  const _CachedObservationList({
    required this.createdAt,
    required this.payload,
  });

  final DateTime createdAt;
  final List<Map<String, dynamic>> payload;
}
