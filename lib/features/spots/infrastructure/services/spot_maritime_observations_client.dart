import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/spots/infrastructure/services/spot_live_observation_history_client.dart';

class SpotMaritimeObservation {
  const SpotMaritimeObservation({
    required this.provider,
    required this.stationKey,
    required this.platformId,
    required this.platformName,
    required this.platformType,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.observedAt,
    required this.windKnots,
    required this.windDirDeg,
    required this.gustKnots,
    required this.airTempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.waveHeightM,
    required this.wavePeriodS,
    required this.seaSurfaceTempC,
  });

  final String provider;
  final String stationKey;
  final String platformId;
  final String? platformName;
  final String? platformType;
  final double latitude;
  final double longitude;
  final double distanceKm;
  final DateTime? observedAt;
  final double? windKnots;
  final int? windDirDeg;
  final double? gustKnots;
  final double? airTempC;
  final int? pressureHpa;
  final int? humidityPct;
  final double? waveHeightM;
  final double? wavePeriodS;
  final double? seaSurfaceTempC;

  String get displayName {
    final name = platformName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return platformId;
  }
}

class SpotMaritimeObservationsResult {
  const SpotMaritimeObservationsResult({
    required this.observations,
    required this.total,
    required this.offset,
    required this.limit,
    required this.hasMore,
  });

  static const empty = SpotMaritimeObservationsResult(
    observations: <SpotMaritimeObservation>[],
    total: 0,
    offset: 0,
    limit: 10,
    hasMore: false,
  );

  final List<SpotMaritimeObservation> observations;
  final int total;
  final int offset;
  final int limit;
  final bool hasMore;
}

class SpotMaritimeObservationsClient {
  SpotMaritimeObservationsClient({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static SpotMaritimeObservationsClient? maybeCreate() {
    return EnvConfig.supabaseConfigured
        ? SpotMaritimeObservationsClient()
        : null;
  }

  Future<SpotMaritimeObservationsResult> fetchNearby({
    required String spotName,
    required double latitude,
    required double longitude,
    double radiusKm = 10,
    int maxResults = 10,
    int offset = 0,
    bool forceRefresh = false,
  }) async {
    if (!EnvConfig.supabaseConfigured) {
      return SpotMaritimeObservationsResult.empty;
    }

    try {
      return await _invokeNearbyFunction(
        functionName: 'copernicus-marine-nearby',
        spotName: spotName,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        maxResults: maxResults,
        offset: offset,
        forceRefresh: forceRefresh,
      );
    } catch (error) {
      debugPrint('Copernicus Marine nearby failed, trying MADIS: $error');
    }

    return _invokeNearbyFunction(
      functionName: 'madis-maritime-nearby',
      spotName: spotName,
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      maxResults: maxResults,
      offset: offset,
      forceRefresh: forceRefresh,
    );
  }

  Future<SpotMaritimeObservationsResult> _invokeNearbyFunction({
    required String functionName,
    required String spotName,
    required double latitude,
    required double longitude,
    required double radiusKm,
    required int maxResults,
    required int offset,
    required bool forceRefresh,
  }) async {
    final response = await _client.functions
        .invoke(
          functionName,
          body: <String, Object?>{
            'spotKey': _spotKey(spotName),
            'spotName': spotName,
            'latitude': latitude,
            'longitude': longitude,
            'radiusKm': radiusKm,
            'maxResults': maxResults,
            'offset': offset,
            'forceRefresh': forceRefresh,
          },
        )
        .timeout(const Duration(seconds: 25));

    final data = response.data;
    if (data is! Map) {
      return SpotMaritimeObservationsResult.empty;
    }
    final observations = data['observations'];
    if (observations is! List) {
      return SpotMaritimeObservationsResult.empty;
    }
    final parsedObservations = observations
        .whereType<Map>()
        .map((row) => _parseObservation(row.cast<String, dynamic>()))
        .nonNulls
        .toList(growable: false);
    return SpotMaritimeObservationsResult(
      observations: parsedObservations,
      total: _readInt(data['total']) ?? parsedObservations.length,
      offset: _readInt(data['offset']) ?? offset,
      limit: _readInt(data['limit']) ?? maxResults,
      hasMore: data['hasMore'] == true,
    );
  }

  Future<List<SpotLiveObservationHistoryPoint>> fetchHistory({
    required String spotName,
    required String stationKey,
    Duration range = const Duration(hours: 72),
  }) async {
    if (!EnvConfig.supabaseConfigured) {
      return const <SpotLiveObservationHistoryPoint>[];
    }
    final since = DateTime.now().toUtc().subtract(range).toIso8601String();
    final rows = await _client
        .from('spot_maritime_observations')
        .select('observed_at, wind_speed_knots, gust_knots, wind_dir_deg')
        .eq('spot_key', _spotKey(spotName))
        .eq('station_key', stationKey)
        .gte('observed_at', since)
        .order('observed_at')
        .limit(1000)
        .timeout(const Duration(seconds: 12));

    return rows
        .whereType<Map<String, dynamic>>()
        .map(_parseHistoryPoint)
        .nonNulls
        .toList(growable: false);
  }

  SpotMaritimeObservation? _parseObservation(Map<String, dynamic> row) {
    final stationKey = row['station_key'] as String?;
    final platformId = row['platform_id'] as String?;
    final latitude = _readDouble(row['latitude']);
    final longitude = _readDouble(row['longitude']);
    final distanceKm = _readDouble(row['distance_km']);
    if (stationKey == null ||
        platformId == null ||
        latitude == null ||
        longitude == null ||
        distanceKm == null) {
      debugPrint('SpotMaritimeObservations invalid row=$row');
      return null;
    }
    return SpotMaritimeObservation(
      provider: row['provider'] as String? ?? 'MADIS_MARITIME',
      stationKey: stationKey,
      platformId: platformId,
      platformName: row['platform_name'] as String?,
      platformType: row['platform_type'] as String?,
      latitude: latitude,
      longitude: longitude,
      distanceKm: distanceKm,
      observedAt: DateTime.tryParse(
        row['observed_at'] as String? ?? '',
      )?.toLocal(),
      windKnots: _readDouble(row['wind_speed_knots']),
      windDirDeg: _readDouble(row['wind_dir_deg'])?.round(),
      gustKnots: _readDouble(row['gust_knots']),
      airTempC: _readDouble(row['air_temp_c']),
      pressureHpa: _readDouble(row['pressure_hpa'])?.round(),
      humidityPct: _readDouble(row['humidity_pct'])?.round(),
      waveHeightM: _readDouble(row['wave_height_m']),
      wavePeriodS: _readDouble(row['wave_period_s']),
      seaSurfaceTempC: _readDouble(row['sea_surface_temp_c']),
    );
  }

  SpotLiveObservationHistoryPoint? _parseHistoryPoint(
    Map<String, dynamic> row,
  ) {
    final observedAt = DateTime.tryParse(row['observed_at'] as String? ?? '');
    if (observedAt == null) {
      return null;
    }
    return SpotLiveObservationHistoryPoint(
      observedAt: observedAt.toLocal(),
      windKnots: _readDouble(row['wind_speed_knots']),
      windMinKnots: null,
      gustKnots: _readDouble(row['gust_knots']),
      windDirectionDeg: _readDouble(row['wind_dir_deg'])?.round(),
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

  String _spotKey(String spotName) {
    return spotName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'[^a-z0-9:_-]'), '');
  }
}
