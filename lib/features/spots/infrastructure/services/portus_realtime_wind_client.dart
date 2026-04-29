import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

class PortusRealtimeWindClient {
  PortusRealtimeWindClient({
    HttpClient? httpClient,
    Future<dynamic> Function(String url, Object? body)? fetchJson,
  }) : _httpClient = httpClient,
       _fetchJsonOverride = fetchJson;

  final HttpClient? _httpClient;
  final Future<dynamic> Function(String url, Object? body)? _fetchJsonOverride;

  static List<PortusWindStation>? _cachedWindStations;

  Future<List<PortusWindSnapshot>> fetchNearestWindStations({
    required double latitude,
    required double longitude,
    int limit = 6,
    double maxDistanceKm = 80,
  }) async {
    final stations = await _fetchWindStations();
    final nearest =
        stations
            .map(
              (station) => (
                station: station,
                distanceKm: _distanceKm(
                  latitude,
                  longitude,
                  station.latitude,
                  station.longitude,
                ),
              ),
            )
            .where((entry) => entry.distanceKm <= maxDistanceKm)
            .toList(growable: false)
          ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    final snapshots = <PortusWindSnapshot>[];
    for (final entry in nearest.take(limit * 2)) {
      final latest = await _fetchLatestWind(entry.station);
      if (latest == null) {
        continue;
      }
      snapshots.add(latest.copyWith(distanceKm: entry.distanceKm));
      if (snapshots.length >= limit) {
        break;
      }
    }
    return snapshots;
  }

  Future<PortusWindSnapshot?> fetchWindStation({required int stationId}) async {
    final stations = await _fetchWindStations();
    final station = stations.cast<PortusWindStation?>().firstWhere(
      (entry) => entry?.id == stationId,
      orElse: () => null,
    );
    if (station == null) {
      return null;
    }
    return _fetchLatestWind(station);
  }

  Future<List<PortusWindHistoryPoint>> fetchWindHistory({
    required int stationId,
  }) async {
    final raw = await _fetchJson(
      '$_baseUrl/RTData/station/$stationId?locale=es',
      _windHistoryParameterIds,
    );
    if (raw is! List) {
      return const <PortusWindHistoryPoint>[];
    }
    final points =
        raw
            .whereType<Map<String, dynamic>>()
            .map(_parseHistoryPoint)
            .nonNulls
            .toList(growable: false)
          ..sort((a, b) => a.time.compareTo(b.time));
    return points;
  }

  Future<List<PortusWindStation>> _fetchWindStations() async {
    final cached = _cachedWindStations;
    if (cached != null) {
      return cached;
    }
    final raw = await _fetchJson(_windStationsUrl, null);
    if (raw is! List) {
      return const <PortusWindStation>[];
    }
    final stations = raw
        .whereType<Map<String, dynamic>>()
        .map(PortusWindStation.tryParse)
        .nonNulls
        .toList(growable: false);
    _cachedWindStations = stations;
    return stations;
  }

  Future<PortusWindSnapshot?> _fetchLatestWind(
    PortusWindStation station,
  ) async {
    final raw = await _fetchJson(
      '$_baseUrl/lastData/station/${station.id}?locale=es',
      const <String>['WIND', 'AIR_TEMP', 'AIR_PRESURE'],
    );
    if (raw is! Map<String, dynamic>) {
      return null;
    }
    final observedAt = _parsePortusDate(raw['fecha'] as String?);
    final rawData = raw['datos'];
    if (observedAt == null || rawData is! List) {
      return null;
    }

    double? windMps;
    double? windDeg;
    double? gustMps;
    double? tempC;
    int? pressureHpa;
    for (final item in rawData.whereType<Map<String, dynamic>>()) {
      final param = item['paramEseoo'] as String?;
      final value = _scaledValue(item);
      if (value == null) {
        continue;
      }
      switch (param) {
        case 'WindSpeed':
          windMps = value;
        case 'WindDir':
          windDeg = value;
        case 'WindSpeedMax':
          gustMps = value;
        case 'AirTemp':
          tempC = value;
        case 'AirPressure':
          pressureHpa = value.round();
      }
    }
    if (windMps == null) {
      return null;
    }
    return PortusWindSnapshot(
      stationId: station.id,
      stationName: station.name,
      latitude: station.latitude,
      longitude: station.longitude,
      cadenceMinutes: station.cadenceMinutes,
      distanceKm: null,
      windKnots: _mpsToKnots(windMps),
      windDirectionDeg: windDeg?.round(),
      gustKnots: gustMps == null ? null : _mpsToKnots(gustMps),
      tempC: tempC,
      pressureHpa: pressureHpa,
      observedAt: observedAt,
    );
  }

