import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class AvametIntradayHistoryPoint {
  const AvametIntradayHistoryPoint({
    required this.time,
    required this.windKnots,
    required this.windDirectionDeg,
  });

  final DateTime time;
  final double windKnots;
  final int? windDirectionDeg;
}

class AvametIntradayHistoryClient {
  AvametIntradayHistoryClient({
    HttpClient? httpClient,
    Future<String> Function(String url)? fetchText,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient,
       _fetchTextOverride = fetchText,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  final HttpClient? _httpClient;
  final Future<String> Function(String url)? _fetchTextOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;
  static const Duration _historyRequestTimeout = Duration(seconds: 6);

  Future<List<AvametIntradayHistoryPoint>> fetchIntradayWindHistory({
    required String stationId,
  }) async {
    final body =
        await (_forecastProxyClient != null
                ? _forecastProxyClient.fetchAvametIntradayHistoryHtml(
                    stationId: stationId,
                  )
                : _fetchText('https://www.avamet.org/mxo_i.php?id=$stationId'))
            .timeout(_historyRequestTimeout);
    return _parseIntradayWindHistory(body);
  }

  List<AvametIntradayHistoryPoint> _parseIntradayWindHistory(String body) {
    final chartStart = body.indexOf(r"$('#grafic3').highcharts(");
    if (chartStart == -1) {
      return const <AvametIntradayHistoryPoint>[];
    }
    final chartEnd = body.indexOf(r"$('#grafic4').highcharts(", chartStart);
    final chartBlock = chartEnd == -1
        ? body.substring(chartStart)
        : body.substring(chartStart, chartEnd);

    final directionSeries = _extractSeriesData(
      chartBlock,
      seriesNames: const <String>[
        "name:'Direcció'",
        "name:'DirecciÃ³'",
        "name:'Dire",
      ],
    );
    final speedSeries = _extractSeriesData(
      chartBlock,
      seriesNames: const <String>["name:'Velocitat'"],
    );
    if (speedSeries == null || speedSeries.isEmpty) {
      return const <AvametIntradayHistoryPoint>[];
    }

    final directionPoints = _parseSeriesPairs(directionSeries);
    final speedPoints = _parseSeriesPairs(speedSeries);
    final points = <AvametIntradayHistoryPoint>[];

    for (final speedPoint in speedPoints) {
      points.add(
        AvametIntradayHistoryPoint(
          time: DateTime.fromMillisecondsSinceEpoch(
            speedPoint.timestampMillis,
            isUtc: true,
          ).toLocal(),
          windKnots: speedPoint.value * 0.539957,
          windDirectionDeg: _findNearestDirectionDeg(
            directionPoints,
            speedPoint.timestampMillis,
          ),
        ),
      );
    }

    points.sort((a, b) => a.time.compareTo(b.time));
    return points;
  }

  List<_SeriesPoint> _parseSeriesPairs(String? rawSeries) {
    if (rawSeries == null || rawSeries.isEmpty) {
      return const <_SeriesPoint>[];
    }
    final pairRegex = RegExp(r'\[(\d{10,13}),(-?[0-9]+(?:\.[0-9]+)?)\]');
    final values = <_SeriesPoint>[];
    for (final match in pairRegex.allMatches(rawSeries)) {
      final millis = int.tryParse(match.group(1) ?? '');
      final value = double.tryParse(match.group(2) ?? '');
      if (millis == null || value == null) {
        continue;
      }
      values.add(_SeriesPoint(timestampMillis: millis, value: value));
    }
    values.sort((a, b) => a.timestampMillis.compareTo(b.timestampMillis));
    return values;
  }

  int? _findNearestDirectionDeg(
    List<_SeriesPoint> directions,
    int speedTimestampMillis,
  ) {
    if (directions.isEmpty) {
      return null;
    }

    _SeriesPoint? bestMatch;
    var bestDistance = 1 << 30;
    for (final direction in directions) {
      final distance = (direction.timestampMillis - speedTimestampMillis).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        bestMatch = direction;
      }
      if (distance == 0) {
        break;
      }
    }

    if (bestMatch == null) {
      return null;
    }
    if (bestDistance > const Duration(hours: 3).inMilliseconds) {
      return null;
    }
    return bestMatch.value.round();
  }

  String? _extractSeriesData(
    String chartBlock, {
    required List<String> seriesNames,
  }) {
    var nameIndex = -1;
    for (final seriesName in seriesNames) {
      nameIndex = chartBlock.indexOf(seriesName);
      if (nameIndex != -1) {
        break;
      }
    }
    if (nameIndex == -1) {
      return null;
    }

    final dataIndex = chartBlock.lastIndexOf('data:[', nameIndex);
    if (dataIndex == -1) {
      return null;
    }

    final buffer = StringBuffer();
    var depth = 1;
    for (var i = dataIndex + 'data:['.length; i < chartBlock.length; i++) {
      final char = chartBlock[i];
      if (char == '[') {
        depth++;
      } else if (char == ']') {
        depth--;
        if (depth == 0) {
          return buffer.toString();
        }
      }
      buffer.write(char);
    }
    return null;
  }

  Future<String> _fetchText(String url) async {
    if (_fetchTextOverride != null) {
      return _fetchTextOverride(url);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'AVAMET intraday history direct HttpClient is not available on web.',
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

class _SeriesPoint {
  const _SeriesPoint({required this.timestampMillis, required this.value});

  final int timestampMillis;
  final double value;
}
