import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class WundergroundPwsSnapshot {
  const WundergroundPwsSnapshot({
    required this.stationId,
    required this.observedAt,
    required this.observedAtLabel,
    required this.latitude,
    required this.longitude,
    required this.windKnots,
    required this.windDirectionDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.rainMm,
  });

  final String stationId;
  final DateTime? observedAt;
  final String? observedAtLabel;
  final double? latitude;
  final double? longitude;
  final double? windKnots;
  final int? windDirectionDeg;
  final double? gustKnots;
  final double? tempC;
  final int? pressureHpa;
  final int? humidityPct;
  final double? rainMm;
}

class WundergroundPwsHistoryPoint {
  const WundergroundPwsHistoryPoint({
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

class WundergroundPwsClient {
  WundergroundPwsClient({
    HttpClient? httpClient,
    Future<String> Function(Uri uri)? fetchText,
  }) : _httpClient = httpClient,
       _fetchTextOverride = fetchText;

  static const String _dashboardHost = 'www.wunderground.com';
  static const String _apiHost = 'api.weather.com';
  static const String _referer = 'https://www.wunderground.com/';

  final HttpClient? _httpClient;
  final Future<String> Function(Uri uri)? _fetchTextOverride;
  String? _cachedApiKey;

  Future<WundergroundPwsSnapshot?> fetchCurrent({
    required String stationId,
  }) async {
    final payload = await _fetchJson(
      _apiUri(path: '/v2/pws/observations/current', stationId: stationId),
    );
    final observations = payload['observations'];
    if (observations is! List || observations.isEmpty) {
      return null;
    }
    final observation = observations.first;
    if (observation is! Map<String, dynamic>) {
      return null;
    }
    return _snapshotFromObservation(observation);
  }

  Future<List<WundergroundPwsHistoryPoint>> fetchOneDayHistory({
    required String stationId,
  }) async {
    final payload = await _fetchJson(
      _apiUri(path: '/v2/pws/observations/all/1day', stationId: stationId),
    );
    final observations = payload['observations'];
    if (observations is! List) {
      return const <WundergroundPwsHistoryPoint>[];
    }
    return observations
        .whereType<Map<String, dynamic>>()
        .map(_historyPointFromObservation)
        .whereType<WundergroundPwsHistoryPoint>()
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> _fetchJson(Future<Uri> uriFuture) async {
    final body = await _fetchText(await uriFuture);
    final data = jsonDecode(body);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Unexpected Wunderground response shape.');
    }
    return data;
  }

  Future<Uri> _apiUri({required String path, required String stationId}) async {
    final apiKey = await _resolveApiKey(stationId: stationId);
    return Uri.https(_apiHost, path, <String, String>{
      'stationId': stationId,
      'numericPrecision': 'decimal',
      'format': 'json',
      'units': 'm',
      'apiKey': apiKey,
    });
  }

  Future<String> _resolveApiKey({required String stationId}) async {
    final cachedApiKey = _cachedApiKey;
    if (cachedApiKey != null) {
      return cachedApiKey;
    }
    final dashboard = await _fetchText(
      Uri.https(_dashboardHost, '/dashboard/pws/$stationId'),
    );
    final match = RegExp(r'apiKey=([A-Za-z0-9]+)').firstMatch(dashboard);
    final apiKey = match?.group(1);
    if (apiKey == null || apiKey.isEmpty) {
      throw const FormatException(
        'Wunderground dashboard did not expose an API key.',
      );
    }
    _cachedApiKey = apiKey;
    return apiKey;
  }

  WundergroundPwsSnapshot _snapshotFromObservation(
    Map<String, dynamic> observation,
  ) {
    final metric = _readMap(observation['metric']);
    return WundergroundPwsSnapshot(
      stationId: _readString(observation['stationID']) ?? '',
      observedAt: _readObservedAt(observation),
      observedAtLabel: _readString(observation['obsTimeLocal']),
      latitude: _readDouble(observation['lat']),
      longitude: _readDouble(observation['lon']),
      windKnots: _kmhToKnots(_readDouble(metric['windSpeed'])),
      windDirectionDeg: _readDouble(observation['winddir'])?.round(),
      gustKnots: _kmhToKnots(_readDouble(metric['windGust'])),
      tempC: _readDouble(metric['temp']),
      pressureHpa: _readDouble(metric['pressure'])?.round(),
      humidityPct: _readDouble(observation['humidity'])?.round(),
      rainMm: _readDouble(metric['precipTotal']),
    );
  }

  WundergroundPwsHistoryPoint? _historyPointFromObservation(
    Map<String, dynamic> observation,
  ) {
    final time = _readObservedAt(observation);
    final metric = _readMap(observation['metric']);
    final windKnots = _kmhToKnots(_readDouble(metric['windspeedAvg']));
    if (time == null || windKnots == null) {
      return null;
    }
    return WundergroundPwsHistoryPoint(
      time: time,
      windKnots: windKnots,
      gustKnots: _kmhToKnots(_readDouble(metric['windgustHigh'])),
      windDirectionDeg: _readDouble(observation['winddirAvg'])?.round(),
    );
  }

  Future<String> _fetchText(Uri uri) async {
    final override = _fetchTextOverride;
    if (override != null) {
      return override(uri);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Wunderground PWS direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient()
      ..connectionTimeout = const Duration(seconds: 8);
    final request = await httpClient.getUrl(uri);
    request.headers
      ..set(HttpHeaders.refererHeader, _referer)
      ..set(HttpHeaders.userAgentHeader, 'WindWisher/1.0')
      ..set(HttpHeaders.acceptHeader, 'application/json,text/html,*/*');
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Wunderground returned ${response.statusCode}',
        uri: uri,
      );
    }
    return body;
  }

  DateTime? _readObservedAt(Map<String, dynamic> observation) {
    final epoch = _readDouble(observation['epoch']);
    if (epoch != null) {
      return DateTime.fromMillisecondsSinceEpoch(
        (epoch * 1000).round(),
        isUtc: true,
      ).toLocal();
    }
    final utc = _readString(observation['obsTimeUtc']);
    if (utc != null) {
      return DateTime.tryParse(utc)?.toLocal();
    }
    return null;
  }

  Map<String, dynamic> _readMap(Object? value) {
    return value is Map<String, dynamic> ? value : const <String, dynamic>{};
  }

  String? _readString(Object? value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return null;
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

  double? _kmhToKnots(double? value) {
    if (value == null) {
      return null;
    }
    return value / 1.852;
  }
}
