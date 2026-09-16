import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/sessions/presentation/mappers/start_session_mapper.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

void main() {
  group('device session transfer presentation', () {
    test('offers download only after sessions are detected', () {
      final data = StartSessionPresentationMapper.buildDeviceTransferData(
        phase: SessionDeviceTransferPhase.sessionsAvailable,
        sessionCount: 2,
      );

      expect(data.message, 'Hay 2 sesiones nuevas en el dispositivo.');
      expect(data.actionLabel, 'Descargar sesiones');
      expect(data.isBusy, isFalse);
    });

    test('offers upload only after a session is downloaded', () {
      final data = StartSessionPresentationMapper.buildDeviceTransferData(
        phase: SessionDeviceTransferPhase.readyToUpload,
        sessionCount: 1,
      );

      expect(data.message, 'La sesion esta descargada y lista para revisar.');
      expect(data.actionLabel, 'Subir sesion');
      expect(data.isBusy, isFalse);
    });

    test('does not expose actions for unsupported devices', () {
      final data = StartSessionPresentationMapper.buildDeviceTransferData(
        phase: SessionDeviceTransferPhase.unavailable,
      );

      expect(data.actionLabel, isNull);
      expect(data.message, contains('todavia no esta disponible'));
    });
  });
}
