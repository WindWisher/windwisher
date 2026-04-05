import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';

class StartSessionDeviceDetectionLogic {
  const StartSessionDeviceDetectionLogic._();

  static Future<LinkedDevice> detectCurrentDevice({
    required String phoneDeviceId,
    required LinkedDevice fallbackDevice,
  }) async {
    try {
      final plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        final info = await plugin.webBrowserInfo;
        final browserName = info.browserName.name;
        return LinkedDevice(
          id: phoneDeviceId,
          name: 'Este navegador',
          kind: 'Web · $browserName',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        final brand = info.brand.trim();
        final model = info.model.trim();
        final manufacturer = info.manufacturer.trim();
        final resolvedBrand = brand.isNotEmpty ? brand : manufacturer;
        final label = [resolvedBrand, model]
            .where((value) => value.isNotEmpty)
            .join(' ');
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? fallbackDevice.name : label,
          kind: 'Android',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        final label = [info.name.trim(), info.model.trim()]
            .where((value) => value.isNotEmpty)
            .join(' · ');
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? fallbackDevice.name : label,
          kind: 'iPhone',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isMacOS) {
        final info = await plugin.macOsInfo;
        final label = [info.model.trim(), info.osRelease.trim()]
            .where((value) => value.isNotEmpty)
            .join(' · ');
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? 'Este Mac' : label,
          kind: 'macOS',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isWindows) {
        final info = await plugin.windowsInfo;
        final label = info.computerName.trim();
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? 'Este PC' : label,
          kind: 'Windows',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }

      if (Platform.isLinux) {
        final info = await plugin.linuxInfo;
        final label = info.prettyName.trim();
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? 'Este equipo' : label,
          kind: 'Linux',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
        );
      }
    } catch (_) {}

    return fallbackDevice;
  }
}
