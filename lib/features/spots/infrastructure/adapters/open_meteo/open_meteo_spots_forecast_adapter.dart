import 'dart:convert';
import 'dart:io';

import 'package:windwisher/features/spots/domain/entities/spot_forecast_entry.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_forecast_port.dart';

class OpenMeteoSpotsForecastAdapter implements SpotsForecastPort {
  OpenMeteoSpotsForecastAdapter({
    HttpClient? httpClient,
    Future<Map<String, dynamic>> Function(String url)? fetchJson,
  }) : _httpClient = httpClient ?? HttpClient(),
       _fetchJsonOverride = fetchJson;

  final HttpClient _httpClient;
  final Future<Map<String, dynamic>> Function(String url)? _fetchJsonOverride;

  @override
  Future<List<SpotForecastEntry>> getForecast({
    required SpotItem spot,
    required String provider,
    required String model,
  }) async {
    if (provider != 'Open-Meteo') {
      return const <SpotForecastEntry>[];
    }

    final location = _resolveLocation(spot: spot);
    final weatherJson = await _fetchJson(_weatherUrl(location, model));
    final marineJson = await _fetchJson(_marineUrl(location));

    final weatherHourly = weatherJson['hourly'] as Map<String, dynamic>?;
    final marineHourly = marineJson['hourly'] as Map<String, dynamic>?;
    if (weatherHourly == null || marineHourly == null) {
      return const [];
    }

    final weatherTimes = (weatherHourly['time'] as List<dynamic>)
        .cast<String>();
    final marineTimes = (marineHourly['time'] as List<dynamic>).cast<String>();
    final marineByTime = <String, int>{
      for (var i = 0; i < marineTimes.length; i++) marineTimes[i]: i,
    };

    final windSpeeds = _toNullableNumList(weatherHourly['wind_speed_10m']);
    final gusts = _toNullableNumList(weatherHourly['wind_gusts_10m']);
    final directions = _toNullableNumList(weatherHourly['wind_direction_10m']);
    final airTemps = _toNullableNumList(weatherHourly['temperature_2m']);
    final pressures = _toNullableNumList(weatherHourly['pressure_msl']);
    final clouds = _toNullableNumList(weatherHourly['cloud_cover']);
    final rain = _toNullableNumList(weatherHourly['precipitation']);
    final waterTemps = _toNullableNumList(
      marineHourly['sea_surface_temperature'],
    );
    final waves = _toNullableNumList(marineHourly['wave_height']);

    final results = <SpotForecastEntry>[];
    for (var i = 0; i < weatherTimes.length; i += 3) {
      final time = weatherTimes[i];
      final marineIndex = marineByTime[time];
      if (marineIndex == null) {
        continue;
      }

      final windSpeed = _numAtOrNull(windSpeeds, i);
      final gust = _numAtOrNull(gusts, i);
      final direction = _numAtOrNull(directions, i);
      final airTemp = _numAtOrNull(airTemps, i);
      final pressure = _numAtOrNull(pressures, i);
      final cloud = _numAtOrNull(clouds, i);
      final rainMm = _numAtOrNull(rain, i);
      final waterTemp = _numAtOrNull(waterTemps, marineIndex);
      final wave = _numAtOrNull(waves, marineIndex);
      if (windSpeed == null ||
          gust == null ||
          direction == null ||
          airTemp == null ||
          pressure == null ||
          cloud == null ||
          rainMm == null ||
          waterTemp == null ||
          wave == null) {
        continue;
      }

      results.add(
        SpotForecastEntry(
          time: DateTime.parse(time),
          windKnots: _kmhToKnots(windSpeed.toDouble()).round(),
          gustKnots: _kmhToKnots(gust.toDouble()).round(),
          windDeg: direction.round(),
          airTempC: airTemp.round(),
          waterTempC: waterTemp.round(),
          pressureHpa: pressure.round(),
          cloudCoverPct: cloud.round(),
          waveM: wave.toDouble(),
          rainMm: rainMm.toDouble(),
        ),
      );
    }

    return results;
  }

  ({double lat, double lon}) _resolveLocation({required SpotItem spot}) {
    final latitude = spot.latitude;
    final longitude = spot.longitude;
    if (latitude == null || longitude == null) {
      throw StateError('Open-Meteo requiere coordenadas en el spot.');
    }
    return (lat: latitude, lon: longitude);
  }

  String _weatherUrl(({double lat, double lon}) location, String model) {
    final normalizedModel = switch (model) {
      'Best match' => null,
      'ICON' => 'icon_seamless',
      'ECMWF' => 'ecmwf_ifs025',
      'AROME Seamless' => 'meteofrance_arome_seamless',
      'AROME France' => 'meteofrance_arome_france',
      'ARPEGE Europe' => 'meteofrance_arpege_europe',
      'ARPEGE Seamless' => 'meteofrance_seamless',
      'ARPEGE World' => 'meteofrance_arpege_world',
      _ => 'gfs_seamless',
    };
    final modelsQuery = normalizedModel == null
        ? ''
        : '&models=$normalizedModel';
    return 'https://api.open-meteo.com/v1/forecast?latitude=${location.lat}&longitude=${location.lon}&hourly=temperature_2m,pressure_msl,cloud_cover,precipitation,wind_speed_10m,wind_direction_10m,wind_gusts_10m&forecast_days=16$modelsQuery&timezone=auto';
  }

  String _marineUrl(({double lat, double lon}) location) {
    return 'https://marine-api.open-meteo.com/v1/marine?latitude=${location.lat}&longitude=${location.lon}&hourly=wave_height,sea_surface_temperature&forecast_days=16&timezone=auto';
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

  double _kmhToKnots(double kmh) => kmh / 1.852;
}