  PortusWindHistoryPoint? _parseHistoryPoint(Map<String, dynamic> json) {
    final time = _parsePortusDate(json['fecha'] as String?);
    final rawData = json['datos'];
    if (time == null || rawData is! List) {
      return null;
    }

    double? windMps;
    double? windDeg;
    double? gustMps;
    for (final item in rawData.whereType<Map<String, dynamic>>()) {
      final param = item['paramEseoo'] as String?;
      final value = _scaledValue(item);
      if (value == null) {
        continue;
      }
      switch (param) {
        case 'WindSpeed':
          windMps = value;
        case 'WindDir':
          windDeg = value;
        case 'WindSpeedMax':
          gustMps = value;
      }
    }
    if (windMps == null) {
      return null;
    }
    return PortusWindHistoryPoint(
      time: time,
      windKnots: _mpsToKnots(windMps),
      gustKnots: gustMps == null ? null : _mpsToKnots(gustMps),
      windDirectionDeg: windDeg?.round(),
    );
  }

  double? _scaledValue(Map<String, dynamic> item) {
    final rawValue = item['valor'];
    final factor = (item['factor'] as num?)?.toDouble();
    final parsed = switch (rawValue) {
      num value => value.toDouble(),
      String value => double.tryParse(value.replaceAll(',', '.')),
      _ => null,
    };
    if (parsed == null || factor == null || factor == 0) {
      return null;
    }
    return parsed / factor;
  }

  DateTime? _parsePortusDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})',
    ).firstMatch(raw.trim());
    if (match == null) {
      return null;
    }
    int part(int index) => int.parse(match.group(index)!);
    return DateTime.utc(
      part(1),
      part(2),
      part(3),
      part(4),
      part(5),
      part(6),
    ).toLocal();
  }

  Future<dynamic> _fetchJson(String url, Object? body) async {
    final override = _fetchJsonOverride;
    if (override != null) {
      return override(url, body);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Portus realtime direct HttpClient is not available on web.',
      );
    }
    final client = _httpClient ?? _createPortusHttpClient();
    final request = body == null
        ? await client.getUrl(Uri.parse(url))
        : await client.postUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (body != null) {
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(body));
    }
    final response = await request.close().timeout(const Duration(seconds: 15));
    final text = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Portus realtime request failed: ${response.statusCode} ${text.length > 240 ? text.substring(0, 240) : text}',
        uri: Uri.parse(url),
      );
    }
    return jsonDecode(text);
  }

  HttpClient _createPortusHttpClient() {
    return HttpClient()
      ..badCertificateCallback = (certificate, host, port) {
        return host == 'portus.puertos.es';
      };
  }

  double _distanceKm(double latA, double lonA, double latB, double lonB) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(latB - latA);
    final dLon = _toRadians(lonB - lonA);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latA)) *
            math.cos(_toRadians(latB)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double degrees) => degrees * math.pi / 180;

  double _mpsToKnots(double mps) => mps * 1.9438444924406;

  static const String _baseUrl = 'https://portus.puertos.es/portussvr/api';
  static const String _windStationsUrl =
      '$_baseUrl/estaciones/rt/WIND?locale=es';
  static const List<int> _windHistoryParameterIds = <int>[42, 40, 43];
}

class PortusWindStation {
  const PortusWindStation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.cadenceMinutes,
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int? cadenceMinutes;

  static PortusWindStation? tryParse(Map<String, dynamic> json) {
    final id = (json['id'] as num?)?.toInt();
    final name = (json['nombre'] as String?)?.trim();
    final latitude = (json['latitud'] as num?)?.toDouble();
    final longitude = (json['longitud'] as num?)?.toDouble();
    if (id == null ||
        name == null ||
        name.isEmpty ||
        latitude == null ||
        longitude == null) {
      return null;
    }
    return PortusWindStation(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      cadenceMinutes: (json['cadencia'] as num?)?.toInt(),
    );
  }
}

class PortusWindHistoryPoint {
  const PortusWindHistoryPoint({
    required this.time,
    required this.windKnots,
    required this.gustKnots,
    required this.windDirectionDeg,
  });

  final DateTime time;
  final double windKnots;
  final double? gustKnots;
  final int? windDirectionDeg;
}

class PortusWindSnapshot {
  const PortusWindSnapshot({
    required this.stationId,
    required this.stationName,
    required this.latitude,
    required this.longitude,
    required this.cadenceMinutes,
    required this.distanceKm,
    required this.windKnots,
    required this.windDirectionDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.observedAt,
  });

  final int stationId;
  final String stationName;
  final double latitude;
  final double longitude;
  final int? cadenceMinutes;
  final double? distanceKm;
  final double windKnots;
  final int? windDirectionDeg;
  final double? gustKnots;
  final double? tempC;
  final int? pressureHpa;
  final DateTime observedAt;

  PortusWindSnapshot copyWith({double? distanceKm}) {
    return PortusWindSnapshot(
      stationId: stationId,
      stationName: stationName,
      latitude: latitude,
      longitude: longitude,
      cadenceMinutes: cadenceMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      windKnots: windKnots,
      windDirectionDeg: windDirectionDeg,
      gustKnots: gustKnots,
      tempC: tempC,
      pressureHpa: pressureHpa,
      observedAt: observedAt,
    );
  }
}
