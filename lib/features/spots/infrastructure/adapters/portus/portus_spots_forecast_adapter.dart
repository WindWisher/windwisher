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
  static List<_PortusGridPoint>? _cachedWavePoints;
  static List<_PortusGridPoint>? _cachedCurrentPoints;
  static final Map<String, _CachedPortusForecast> _forecastCache =
      <String, _CachedPortusForecast>{};
  static final Map<String, Future<List<SpotForecastEntry>>> _inFlightForecasts =
      <String, Future<List<SpotForecastEntry>>>{};
  static const Duration _forecastCacheTtl = Duration(minutes: 10);

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
    final cacheKey = _forecastCacheKey(location);
    final cached = _cachedForecast(cacheKey);
    if (cached != null) {
      return cached;
    }

    final inFlight = _inFlightForecasts[cacheKey];
    if (inFlight != null) {
      return inFlight;
    }

    final request = _fetchForecastRows(location);
    _inFlightForecasts[cacheKey] = request;
    try {
      final rows = await request;
      if (rows.isNotEmpty) {
        _forecastCache[cacheKey] = _CachedPortusForecast(
          createdAt: DateTime.now(),
          entries: rows,
        );
      }
      return rows;
    } finally {
      _inFlightForecasts.remove(cacheKey);
    }
  }

  Future<List<SpotForecastEntry>> _fetchForecastRows(
    ({double lat, double lon}) location,
  ) async {
    final atmospherePointFuture = _nearestPoint(
      location,
      pointsLoader: _fetchAtmospherePoints,
      emptyMessage: 'Portus no ha devuelto puntos de malla atmosfericos.',
    );
    final waveByTimestampFuture = _safeFetchWaveByTimestamp(location);
    final marineByTimestampFuture = _safeFetchMarineByTimestamp(location);

    final atmospherePoint = await atmospherePointFuture;
    final rawWindRows = await _fetchJson(_windForecastUrl(atmospherePoint.id));
    if (rawWindRows is! List) {
      return const <SpotForecastEntry>[];
    }

    final waveByTimestamp = await waveByTimestampFuture;
    final marineByTimestamp = await marineByTimestampFuture;

    final rows = <SpotForecastEntry>[];
    for (final rawRow in rawWindRows) {
      final row = _parseWindForecastRow(
        rawRow,
        waveByTimestamp: waveByTimestamp,
        marineByTimestamp: marineByTimestamp,
      );
      if (row != null) {
        rows.add(row);
      }
    }
    return rows;
  }

  List<SpotForecastEntry>? _cachedForecast(String cacheKey) {
    final cached = _forecastCache[cacheKey];
    if (cached == null) {
      return null;
    }
    final isFresh =
        DateTime.now().difference(cached.createdAt) <= _forecastCacheTtl;
    if (!isFresh) {
      _forecastCache.remove(cacheKey);
      return null;
    }
    return cached.entries;
  }

  String _forecastCacheKey(({double lat, double lon}) location) {
    final lat = location.lat.toStringAsFixed(4);
    final lon = location.lon.toStringAsFixed(4);
    return 'Portus|$lat|$lon';
  }

  ({double lat, double lon}) _resolveLocation(SpotItem spot) {
    final latitude = spot.latitude;
    final longitude = spot.longitude;
    if (latitude == null || longitude == null) {
      throw StateError('Portus requiere coordenadas en el spot.');
    }
    return (lat: latitude, lon: longitude);
  }

  Future<_PortusGridPoint> _nearestPoint(
    ({double lat, double lon}) location, {
    required Future<List<_PortusGridPoint>> Function() pointsLoader,
    required String emptyMessage,
  }) async {
    final points = await pointsLoader();
    if (points.isEmpty) {
      throw StateError(emptyMessage);
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

    final rawPoints = await _fetchJson(_atmospherePointsUrl);
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

  Future<List<_PortusGridPoint>> _fetchWavePoints() async {
    final cached = _cachedWavePoints;
    if (cached != null) {
      return cached;
    }

    final rawPoints = await _fetchJson(_wavePointsUrl);
    if (rawPoints is! List) {
      return const <_PortusGridPoint>[];
    }

    final points = rawPoints
        .whereType<Map<String, dynamic>>()
        .map(_PortusGridPoint.tryParse)
        .nonNulls
        .toList(growable: false);
    _cachedWavePoints = points;
    return points;
  }

  Future<List<_PortusGridPoint>> _fetchCurrentPoints() async {
    final cached = _cachedCurrentPoints;
    if (cached != null) {
      return cached;
    }

    final rawPoints = await _fetchJson(_currentPointsUrl);
    if (rawPoints is! List) {
      return const <_PortusGridPoint>[];
    }

    final points = rawPoints
        .whereType<Map<String, dynamic>>()
        .map(_PortusGridPoint.tryParse)
        .nonNulls
        .toList(growable: false);
    _cachedCurrentPoints = points;
    return points;
  }

  Future<Map<int, _PortusWaveForecast>> _safeFetchWaveByTimestamp(
    ({double lat, double lon}) location,
  ) async {
    try {
      final point = await _nearestPoint(
        location,
        pointsLoader: _fetchWavePoints,
        emptyMessage: 'Portus no ha devuelto puntos de malla de oleaje.',
      );
      final rawRows = await _fetchJson(_waveForecastUrl(point.id));
      if (rawRows is! List) {
        return const <int, _PortusWaveForecast>{};
      }
      return _parseWaveForecastRows(rawRows);
    } catch (_) {
      return const <int, _PortusWaveForecast>{};
    }
  }

  Future<Map<int, _PortusMarineForecast>> _safeFetchMarineByTimestamp(
    ({double lat, double lon}) location,
  ) async {
    try {
      final point = await _nearestPoint(
        location,
        pointsLoader: _fetchCurrentPoints,
        emptyMessage: 'Portus no ha devuelto puntos de malla oceanicos.',
      );
      final rawRows = await _fetchJson(_marineForecastUrl(point.id));
      if (rawRows is! List) {
        return const <int, _PortusMarineForecast>{};
      }
      return _parseMarineForecastRows(rawRows);
    } catch (_) {
      return const <int, _PortusMarineForecast>{};
    }
  }

  SpotForecastEntry? _parseWindForecastRow(
    dynamic rawRow, {
    required Map<int, _PortusWaveForecast> waveByTimestamp,
    required Map<int, _PortusMarineForecast> marineByTimestamp,
  }) {
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
    final timestampKey = timestampSeconds.round();
    final windFromDeg = (propagationDeg.round() + 180) % 360;
    final wave = waveByTimestamp[timestampKey];
    final marine = marineByTimestamp[timestampKey];
    return SpotForecastEntry(
      time: DateTime.fromMillisecondsSinceEpoch(
        timestampMillis,
        isUtc: true,
      ).toLocal(),
      windKnots: _mpsToKnots(windMps).round(),
      windDeg: windFromDeg,
      waterTempC: marine?.waterTempC?.round(),
      waveM: wave?.heightM,
      wavePeriodSeconds: wave?.peakPeriodSeconds,
      waveDirDeg: wave?.directionDeg,
      currentMps: marine?.currentMps,
      currentDirDeg: marine?.currentDirDeg,
      salinityPsu: marine?.salinityPsu,
    );
  }

  Map<int, _PortusWaveForecast> _parseWaveForecastRows(List<dynamic> rawRows) {
    final rows = <int, _PortusWaveForecast>{};
    for (final rawRow in rawRows) {
      if (rawRow is! List || rawRow.length < 5) {
        continue;
      }
      final timestampSeconds = _toDouble(rawRow[0]);
      final heightM = _toDouble(rawRow[1]);
      final peakPeriodSeconds = _toDouble(rawRow[2]);
      final meanPeriodSeconds = _toDouble(rawRow[3]);
      final propagationDeg = _toDouble(rawRow[4]);
      if (timestampSeconds == null || heightM == null) {
        continue;
      }
      rows[timestampSeconds.round()] = _PortusWaveForecast(
        heightM: heightM,
        peakPeriodSeconds: peakPeriodSeconds,
        meanPeriodSeconds: meanPeriodSeconds,
        directionDeg: propagationDeg == null
            ? null
            : (propagationDeg.round() + 180) % 360,
      );
    }
    return rows;
  }

  Map<int, _PortusMarineForecast> _parseMarineForecastRows(
    List<dynamic> rawRows,
  ) {
    final rows = <int, _PortusMarineForecast>{};
    for (final rawRow in rawRows) {
      if (rawRow is! List || rawRow.length < 5) {
        continue;
      }
      final timestampSeconds = _toDouble(rawRow[0]);
      final waterTempC = _toDouble(rawRow[1]);
      final currentMps = _toDouble(rawRow[2]);
      final currentDir = _toDouble(rawRow[3]);
      final salinityPsu = _toDouble(rawRow[4]);
      if (timestampSeconds == null) {
        continue;
      }
      rows[timestampSeconds.round()] = _PortusMarineForecast(
        waterTempC: waterTempC,
        currentMps: currentMps,
        currentDirDeg: currentDir?.round(),
        salinityPsu: salinityPsu,
      );
    }
    return rows;
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

  String _windForecastUrl(String pointId) {
    return 'https://poem.puertos.es/portus/ForecastData/Atmosfera/forecast'
        '?code=$pointId&fields=Datetime,WindSpeed,WindDir180';
  }

  String _waveForecastUrl(String pointId) {
    return 'https://poem.puertos.es/portus/ForecastData/Siwana/forecast'
        '?code=$pointId&fields=Datetime,Hm0,Tp,Tm02,MeanDir180';
  }

  String _marineForecastUrl(String pointId) {
    return 'https://poem.puertos.es/portus/ForecastData/Cirana/forecast'
        '?code=$pointId&fields=Datetime,WaterTemp,CurrentSpeed,CurrentDir,Salinity';
  }

  static const _atmospherePointsUrl =
      'https://portus.puertos.es/portussvr/api/puntosMalla/portus/pred/Atmosfera';
  static const _wavePointsUrl =
      'https://portus.puertos.es/portussvr/api/puntosMalla/portus/pred/Wana';
  static const _currentPointsUrl =
      'https://portus.puertos.es/portussvr/api/puntosMalla/portus/pred/Cirana';

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

class _PortusWaveForecast {
  const _PortusWaveForecast({
    required this.heightM,
    this.peakPeriodSeconds,
    this.meanPeriodSeconds,
    this.directionDeg,
  });

  final double heightM;
  final double? peakPeriodSeconds;
  final double? meanPeriodSeconds;
  final int? directionDeg;
}

class _PortusMarineForecast {
  const _PortusMarineForecast({
    this.waterTempC,
    this.currentMps,
    this.currentDirDeg,
    this.salinityPsu,
  });

  final double? waterTempC;
  final double? currentMps;
  final int? currentDirDeg;
  final double? salinityPsu;
}

class _CachedPortusForecast {
  const _CachedPortusForecast({required this.createdAt, required this.entries});

  final DateTime createdAt;
  final List<SpotForecastEntry> entries;
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
