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
}

class SupabaseForecastProxyException implements Exception {
  const SupabaseForecastProxyException(this.message);

  final String message;

  @override
  String toString() => message;
}
