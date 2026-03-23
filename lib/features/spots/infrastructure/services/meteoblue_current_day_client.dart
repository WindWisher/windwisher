import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class MeteoblueCurrentDaySnapshot {
  const MeteoblueCurrentDaySnapshot({
    required this.current,
    required this.sea,
    required this.days,
  });

  final MeteoblueCurrentData? current;
  final List<MeteoblueSeaData> sea;
  final List<MeteoblueDayData> days;
}

class MeteoblueCurrentData {
  const MeteoblueCurrentData({
    required this.time,
    this.temperatureC,
    this.windKnots,
    this.windDeg,
    this.pressureHpa,
    this.cloudCoverPct,
    this.isObservedData,
  });

  final DateTime? time;
  final double? temperatureC;
  final double? windKnots;
  final int? windDeg;
  final int? pressureHpa;
  final int? cloudCoverPct;
  final bool? isObservedData;
}

class MeteoblueSeaData {
  const MeteoblueSeaData({
    required this.time,
    this.surfaceWaterTempC,
    this.surfWaveHeightM,
    this.significantWaveHeightM,
    this.swellWaveHeightM,
    this.swellMeanPeriodS,
    this.swellMeanDirectionDeg,
    this.windWaveHeightM,
    this.meanWavePeriodS,
    this.windWaveMeanPeriodS,
    this.windWaveDirectionDeg,
    this.douglasSeaState,
    this.meanWaveDirectionDeg,
  });

  final DateTime? time;
  final double? surfaceWaterTempC;
  final double? surfWaveHeightM;
  final double? significantWaveHeightM;
  final double? swellWaveHeightM;
  final double? swellMeanPeriodS;
  final int? swellMeanDirectionDeg;
  final double? windWaveHeightM;
  final double? meanWavePeriodS;
  final double? windWaveMeanPeriodS;
  final int? windWaveDirectionDeg;
  final int? douglasSeaState;
  final int? meanWaveDirectionDeg;
}

class MeteoblueDayData {
  const MeteoblueDayData({
    required this.date,
    this.tempMinC,
    this.tempMaxC,
    this.windMeanKnots,
    this.precipitationMm,
    this.predictabilityPct,
  });

  final DateTime? date;
  final double? tempMinC;
  final double? tempMaxC;
  final double? windMeanKnots;
  final double? precipitationMm;
  final int? predictabilityPct;
}

class MeteoblueCurrentDayClient {
  MeteoblueCurrentDayClient({
    HttpClient? httpClient,
    String? apiKey,
    Future<Map<String, dynamic>> Function(String url)? fetchJson,
    SupabaseForecastProxyClient? forecastProxyClient,
  }) : _httpClient = httpClient,
       _apiKey = apiKey ?? EnvConfig.meteoblueApiKey,
       _fetchJsonOverride = fetchJson,
       _forecastProxyClient =
           forecastProxyClient ?? SupabaseForecastProxyClient.maybeCreate();

  final HttpClient? _httpClient;
  final String _apiKey;
  final Future<Map<String, dynamic>> Function(String url)? _fetchJsonOverride;
  final SupabaseForecastProxyClient? _forecastProxyClient;

