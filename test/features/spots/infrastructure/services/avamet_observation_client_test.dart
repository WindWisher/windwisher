import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/avamet_observation_client.dart';

void main() {
  test('parses AVAMET station observations from HTML snippet', () async {
    const html = '''
Oliva Club N&agrave;utic
12-03-2026 21:37
16,5&deg;
Humitat74%
Pressi&oacute; al nivell de la mar1.018hPa
Vent10km/h ONO
Vent m&agrave;x19km/h
Pluja hui0,0mm
''';
    final client = AvametObservationClient(fetchText: (url) async => html);

    final snapshot = await client.fetchStationObservation(
      stationId: 'c25m181e07',
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.observedAt, DateTime(2026, 3, 12, 21, 37));
    expect(snapshot.tempC, closeTo(16.5, 0.01));
    expect(snapshot.humidityPct, 74);
    expect(snapshot.pressureHpa, closeTo(1018, 0.01));
    expect(snapshot.windKnots, closeTo(5.4, 0.1));
    expect(snapshot.windDirectionDeg, 293);
    expect(snapshot.gustKnots, closeTo(10.3, 0.1));
    expect(snapshot.rainMm, closeTo(0.0, 0.01));
  });

  test('parses AVAMET humidity without percent symbol', () async {
    const html = '''
Oliva Club N&agrave;utic
12-03-2026 21:37
16,5&deg;
Humitat74
Pressi&oacute; al nivell de la mar1.018hPa
Vent10km/h ONO
Vent m&agrave;x19km/h
Pluja hui0,0mm
''';
    final client = AvametObservationClient(fetchText: (url) async => html);

    final snapshot = await client.fetchStationObservation(
      stationId: 'c25m181e07',
    );

    expect(snapshot, isNotNull);
    expect(snapshot!.humidityPct, 74);
  });
}
