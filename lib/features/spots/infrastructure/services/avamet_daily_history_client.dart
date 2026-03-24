import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class AvametDailyHistoryPoint {
  const AvametDailyHistoryPoint({
    required this.time,
    required this.windKnots,
  });

  final DateTime time;
  final double windKnots;
}

class AvametDailyHistoryClient {
  AvametDailyHistoryClient({
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

  Future<List<AvametDailyHistoryPoint>> fetchDailyWindHistory({
    required String stationId,
    int maxDays = 30,
  }) async {
    final body = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchAvametDailyHistoryHtml(
            stationId: stationId,
          )
        : await _fetchText(
            'https://www.avamet.org/mx-dia.php?id=$stationId',
          );
    final points = _parseDailyWindHistory(body);
    if (points.length <= maxDays) {
      return points;
    }
    return points.sublist(points.length - maxDays);
  }

  List<AvametDailyHistoryPoint> _parseDailyWindHistory(String body) {
    final chartStart = body.indexOf(r"$('#grafic3').highcharts(");
    if (chartStart == -1) {
      return const <AvametDailyHistoryPoint>[];
    }
    final chartEnd = body.indexOf(r"$('#grafic4').highcharts(", chartStart);
    final chartBlock = chartEnd == -1
        ? body.substring(chartStart)
        : body.substring(chartStart, chartEnd);
    final meanWindSeries = _extractSeriesData(
      chartBlock,
      seriesName: "name:'Vel Mit'",
    );
    if (meanWindSeries == null || meanWindSeries.isEmpty) {
      return const <AvametDailyHistoryPoint>[];
    }

    final pairRegex = RegExp(r'\[(\d{10,13}),([0-9]+(?:\.[0-9]+)?)\]');
    final points = <AvametDailyHistoryPoint>[];
    for (final match in pairRegex.allMatches(meanWindSeries)) {
      final millis = int.tryParse(match.group(1) ?? '');
      final kmh = double.tryParse(match.group(2) ?? '');
      if (millis == null || kmh == null) {
        continue;
      }
      points.add(
        AvametDailyHistoryPoint(
          time: DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true)
              .toLocal(),
          windKnots: kmh * 0.539957,
        ),
      );
    }
    points.sort((a, b) => a.time.compareTo(b.time));
    return points;
  }

  String? _extractSeriesData(String chartBlock, {required String seriesName}) {
    final nameIndex = chartBlock.indexOf(seriesName);
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
        'AVAMET daily history direct HttpClient is not available on web.',
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
