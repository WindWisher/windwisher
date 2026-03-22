import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/services/meteostat_day_client.dart';

void main() {
  test('maps Meteostat daily payload into day snapshot', () async {
    final client = MeteostatDayClient(
      rapidApiKey: 'test-key',
      rapidApiHost: 'meteostat.p.rapidapi.com',
      fetchJson: (url) async {
        return {
          'data': [
            {
              'date': '2026-03-09 00:00:00',
              'tavg': 11.8,
              'tmin': 6.6,
              'tmax': 17.0,
              'prcp': 7.9,
              'wspd': 9.3,
              'wpgt': 31.5,
              'pres': 1019.8,
              'tsun': 240,
            },
          ],
        };
      },
    );

    final snapshot = await client.fetchSnapshot(
      spot: SpotItem(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        createdAt: DateTime(2026, 3, 8),
      ),
    );

    expect(snapshot.days, hasLength(1));
    expect(snapshot.days.first.tempAvgC, 11.8);
    expect(snapshot.days.first.tempMinC, 6.6);
    expect(snapshot.days.first.tempMaxC, 17.0);
    expect(snapshot.days.first.precipitationMm, 7.9);
    expect(snapshot.days.first.windMeanKnots, closeTo(5.0, 0.1));
    expect(snapshot.days.first.gustKnots, closeTo(17.0, 0.1));
    expect(snapshot.days.first.pressureHpa, 1019.8);
    expect(snapshot.days.first.sunshineMinutes, 240);
  });
}
