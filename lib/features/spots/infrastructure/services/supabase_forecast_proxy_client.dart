import 'package:windwisher/core/config/env/env_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseForecastProxyClient {
  SupabaseForecastProxyClient({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static SupabaseForecastProxyClient? maybeCreate() {
    return EnvConfig.supabaseConfigured ? SupabaseForecastProxyClient() : null;
  }

  Future<List<Map<String, dynamic>>> fetchAemetMunicipalForecast({
    required String municipalityCode,
  }) {
    return _invokeList(
      action: 'aemet-municipal-forecast',
      body: <String, dynamic>{
        'action': 'aemet-municipal-forecast',
        'municipalityCode': municipalityCode,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAemetBeachForecast({
    required String beachCode,
  }) {
    return _invokeList(
      action: 'aemet-beach-forecast',
      body: <String, dynamic>{
        'action': 'aemet-beach-forecast',
        'beachCode': beachCode,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAemetCoastalForecast({
    required String coastalCode,
  }) {
    return _invokeList(
      action: 'aemet-coastal-forecast',
      body: <String, dynamic>{
        'action': 'aemet-coastal-forecast',
        'coastalCode': coastalCode,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAemetStationObservation({
    required String stationId,
  }) {
    return _invokeList(
      action: 'aemet-station-observation',
      body: <String, dynamic>{
        'action': 'aemet-station-observation',
        'stationId': stationId,
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchAemetLatestObservations() {
    return _invokeList(
      action: 'aemet-observations-latest',
      body: const <String, dynamic>{'action': 'aemet-observations-latest'},
    );
  }

  Future<Map<String, dynamic>> fetchMeteoblueForecastPackage({
    required double latitude,
    required double longitude,
    required String name,
  }) {
    return _invokeMap(
      action: 'meteoblue-forecast-package',
      body: <String, dynamic>{
        'action': 'meteoblue-forecast-package',
        'lat': latitude,
        'lon': longitude,
        'name': name,
      },
    );
  }

  Future<Map<String, dynamic>> fetchMeteosourcePointForecast({
    required double latitude,
    required double longitude,
    required String sections,
  }) {
    return _invokeMap(
      action: 'meteosource-point-forecast',
      body: <String, dynamic>{
        'action': 'meteosource-point-forecast',
        'lat': latitude,
        'lon': longitude,
        'sections': sections,
      },
    );
  }

  Future<Map<String, dynamic>> fetchMeteostatPointHourly({
    required double latitude,
    required double longitude,
    required String startDate,
    required String endDate,
  }) {
    return _invokeMap(
      action: 'meteostat-point-hourly',
      body: <String, dynamic>{
        'action': 'meteostat-point-hourly',
        'lat': latitude,
        'lon': longitude,
        'start': startDate,
        'end': endDate,
      },
    );
  }

  Future<Map<String, dynamic>> fetchMeteostatPointDaily({
    required double latitude,
    required double longitude,
    required String startDate,
    required String endDate,
  }) {
    return _invokeMap(
      action: 'meteostat-point-daily',
      body: <String, dynamic>{
        'action': 'meteostat-point-daily',
        'lat': latitude,
        'lon': longitude,
        'start': startDate,
        'end': endDate,
      },
    );
  }

  Future<Map<String, dynamic>> fetchOpenMeteoPointForecast({
    required double latitude,
    required double longitude,
    required String model,
  }) {
    return _invokeMap(
      action: 'open-meteo-point-forecast',
      body: <String, dynamic>{
        'action': 'open-meteo-point-forecast',
        'lat': latitude,
        'lon': longitude,
        'model': model,
      },
    );
  }

  Future<Map<String, dynamic>> fetchOpenMeteoPointMarine({
    required double latitude,
    required double longitude,
  }) {
    return _invokeMap(
      action: 'open-meteo-point-marine',
      body: <String, dynamic>{
        'action': 'open-meteo-point-marine',
        'lat': latitude,
        'lon': longitude,
      },
    );
  }

  Future<String> fetchAvametDailyHistoryHtml({
    required String stationId,
  }) {
    return _invokeText(
      action: 'avamet-daily-history',
      body: <String, dynamic>{
        'action': 'avamet-daily-history',
        'stationId': stationId,
      },
    );
  }

  Future<String> fetchAvametIntradayHistoryHtml({
    required String stationId,
  }) {
    return _invokeText(
      action: 'avamet-intraday-history',
      body: <String, dynamic>{
        'action': 'avamet-intraday-history',
        'stationId': stationId,
      },
    );
  }

  Future<String> fetchAvametObservationHtml({
    required String stationId,
  }) {
    return _invokeText(
      action: 'avamet-observation',
      body: <String, dynamic>{
        'action': 'avamet-observation',
        'stationId': stationId,
      },
    );
  }

  Future<Map<String, dynamic>> fetchAiguaBlancaLatest() {
    return _invokeMap(
      action: 'aigua-blanca-latest',
      body: const <String, dynamic>{'action': 'aigua-blanca-latest'},
    );
  }

  Future<dynamic> fetchOpenMeteoWeatherGrid({
    required String latitudes,
    required String longitudes,
    required String model,
  }) {
    return _invokeDynamic(
      action: 'open-meteo-weather-grid',
      body: <String, dynamic>{
        'action': 'open-meteo-weather-grid',
        'latitudes': latitudes,
        'longitudes': longitudes,
        'model': model,
      },
    );
  }

  Future<dynamic> fetchOpenMeteoMarineGrid({
    required String latitudes,
    required String longitudes,
  }) {
    return _invokeDynamic(
      action: 'open-meteo-marine-grid',
      body: <String, dynamic>{
        'action': 'open-meteo-marine-grid',
        'latitudes': latitudes,
        'longitudes': longitudes,
      },
    );
  }

  Future<String> fetchInforatgePage({
    required String url,
  }) {
    return _invokeText(
      action: 'inforatge-page',
      body: <String, dynamic>{
        'action': 'inforatge-page',
        'url': url,
      },
    );
  }

  Future<String> fetchInforatgeGraph({
    required String url,
    required Map<String, String> formData,
  }) {
    return _invokeText(
      action: 'inforatge-graph',
      body: <String, dynamic>{
        'action': 'inforatge-graph',
        'url': url,
        'formData': formData,
      },
    );
  }

  Future<List<Map<String, dynamic>>> _invokeList({
    required String action,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'forecast-proxy',
        body: body,
      );
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const SupabaseForecastProxyException('invalid-proxy-payload');
      }
      final data = payload['data'];
      if (data is! List) {
        throw SupabaseForecastProxyException('missing-data-list:$action');
      }
      return data.whereType<Map<String, dynamic>>().toList(growable: false);
    } on FunctionException catch (error) {
      throw SupabaseForecastProxyException(
        'function-${error.status}:${error.details ?? error.reasonPhrase ?? action}',
      );
    } catch (error) {
      throw SupabaseForecastProxyException('$action:$error');
    }
  }

  Future<Map<String, dynamic>> _invokeMap({
    required String action,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'forecast-proxy',
        body: body,
      );
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const SupabaseForecastProxyException('invalid-proxy-payload');
      }
      final data = payload['data'];
      if (data is! Map<String, dynamic>) {
        throw SupabaseForecastProxyException('missing-data-map:$action');
      }
      return data;
    } on FunctionException catch (error) {
      throw SupabaseForecastProxyException(
        'function-${error.status}:${error.details ?? error.reasonPhrase ?? action}',
      );
    } catch (error) {
      throw SupabaseForecastProxyException('$action:$error');
    }
  }

  Future<String> _invokeText({
    required String action,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'forecast-proxy',
        body: body,
      );
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const SupabaseForecastProxyException('invalid-proxy-payload');
      }
      final data = payload['data'];
      if (data is! String) {
        throw SupabaseForecastProxyException('missing-data-text:$action');
      }
      return data;
    } on FunctionException catch (error) {
      throw SupabaseForecastProxyException(
        'function-${error.status}:${error.details ?? error.reasonPhrase ?? action}',
      );
    } catch (error) {
      throw SupabaseForecastProxyException('$action:$error');
    }
  }

  Future<dynamic> _invokeDynamic({
    required String action,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'forecast-proxy',
        body: body,
      );
      final payload = response.data;
      if (payload is! Map<String, dynamic>) {
        throw const SupabaseForecastProxyException('invalid-proxy-payload');
      }
      if (!payload.containsKey('data')) {
        throw SupabaseForecastProxyException('missing-data:$action');
      }
      return payload['data'];
    } on FunctionException catch (error) {
      throw SupabaseForecastProxyException(
        'function-${error.status}:${error.details ?? error.reasonPhrase ?? action}',
      );
    } catch (error) {
      throw SupabaseForecastProxyException('$action:$error');
    }
  }
}

class SupabaseForecastProxyException implements Exception {
  const SupabaseForecastProxyException(this.message);

  final String message;

  @override
  String toString() => message;
}
