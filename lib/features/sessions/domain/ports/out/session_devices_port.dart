import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';

abstract class SessionDevicesPort {
  List<LinkedDevice> getLinkedDevices();

  void saveLinkedDevice(LinkedDevice device);

  void deleteLinkedDevice(String id);

  String? getSelectedDeviceId();

  void saveSelectedDeviceId(String? id);
}
