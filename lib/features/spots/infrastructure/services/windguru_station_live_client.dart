import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class WindguruStationLiveSnapshot {
  const WindguruStationLiveSnapshot({
    required this.windKnots,
    required this.windMinKnots,
    required this.windDirectionDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.observedAt,
    required this.observedAtLabel,
  });

  final double? windKnots;
  final double? windMinKnots;
  final int? windDirectionDeg;
  final double? gustKnots;
  final double? tempC;
  final int? pressureHpa;
  final int? humidityPct;
  final DateTime? observedAt;
  final String? observedAtLabel;
}

class WindguruStationLiveClient {
  WindguruStationLiveClient({
    HttpClient? httpClient,
    Future<String> Function(Uri uri)? fetchText,
  }) : _httpClient = httpClient,
       _fetchTextOverride = fetchText;

  static const String _referer = 'https://www.dkpiles.com/meteo.html';
  static const String _callback = 'windwisher';

  final HttpClient? _httpClient;
  final Future<String> Function(Uri uri)? _fetchTextOverride;

  Future<WindguruStationLiveSnapshot?> fetchCurrent({
    required int stationId,
  }) async {
    final uri = Uri.https('www.windguru.cz', '/int/iapi.php', <String, String>{
      'callback': _callback,
      'q': 'station_data_current',
      'id_station': stationId.toString(),
      'date_format': 'Y-m-d H:i:s T',
    });
    final payload = _decodeJsonp(await _fetchText(uri));
    final data = jsonDecode(payload);
    if (data is! Map<String, dynamic> || data['return'] == 'error') {
      return null;
    }

    return WindguruStationLiveSnapshot(
      windKnots: _readDouble(data['wind_avg']),
      windMinKnots: _readDouble(data['wind_min']),
      windDirectionDeg: _readDouble(data['wind_direction'])?.round(),
      gustKnots: _readDouble(data['wind_max']),
      tempC: _readDouble(data['temperature']),
      pressureHpa: _readDouble(data['mslp'])?.round(),
      humidityPct: _readDouble(data['rh'])?.round(),
      observedAt: _readObservedAt(data),
      observedAtLabel: data['datetime'] as String?,
    );
  }

  Future<String> _fetchText(Uri uri) async {
    final override = _fetchTextOverride;
    if (override != null) {
      return override(uri);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Windguru station direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(uri);
    request.headers
      ..set(HttpHeaders.refererHeader, _referer)
      ..set(HttpHeaders.userAgentHeader, 'WindWisher/1.0');
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Windguru station returned ${response.statusCode}',
        uri: uri,
      );
    }
    return body;
  }

  String _decodeJsonp(String body) {
    final trimmed = body.trim();
    final prefix = '$_callback(';
    if (trimmed.startsWith(prefix) && trimmed.endsWith(');')) {
      return trimmed.substring(prefix.length, trimmed.length - 2);
    }
    return trimmed;
  }

  DateTime? _readObservedAt(Map<String, dynamic> data) {
    final unixTime = data['unixtime'];
    if (unixTime is num) {
      return DateTime.fromMillisecondsSinceEpoch(
        (unixTime * 1000).round(),
        isUtc: true,
      ).toLocal();
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
}
