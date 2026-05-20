import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class MeteoclimaticLiveSnapshot {
  const MeteoclimaticLiveSnapshot({
    required this.stationId,
    required this.stationName,
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
  final String? stationName;
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

class MeteoclimaticLiveClient {
  MeteoclimaticLiveClient({
    HttpClient? httpClient,
    Future<String> Function(Uri uri)? fetchText,
  }) : _httpClient = httpClient,
       _fetchTextOverride = fetchText;

  static const String _host = 'www.meteoclimatic.net';

  final HttpClient? _httpClient;
  final Future<String> Function(Uri uri)? _fetchTextOverride;

  Future<MeteoclimaticLiveSnapshot?> fetchSnapshot({
    required String stationId,
  }) async {
    final uri = Uri.https(_host, '/feed/rss/$stationId');
    final body = await _fetchText(uri);
    final dataLine = RegExp(
      r'\[\[<([A-Z0-9]+);\(([^)]*)\);\(([^)]*)\);\(([^)]*)\);\(([^)]*)\);\(([^)]*)\);([^>]*)>\]\]',
      dotAll: true,
    ).firstMatch(body);
    if (dataLine == null) {
      return null;
    }

    final temperature = _splitTuple(dataLine.group(2));
    final humidity = _splitTuple(dataLine.group(3));
    final pressure = _splitTuple(dataLine.group(4));
    final wind = _splitTuple(dataLine.group(5));
    final rain = _splitTuple(dataLine.group(6));

    final observedAt = _readPubDate(body);
    final coordinates = _readCoordinates(body);
    return MeteoclimaticLiveSnapshot(
      stationId: stationId,
      stationName: _decodeXmlText(dataLine.group(7)),
      observedAt: observedAt,
      observedAtLabel: _readUpdatedLabel(body),
      latitude: coordinates?.$1,
      longitude: coordinates?.$2,
      windKnots: _kmhToKnots(_readDecimal(wind, 0)),
      windDirectionDeg: _readDecimal(wind, 2)?.round(),
      gustKnots: _kmhToKnots(_readDecimal(wind, 1)),
      tempC: _readDecimal(temperature, 0),
      pressureHpa: _readDecimal(pressure, 0)?.round(),
      humidityPct: _readDecimal(humidity, 0)?.round(),
      rainMm: _readDecimal(rain, 0),
    );
  }

  Future<String> _fetchText(Uri uri) async {
    final override = _fetchTextOverride;
    if (override != null) {
      return override(uri);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Meteoclimatic direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient()
      ..connectionTimeout = const Duration(seconds: 8);
    final request = await httpClient.getUrl(uri);
    request.headers
      ..set(HttpHeaders.userAgentHeader, 'WindWisher/1.0')
      ..set(HttpHeaders.acceptHeader, 'application/rss+xml,text/xml,*/*');
    final response = await request.close();
    final body = await latin1.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Meteoclimatic returned ${response.statusCode}',
        uri: uri,
      );
    }
    return body;
  }

  List<String> _splitTuple(String? tuple) {
    return tuple?.split(';').map((value) => value.trim()).toList() ??
        const <String>[];
  }

  double? _readDecimal(List<String> values, int index) {
    if (index >= values.length) {
      return null;
    }
    return double.tryParse(values[index].replaceAll(',', '.'));
  }

  double? _kmhToKnots(double? value) {
    if (value == null) {
      return null;
    }
    return value * 0.539957;
  }

  DateTime? _readPubDate(String body) {
    final raw = RegExp(
      r'<pubDate>([^<]+)</pubDate>',
    ).firstMatch(body)?.group(1)?.trim();
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return HttpDate.parse(raw).toLocal();
    } on HttpException {
      return _parseRssDate(raw)?.toLocal();
    }
  }

  DateTime? _parseRssDate(String raw) {
    final match = RegExp(
      r'^[A-Za-z]{3},\s+(\d{1,2})\s+([A-Za-z]{3})\s+(\d{4})\s+'
      r'(\d{2}):(\d{2}):(\d{2})\s+([+-])(\d{2})(\d{2})$',
    ).firstMatch(raw);
    if (match == null) {
      return null;
    }
    final day = int.tryParse(match.group(1) ?? '');
    final month = _monthNumber(match.group(2));
    final year = int.tryParse(match.group(3) ?? '');
    final hour = int.tryParse(match.group(4) ?? '');
    final minute = int.tryParse(match.group(5) ?? '');
    final second = int.tryParse(match.group(6) ?? '');
    final offsetSign = match.group(7) == '-' ? -1 : 1;
    final offsetHours = int.tryParse(match.group(8) ?? '');
    final offsetMinutes = int.tryParse(match.group(9) ?? '');
    if (day == null ||
        month == null ||
        year == null ||
        hour == null ||
        minute == null ||
        second == null ||
        offsetHours == null ||
        offsetMinutes == null) {
      return null;
    }
    final localWithOffset = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
    );
    final offset = Duration(
      hours: offsetHours * offsetSign,
      minutes: offsetMinutes * offsetSign,
    );
    return localWithOffset.subtract(offset);
  }

  int? _monthNumber(String? raw) {
    switch (raw?.toLowerCase()) {
      case 'jan':
        return 1;
      case 'feb':
        return 2;
      case 'mar':
        return 3;
      case 'apr':
        return 4;
      case 'may':
        return 5;
      case 'jun':
        return 6;
      case 'jul':
        return 7;
      case 'aug':
        return 8;
      case 'sep':
        return 9;
      case 'oct':
        return 10;
      case 'nov':
        return 11;
      case 'dec':
        return 12;
    }
    return null;
  }

  String? _readUpdatedLabel(String body) {
    final raw = RegExp(
      r'Actualizado:\s*([^<]+)</li>',
      dotAll: true,
    ).firstMatch(body)?.group(1)?.trim();
    return _decodeXmlText(raw);
  }

  (double, double)? _readCoordinates(String body) {
    final match = RegExp(
      r'<georss:point>\s*([-0-9.]+)\s+([-0-9.]+)\s*</georss:point>',
    ).firstMatch(body);
    final latitude = double.tryParse(match?.group(1) ?? '');
    final longitude = double.tryParse(match?.group(2) ?? '');
    if (latitude == null || longitude == null) {
      return null;
    }
    return (latitude, longitude);
  }

  String? _decodeXmlText(String? raw) {
    if (raw == null) {
      return null;
    }
    return raw
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#243;', 'o')
        .replaceAll('&oacute;', 'o')
        .trim();
  }
}
