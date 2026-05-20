import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/meteoclimatic_live_client.dart';

void main() {
  test('maps Meteoclimatic RSS station snapshot', () async {
    final client = MeteoclimaticLiveClient(
      fetchText: (_) async => '''
<?xml version="1.0" encoding="ISO-8859-15"?>
<rss version="2.0">
 <channel>
  <item>
   <pubDate>Tue, 19 May 2026 19:38:18 +0000</pubDate>
   <description>
    <![CDATA[
     <ul>
      <li> Actualizado: 19-05-2026 19:17 UTC</li>
     </ul>
    ]]>
<!--
[[<BEGIN:ESPVA4600000046420A:DATA>]]
[[<ESPVA4600000046420A;(22,0;28,6;16,0;moon);(72,0;87,0;36,0);(1018,4;1019,3;1017,3);(11,0;48,0;103);(0,0);El Perell&#243;>]]
[[<END:ESPVA4600000046420A:DATA>]]
-->
   </description>
   <georss:point>39.27 -0.28</georss:point>
  </item>
 </channel>
</rss>
''',
    );

    final snapshot = await client.fetchSnapshot(
      stationId: 'ESPVA4600000046420A',
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.stationId, 'ESPVA4600000046420A');
    expect(snapshot.stationName, 'El Perello');
    expect(
      snapshot.observedAt?.isAtSameMomentAs(
        DateTime.utc(2026, 5, 19, 19, 38, 18),
      ),
      isTrue,
    );
    expect(snapshot.observedAtLabel, '19-05-2026 19:17 UTC');
    expect(snapshot.latitude, 39.27);
    expect(snapshot.longitude, -0.28);
    expect(snapshot.windKnots, closeTo(5.94, 0.01));
    expect(snapshot.gustKnots, closeTo(25.92, 0.01));
    expect(snapshot.windDirectionDeg, 103);
    expect(snapshot.tempC, 22);
    expect(snapshot.pressureHpa, 1018);
    expect(snapshot.humidityPct, 72);
    expect(snapshot.rainMm, 0);
  });
}
