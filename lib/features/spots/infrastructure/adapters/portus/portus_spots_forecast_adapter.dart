import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_forecast_port.dart';

class PortusSpotsForecastAdapter implements SpotsForecastPort {
  PortusSpotsForecastAdapter({
    HttpClient? httpClient,
    Future<dynamic> Function(String url)? fetchJson,
  }) : _httpClient = httpClient,
       _fetchJsonOverride = fetchJson;

  final HttpClient? _httpClient;
  final Future<dynamic> Function(String url)? _fetchJsonOverride;

  static List<_PortusGridPoint>? _cachedAtmospherePoints;

  @override
  Future<List<SpotForecastEntry>> getForecast({
    required SpotItem spot,
    required String provider,
    required String model,
  }) async {
    if (provider != 'Portus') {
      return const <SpotForecastEntry>[];
    }

    final location = _resolveLocation(spot);
    final point = await _nearestAtmospherePoint(location);
    final rawRows = await _fetchJson(_forecastUrl(point.id));
    if (rawRows is! List) {
      return const <SpotForecastEntry>[];
    }

    final rows = <SpotForecastEntry>[];
    for (final rawRow in rawRows) {
      final row = _parseForecastRow(rawRow);
      if (row != null) {
        rows.add(row);
      }
    }
    return rows;
  }

  ({double lat, double lon}) _resolveLocation(SpotItem spot) {
    final latitude = spot.latitude;
    final longitude = spot.longitude;
    if (latitude == null || longitude == null) {
      throw StateError('Portus requiere coordenadas en el spot.');
    }
    return (lat: latitude, lon: longitude);
  }

  Future<_PortusGridPoint> _nearestAtmospherePoint(
    ({double lat, double lon}) location,
  ) async {
    final points = await _fetchAtmospherePoints();
    if (points.isEmpty) {
      throw StateError('Portus no ha devuelto puntos de malla.');
    }

    _PortusGridPoint nearest = points.first;
    var nearestDistance = double.infinity;
    for (final point in points) {
      final distance = _distanceKm(
        location.lat,
        location.lon,
        point.latitude,
        point.longitude,
      );
      if (distance < nearestDistance) {
        nearest = point;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  Future<List<_PortusGridPoint>> _fetchAtmospherePoints() async {
    final cached = _cachedAtmospherePoints;
    if (cached != null) {
      return cached;
    }

    final rawPoints = await _fetchJson(_pointsUrl);
    if (rawPoints is! List) {
      return const <_PortusGridPoint>[];
    }

    final points = rawPoints
        .whereType<Map<String, dynamic>>()
        .map(_PortusGridPoint.tryParse)
        .nonNulls
        .toList(growable: false);
    _cachedAtmospherePoints = points;
    return points;
  }

  SpotForecastEntry? _parseForecastRow(dynamic rawRow) {
    if (rawRow is! List || rawRow.length < 3) {
      return null;
    }

    final timestampSeconds = _toDouble(rawRow[0]);
    final windMps = _toDouble(rawRow[1]);
    final propagationDeg = _toDouble(rawRow[2]);
    if (timestampSeconds == null || windMps == null || propagationDeg == null) {
      return null;
    }

    final timestampMillis = (timestampSeconds * 1000).round();
    final windFromDeg = (propagationDeg.round() + 180) % 360;
    return SpotForecastEntry(
      time: DateTime.fromMillisecondsSinceEpoch(
        timestampMillis,
        isUtc: true,
      ).toLocal(),
      windKnots: _mpsToKnots(windMps).round(),
      windDeg: windFromDeg,
    );
  }

  Future<dynamic> _fetchJson(String url) async {
    final fetchJsonOverride = _fetchJsonOverride;
    if (fetchJsonOverride != null) {
      return fetchJsonOverride(url);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Portus direct HttpClient is not available on web.',
      );
    }

    final httpClient = _httpClient ?? _createPortusHttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Portus request failed: ${response.statusCode} ${body.length > 240 ? body.substring(0, 240) : body}',
        uri: Uri.parse(url),
      );
    }
    return jsonDecode(body);
  }

  HttpClient _createPortusHttpClient() {
    final httpClient = HttpClient();
    httpClient.badCertificateCallback = (_, host, _) =>
        host == 'poem.puertos.es' || host == 'portus.puertos.es';
    return httpClient;
  }

  String _forecastUrl(String pointId) {
    return 'https://poem.puertos.es/portus/ForecastData/Atmosfera/forecast'
        '?code=$pointId&fields=Datetime,WindSpeed,WindDir180';
  }

  static const _pointsUrl =
      'https://portus.puertos.es/portussvr/api/puntosMalla/portus/pred/Atmosfera';

  double _mpsToKnots(double value) => value * 1.9438444924406;

  double? _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }

  double _distanceKm(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusKm = 6371.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double value) => value * math.pi / 180;
}

class _PortusGridPoint {
  const _PortusGridPoint({
    required this.id,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final double latitude;
  final double longitude;

  static _PortusGridPoint? tryParse(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final latitude = _toPointDouble(json['latitud']);
    final longitude = _toPointDouble(json['longitud']);
    if (id == null || id.isEmpty || latitude == null || longitude == null) {
      return null;
    }
    return _PortusGridPoint(id: id, latitude: latitude, longitude: longitude);
  }

  static double? _toPointDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return null;
  }
}
