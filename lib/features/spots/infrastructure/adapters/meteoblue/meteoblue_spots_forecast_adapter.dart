import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_forecast_port.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class MeteoblueSpotsForecastAdapter implements SpotsForecastPort {
  MeteoblueSpotsForecastAdapter({
    HttpClient? httpClient,
    String? apiKey,
    Future<Map<String, dynamic>> Function(String url)? fetchJson,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient ?? HttpClient(),
       _apiKey = apiKey ?? EnvConfig.meteoblueApiKey,
       _fetchJsonOverride = fetchJson,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  final HttpClient _httpClient;
  final String _apiKey;
  final Future<Map<String, dynamic>> Function(String url)? _fetchJsonOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  @override
  Future<List<SpotForecastEntry>> getForecast({
    required SpotItem spot,
    required String provider,
    required String model,
  }) async {
    if (provider != 'Meteoblue' ||
        (_apiKey.isEmpty && _forecastProxyClient == null)) {
      return const <SpotForecastEntry>[];
    }

    final location = _resolveLocation(spot: spot);
    final json = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchMeteoblueForecastPackage(
            latitude: location.lat,
            longitude: location.lon,
            name: spot.name,
          )
        : await _fetchJson(_forecastUrl(location, spot.name));
    final meteoData = _extractMeteoData(json);
    if (meteoData == null) {
      return const <SpotForecastEntry>[];
    }
    final hourlyData = _extractHourlyData(json) ?? const <String, dynamic>{};
    final marineData = _extractMarineData(json) ?? const <String, dynamic>{};

    final times = _toStringList(meteoData['time']);
    final hourlyTimes = _toStringList(hourlyData['time']);
    final hourlyByTime = <String, int>{
      for (var i = 0; i < hourlyTimes.length; i++)
        _normalizeTimeKey(hourlyTimes[i]): i,
    };

    final winds = _toNullableNumList(_pick(meteoData, const ['windspeed']));
    final meteoGusts = _toNullableNumList(
      _pick(meteoData, const ['gust', 'windgusts']),
    );
    final hourlyGusts = _toNullableNumList(
      _pick(hourlyData, const ['gust', 'windgusts']),
    );
    final directions = _toNullableNumList(
      _pick(meteoData, const ['winddirection']),
    );
    final temperatures = _toNullableNumList(
      _pick(meteoData, const ['temperature']),
    );
    final pressures = _toNullableNumList(
      _pick(meteoData, const ['sealevelpressure', 'pressure']),
    );
    final clouds = _toNullableNumList(
      _pick(meteoData, const ['totalcloudcover', 'cloudcover']),
    );
    final precipitation = _toNullableNumList(
      _pick(meteoData, const ['precipitation']),
    );
    final seaTemperature = _toNullableNumList(
      _pick(marineData, const ['seasurfacetemperature', 'seatemperature']),
    );
    final waveHeight = _toNullableNumList(
      _pick(marineData, const [
        'surfwave_height',
        'surfwaveheight',
        'significantwaveheight',
      ]),
    );
    final results = <SpotForecastEntry>[];
    for (var i = 0; i < times.length; i++) {
      final wind = _numAtOrNull(winds, i);
      final hourlyIndex = hourlyByTime[_normalizeTimeKey(times[i])];
      final gust =
          _numAtOrNull(meteoGusts, i) ??
          (hourlyIndex == null ? null : _numAtOrNull(hourlyGusts, hourlyIndex));
      final direction = _numAtOrNull(directions, i);
      final temperature = _numAtOrNull(temperatures, i);
      if (wind == null || direction == null || temperature == null) {
        continue;
      }

      final parsedTime = _parseTime(times[i]);
      if (parsedTime == null) {
        continue;
      }

      final marineIndex = hourlyByTime[_normalizeTimeKey(times[i])];

      results.add(
        SpotForecastEntry(
          time: parsedTime,
          windKnots: wind.round(),
          gustKnots: gust?.round(),
          windDeg: direction.round(),
          airTempC: temperature.round(),
          waterTempC: marineIndex == null
              ? null
              : _numAtOrNull(seaTemperature, marineIndex)?.round(),
          pressureHpa: _numAtOrNull(pressures, i)?.round(),
          cloudCoverPct: _numAtOrNull(clouds, i)?.round(),
          waveM: marineIndex == null
              ? null
              : _numAtOrNull(waveHeight, marineIndex)?.toDouble(),
          rainMm: _numAtOrNull(precipitation, i)?.toDouble(),
        ),
      );
    }

    return results;
  }

  ({double lat, double lon}) _resolveLocation({required SpotItem spot}) {
    if (spot.latitude != null && spot.longitude != null) {
      return (lat: spot.latitude!, lon: spot.longitude!);
    }
    if (spot.area.toLowerCase().contains('valencia')) {
      return (lat: 39.2763, lon: -0.2758);
    }
    return (lat: 38.9196, lon: -0.1192);
  }

  String _forecastUrl(({double lat, double lon}) location, String name) {
    final encodedName = Uri.encodeComponent(name);
    return 'https://my.meteoblue.com/packages/basic-15min_basic-day_current_clouds-15min_sea-1h_air-15min_wind-1h?lat=${location.lat}&lon=${location.lon}&tz=utc&format=json&windspeed=kn&winddirection=degree&forecast_days=7&name=$encodedName&apikey=$_apiKey';
  }

  Map<String, dynamic>? _extractMeteoData(Map<String, dynamic> source) {
    final section = source['data_xmin'];
    if (section is Map<String, dynamic>) {
      return section;
    }
    return _extractHourlyData(source);
  }

  Map<String, dynamic>? _extractMarineData(Map<String, dynamic> source) {
    final section = source['data_1h'];
    if (section is Map<String, dynamic>) {
      return section;
    }
    return _extractHourlyData(source);
  }

  Map<String, dynamic>? _extractHourlyData(Map<String, dynamic> source) {
    final section = source['data_1h'];
    if (section is Map<String, dynamic>) {
      return section;
    }
    return source;
  }

  dynamic _pick(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      if (source.containsKey(key)) {
        return source[key];
      }
    }
    return null;
  }

  List<String> _toStringList(dynamic source) {
    if (source is! List) {
      return const <String>[];
    }
    return source.whereType<String>().toList(growable: false);
  }

  List<num?> _toNullableNumList(dynamic source) {
    if (source is! List) {
      return const <num?>[];
    }
    return source.map((value) => value is num ? value : null).toList();
  }

  num? _numAtOrNull(List<num?> values, int index) {
    if (index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  DateTime? _parseTime(String value) {
    try {
      return DateTime.parse(value.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  String _normalizeTimeKey(String value) {
    return value.replaceFirst('T', ' ').trim();
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    final fetchJsonOverride = _fetchJsonOverride;
    if (fetchJsonOverride != null) {
      return fetchJsonOverride(url);
    }
    final request = await _httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Forecast request failed: ${response.statusCode} ${body.length > 240 ? body.substring(0, 240) : body}',
        uri: Uri.parse(url),
      );
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }
}
