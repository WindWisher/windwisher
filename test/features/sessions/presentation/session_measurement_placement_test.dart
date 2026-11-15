import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

void main() {
  test('SurfR respects chest, wrist and board placement', () {
    for (final placement in ['chest', 'wrist']) {
      expect(
        SessionInsightData.jumpDetectionModeForDevice(
          deviceKind: 'SurfR',
          placement: placement,
        ),
        'body_imu',
      );
    }
    expect(
      SessionInsightData.jumpDetectionModeForDevice(
        deviceKind: 'SurfR',
        placement: 'board',
      ),
      'board_imu',
    );
  });

  test('Provider name alone does not imply board mounting', () {
    expect(
      SessionInsightData.jumpDetectionModeForDevice(deviceKind: 'SurfR'),
      'body_imu',
    );
    expect(
      SessionInsightData.jumpDetectionModeForDevice(deviceKind: 'WOO'),
      'board_imu',
    );
  });
}