  Future<MeteoblueCurrentDaySnapshot> fetchSnapshot({
    required SpotItem spot,
  }) async {
    if (_apiKey.isEmpty && _forecastProxyClient == null) {
      return const MeteoblueCurrentDaySnapshot(
        current: null,
        sea: <MeteoblueSeaData>[],
        days: <MeteoblueDayData>[],
      );
    }

    final location = _resolveLocation(spot: spot);
    final json = _forecastProxyClient != null
        ? await _forecastProxyClient.fetchMeteoblueForecastPackage(
            latitude: location.lat,
            longitude: location.lon,
            name: spot.name,
          )
        : await _fetchJson(_buildUrl(location, spot.name));
    final current = _parseCurrent(json['data_current']);
    final meteoData = json['data_xmin'] is Map<String, dynamic>
        ? json['data_xmin'] as Map<String, dynamic>
        : null;
    final seaData = json['data_1h'] is Map<String, dynamic>
        ? json['data_1h'] as Map<String, dynamic>
        : null;
    return MeteoblueCurrentDaySnapshot(
      current: _enrichCurrent(current, meteoData),
      sea: _parseSeaSeries(seaData),
      days: _parseDays(json['data_day']),
    );
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

  String _buildUrl(({double lat, double lon}) location, String name) {
    final encodedName = Uri.encodeComponent(name);
    return 'https://my.meteoblue.com/packages/basic-15min_basic-day_current_clouds-15min_sea-1h_air-15min_wind-1h?lat=${location.lat}&lon=${location.lon}&tz=utc&format=json&windspeed=kn&winddirection=degree&forecast_days=7&name=$encodedName&apikey=$_apiKey';
  }

  MeteoblueCurrentData? _parseCurrent(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    return MeteoblueCurrentData(
      time: _parseDateTime(source['time']),
      temperatureC: (source['temperature'] as num?)?.toDouble(),
      windKnots: (source['windspeed'] as num?)?.toDouble(),
      isObservedData: switch (source['isobserveddata']) {
        1 => true,
        0 => false,
        _ => null,
      },
    );
  }

  MeteoblueCurrentData? _enrichCurrent(
    MeteoblueCurrentData? current,
    Map<String, dynamic>? meteoData,
  ) {
    if (current == null) {
      return null;
    }
    if (meteoData == null) {
      return current;
    }
    final timeIndex = _nearestTimeIndex(meteoData['time'], current.time);
    if (timeIndex == null) {
      return current;
    }
    return MeteoblueCurrentData(
      time: current.time,
      temperatureC: current.temperatureC,
      windKnots: current.windKnots,
      windDeg: _numAt(
        _asNumList(meteoData['winddirection']),
        timeIndex,
      )?.round(),
      pressureHpa: _numAt(
        _asNumList(meteoData['sealevelpressure']),
        timeIndex,
      )?.round(),
      cloudCoverPct: _numAt(
        _asNumList(meteoData['totalcloudcover']),
        timeIndex,
      )?.round(),
      isObservedData: current.isObservedData,
    );
  }

  List<MeteoblueSeaData> _parseSeaSeries(Map<String, dynamic>? source) {
    if (source == null) {
      return const <MeteoblueSeaData>[];
    }
    final times = _asList<String>(source['time']);
    final waterTemps = _asNumList(source['seasurfacetemperature']);
    final surfHeights = _asNumList(source['surfwave_height']);
    final significantHeights = _asNumList(source['significantwaveheight']);
    final swellHeights = _asNumList(source['swell_significantheight']);
    final swellPeriods = _asNumList(source['swell_meanperiod']);
    final swellDirections = _asNumList(source['swell_meandirection']);
    final windWaveHeights = _asNumList(source['windwave_height']);
    final meanPeriods = _asNumList(source['mean_waveperiod']);
    final windWavePeriods = _asNumList(source['windwave_meanperiod']);
    final windWaveDirections = _asNumList(source['windwave_direction']);
    final douglasStates = _asNumList(source['douglas_seastate']);
    final meanDirections = _asNumList(source['mean_wavedirection']);

    return List.generate(times.length, (index) {
      return MeteoblueSeaData(
        time: _parseDateTime(times[index]),
        surfaceWaterTempC: _numAt(waterTemps, index)?.toDouble(),
        surfWaveHeightM: _numAt(surfHeights, index)?.toDouble(),
        significantWaveHeightM: _numAt(significantHeights, index)?.toDouble(),
        swellWaveHeightM: _numAt(swellHeights, index)?.toDouble(),
        swellMeanPeriodS: _numAt(swellPeriods, index)?.toDouble(),
        swellMeanDirectionDeg: _numAt(swellDirections, index)?.round(),
        windWaveHeightM: _numAt(windWaveHeights, index)?.toDouble(),
        meanWavePeriodS: _numAt(meanPeriods, index)?.toDouble(),
        windWaveMeanPeriodS: _numAt(windWavePeriods, index)?.toDouble(),
        windWaveDirectionDeg: _numAt(windWaveDirections, index)?.round(),
        douglasSeaState: _numAt(douglasStates, index)?.round(),
        meanWaveDirectionDeg: _numAt(meanDirections, index)?.round(),
      );
    });
  }

  List<MeteoblueDayData> _parseDays(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return const <MeteoblueDayData>[];
    }
    final times = _asList<String>(source['time']);
    final tempMin = _asNumList(source['temperature_min']);
    final tempMax = _asNumList(source['temperature_max']);
    final windMean = _asNumList(source['windspeed_mean']);
    final rain = _asNumList(source['precipitation']);
    final predictability = _asNumList(source['predictability']);

    return List.generate(times.length, (index) {
      return MeteoblueDayData(
        date: _parseDateTime(times[index]),
        tempMinC: _numAt(tempMin, index)?.toDouble(),
        tempMaxC: _numAt(tempMax, index)?.toDouble(),
        windMeanKnots: _numAt(windMean, index)?.toDouble(),
        precipitationMm: _numAt(rain, index)?.toDouble(),
        predictabilityPct: _numAt(predictability, index)?.round(),
      );
    });
  }

  List<T> _asList<T>(dynamic source) {
    if (source is! List) {
      return <T>[];
    }
    return source.whereType<T>().toList(growable: false);
  }

  List<num?> _asNumList(dynamic source) {
    if (source is! List) {
      return const <num?>[];
    }
    return source
        .map((value) => value is num ? value : null)
        .toList(growable: false);
  }

  num? _numAt(List<num?> values, int index) {
    if (index < 0 || index >= values.length) {
      return null;
    }
    return values[index];
  }

  int? _nearestTimeIndex(dynamic source, DateTime? target) {
    final times = _asList<String>(
      source,
    ).map(_parseDateTime).toList(growable: false);
    if (times.isEmpty) {
      return null;
    }
    if (target == null) {
      return 0;
    }
    var bestIndex = 0;
    var bestDelta = times.first == null
        ? Duration(days: 999)
        : times.first!.difference(target).abs();
    for (var i = 1; i < times.length; i++) {
      final time = times[i];
      if (time == null) {
        continue;
      }
      final delta = time.difference(target).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(value.replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> _fetchJson(String url) async {
    final fetchJsonOverride = _fetchJsonOverride;
    if (fetchJsonOverride != null) {
      return fetchJsonOverride(url);
    }
    if (kIsWeb) {
      throw UnsupportedError(
        'Meteoblue direct HttpClient is not available on web.',
      );
    }
    final httpClient = _httpClient ?? HttpClient();
    final request = await httpClient.getUrl(Uri.parse(url));
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Meteoblue current/day request failed: ${response.statusCode}',
        uri: Uri.parse(url),
      );
    }
    return jsonDecode(body) as Map<String, dynamic>;
  }
}
