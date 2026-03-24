import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class InforatgeOlivaNovaPoint {
  const InforatgeOlivaNovaPoint({
    required this.time,
    required this.windKnots,
    required this.windDirectionDeg,
  });

  final DateTime time;
  final double windKnots;
  final int? windDirectionDeg;
}

class InforatgeOlivaNovaSnapshot {
  const InforatgeOlivaNovaSnapshot({
    required this.observedAt,
    required this.windKnots,
    required this.windDirectionDeg,
    required this.gustKnots,
    required this.tempC,
    required this.pressureHpa,
    required this.humidityPct,
    required this.rainMm,
  });

  final DateTime observedAt;
  final int? windKnots;
  final int? windDirectionDeg;
  final int? gustKnots;
  final double? tempC;
  final int? pressureHpa;
  final int? humidityPct;
  final double? rainMm;
}

class InforatgeOlivaNovaFeed {
  const InforatgeOlivaNovaFeed({
    required this.points,
    required this.latestSnapshot,
  });

  final List<InforatgeOlivaNovaPoint> points;
  final InforatgeOlivaNovaSnapshot? latestSnapshot;
}

class InforatgeOlivaNovaClient {
  InforatgeOlivaNovaClient({
    HttpClient? httpClient,
    Future<String> Function(String url)? fetchText,
    Future<String> Function(String url, Map<String, String> formData)?
    postForm,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient,
       _fetchTextOverride = fetchText,
       _postFormOverride = postForm,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  static const String liveOlivaNovaUrl = 'https://inforatge.com/meteo-oliva-02';
  static const String livePoliesportiuUrl = 'https://inforatge.com/meteo-oliva';
  static const String historyUrl = 'https://inforatge.com/meteo-oliva/estacio';

  final HttpClient? _httpClient;
  final Future<String> Function(String url)? _fetchTextOverride;
  final Future<String> Function(String url, Map<String, String> formData)?
  _postFormOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  Future<InforatgeOlivaNovaFeed> fetchFeed({
    String stationCode = '02',
    String liveUrl = liveOlivaNovaUrl,
  }) async {
    final liveFuture = _safeFetchText(liveUrl);
    final historyPage = await _fetchText(historyUrl);
    final actionUrl = _extractGraphActionUrl(historyPage);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final formData = <String, String>{
      'e': stationCode,
      'v1': '002',
      'v2': '003',
      'd1': _formatDate(start),
      'd2': _formatDate(now),
      'g': 'i',
    };
    final graphHtml = actionUrl == null
        ? null
        : await _safePostForm(actionUrl, formData);
    final points = graphHtml == null
        ? const <InforatgeOlivaNovaPoint>[]
        : _parseHistoricalPoints(graphHtml);
    final liveBody = await liveFuture;
    final liveSnapshot = liveBody == null ? null : _parseLiveSnapshot(liveBody);
    final latestPoint = points.isEmpty ? null : points.last;
    return InforatgeOlivaNovaFeed(
      points: points,
      latestSnapshot:
          liveSnapshot ??
          (latestPoint == null
              ? null
              : InforatgeOlivaNovaSnapshot(
                  observedAt: latestPoint.time,
                  windKnots: latestPoint.windKnots.round(),
                  windDirectionDeg: latestPoint.windDirectionDeg,
                  gustKnots: null,
                  tempC: null,
                  pressureHpa: null,
                  humidityPct: null,
                  rainMm: null,
                )),
    );
  }

  List<InforatgeOlivaNovaPoint> _parseHistoricalPoints(String body) {
    final categoriesMatch = RegExp(
      r'categories:\s*\[(.*?)\]',
      dotAll: true,
    ).firstMatch(body);
    if (categoriesMatch == null) {
      return const <InforatgeOlivaNovaPoint>[];
    }
    final categories = RegExp(
      r"'([^']*)'",
    ).allMatches(categoriesMatch.group(1) ?? '').map((m) => m.group(1)!).toList(
      growable: false,
    );
    final seriesMatches = RegExp(
      r"data:\[(.*?)\].*?name:'([^']+)'",
      dotAll: true,
    ).allMatches(body).toList(growable: false);
    if (seriesMatches.length < 2) {
      return const <InforatgeOlivaNovaPoint>[];
    }
    final speedValues = _parseNumericSeries(seriesMatches[0].group(1) ?? '');
    final directionValues = _parseNumericSeries(seriesMatches[1].group(1) ?? '');
    final count = [
      categories.length,
      speedValues.length,
      directionValues.length,
    ].reduce((value, element) => value < element ? value : element);
    if (count == 0) {
      return const <InforatgeOlivaNovaPoint>[];
    }
    final points = <InforatgeOlivaNovaPoint>[];
    for (var i = 0; i < count; i++) {
      final time = _parseChartTime(categories[i]);
      final speedKmH = speedValues[i];
      if (time == null || speedKmH == null) {
        continue;
      }
      points.add(
        InforatgeOlivaNovaPoint(
          time: time,
          windKnots: speedKmH * 0.539957,
          windDirectionDeg: directionValues[i]?.round(),
        ),
      );
    }
    return points;
  }

  InforatgeOlivaNovaSnapshot? _parseLiveSnapshot(String body) {
    final updatedMatch = RegExp(
      r'<h2>(\d{1,2}:\d{2}:\d{2})<br>(.*?)</h2>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    final windMatch = RegExp(
      r'velocitat i direcci&oacute; del vent</div>\s*<div class="blocValor">(\d+(?:,\d+)?)<span class="vPetit">\s*([^<]+)</span></div>\s*<div class="blocUnitats">km/h</div>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    final tempMatch = RegExp(
      r'<div class="blocTitol">temperatura</div>\s*<div class="blocValorTM">(\d+(?:,\d+)?)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    final humidityMatch = RegExp(
      r'<div class="blocTitol">humitat relativa</div>\s*<div class="blocValor">(\d+)</div>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    final pressureMatch = RegExp(
      r'<div class="blocTitol">pressi(?:&oacute;|ó|o) barom[^<]*</div>\s*<div class="blocValor">(\d+)',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    final rainMatch = RegExp(
      r'<div class="blocTitol">pluja del dia</div>\s*<div class="blocValor">(\d+(?:,\d+)?)</div>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    final gustMatch = RegExp(
      r'boxpetitkVX[^>]*>.*?(\d+(?:,\d+)?)\s*<span class="tPetit">km/h</span>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(body);
    if (updatedMatch == null || windMatch == null) {
      return null;
    }
    final observedAt = _parseLiveObservedAt(
      updatedMatch.group(1),
      updatedMatch.group(2),
    );
    final windKmH = _readLocaleDouble(windMatch.group(1));
    if (observedAt == null || windKmH == null) {
      return null;
    }
    return InforatgeOlivaNovaSnapshot(
      observedAt: observedAt,
      windKnots: (windKmH * 0.539957).round(),
      windDirectionDeg: _cardinalToDegrees(windMatch.group(2)),
      gustKnots: _kmhToKnotsInt(_readLocaleDouble(gustMatch?.group(1))),
      tempC: _readLocaleDouble(tempMatch?.group(1)),
      pressureHpa: _readLocaleDouble(pressureMatch?.group(1))?.round(),
      humidityPct: int.tryParse((humidityMatch?.group(1) ?? '').trim()),
      rainMm: _readLocaleDouble(rainMatch?.group(1)),
    );
  }

  String? _extractGraphActionUrl(String body) {
    final match = RegExp(
      r'<form[^>]+action="([^"]*graficc\.php[^"]+)"',
      caseSensitive: false,
    ).firstMatch(body);
    return match?.group(1);
  }

  List<double?> _parseNumericSeries(String body) {
    return body
        .split(',')
        .map((value) {
          final normalized = value.trim();
          if (normalized.isEmpty || normalized == 'null') {
            return null;
          }
          return double.tryParse(normalized);
        })
        .toList(growable: false);
  }

  DateTime? _parseChartTime(String value) {
    final match = RegExp(
      r'^(\d{2})/(\d{2})/(\d{2}) (\d{2}):(\d{2})$',
    ).firstMatch(value.trim());
    if (match == null) {
      return null;
    }
    final day = int.tryParse(match.group(1) ?? '');
    final month = int.tryParse(match.group(2) ?? '');
    final year = int.tryParse(match.group(3) ?? '');
    final hour = int.tryParse(match.group(4) ?? '');
    final minute = int.tryParse(match.group(5) ?? '');
    if (day == null ||
        month == null ||
        year == null ||
        hour == null ||
        minute == null) {
      return null;
    }
    return DateTime(2000 + year, month, day, hour, minute);
  }

  DateTime? _parseLiveObservedAt(String? timeValue, String? dateValue) {
    if (timeValue == null || dateValue == null) {
      return null;
    }
    final timeMatch = RegExp(
      r'^(\d{1,2}):(\d{2}):(\d{2})$',
    ).firstMatch(timeValue.trim());
    final dateMatch = RegExp(
      r'(\d{1,2}) de ([a-zA-Z&;]+) de (\d{4})',
      caseSensitive: false,
    ).firstMatch(dateValue.replaceAll('\n', ' ').trim());
    if (timeMatch == null || dateMatch == null) {
      return null;
    }
    final day = int.tryParse(dateMatch.group(1) ?? '');
    final month = _monthFromCatalan(dateMatch.group(2));
    final year = int.tryParse(dateMatch.group(3) ?? '');
    final hour = int.tryParse(timeMatch.group(1) ?? '');
    final minute = int.tryParse(timeMatch.group(2) ?? '');
    final second = int.tryParse(timeMatch.group(3) ?? '');
    if (day == null ||
        month == null ||
        year == null ||
        hour == null ||
        minute == null ||
        second == null) {
      return null;
    }
    return DateTime(year, month, day, hour, minute, second);
  }

  int? _monthFromCatalan(String? value) {
    final normalized = (value ?? '')
        .toLowerCase()
        .replaceAll('&ccedil;', 'c')
        .replaceAll('ç', 'c')
        .trim();
    switch (normalized) {
      case 'gener':
        return 1;
      case 'febrer':
        return 2;
      case 'marc':
        return 3;
      case 'abril':
        return 4;
      case 'maig':
        return 5;
      case 'juny':
        return 6;
      case 'juliol':
        return 7;
      case 'agost':
        return 8;
      case 'setembre':
        return 9;
      case 'octubre':
        return 10;
      case 'novembre':
        return 11;
      case 'desembre':
        return 12;
      default:
        return null;
    }
  }

  double? _readLocaleDouble(String? value) {
    final normalized = value?.replaceAll(',', '.').trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  int? _kmhToKnotsInt(double? value) {
    if (value == null) {
      return null;
    }
    return (value * 0.539957).round();
  }

  int? _cardinalToDegrees(String? value) {
    switch ((value ?? '').trim().toUpperCase()) {
      case 'N':
        return 0;
      case 'NNE':
        return 23;
      case 'NE':
        return 45;
      case 'ENE':
        return 68;
      case 'E':
        return 90;
      case 'ESE':
        return 113;
      case 'SE':
        return 135;
      case 'SSE':
        return 158;
      case 'S':
        return 180;
      case 'SSO':
      case 'SSW':
        return 203;
      case 'SO':
      case 'SW':
        return 225;
      case 'OSO':
      case 'WSW':
        return 248;
      case 'O':
      case 'W':
        return 270;
      case 'ONO':
      case 'WNW':
        return 293;
      case 'NO':
      case 'NW':
        return 315;
      case 'NNO':
      case 'NNW':
        return 338;
      default:
        return null;
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<String?> _safeFetchText(String url) async {
    try {
      return await _fetchText(url);
    } catch (_) {
      return null;
    }
  }

  Future<String?> _safePostForm(String url, Map<String, String> formData) async {
    try {
      return await _postForm(url, formData);
    } catch (_) {
      return null;
    }
  }

  Future<String> _fetchText(String url) async {
    if (_fetchTextOverride != null) {
      return _fetchTextOverride(url);
    }
    if (_forecastProxyClient != null) {
      return _forecastProxyClient.fetchInforatgePage(url: url);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Inforatge Oliva Nova direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Request failed: ${response.statusCode}', uri: Uri.parse(url));
    }
    return response.transform(const SystemEncoding().decoder).join();
  }

  Future<String> _postForm(String url, Map<String, String> formData) async {
    if (_postFormOverride != null) {
      return _postFormOverride(url, formData);
    }
    if (_forecastProxyClient != null) {
      return _forecastProxyClient.fetchInforatgeGraph(
        url: url,
        formData: formData,
      );
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Inforatge Oliva Nova direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.postUrl(Uri.parse(url));
    request.headers.contentType = ContentType(
      'application',
      'x-www-form-urlencoded',
      charset: 'utf-8',
    );
    request.write(Uri(queryParameters: formData).query);
    final response = await request.close();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException('Request failed: ${response.statusCode}', uri: Uri.parse(url));
    }
    return response.transform(const SystemEncoding().decoder).join();
  }
}
