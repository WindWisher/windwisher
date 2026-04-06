import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/ble/ble_session_device_discovery_adapter.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class StartSessionDeviceDetectionLogic {
  const StartSessionDeviceDetectionLogic._();

  static Future<List<SessionDetectedCompatibleDeviceData>>
  detectExternalSessionDevices() async {
    try {
      final adapter = BleSessionDeviceDiscoveryAdapter();
      return await adapter.scanSupportedDevices();
    } catch (_) {
      return const <SessionDetectedCompatibleDeviceData>[];
    }
  }

  static List<String> physicalSensorsForCurrentDeviceKind(String kind) {
    switch (kind) {
      case 'Android':
      case 'Dispositivo Android':
        return <String>['gps', 'accelerometer', 'gyroscope', 'magnetometer'];
      case 'iPhone':
        return <String>['gps', 'accelerometer', 'gyroscope', 'magnetometer'];
      case 'Web':
        return <String>['gps'];
      case 'macOS':
      case 'Windows':
      case 'Linux':
        return <String>['gps'];
      default:
        return const <String>[];
    }
  }

  static Future<LinkedDevice> detectCurrentDevice({
    required String phoneDeviceId,
    required LinkedDevice fallbackDevice,
  }) async {
    try {
      final plugin = DeviceInfoPlugin();
      if (kIsWeb) {
        final info = await plugin.webBrowserInfo;
        final browserName = info.browserName.name;
        const kind = 'Web';
        return LinkedDevice(
          id: phoneDeviceId,
          name: 'Este navegador',
          kind: '$kind · $browserName',
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
          family: 'phone',
          placement: 'local',
          physicalSensorKeys: physicalSensorsForCurrentDeviceKind(kind),
          isSessionEligible: true,
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
        const kind = 'Android';
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? fallbackDevice.name : label,
          kind: kind,
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
          family: 'phone',
          placement: 'local',
          physicalSensorKeys: physicalSensorsForCurrentDeviceKind(kind),
          isSessionEligible: true,
        );
      }

      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        final label = [info.name.trim(), info.model.trim()]
            .where((value) => value.isNotEmpty)
            .join(' · ');
        const kind = 'iPhone';
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? fallbackDevice.name : label,
          kind: kind,
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
          family: 'phone',
          placement: 'local',
          physicalSensorKeys: physicalSensorsForCurrentDeviceKind(kind),
          isSessionEligible: true,
        );
      }

      if (Platform.isMacOS) {
        final info = await plugin.macOsInfo;
        final label = [info.model.trim(), info.osRelease.trim()]
            .where((value) => value.isNotEmpty)
            .join(' · ');
        const kind = 'macOS';
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? 'Este Mac' : label,
          kind: kind,
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
          family: 'phone',
          placement: 'local',
          physicalSensorKeys: physicalSensorsForCurrentDeviceKind(kind),
          isSessionEligible: true,
        );
      }

      if (Platform.isWindows) {
        final info = await plugin.windowsInfo;
        final label = info.computerName.trim();
        const kind = 'Windows';
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? 'Este PC' : label,
          kind: kind,
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
          family: 'phone',
          placement: 'local',
          physicalSensorKeys: physicalSensorsForCurrentDeviceKind(kind),
          isSessionEligible: true,
        );
      }

      if (Platform.isLinux) {
        final info = await plugin.linuxInfo;
        final label = info.prettyName.trim();
        const kind = 'Linux';
        return LinkedDevice(
          id: phoneDeviceId,
          name: label.isEmpty ? 'Este equipo' : label,
          kind: kind,
          status: 'Listo',
          lastSync: 'Disponible en este dispositivo',
          family: 'phone',
          placement: 'local',
          physicalSensorKeys: physicalSensorsForCurrentDeviceKind(kind),
          isSessionEligible: true,
        );
      }
    } catch (_) {}

    return fallbackDevice;
  }
}
