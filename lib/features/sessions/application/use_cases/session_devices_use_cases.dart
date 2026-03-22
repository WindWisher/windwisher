import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_devices_port.dart';

class GetLinkedDevicesUseCase {
  const GetLinkedDevicesUseCase(this._port);

  final SessionDevicesPort _port;

  List<LinkedDevice> call() {
    return _port.getLinkedDevices();
  }
}

class SaveLinkedDeviceUseCase {
  const SaveLinkedDeviceUseCase(this._port);

  final SessionDevicesPort _port;

  void call(LinkedDevice device) {
    _port.saveLinkedDevice(device);
  }
}

class DeleteLinkedDeviceUseCase {
  const DeleteLinkedDeviceUseCase(this._port);

  final SessionDevicesPort _port;

  void call(String id) {
    _port.deleteLinkedDevice(id);
  }
}

class GetSelectedDeviceIdUseCase {
  const GetSelectedDeviceIdUseCase(this._port);

  final SessionDevicesPort _port;

  String? call() {
    return _port.getSelectedDeviceId();
  }
}

class SaveSelectedDeviceIdUseCase {
  const SaveSelectedDeviceIdUseCase(this._port);

  final SessionDevicesPort _port;

  void call(String? id) {
    _port.saveSelectedDeviceId(id);
  }
}
