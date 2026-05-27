import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';

class SpotLiveObservationHistoryPoint {
  const SpotLiveObservationHistoryPoint({
    required this.observedAt,
    required this.windKnots,
    required this.windMinKnots,
    required this.gustKnots,
    required this.windDirectionDeg,
  });

  final DateTime observedAt;
  final double? windKnots;
  final double? windMinKnots;
  final double? gustKnots;
  final int? windDirectionDeg;
}

class SpotLiveObservationHistoryClient {
  SpotLiveObservationHistoryClient({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static SpotLiveObservationHistoryClient? maybeCreate() {
    return EnvConfig.supabaseConfigured
        ? SpotLiveObservationHistoryClient()
        : null;
  }

  Future<List<SpotLiveObservationHistoryPoint>> fetchStationHistory({
    required String stationKey,
    Duration range = const Duration(hours: 72),
  }) async {
    if (!EnvConfig.supabaseConfigured) {
      return const <SpotLiveObservationHistoryPoint>[];
    }

    final since = DateTime.now().toUtc().subtract(range).toIso8601String();
    final rows = await _fetchRows(stationKey: stationKey, since: since);

    final points = rows
        .whereType<Map<String, dynamic>>()
        .map(_parsePoint)
        .nonNulls
        .toList(growable: false);
    debugPrint(
      'SpotLiveObservationHistory stationKey=$stationKey rows=${rows.length} '
      'points=${points.length} first=${points.isEmpty ? null : points.first.observedAt.toIso8601String()} '
      'last=${points.isEmpty ? null : points.last.observedAt.toIso8601String()}',
    );
    return points;
  }

  Future<List<Map<String, dynamic>>> _fetchRows({
    required String stationKey,
    required String since,
  }) async {
    if (!kIsWeb) {
      return _fetchRowsWithRest(stationKey: stationKey, since: since).onError((
        error,
        stackTrace,
      ) async {
        debugPrint(
          'SpotLiveObservationHistory rest-primary-fallback stationKey=$stationKey '
          'error=$error',
        );
        return _fetchRowsWithSdk(stationKey: stationKey, since: since);
      });
    }

    return _fetchRowsWithSdk(stationKey: stationKey, since: since).onError((
      error,
      stackTrace,
    ) async {
      debugPrint(
        'SpotLiveObservationHistory sdk-fallback stationKey=$stationKey '
        'error=$error',
      );
      return _fetchRowsWithRest(stationKey: stationKey, since: since);
    });
  }

  Future<List<Map<String, dynamic>>> _fetchRowsWithSdk({
    required String stationKey,
    required String since,
  }) async {
    final rows = await _client
        .from('spot_live_observations')
        .select(
          'observed_at, wind_knots, wind_min_knots, gust_knots, wind_direction_deg',
        )
        .eq('station_key', stationKey)
        .gte('observed_at', since)
        .order('observed_at')
        .limit(1000)
        .timeout(const Duration(seconds: 12));
    return rows.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> _fetchRowsWithRest({
    required String stationKey,
    required String since,
  }) async {
    if (kIsWeb) {
      return const <Map<String, dynamic>>[];
    }
    final baseUrl = EnvConfig.supabaseUrl.trim();
    final anonKey = EnvConfig.supabaseAnonKey.trim();
    if (baseUrl.isEmpty || anonKey.isEmpty) {
      return const <Map<String, dynamic>>[];
    }

    final uri = Uri.parse(
      '$baseUrl/rest/v1/spot_live_observations'
      '?select=observed_at,wind_knots,wind_min_knots,gust_knots,wind_direction_deg'
      '&station_key=eq.${Uri.encodeQueryComponent(stationKey)}'
      '&observed_at=gte.${Uri.encodeQueryComponent(since)}'
      '&order=observed_at.asc'
      '&limit=1000',
    );
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client
          .getUrl(uri)
          .timeout(const Duration(seconds: 8));
      request.headers
        ..set(HttpHeaders.acceptHeader, 'application/json')
        ..set('apikey', anonKey)
        ..set(HttpHeaders.authorizationHeader, 'Bearer $anonKey')
        ..set(HttpHeaders.userAgentHeader, 'WindWisher/1.0');
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'spot-live-history-http-${response.statusCode}:$body',
          uri: uri,
        );
      }
      final decoded = jsonDecode(body);
      if (decoded is! List) {
        return const <Map<String, dynamic>>[];
      }
      return decoded.whereType<Map<String, dynamic>>().toList(growable: false);
    } finally {
      client.close(force: true);
    }
  }

  SpotLiveObservationHistoryPoint? _parsePoint(Map<String, dynamic> row) {
    final observedAt = DateTime.tryParse(row['observed_at'] as String? ?? '');
    if (observedAt == null) {
      return null;
    }
    return SpotLiveObservationHistoryPoint(
      observedAt: observedAt.toLocal(),
      windKnots: _readDouble(row['wind_knots']),
      windMinKnots: _readDouble(row['wind_min_knots']),
      gustKnots: _readDouble(row['gust_knots']),
      windDirectionDeg: _readDouble(row['wind_direction_deg'])?.round(),
    );
  }

  double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
