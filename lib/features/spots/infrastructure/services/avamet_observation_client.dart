import 'dart:io';

import 'package:flutter/foundation.dart';

class AvametObservationSnapshot {
  const AvametObservationSnapshot({
    required this.stationId,
    required this.observedAt,
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
  final double? windKnots;
  final int? windDirectionDeg;
  final double? gustKnots;
  final double? tempC;
  final double? pressureHpa;
  final int? humidityPct;
  final double? rainMm;
}

class AvametObservationClient {
  AvametObservationClient({
    HttpClient? httpClient,
    Future<String> Function(String url)? fetchText,
  }) : _httpClient = httpClient,
       _fetchTextOverride = fetchText;

  final HttpClient? _httpClient;
  final Future<String> Function(String url)? _fetchTextOverride;

  Future<AvametObservationSnapshot?> fetchStationObservation({
    required String stationId,
  }) async {
    final body = await _fetchText(
      'https://www.avamet.org/mxo_i.php?id=$stationId',
    );
    return _parseSnapshot(body, stationId: stationId);
  }

  AvametObservationSnapshot? _parseSnapshot(
    String body, {
    required String stationId,
  }) {
    final normalizedBody = _normalizeBody(body);
    final observedAt = _parseObservedAt(normalizedBody);
    final tempC = _parseDouble(_match(normalizedBody, _tempRegex));
    final humidityPct = _parseInt(_match(normalizedBody, _humidityRegex));
    final pressureHpa = _parsePressure(_match(normalizedBody, _pressureRegex));
    final windMatch = _windRegex.firstMatch(normalizedBody);
    final windKmh = _parseDouble(windMatch?.group(1));
    final windKnots = _kmhToKnots(windKmh);
    final windDirectionDeg = _directionToDegrees(windMatch?.group(2));
    final gustKmh = _parseDouble(_match(normalizedBody, _gustRegex));
    final gustKnots = _kmhToKnots(gustKmh);
    final rainMm = _parseDouble(_match(normalizedBody, _rainRegex));

    if ([
      observedAt,
      tempC,
      humidityPct,
      pressureHpa,
      windKnots,
      windDirectionDeg,
      gustKnots,
      rainMm,
    ].every((value) => value == null)) {
      return null;
    }

    return AvametObservationSnapshot(
      stationId: stationId,
      observedAt: observedAt,
      windKnots: windKnots,
      windDirectionDeg: windDirectionDeg,
      gustKnots: gustKnots,
      tempC: tempC,
      pressureHpa: pressureHpa,
      humidityPct: humidityPct,
      rainMm: rainMm,
    );
  }

  String? _match(String body, RegExp regex) {
    return regex.firstMatch(body)?.group(1);
  }

  String _normalizeBody(String body) {
    var normalized = body
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#160;', ' ')
        .replaceAll('&deg;', '°');
    normalized = normalized.replaceAll(RegExp(r'<[^>]+>'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  DateTime? _parseObservedAt(String body) {
    final match = _observedAtRegex.firstMatch(body);
    if (match == null) {
      return null;
    }
    final datePart = match.group(1);
    final timePart = match.group(2);
    if (datePart == null || timePart == null) {
      return null;
    }
    final datePieces = datePart.split('-');
    final timePieces = timePart.split(':');
    if (datePieces.length != 3 || timePieces.length != 2) {
      return null;
    }
    final day = int.tryParse(datePieces[0]);
    final month = int.tryParse(datePieces[1]);
    final year = int.tryParse(datePieces[2]);
    final hour = int.tryParse(timePieces[0]);
    final minute = int.tryParse(timePieces[1]);
    if (day == null ||
        month == null ||
        year == null ||
        hour == null ||
        minute == null) {
      return null;
    }
    return DateTime(year, month, day, hour, minute);
  }

  double? _parseDouble(String? raw) {
    if (raw == null) {
      return null;
    }
    var cleaned = raw.trim();
    if (cleaned.isEmpty) {
      return null;
    }
    cleaned = cleaned.replaceAll(RegExp(r'[^0-9,\.]'), '');
    if (cleaned.contains(',') && cleaned.contains('.')) {
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (cleaned.contains(',')) {
      cleaned = cleaned.replaceAll(',', '.');
    } else if (cleaned.contains('.')) {
      final parts = cleaned.split('.');
      if (parts.length == 2 && parts[0].length <= 2 && parts[1].length == 3) {
        cleaned = '${parts[0]}${parts[1]}';
      }
    }
    return double.tryParse(cleaned);
  }

  int? _parseInt(String? raw) {
    if (raw == null) {
      return null;
    }
    return int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), ''));
  }

  double? _parsePressure(String? raw) {
    return _parseDouble(raw);
  }

  double? _kmhToKnots(double? value) {
    if (value == null) {
      return null;
    }
    return value * 0.539957;
  }

  int? _directionToDegrees(String? raw) {
    if (raw == null) {
      return null;
    }
    final normalized = raw.trim().toUpperCase();
    final degrees = _directionDegrees[normalized];
    if (degrees == null) {
      return null;
    }
    return degrees.round();
  }

  Future<String> _fetchText(String url) async {
    if (_fetchTextOverride != null) {
      return _fetchTextOverride(url);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'AVAMET observation direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    request.headers.set(HttpHeaders.userAgentHeader, 'WindWisher/1.0');
    final response = await request.close();
    final bytes = await response.fold<List<int>>(
      <int>[],
      (buffer, chunk) => buffer..addAll(chunk),
    );
    return String.fromCharCodes(bytes);
  }
}

final RegExp _observedAtRegex = RegExp(r'(\d{2}-\d{2}-\d{4})\s+(\d{2}:\d{2})');
final RegExp _tempRegex = RegExp(r'(\d{1,2}(?:[\.,]\d+)?)\s*(?:&deg;|°)');
final RegExp _humidityRegex = RegExp(
  r'Humit(?:at|ad)[^0-9]{0,15}([0-9]{1,3})(?:\s*%|\s*percent)?',
  caseSensitive: false,
);
final RegExp _pressureRegex = RegExp(
  r'Pressi[^0-9]*([0-9\.,]+)\s*hPa',
  caseSensitive: false,
);
final RegExp _windRegex = RegExp(
  r'Vent[^0-9]*([0-9\.,]+)\s*km/h\s*([A-Z]{1,3})',
  caseSensitive: false,
);
final RegExp _gustRegex = RegExp(
  r'Vent[^0-9]*m[^0-9]*([0-9\.,]+)\s*km/h',
  caseSensitive: false,
);
final RegExp _rainRegex = RegExp(
  r'Pluja\s*hui\s*([0-9\.,]+)\s*mm',
  caseSensitive: false,
);

const Map<String, double> _directionDegrees = {
  'N': 0.0,
  'NNE': 22.5,
  'NE': 45.0,
  'ENE': 67.5,
  'E': 90.0,
  'ESE': 112.5,
  'SE': 135.0,
  'SSE': 157.5,
  'S': 180.0,
  'SSO': 202.5,
  'SO': 225.0,
  'OSO': 247.5,
  'O': 270.0,
  'ONO': 292.5,
  'NO': 315.0,
  'NNO': 337.5,
};
