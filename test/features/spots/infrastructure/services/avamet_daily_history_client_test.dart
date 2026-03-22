import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/avamet_daily_history_client.dart';

void main() {
  test('parses AVAMET daily mean wind series from mx-dia Highcharts block', () async {
    const html = r'''
<script>
$('#grafic3').highcharts({
  series:[
    {yAxis: 0,data:[[1773356400000,8.2],[1773270000000,5.6]],color:'#CCCCCC',lineWidth:2,marker: {enabled: false},name:'Vel Mit'},
    {yAxis: 0,data:[[1773356400000,29.0],[1773270000000,20.9]],color:'#009966',lineWidth:1,marker: {enabled: false},name:'Vel Max'}
  ],
  plotOptions:{}
});
</script>
<script>
$('#grafic4').highcharts({});
</script>
''';

    final client = AvametDailyHistoryClient(fetchText: (url) async => html);

    final points = await client.fetchDailyWindHistory(
      stationId: 'c25m181e07',
      maxDays: 30,
    );

    expect(points, hasLength(2));
    expect(points.first.time.isBefore(points.last.time), isTrue);
    expect(points.first.windKnots, closeTo(5.6 * 0.539957, 0.001));
    expect(points.last.windKnots, closeTo(8.2 * 0.539957, 0.001));
  });
}
