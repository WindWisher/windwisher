import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/services/meteosource_current_day_client.dart';

void main() {
  test('maps current and day Meteosource payloads', () async {
    final client = MeteosourceCurrentDayClient(
      apiKey: 'test-key',
      fetchJson: (url) async {
        return {
          'current': {
            'summary': 'Mostly cloudy',
            'temperature': 14.5,
            'wind': {'speed': 1.5, 'angle': 91, 'dir': 'E'},
            'precipitation': {'total': 0.0, 'type': 'none'},
            'cloud_cover': 79,
          },
          'daily': {
            'data': [
              {
                'day': '2026-03-08',
                'summary': 'Mostly cloudy, more clouds in the afternoon.',
                'all_day': {
                  'temperature_min': 8.2,
                  'temperature_max': 14.5,
                  'wind': {'speed': 1.2, 'angle': 337, 'dir': 'NNW'},
                  'precipitation': {'total': 0.4, 'type': 'rain'},
                },
              },
            ],
          },
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

    expect(snapshot.current, isNotNull);
    expect(snapshot.current!.temperatureC, 14.5);
    expect(snapshot.current!.windKnots, closeTo(2.9, 0.1));
    expect(snapshot.current!.windDeg, 91);
    expect(snapshot.current!.cloudCoverPct, 79);
    expect(snapshot.days, hasLength(1));
    expect(snapshot.days.first.tempMinC, 8.2);
    expect(snapshot.days.first.tempMaxC, 14.5);
    expect(snapshot.days.first.windMeanKnots, closeTo(2.3, 0.1));
    expect(snapshot.days.first.precipitationMm, 0.4);
  });
}
