import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/aemet_observation_client.dart';

void main() {
  test(
    'maps nearest AEMET observations into ordered station snapshots',
    () async {
      final client = AemetObservationClient(
        apiKey: 'test-key',
        fetchJson: (url) async => {'datos': 'test://aemet-observations'},
        fetchJsonList: (url) async => [
          {
            'idema': '9999X',
            'ubi': 'LEJANA',
            'lat': 39.5,
            'lon': -1.2,
            'fint': '2026-03-08T20:00:00+0000',
            'vv': 4.0,
            'dv': 180,
            'vmax': 6.0,
            'ta': 14.2,
            'pres': 1018.5,
            'hr': 65,
            'prec': 0.0,
          },
          {
            'idema': '8058X',
            'ubi': 'OLIVA',
            'lat': 38.904444,
            'lon': -0.065,
            'fint': '2026-03-08T20:00:00+0000',
            'vv': 1.2,
            'dv': 255,
            'vmax': 2.4,
            'ta': 11.5,
            'pres': 1021.9,
            'hr': 94,
            'prec': 0.0,
          },
          {
            'idema': '8888X',
            'ubi': 'MIRAMAR',
            'lat': 38.95,
            'lon': -0.12,
            'fint': '2026-03-08T20:00:00+0000',
            'vv': 2.0,
            'dv': 90,
            'vmax': 3.0,
            'ta': 12.8,
            'pres': 1020.5,
            'hr': 88,
            'prec': 0.2,
          },
        ],
      );

      final snapshots = await client.fetchNearestStations(
        latitude: 38.904444,
        longitude: -0.065,
        limit: 2,
      );

      expect(snapshots, hasLength(2));
      expect(snapshots.first.stationId, '8058X');
      expect(snapshots.first.stationName, 'OLIVA');
      expect(snapshots.first.distanceKm, closeTo(0, 0.1));
      expect(snapshots.first.windKnots, closeTo(2.3, 0.1));
      expect(snapshots.first.gustKnots, closeTo(4.7, 0.1));
      expect(snapshots.first.windDirectionDeg, 255);
      expect(snapshots.first.tempC, 11.5);
      expect(snapshots.first.pressureHpa, 1021.9);
      expect(snapshots.first.humidityPct, 94);
      expect(snapshots.first.rainMm, 0.0);
      expect(snapshots.last.stationId, '8888X');
    },
  );

  test(
    'maps station observation series into chronological AEMET snapshots',
    () async {
      final client = AemetObservationClient(
        apiKey: 'test-key',
        fetchJson: (url) async => {'datos': 'test://aemet-station'},
        fetchJsonList: (url) async => [
          {
            'idema': '8058X',
            'ubi': 'OLIVA',
            'lat': 38.904444,
            'lon': -0.065,
            'fint': '2026-03-17T15:00:00+0000',
            'vv': 1.8,
            'dv': 23,
            'vmax': 2.4,
            'ta': 17.2,
            'pres': 1013.5,
            'hr': 63,
            'prec': 0.0,
          },
          {
            'idema': '8058X',
            'ubi': 'OLIVA',
            'lat': 38.904444,
            'lon': -0.065,
            'fint': '2026-03-17T10:00:00+0000',
            'vv': 1.6,
            'dv': 85,
            'vmax': 3.2,
            'ta': 15.4,
            'pres': 1017.5,
            'hr': 66,
            'prec': 0.0,
          },
          {
            'idema': '8058X',
            'ubi': 'OLIVA',
            'lat': 38.904444,
            'lon': -0.065,
            'fint': '2026-03-17T12:00:00+0000',
            'vv': 2.6,
            'dv': 66,
            'vmax': 3.5,
            'ta': 16.4,
            'pres': 1016.2,
            'hr': 73,
            'prec': 0.0,
          },
        ],
      );

      final snapshots = await client.fetchStationObservations(
        stationId: '8058X',
      );

      expect(snapshots, hasLength(3));
      expect(snapshots.first.stationId, '8058X');
      expect(snapshots.first.observedAt, isNotNull);
      expect(snapshots[1].observedAt, isNotNull);
      expect(snapshots.last.observedAt, isNotNull);
      expect(
        snapshots.first.observedAt!.isBefore(snapshots[1].observedAt!),
        isTrue,
      );
      expect(
        snapshots[1].observedAt!.isBefore(snapshots.last.observedAt!),
        isTrue,
      );
      expect(snapshots.first.windKnots, closeTo(3.1, 0.1));
      expect(snapshots[1].windDirectionDeg, 66);
    },
  );
}
