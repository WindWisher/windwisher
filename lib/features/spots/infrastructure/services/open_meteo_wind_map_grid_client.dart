import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class OpenMeteoWindMapGridNode {
  const OpenMeteoWindMapGridNode({
    required this.latitude,
    required this.longitude,
    required this.alignX,
    required this.alignY,
    required this.windKnots,
    required this.windDeg,
    this.gustKnots,
    this.waveM,
  });

  final double latitude;
  final double longitude;
  final double alignX;
  final double alignY;
  final int windKnots;
  final int windDeg;
  final int? gustKnots;
  final double? waveM;
}

class OpenMeteoWindMapGridSnapshot {
  const OpenMeteoWindMapGridSnapshot({
    required this.time,
    required this.nodes,
  });

  final DateTime time;
  final List<OpenMeteoWindMapGridNode> nodes;
}

class OpenMeteoWindMapGridClient {
  OpenMeteoWindMapGridClient({
    HttpClient? httpClient,
    Future<dynamic> Function(String url)? fetchJson,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient,
       _fetchJsonOverride = fetchJson,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  final HttpClient? _httpClient;
  final Future<dynamic> Function(String url)? _fetchJsonOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  Future<List<OpenMeteoWindMapGridSnapshot>> fetchGrid({
    required double centerLat,
    required double centerLon,
    required String model,
  }) async {
    final points = _gridPoints(centerLat: centerLat, centerLon: centerLon);
    final latitudes = points
        .map((point) => point.latitude.toStringAsFixed(5))
        .join(',');
    final longitudes = points
        .map((point) => point.longitude.toStringAsFixed(5))
        .join(',');

    final weatherJson = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchOpenMeteoWeatherGrid(
            latitudes: latitudes,
            longitudes: longitudes,
            model: model,
          )
        : await _fetchJson(_weatherUrl(latitudes, longitudes, model));
    final marineJson = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchOpenMeteoMarineGrid(
            latitudes: latitudes,
            longitudes: longitudes,
          )
        : await _fetchJson(_marineUrl(latitudes, longitudes));
    final weatherEntries = _normalizeMultiLocationResponse(weatherJson);
    final marineEntries = _normalizeMultiLocationResponse(marineJson);
    if (weatherEntries.isEmpty) {
      return const <OpenMeteoWindMapGridSnapshot>[];
    }

    final marineByLocation = <int, Map<String, dynamic>>{
      for (var i = 0; i < marineEntries.length; i++) i: marineEntries[i],
    };
    final snapshotsByTime = <DateTime, List<OpenMeteoWindMapGridNode>>{};

    for (var index = 0; index < weatherEntries.length && index < points.length; index++) {
      final weatherHourly = weatherEntries[index]['hourly'] as Map<String, dynamic>?;
      if (weatherHourly == null) {
        continue;
      }
      final marineHourly = marineByLocation[index]?['hourly'] as Map<String, dynamic>?;
      final weatherTimes = (weatherHourly['time'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>();
      final windSpeeds = _toNullableNumList(weatherHourly['wind_speed_10m']);
      final windDirections = _toNullableNumList(weatherHourly['wind_direction_10m']);
      final gusts = _toNullableNumList(weatherHourly['wind_gusts_10m']);
      final marineTimes = (marineHourly?['time'] as List<dynamic>? ?? const <dynamic>[])
          .cast<String>();
      final waves = _toNullableNumList(marineHourly?['wave_height']);
      final marineIndexByTime = <String, int>{
        for (var i = 0; i < marineTimes.length; i++) marineTimes[i]: i,
      };

      for (var timeIndex = 0; timeIndex < weatherTimes.length; timeIndex += 3) {
        final time = DateTime.tryParse(weatherTimes[timeIndex]);
        final speed = _numAtOrNull(windSpeeds, timeIndex);
        final direction = _numAtOrNull(windDirections, timeIndex);
        if (time == null || speed == null || direction == null) {
          continue;
        }
        final gust = _numAtOrNull(gusts, timeIndex);
        final marineIndex = marineIndexByTime[weatherTimes[timeIndex]];
        final wave = marineIndex == null ? null : _numAtOrNull(waves, marineIndex);
        snapshotsByTime.putIfAbsent(time, () => <OpenMeteoWindMapGridNode>[]).add(
          OpenMeteoWindMapGridNode(
            latitude: points[index].latitude,
            longitude: points[index].longitude,
            alignX: points[index].alignX,
            alignY: points[index].alignY,
            windKnots: _kmhToKnots(speed.toDouble()).round(),
            windDeg: direction.round(),
            gustKnots: gust == null ? null : _kmhToKnots(gust.toDouble()).round(),
            waveM: wave?.toDouble(),
          ),
        );
      }
    }

    final snapshots = snapshotsByTime.entries
        .where((entry) => entry.value.isNotEmpty)
        .map(
          (entry) => OpenMeteoWindMapGridSnapshot(
            time: entry.key,
            nodes: entry.value,
          ),
        )
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    return snapshots;
  }

  List<_GridPoint> _gridPoints({
    required double centerLat,
    required double centerLon,
  }) {
    const rowOffsets = <double>[-0.16, -0.08, 0.0, 0.08, 0.16];
    const colOffsets = <double>[-0.20, -0.10, 0.0, 0.10, 0.20];
    const aligns = <double>[0.12, 0.31, 0.50, 0.69, 0.88];
    final points = <_GridPoint>[];
    for (var row = 0; row < rowOffsets.length; row++) {
      for (var col = 0; col < colOffsets.length; col++) {
        points.add(
          _GridPoint(
            latitude: centerLat + rowOffsets[row],
            longitude: centerLon + colOffsets[col],
            alignX: aligns[col],
            alignY: aligns[row],
          ),
        );
      }
    }
    return points;
  }

  String _weatherUrl(String latitudes, String longitudes, String model) {
    final normalizedModel = switch (model) {
      'Best match' => null,
      'ICON' => 'icon_seamless',
      'ECMWF' => 'ecmwf_ifs025',
      'AROME Seamless' => 'meteofrance_arome_seamless',
      'AROME France' => 'meteofrance_arome_france',
      'ARPEGE Europe' => 'meteofrance_arpege_europe',
      'ARPEGE Seamless' => 'meteofrance_seamless',
      'ARPEGE World' => 'meteofrance_arpege_world',
      _ => 'gfs_seamless',
    };
    final modelsQuery = normalizedModel == null ? '' : '&models=$normalizedModel';
    return 'https://api.open-meteo.com/v1/forecast?latitude=$latitudes&longitude=$longitudes&hourly=wind_speed_10m,wind_direction_10m,wind_gusts_10m&forecast_days=16$modelsQuery&timezone=auto';
  }

  String _marineUrl(String latitudes, String longitudes) {
    return 'https://marine-api.open-meteo.com/v1/marine?latitude=$latitudes&longitude=$longitudes&hourly=wave_height&forecast_days=16&timezone=auto';
  }

  Future<dynamic> _fetchJson(String url) async {
    final override = _fetchJsonOverride;
    if (override != null) {
      return override(url);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Open-Meteo grid direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Open-Meteo grid request failed: ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }
    return jsonDecode(body);
  }

  List<Map<String, dynamic>> _normalizeMultiLocationResponse(dynamic json) {
    if (json is List) {
      return json.whereType<Map<String, dynamic>>().toList(growable: false);
    }
    if (json is Map<String, dynamic>) {
      return <Map<String, dynamic>>[json];
    }
    return const <Map<String, dynamic>>[];
  }

  List<num?> _toNullableNumList(dynamic source) {
    if (source is! List) {
      return const <num?>[];
    }
    return source.map((value) => value is num ? value : null).toList(growable: false);
  }

  num? _numAtOrNull(List<num?> values, int index) {
    if (index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  double _kmhToKnots(double kmh) => kmh / 1.852;
}

class _GridPoint {
  const _GridPoint({
    required this.latitude,
    required this.longitude,
    required this.alignX,
    required this.alignY,
  });

  final double latitude;
  final double longitude;
  final double alignX;
  final double alignY;
}
