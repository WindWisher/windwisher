import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class WeathercloudLiveSnapshot {
  const WeathercloudLiveSnapshot({
    required this.deviceId,
    required this.observedAt,
    required this.observedAtLabel,
    required this.windKnots,
    required this.windDirectionDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.rainMm,
  });

  final String deviceId;
  final DateTime? observedAt;
  final String? observedAtLabel;
  final double? windKnots;
  final int? windDirectionDeg;
  final double? gustKnots;
  final double? tempC;
  final int? pressureHpa;
  final int? humidityPct;
  final double? rainMm;
}

class WeathercloudLiveClient {
  WeathercloudLiveClient({
    HttpClient? httpClient,
    Future<String> Function(Uri uri, Map<String, String> headers)? fetchText,
  }) : _httpClient = httpClient,
       _fetchTextOverride = fetchText;

  static const String _host = 'app.weathercloud.net';
  static const String _referer = 'https://app.weathercloud.net/';

  final HttpClient? _httpClient;
  final Future<String> Function(Uri uri, Map<String, String> headers)?
  _fetchTextOverride;

  Future<WeathercloudLiveSnapshot?> fetchCurrent({
    required String deviceId,
  }) async {
    final session = await _fetchSession(deviceId: deviceId);
    final uri = Uri.https(_host, '/device/stats', <String, String>{
      'code': deviceId,
      'WEATHERCLOUD_CSRF_TOKEN': session.csrfToken,
    });
    final body = await _fetchText(uri, <String, String>{
      HttpHeaders.cookieHeader: session.cookieHeader,
      HttpHeaders.refererHeader: 'https://$_host/d$deviceId',
      HttpHeaders.acceptHeader:
          'application/json, text/javascript, */*; q=0.01',
      'X-Requested-With': 'XMLHttpRequest',
    });
    final data = jsonDecode(body);
    if (data is! Map<String, dynamic>) {
      return null;
    }
    return _snapshotFromStats(deviceId: deviceId, data: data);
  }

  Future<_WeathercloudSession> _fetchSession({required String deviceId}) async {
    final uri = Uri.https(_host, '/d$deviceId');
    final result = await _fetchTextWithCookies(uri, <String, String>{
      HttpHeaders.refererHeader: _referer,
      HttpHeaders.acceptHeader: 'text/html,*/*',
    });
    final tokenMatch = RegExp(
      r'WEATHERCLOUD_CSRF_TOKEN:"([^"]+)"',
    ).firstMatch(result.body);
    final token = tokenMatch?.group(1);
    if (token == null || token.isEmpty) {
      throw const FormatException('Weathercloud CSRF token not found.');
    }
    return _WeathercloudSession(
      csrfToken: token,
      cookieHeader: result.cookies.join('; '),
    );
  }

  WeathercloudLiveSnapshot _snapshotFromStats({
    required String deviceId,
    required Map<String, dynamic> data,
  }) {
    final observedAt = _readPairDate(data['last_update']);
    final lastUpdateEpoch = _readPairEpoch(data['last_update']);
    return WeathercloudLiveSnapshot(
      deviceId: deviceId,
      observedAt: observedAt,
      observedAtLabel: observedAt?.toString(),
      windKnots: _mpsToKnots(
        _readFreshPairNumber(data['wspdavg_current'], lastUpdateEpoch),
      ),
      windDirectionDeg: _readFreshPairNumber(
        data['wdiravg_current'],
        lastUpdateEpoch,
        allowNegative: false,
      )?.round(),
      gustKnots: _mpsToKnots(
        _readFreshPairNumber(data['wspdhi_current'], lastUpdateEpoch),
      ),
      tempC: _readFreshPairNumber(data['temp_current'], lastUpdateEpoch),
      pressureHpa: _readFreshPairNumber(
        data['bar_current'],
        lastUpdateEpoch,
      )?.round(),
      humidityPct: _readFreshPairNumber(
        data['hum_current'],
        lastUpdateEpoch,
      )?.round(),
      rainMm: _readFreshPairNumber(data['rain_day_total'], lastUpdateEpoch),
    );
  }

  Future<String> _fetchText(Uri uri, Map<String, String> headers) async {
    final result = await _fetchTextWithCookies(uri, headers);
    return result.body;
  }

  Future<_WeathercloudHttpResult> _fetchTextWithCookies(
    Uri uri,
    Map<String, String> headers,
  ) async {
    final override = _fetchTextOverride;
    if (override != null) {
      return _WeathercloudHttpResult(
        body: await override(uri, headers),
        cookies: const <String>[],
      );
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Weathercloud direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    final request = await httpClient.getUrl(uri);
    request.headers
      ..set(HttpHeaders.userAgentHeader, 'Mozilla/5.0 WindWisher/1.0')
      ..set(HttpHeaders.acceptEncodingHeader, 'gzip')
      ..set(HttpHeaders.acceptLanguageHeader, 'es-ES,es;q=0.9,en;q=0.8');
    for (final entry in headers.entries) {
      request.headers.set(entry.key, entry.value);
    }
    final response = await request.close();
    final body = await utf8.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Weathercloud returned ${response.statusCode}',
        uri: uri,
      );
    }
    return _WeathercloudHttpResult(
      body: body,
      cookies: response.cookies
          .map((cookie) => '${cookie.name}=${cookie.value}')
          .toList(growable: false),
    );
  }

  DateTime? _readPairDate(Object? value) {
    final epoch = _readPairEpoch(value);
    if (epoch == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(
      (epoch * 1000).round(),
      isUtc: true,
    ).toLocal();
  }

  double? _readPairEpoch(Object? value) {
    return value is List && value.isNotEmpty
        ? _readDouble(value.first)
        : _readDouble(value);
  }

  double? _readFreshPairNumber(
    Object? value,
    double? lastUpdateEpoch, {
    bool allowNegative = true,
  }) {
    if (value is! List || value.length < 2) {
      return _readDouble(value);
    }
    final pairEpoch = _readDouble(value.first);
    final pairValue = _readDouble(value[1]);
    if (pairValue == null) {
      return null;
    }
    if (!allowNegative && pairValue < 0) {
      return null;
    }
    if (pairEpoch != null &&
        lastUpdateEpoch != null &&
        pairEpoch < lastUpdateEpoch) {
      return null;
    }
    return pairValue;
  }

  double? _readDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.'));
    }
    return null;
  }

  double? _mpsToKnots(double? value) {
    if (value == null) {
      return null;
    }
    return double.parse((value * 1.9438444924406).toStringAsFixed(2));
  }
}

class _WeathercloudSession {
  const _WeathercloudSession({
    required this.csrfToken,
    required this.cookieHeader,
  });

  final String csrfToken;
  final String cookieHeader;
}

class _WeathercloudHttpResult {
  const _WeathercloudHttpResult({required this.body, required this.cookies});

  final String body;
  final List<String> cookies;
}
