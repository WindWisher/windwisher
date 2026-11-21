import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class XussMeteoSnapshot {
  const XussMeteoSnapshot({
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

class XussMeteoClient {
  XussMeteoClient({
    HttpClient? httpClient,
    Future<String> Function(String url)? fetchText,
  }) : _httpClient = httpClient,
       _fetchTextOverride = fetchText;

  static const String deniaUrl = 'http://www.xuss.es/Meteo/Denia.php';
  static final tz.Location _stationTimeZone = _loadStationTimeZone();

  static tz.Location _loadStationTimeZone() {
    tz_data.initializeTimeZones();
    return tz.getLocation('Europe/Madrid');
  }

  final HttpClient? _httpClient;
  final Future<String> Function(String url)? _fetchTextOverride;

  Future<XussMeteoSnapshot?> fetchDeniaSnapshot() async {
    final body = await _fetchText(deniaUrl);
    final observedAt = _parseObservedAt(body);
    return XussMeteoSnapshot(
      observedAt: observedAt,
      observedAtLabel: _parseObservedAtLabel(body),
      windKnots: _readKmhKtsRow(body, 'Velocidad media del viento')?.kts,
      windDirectionDeg: _readDegreesRow(body, 'Direcci[oó]n del viento'),
      gustKnots: _readKmhKtsRow(body, 'ráfagas maxima')?.kts,
      tempC: _readNumberAfter(body, r'Temperatura actual.*?<b>'),
      pressureHpa: _readNumberAfter(body, r'Bar[oó]metro.*?>')?.round(),
      humidityPct: _readNumberAfter(body, r'Humedad\s*</td>\s*<td>')?.round(),
      rainMm: _readNumberAfter(body, r'Lluvia.*?\(desde medianoche\).*?>'),
    );
  }

  Future<String> _fetchText(String url) async {
    final override = _fetchTextOverride;
    if (override != null) {
      return override(url);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Xuss Meteo direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    request.headers
      ..set(HttpHeaders.userAgentHeader, 'WindWisher/1.0')
      ..set(HttpHeaders.acceptHeader, 'text/html,*/*');
    final response = await request.close();
    final body = await latin1.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Xuss returned ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }
    return body;
  }

  DateTime? _parseObservedAt(String body) {
    final match = RegExp(
      r'Ultima grabaci[oó]n a:\s*(\d{1,2}):(\d{2}).*?Data:\s*(\d{1,2})\s+([A-Za-z]+)\s+(\d{4})',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    if (match == null) {
      return null;
    }
    final hour = int.tryParse(match.group(1) ?? '');
    final minute = int.tryParse(match.group(2) ?? '');
    final day = int.tryParse(match.group(3) ?? '');
    final month = _parseMonth(match.group(4));
    final year = int.tryParse(match.group(5) ?? '');
    if (hour == null ||
        minute == null ||
        day == null ||
        month == null ||
        year == null) {
      return null;
    }
    final calendarDate = DateTime.utc(year, month, day, hour, minute);
    if (calendarDate.year != year ||
        calendarDate.month != month ||
        calendarDate.day != day ||
        hour > 23 ||
        minute > 59) {
      return null;
    }
    return tz.TZDateTime(
      _stationTimeZone,
      year,
      month,
      day,
      hour,
      minute,
    ).toUtc();
  }

  String? _parseObservedAtLabel(String body) {
    final match = RegExp(
      r'Ultima grabaci[oó]n a:\s*([^<]+)',
      caseSensitive: false,
    ).firstMatch(body);
    return match?.group(1)?.trim();
  }

  int? _parseMonth(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'jan':
      case 'ene':
      case 'january':
      case 'enero':
        return 1;
      case 'feb':
      case 'february':
      case 'febrero':
        return 2;
      case 'mar':
      case 'march':
      case 'marzo':
        return 3;
      case 'apr':
      case 'abr':
      case 'april':
      case 'abril':
        return 4;
      case 'may':
      case 'mayo':
        return 5;
      case 'jun':
      case 'june':
      case 'junio':
        return 6;
      case 'jul':
      case 'july':
      case 'julio':
        return 7;
      case 'aug':
      case 'ago':
      case 'august':
      case 'agosto':
        return 8;
      case 'sep':
      case 'sept':
      case 'september':
      case 'septiembre':
        return 9;
      case 'oct':
      case 'october':
      case 'octubre':
        return 10;
      case 'nov':
      case 'november':
      case 'noviembre':
        return 11;
      case 'dec':
      case 'dic':
      case 'december':
      case 'diciembre':
        return 12;
    }
    return null;
  }

  _KmhKts? _readKmhKtsRow(String body, String labelPattern) {
    final match = RegExp(
      '$labelPattern.*?<td[^>]*>\\s*([0-9.,]+)\\s*kmh\\s*\\(([0-9.,]+)\\s*kts\\)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    if (match == null) {
      return null;
    }
    return _KmhKts(
      kmh: _parseNumber(match.group(1)),
      kts: _parseNumber(match.group(2)),
    );
  }

  int? _readDegreesRow(String body, String labelPattern) {
    final match = RegExp(
      '$labelPattern.*?<td[^>]*>.*?\\(([0-9.,]+)&deg;\\)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    return _parseNumber(match?.group(1))?.round();
  }

  double? _readNumberAfter(String body, String prefixPattern) {
    final match = RegExp(
      '$prefixPattern\\s*([0-9.,]+)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    return _parseNumber(match?.group(1));
  }

  double? _parseNumber(String? raw) {
    if (raw == null) {
      return null;
    }
    final parsed = double.tryParse(raw.replaceAll(',', '.'));
    return parsed == null || !parsed.isFinite ? null : parsed;
  }
}

class _KmhKts {
  const _KmhKts({required this.kmh, required this.kts});

  final double? kmh;
  final double? kts;
}
