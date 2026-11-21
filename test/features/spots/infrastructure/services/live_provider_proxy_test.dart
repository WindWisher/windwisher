import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/features/spots/infrastructure/services/meteoclimatic_live_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/portus_realtime_wind_client.dart';
import 'package:windwisher/features/spots/infrastructure/services/supabase_forecast_proxy_client.dart';

class _Proxy extends SupabaseForecastProxyClient {
  _Proxy()
    : super(client: SupabaseClient('https://example.supabase.co', 'test'));

  final calls = <String>[];

  @override
  Future<String> fetchMeteoclimaticObservation({
    required String stationId,
  }) async {
    calls.add(stationId);
    return '<rss>[[<ESPVA4600000046420A;(22;0;0);(72;0;0);'
        '(1018;0;0);(18.52;37.04;90);(0);Test>]]</rss>';
  }

  @override
  Future<dynamic> fetchPortusWind({
    required String operation,
    int? stationId,
  }) async {
    calls.add('$operation:$stationId');
    if (operation == 'stations') {
      return [
        {'id': 123, 'nombre': 'Test', 'latitud': 38.9, 'longitud': -.1},
      ];
    }
    if (operation == 'history') return <dynamic>[];
    return {
      'fecha': '2026-11-21 08:00:00',
      'datos': [
        {'paramEseoo': 'WindSpeed', 'valor': 5, 'factor': 1},
      ],
    };
  }
}

void main() {
  test(
    'Meteoclimatic parses the proxy feed without using HttpClient',
    () async {
      final proxy = _Proxy();
      final snapshot = await MeteoclimaticLiveClient(
        forecastProxyClient: proxy,
      ).fetchSnapshot(stationId: 'ESPVA4600000046420A');
      expect(proxy.calls, ['ESPVA4600000046420A']);
      expect(snapshot?.windKnots, closeTo(10, .001));
    },
  );
  test(
    'Portus routes metadata, current and history through restricted operations',
    () async {
      final proxy = _Proxy();
      final client = PortusRealtimeWindClient(forecastProxyClient: proxy);
      expect(
        (await client.fetchWindStationMetadata(stationId: 123))?.name,
        'Test',
      );
      final current = await client.fetchWindStation(stationId: 123);
      expect(current?.windKnots, closeTo(9.71922246, .00001));
      expect(await client.fetchWindHistory(stationId: 123), isEmpty);
      expect(proxy.calls, ['stations:null', 'current:123', 'history:123']);
    },
  );
}
