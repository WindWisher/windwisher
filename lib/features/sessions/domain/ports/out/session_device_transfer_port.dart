import 'package:windwisher/features/sessions/domain/entities/device_session_transfer.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';

abstract interface class SessionDeviceTransferPort {
  Future<DeviceSessionInventory> inspect(LinkedDevice device);

  Future<List<DownloadedDeviceSession>> download({
    required LinkedDevice device,
    required List<DeviceSessionReference> sessions,
  });
}
