import 'package:windwisher/features/sessions/domain/entities/device_session_transfer.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_device_transfer_port.dart';

class UnsupportedSessionDeviceTransferAdapter
    implements SessionDeviceTransferPort {
  const UnsupportedSessionDeviceTransferAdapter();

  @override
  Future<DeviceSessionInventory> inspect(LinkedDevice device) async {
    return const DeviceSessionInventory.unsupported(
      reason:
          'Este dispositivo no dispone todavia de un transporte de sesiones compatible.',
    );
  }

  @override
  Future<List<DownloadedDeviceSession>> download({
    required LinkedDevice device,
    required List<DeviceSessionReference> sessions,
  }) async {
    throw UnsupportedError(
      'No existe un transporte de sesiones para ${device.family}.',
    );
  }
}
