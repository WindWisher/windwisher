import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/avamet_intraday_history_client.dart';

void main() {
  test('parses AVAMET intraday wind speed and direction from mxo_i chart', () async {
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

    final client = AvametIntradayHistoryClient(fetchText: (url) async => html);

    final points = await client.fetchIntradayWindHistory(
      stationId: 'c25m181e07',
    );

    expect(points, hasLength(2));
    expect(points.first.time.isBefore(points.last.time), isTrue);
    expect(points.first.windDirectionDeg, 90);
    expect(points.last.windDirectionDeg, 135);
    expect(points.first.windKnots, closeTo(18.5 * 0.539957, 0.001));
    expect(points.last.windKnots, closeTo(22.0 * 0.539957, 0.001));
  });
}
