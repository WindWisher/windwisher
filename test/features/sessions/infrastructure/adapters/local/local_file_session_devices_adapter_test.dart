import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/local_file_session_devices_adapter.dart';

void main() {
  test('persists linked devices and selected device id across instances', () {
    const fileName = 'sessions_devices_test_v1.json';
    final file = File(AppStoragePaths.resolve(fileName));
    if (file.existsSync()) {
      file.deleteSync();
    }

    final adapter = LocalFileSessionDevicesAdapter(fileName: fileName);
    adapter.saveLinkedDevice(
      const LinkedDevice(
        id: 'custom-1',
        name: 'Mi wearable',
        kind: 'Smartwatch',
        status: 'Listo',
        lastSync: 'hace 1 min',
      ),
    );
    adapter.saveSelectedDeviceId('custom-1');

    final reloaded = LocalFileSessionDevicesAdapter(fileName: fileName);
    final devices = reloaded.getLinkedDevices();
    expect(devices.any((item) => item.id == 'custom-1'), isTrue);
    expect(reloaded.getSelectedDeviceId(), 'custom-1');

    reloaded.deleteLinkedDevice('custom-1');
    final afterDelete = LocalFileSessionDevicesAdapter(fileName: fileName);
    expect(
      afterDelete.getLinkedDevices().any((item) => item.id == 'custom-1'),
      isFalse,
    );
    expect(afterDelete.getSelectedDeviceId(), isNull);

    if (file.existsSync()) {
      file.deleteSync();
    }
  });
}
