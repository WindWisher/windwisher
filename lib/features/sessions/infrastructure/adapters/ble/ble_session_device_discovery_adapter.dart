import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class BleSessionDeviceDiscoveryAdapter {
  BleSessionDeviceDiscoveryAdapter({FlutterReactiveBle? ble})
    : _ble = ble ?? FlutterReactiveBle();

  final FlutterReactiveBle _ble;

  Future<List<SessionDetectedCompatibleDeviceData>> scanSupportedDevices({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final devices = <String, SessionDetectedCompatibleDeviceData>{};
    final completer = Completer<void>();

    late final StreamSubscription<DiscoveredDevice> subscription;
    subscription = _ble.scanForDevices(withServices: const <Uuid>[]).listen(
      (device) {
        final candidate = _mapDetectedDevice(device);
        if (candidate == null) {
          return;
        }
        devices[candidate.id] = candidate;
      },
      onError: (_) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    Future<void>.delayed(timeout).then((_) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    await completer.future;
    await subscription.cancel();

    final result = devices.values.toList(growable: false);
    result.sort((a, b) => a.defaultName.compareTo(b.defaultName));
    return result;
  }

  SessionDetectedCompatibleDeviceData? _mapDetectedDevice(DiscoveredDevice device) {
    final name = device.name.trim();
    final id = device.id;
    final normalizedName = name.toLowerCase();
    final family = _inferFamily(normalizedName);
    final placement = _placementForFamily(family);
    final physicalSensorKeys = _physicalSensorsForDetectedDevice(
      family: family,
      normalizedName: normalizedName,
    );
    final manufacturer = family == 'board_sensor' ? 'WOO Sports' : 'Desconocido';
    final model = name.isEmpty ? 'Dispositivo BLE' : name;

    return SessionDetectedCompatibleDeviceData(
      id: id,
      defaultName: name.isEmpty ? 'Dispositivo BLE' : name,
      kind: _kindForFamily(family, model),
      status: 'Detectado',
      sensorSummary: _sensorSummary(physicalSensorKeys),
      family: family,
      placement: placement,
      connectionState: 'Detectado',
      manufacturer: manufacturer,
      model: model,
      firmwareVersion: null,
      physicalSensorKeys: physicalSensorKeys,
      isSessionEligible: LinkedDevice.isSessionEligibleForDetectedDevice(
        family: family,
        physicalSensorKeys: physicalSensorKeys,
      ),
    );
  }

  String _inferFamily(String normalizedName) {
    if (normalizedName.startsWith('woo')) {
      return 'board_sensor';
    }
    if (normalizedName.contains('watch') ||
        normalizedName.contains('garmin') ||
        normalizedName.contains('wear')) {
      return 'watch';
    }
    return 'unknown';
  }

  String _placementForFamily(String family) {
    switch (family) {
      case 'watch':
        return 'wrist';
      case 'board_sensor':
        return 'board';
      default:
        return 'unknown';
    }
  }

  List<String> _physicalSensorsForDetectedDevice({
    required String family,
    required String normalizedName,
  }) {
    if (family == 'board_sensor' && normalizedName.startsWith('woo')) {
      return const <String>['barometer', 'accelerometer'];
    }
    return const <String>[];
  }

  String _kindForFamily(String family, String model) {
    switch (family) {
      case 'watch':
        return 'Watch';
      case 'board_sensor':
        return 'WOO';
      default:
        return model;
    }
  }

  String _sensorSummary(List<String> physicalSensorKeys) {
    if (physicalSensorKeys.isEmpty) {
      return 'Sensores físicos aún no identificados';
    }
    return physicalSensorKeys.join(', ');
  }
}
