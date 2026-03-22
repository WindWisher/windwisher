import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/domain/entities/spot_item.dart';
import 'package:windwisher/features/spots/infrastructure/services/meteoblue_current_day_client.dart';

void main() {
  test('maps current, sea and day Meteoblue payloads', () async {
    final client = MeteoblueCurrentDayClient(
      apiKey: 'test-key',
      fetchJson: (url) async {
        return {
          'data_current': {
            'time': '2026-03-07 10:15',
            'temperature': 18.4,
            'windspeed': 15.2,
            'isobserveddata': 1,
          },
          'data_xmin': {
            'time': ['2026-03-07 10:00', '2026-03-07 10:15'],
            'winddirection': [110, 115],
            'sealevelpressure': [1015, 1016],
            'totalcloudcover': [30, 34],
          },
          'data_1h': {
            'time': ['2026-03-07 10:00'],
            'seasurfacetemperature': [17.8],
            'surfwave_height': [0.9],
            'significantwaveheight': [1.1],
            'swell_significantheight': [0.8],
            'swell_meanperiod': [6.4],
            'swell_meandirection': [96],
            'windwave_height': [0.2],
            'mean_waveperiod': [5.7],
            'windwave_meanperiod': [4.2],
            'windwave_direction': [122],
            'douglas_seastate': [3],
            'mean_wavedirection': [98],
          },
          'data_day': {
            'time': ['2026-03-07'],
            'temperature_min': [14.0],
            'temperature_max': [21.0],
            'windspeed_mean': [12.0],
            'precipitation': [0.4],
            'predictability': [82],
          },
        };
      },
    );

    final result = await client.fetchSnapshot(
      spot: SpotItem(
        name: 'Oliva Puerto',
        area: 'Valencia',
        isCustom: false,
        createdAt: DateTime(2026, 3, 8),
      ),
    );

    expect(result.current, isNotNull);
    expect(result.current!.windDeg, 115);
    expect(result.current!.pressureHpa, 1016);
    expect(result.current!.cloudCoverPct, 34);
    expect(result.sea, hasLength(1));
    expect(result.sea.single.surfaceWaterTempC, 17.8);
    expect(result.sea.single.surfWaveHeightM, 0.9);
    expect(result.sea.single.swellWaveHeightM, 0.8);
    expect(result.sea.single.swellMeanPeriodS, 6.4);
    expect(result.sea.single.swellMeanDirectionDeg, 96);
    expect(result.sea.single.windWaveHeightM, 0.2);
    expect(result.sea.single.meanWavePeriodS, 5.7);
    expect(result.sea.single.windWaveDirectionDeg, 122);
    expect(result.sea.single.douglasSeaState, 3);
    expect(result.sea.single.meanWaveDirectionDeg, 98);
    expect(result.days.single.predictabilityPct, 82);
  });
}
