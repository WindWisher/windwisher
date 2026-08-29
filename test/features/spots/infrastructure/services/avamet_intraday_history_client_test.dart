import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/avamet_intraday_history_client.dart';

void main() {
  test(
    'parses AVAMET intraday wind speed and direction from mxo_i chart',
    () async {
      const html = r'''
<script>
$('#grafic3').highcharts({
  series:[
    {yAxis: 0,data:[[1773500000000,90],[1773503600000,135]],name:'Direcció'},
    {yAxis: 1,data:[[1773500000000,18.5],[1773503600000,22.0]],name:'Velocitat'}
  ],
  tooltip:{}
});
</script>
<script>
$('#grafic4').highcharts({});
</script>
''';

      final client = AvametIntradayHistoryClient(
        fetchText: (url) async => html,
      );

      final points = await client.fetchIntradayWindHistory(
        stationId: 'c25m181e07',
      );

      expect(points, hasLength(2));
      expect(points.first.time.isBefore(points.last.time), isTrue);
      expect(points.first.time.isUtc, isFalse);
      expect(points.first.windDirectionDeg, 90);
      expect(points.last.windDirectionDeg, 135);
      expect(points.first.windKnots, closeTo(18.5 * 0.539957, 0.001));
      expect(points.last.windKnots, closeTo(22.0 * 0.539957, 0.001));
    },
  );

  test(
    'keeps AVAMET summer wall-clock time without applying a UTC offset',
    () async {
      // AVAMET shows this sample as 28-08-2026 21:52. The epoch value has the
      // same 21:52 fields in UTC and must not be converted to 23:52 in Spain.
      const html = r'''
<script>
$('#grafic3').highcharts({
  series:[
    {data:[[1787953920000,270]],name:'Direcció'},
    {data:[[1787953920000,4.8]],name:'Velocitat'}
  ]
});
</script>
<script>$('#grafic4').highcharts({});</script>
''';
      final client = AvametIntradayHistoryClient(fetchText: (_) async => html);

      final points = await client.fetchIntradayWindHistory(
        stationId: 'c25m181e07',
      );

      expect(points, hasLength(1));
      expect(points.single.time, DateTime(2026, 8, 28, 21, 52));
      expect(points.single.windKnots, closeTo(4.8 * 0.539957, 0.001));
      expect(points.single.windDirectionDeg, 270);
    },
  );

  test('keeps AVAMET winter wall-clock time without adding one hour', () async {
    const html = r'''
<script>
$('#grafic3').highcharts({
  series:[
    {data:[[1768513920000,90]],name:'Direcció'},
    {data:[[1768513920000,12.0]],name:'Velocitat'}
  ]
});
</script>
<script>$('#grafic4').highcharts({});</script>
''';
    final client = AvametIntradayHistoryClient(fetchText: (_) async => html);

    final points = await client.fetchIntradayWindHistory(
      stationId: 'c25m181e07',
    );

    expect(points, hasLength(1));
    expect(points.single.time, DateTime(2026, 1, 15, 21, 52));
  });

  test('preserves AVAMET wall-clock fields across the DST jump', () async {
    const html = r'''
<script>
$('#grafic3').highcharts({
  series:[
    {data:[[1774749000000,90],[1774753800000,135]],name:'Direcció'},
    {data:[[1774749000000,10.0],[1774753800000,14.0]],name:'Velocitat'}
  ]
});
</script>
<script>$('#grafic4').highcharts({});</script>
''';
    final client = AvametIntradayHistoryClient(fetchText: (_) async => html);

    final points = await client.fetchIntradayWindHistory(
      stationId: 'c25m181e07',
    );

    expect(points, hasLength(2));
    expect(points.first.time, DateTime(2026, 3, 29, 1, 50));
    expect(points.last.time, DateTime(2026, 3, 29, 3, 10));
  });
}
