import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/ble/ble_session_device_discovery_adapter.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class StartSessionDeviceDetectionLogic {
  const StartSessionDeviceDetectionLogic._();

  static const MethodChannel _bluetoothDevicesChannel = MethodChannel(
    'windwisher/bluetooth_devices',
  );

  static Future<SessionExternalDeviceDiscoveryAvailability>
  externalDeviceDiscoveryAvailability() async {
    try {
      final adapter = BleSessionDeviceDiscoveryAdapter();
      final status = await adapter.currentStatus();
      return switch (status) {
        BleStatus.ready => SessionExternalDeviceDiscoveryAvailability.ready,
        BleStatus.poweredOff =>
          SessionExternalDeviceDiscoveryAvailability.bluetoothOff,
        BleStatus.unauthorized =>
          SessionExternalDeviceDiscoveryAvailability.unauthorized,
        BleStatus.unsupported =>
          SessionExternalDeviceDiscoveryAvailability.unsupported,
        BleStatus.locationServicesDisabled =>
          SessionExternalDeviceDiscoveryAvailability.locationServicesDisabled,
        BleStatus.unknown => SessionExternalDeviceDiscoveryAvailability.unknown,
      };
    } catch (_) {
      return SessionExternalDeviceDiscoveryAvailability.unknown;
    }
  }

  static Future<List<SessionDetectedCompatibleDeviceData>>
  detectExternalSessionDevices() async {
    final devicesById = <String, SessionDetectedCompatibleDeviceData>{};

    for (final device in await _androidBondedExternalSessionDevices()) {
      devicesById[device.id] = device;
    }

    try {
      final adapter = BleSessionDeviceDiscoveryAdapter();
      final scannedDevices = await adapter.scanSupportedDevices();
      for (final device in scannedDevices) {
        devicesById.putIfAbsent(device.id, () => device);
      }
    } catch (_) {
      // Keep already bonded devices even if active BLE scanning fails.
    }

    return devicesById.values.toList(growable: false);
  }

  static Future<List<SessionDetectedCompatibleDeviceData>>
  _androidBondedExternalSessionDevices() async {
    if (kIsWeb || !Platform.isAndroid) {
      return const <SessionDetectedCompatibleDeviceData>[];
    }

    try {
      final rawDevices = await _bluetoothDevicesChannel
          .invokeMethod<List<dynamic>>('bondedDevices');
      if (rawDevices == null || rawDevices.isEmpty) {
        return const <SessionDetectedCompatibleDeviceData>[];
      }

      return rawDevices
          .whereType<Map<dynamic, dynamic>>()
          .map(_mapAndroidBondedDevice)
          .whereType<SessionDetectedCompatibleDeviceData>()
          .toList(growable: false);
    } catch (_) {
      return const <SessionDetectedCompatibleDeviceData>[];
    }
  }

  static SessionDetectedCompatibleDeviceData? _mapAndroidBondedDevice(
    Map<dynamic, dynamic> rawDevice,
  ) {
    final id = '${rawDevice['id'] ?? ''}'.trim();
    if (id.isEmpty) {
      return null;
    }

    final name = '${rawDevice['name'] ?? ''}'.trim();
    final type = '${rawDevice['type'] ?? 'unknown'}'.trim();
    final bondState = '${rawDevice['bondState'] ?? 'unknown'}'.trim();
    final normalizedName = name.toLowerCase();
    final family = _inferExternalDeviceFamily(normalizedName, type);
    final placement = _placementForExternalDeviceFamily(family);
    final displayName = name.isEmpty ? _bluetoothFallbackDeviceLabel(id) : name;
    final kind = switch (family) {
      'watch' => 'Smartwatch',
      'board_sensor' => 'Sensor de tabla',
      _ => 'Bluetooth vinculado',
    };

    return SessionDetectedCompatibleDeviceData(
      id: id,
      defaultName: displayName,
      kind: kind,
      status: 'Vinculado al telefono',
      sensorSummary: 'Sensores aun no detectados',
      family: family,
      placement: placement,
      connectionState: 'Vinculado al telefono',
      manufacturer: 'Desconocido',
      model: displayName,
      firmwareVersion: null,
      physicalSensorKeys: const <String>[],
      isSessionEligible: false,
      canConnect: true,
      diagnosticSummary:
          'Bluetooth vinculado: type=$type, bondState=$bondState',
    );
  }

  static String _inferExternalDeviceFamily(String normalizedName, String type) {
    if (normalizedName.startsWith('woo')) {
      return 'board_sensor';
    }
    if (normalizedName.contains('watch') ||
        normalizedName.contains('reloj') ||
        normalizedName.contains('garmin') ||
        normalizedName.contains('wear')) {
      return 'watch';
    }
    return 'unknown';
  }

  static String _placementForExternalDeviceFamily(String family) {
    return switch (family) {
      'watch' => 'wrist',
      'board_sensor' => 'board',
      _ => 'unknown',
    };
  }

  static String _bluetoothFallbackDeviceLabel(String id) {
    final compactId = id.replaceAll(':', '').replaceAll('-', '');
    final suffix = compactId.length <= 8
        ? compactId
        : compactId.substring(compactId.length - 8);
    return 'Bluetooth $suffix';
  }

  static Future<SessionDetectedCompatibleDeviceData> probeExternalSessionDevice(
    SessionDetectedCompatibleDeviceData device,
  ) async {
    try {
      final adapter = BleSessionDeviceDiscoveryAdapter();
      return await adapter.probeDeviceCapabilities(device);
    } catch (_) {
      return device;
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
        final label = [
          resolvedBrand,
          model,
        ].where((value) => value.isNotEmpty).join(' ');
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
        final label = [
          info.name.trim(),
          info.model.trim(),
        ].where((value) => value.isNotEmpty).join(' · ');
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
        final label = [
          info.model.trim(),
          info.osRelease.trim(),
        ].where((value) => value.isNotEmpty).join(' · ');
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
