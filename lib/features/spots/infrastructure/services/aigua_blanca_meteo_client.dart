import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class AiguaBlancaMeteoPoint {
  const AiguaBlancaMeteoPoint({
    required this.time,
    required this.windKnots,
    required this.windDirectionDeg,
    required this.gustKnots,
  });

  final DateTime time;
  final double windKnots;
  final int? windDirectionDeg;
  final double? gustKnots;
}

class AiguaBlancaMeteoSnapshot {
  const AiguaBlancaMeteoSnapshot({
    required this.observedAt,
    required this.windKnots,
    required this.windDirectionDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.rainMm,
  });

  final DateTime observedAt;
  final double? windKnots;
  final int? windDirectionDeg;
  final double? gustKnots;
  final double? tempC;
  final int? pressureHpa;
  final int? humidityPct;
  final double? rainMm;
}

class AiguaBlancaMeteoFeed {
  const AiguaBlancaMeteoFeed({
    required this.points,
    required this.latestSnapshot,
  });

  final List<AiguaBlancaMeteoPoint> points;
  final AiguaBlancaMeteoSnapshot? latestSnapshot;
}

class AiguaBlancaMeteoClient {
  AiguaBlancaMeteoClient({
    HttpClient? httpClient,
    Future<Map<String, dynamic>> Function(String url, Map<String, String> headers)?
    fetchJson,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient,
       _fetchJsonOverride = fetchJson,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  static const String apiBaseUrl = 'https://meteo.feedket.com/api/endpoints';
  static const String latestUrl = '$apiBaseUrl/latest.php';
  static const String apiKey = 'GDFH85DF-GD75D65-SFSEF5';

  final HttpClient? _httpClient;
  final Future<Map<String, dynamic>> Function(
    String url,
    Map<String, String> headers,
  )?
  _fetchJsonOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  Future<AiguaBlancaMeteoFeed> fetchFeed() async {
    final payload = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchAiguaBlancaLatest()
        : await _fetchJson(
            latestUrl,
            const <String, String>{'X-API-KEY': apiKey},
          );
    final latest =
        payload['latest'] is Map<String, dynamic>
            ? payload['latest'] as Map<String, dynamic>
            : payload['latest'] is Map
            ? Map<String, dynamic>.from(payload['latest'] as Map)
            : null;
    final historyRaw =
        payload['history'] is List
            ? (payload['history'] as List)
            : const <Object?>[];
    final points = historyRaw
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .map(_parsePoint)
        .whereType<AiguaBlancaMeteoPoint>()
        .toList(growable: false);
    final sortedPoints = List<AiguaBlancaMeteoPoint>.from(points)
      ..sort((a, b) => a.time.compareTo(b.time));
    final latestSnapshot = latest == null ? null : _parseSnapshot(latest);
    final historySnapshot = sortedPoints.isEmpty
        ? null
        : AiguaBlancaMeteoSnapshot(
            observedAt: sortedPoints.last.time,
            windKnots: sortedPoints.last.windKnots,
            windDirectionDeg: sortedPoints.last.windDirectionDeg,
            gustKnots: sortedPoints.last.gustKnots,
            tempC: null,
            pressureHpa: null,
            humidityPct: null,
            rainMm: null,
          );
    return AiguaBlancaMeteoFeed(
      points: sortedPoints,
      latestSnapshot: _pickNewestSnapshot(latestSnapshot, historySnapshot),
    );
  }

  AiguaBlancaMeteoSnapshot? _pickNewestSnapshot(
    AiguaBlancaMeteoSnapshot? primary,
    AiguaBlancaMeteoSnapshot? fallback,
  ) {
    if (primary == null) {
      return fallback;
    }
    if (fallback == null) {
      return primary;
    }
    return primary.observedAt.isBefore(fallback.observedAt) ? fallback : primary;
  }

  AiguaBlancaMeteoPoint? _parsePoint(Map<String, dynamic> raw) {
    final time = _parseUtcTimestamp(raw['created_at']);
    final windKnots = _readDouble(raw['wind_speed_kt']);
    if (time == null || windKnots == null) {
      return null;
    }
    return AiguaBlancaMeteoPoint(
      time: time,
      windKnots: windKnots,
      windDirectionDeg: _readInt(raw['wind_dir']),
      gustKnots: _readDouble(raw['wind_gust_kt']),
    );
  }

  AiguaBlancaMeteoSnapshot? _parseSnapshot(Map<String, dynamic> raw) {
    final observedAt = _parseUtcTimestamp(raw['created_at']);
    final windKnots = _readDouble(raw['wind_speed_kt']);
    if (observedAt == null || windKnots == null) {
      return null;
    }
    return AiguaBlancaMeteoSnapshot(
      observedAt: observedAt,
      windKnots: windKnots,
      windDirectionDeg: _readInt(raw['wind_dir']),
      gustKnots: _readDouble(raw['wind_gust_kt']),
      tempC: _readDouble(raw['temp_c']),
      pressureHpa: _mmHgToHpa(_readDouble(raw['baromrelin']))?.round(),
      humidityPct: _readInt(raw['humidity']),
      rainMm: _readDouble(raw['day_rain_mm']),
    );
  }

  Future<Map<String, dynamic>> _fetchJson(
    String url,
    Map<String, String> headers,
  ) async {
    final override = _fetchJsonOverride;
    if (override != null) {
      return override(url, headers);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Aigua Blanca Meteo direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    headers.forEach(request.headers.set);
    request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Aigua Blanca Meteo returned ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('Invalid Aigua Blanca Meteo payload');
  }

  DateTime? _parseUtcTimestamp(Object? raw) {
    final value = raw?.toString().trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse('${value.replaceFirst(' ', 'T')}Z')?.toLocal();
  }

  double? _readDouble(Object? raw) => double.tryParse(raw?.toString() ?? '');

  int? _readInt(Object? raw) => int.tryParse(raw?.toString() ?? '');

  double? _mmHgToHpa(double? value) {
    if (value == null) {
      return null;
    }
    return value * 1.3332239;
  }
}
