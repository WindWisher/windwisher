import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_devices_port.dart';

class InMemorySessionDevicesAdapter implements SessionDevicesPort {
  static const String phoneDeviceId = 'phone-1';

  final List<LinkedDevice> _devices = [
    const LinkedDevice(
      id: 'woo-1',
      name: 'Woo Sports 3',
      kind: 'Woo Sports',
      status: 'Conectado',
      lastSync: 'hace 8 min',
    ),
    const LinkedDevice(
      id: 'watch-1',
      name: 'Apple Watch Ultra',
      kind: 'Apple Watch',
      status: 'Listo',
      lastSync: 'hace 22 min',
    ),
    const LinkedDevice(
      id: phoneDeviceId,
      name: 'Telefono del usuario',
      kind: 'Dispositivo Android',
      status: 'Listo',
      lastSync: 'hace 2 min',
    ),
  ];
  String? _selectedDeviceId = 'woo-1';

  @override
  List<LinkedDevice> getLinkedDevices() {
    return List<LinkedDevice>.unmodifiable(_devices);
  }

  @override
  void saveLinkedDevice(LinkedDevice device) {
    final index = _devices.indexWhere((item) => item.id == device.id);
    if (index >= 0) {
      _devices[index] = device;
      return;
    }
    _devices.insert(0, device);
  }

  @override
  void deleteLinkedDevice(String id) {
    if (id == phoneDeviceId) {
      return;
    }
    _devices.removeWhere((item) => item.id == id);
    if (_selectedDeviceId == id) {
      _selectedDeviceId = null;
    }
  }

  @override
  String? getSelectedDeviceId() {
    return _selectedDeviceId;
  }

  @override
  void saveSelectedDeviceId(String? id) {
    _selectedDeviceId = id;
  }
}
