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
    final rows = await _client
        .from('spot_live_observations')
        .select(
          'observed_at, wind_knots, wind_min_knots, gust_knots, wind_direction_deg',
        )
        .eq('station_key', stationKey)
        .gte('observed_at', since)
        .order('observed_at');

    return rows
        .whereType<Map<String, dynamic>>()
        .map(_parsePoint)
        .nonNulls
        .toList(growable: false);
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
