import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

class MeteopilesLiveSnapshot {
  const MeteopilesLiveSnapshot({
    required this.windKnots,
    required this.windDirectionDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.rainMm,
    required this.observedAt,
    required this.observedAtLabel,
  });

  final double? windKnots;
  final int? windDirectionDeg;
  final double? gustKnots;
  final double? tempC;
  final int? pressureHpa;
  final int? humidityPct;
  final double? rainMm;
  final DateTime? observedAt;
  final String? observedAtLabel;
}

class MeteopilesLiveClient {
  MeteopilesLiveClient({
    HttpClient? httpClient,
    Future<String> Function(String url)? fetchText,
  }) : _httpClient = httpClient,
       _fetchTextOverride = fetchText;

  static const String wflashUrl =
      'http://www.meteopiles.es/wflash/Data/wflash.txt';

  final HttpClient? _httpClient;
  final Future<String> Function(String url)? _fetchTextOverride;

  Future<MeteopilesLiveSnapshot?> fetchSnapshot() async {
    final body = await _fetchText(wflashUrl);
    final values = body.trim().split(',');
    if (values.length < 26 || !values.first.startsWith('F=')) {
      return null;
    }

    return MeteopilesLiveSnapshot(
      windKnots: _mphToKnots(_readDouble(values, 4)),
      windDirectionDeg: _readInt(values, 3),
      gustKnots: _mphToKnots(_readDouble(values, 5)),
      tempC: _fahrenheitToCelsius(_readDouble(values, 9)),
      pressureHpa: _inHgToHpa(_readDouble(values, 25))?.round(),
      humidityPct: _readDouble(values, 7)?.round(),
      rainMm: _inchesToMm(_readDouble(values, 11)),
      observedAt: _parseObservedAt(_readString(values, 1)),
      observedAtLabel: _readString(values, 1),
    );
  }

  Future<String> _fetchText(String url) async {
    final override = _fetchTextOverride;
    if (override != null) {
      return override(url);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Meteo Piles direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final body = await latin1.decoder.bind(response).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Meteo Piles returned ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }
    return body;
  }

  String? _readString(List<String> values, int index) {
    if (index >= values.length) {
      return null;
    }
    final value = values[index].trim();
    return value.isEmpty ? null : value;
  }

  double? _readDouble(List<String> values, int index) {
    return double.tryParse(_readString(values, index) ?? '');
  }

  int? _readInt(List<String> values, int index) {
    return _readDouble(values, index)?.round();
  }

  DateTime? _parseObservedAt(String? timeLabel) {
    if (timeLabel == null) {
      return null;
    }
    final parts = timeLabel.split(':');
    if (parts.length < 2) {
      return null;
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    final second = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;
    if (hour == null || minute == null) {
      return null;
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute, second);
  }

  double? _mphToKnots(double? value) {
    if (value == null) {
      return null;
    }
    return value * 0.868976242;
  }

  double? _fahrenheitToCelsius(double? value) {
    if (value == null) {
      return null;
    }
    return (value - 32) * 5 / 9;
  }

  double? _inHgToHpa(double? value) {
    if (value == null) {
      return null;
    }
    return value * 33.8638866667;
  }

  double? _inchesToMm(double? value) {
    if (value == null) {
      return null;
    }
    return value * 25.4;
  }
}
