import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class BleSessionDeviceDiscoveryAdapter {
  BleSessionDeviceDiscoveryAdapter({FlutterReactiveBle? ble})
    : _ble = ble ?? FlutterReactiveBle();

  static final Uuid _fitCloudServiceId = Uuid.parse(
    '000001ff-3c17-d293-8e48-14fe2e4da212',
  );
  static final Uuid _fitCloudWriteCharacteristicId = Uuid.parse(
    '0000ff02-0000-1000-8000-00805f9b34fb',
  );
  static final Uuid _fitCloudNotifyCharacteristicId = Uuid.parse(
    '0000ff03-0000-1000-8000-00805f9b34fb',
  );
  static const List<int> _fitCloudHeartRateStartFrame = <int>[
    0xab,
    0x00,
    0x00,
    0x09,
    0x02,
    0x4f,
    0x00,
    0x01,
    0x05,
    0x00,
    0x23,
    0x00,
    0x04,
    0x00,
    0x01,
    0x05,
    0x01,
  ];
  static const List<int> _fitCloudHeartRateStopFrame = <int>[
    0xab,
    0x00,
    0x00,
    0x09,
    0x02,
    0xdf,
    0x00,
    0x02,
    0x05,
    0x00,
    0x23,
    0x00,
    0x04,
    0x00,
    0x00,
    0x05,
    0x00,
  ];

  final FlutterReactiveBle _ble;

  Future<BleStatus> currentStatus({
    Duration timeout = const Duration(seconds: 2),
  }) async {
    var status = _ble.status;
    if (status == BleStatus.ready ||
        status == BleStatus.poweredOff ||
        status == BleStatus.unsupported) {
      return status;
    }

    try {
      await for (final next in _ble.statusStream.timeout(timeout)) {
        status = next;
        if (next == BleStatus.ready ||
            next == BleStatus.poweredOff ||
            next == BleStatus.unsupported) {
          return next;
        }
      }
    } catch (_) {
      final latest = _ble.status;
      if (latest != BleStatus.unknown) {
        return latest;
      }
    }

    return status;
  }

  Future<List<SessionDetectedCompatibleDeviceData>> scanSupportedDevices({
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final devices = <String, SessionDetectedCompatibleDeviceData>{};
    final completer = Completer<void>();

    late final StreamSubscription<DiscoveredDevice> subscription;
    subscription = _ble
        .scanForDevices(withServices: const <Uuid>[])
        .listen(
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

  Future<SessionDetectedCompatibleDeviceData> probeDeviceCapabilities(
    SessionDetectedCompatibleDeviceData device, {
    Duration connectionTimeout = const Duration(seconds: 6),
  }) async {
    if (!device.canConnect) {
      return _copyDeviceWithProbeResult(
        device: device,
        family: device.family,
        placement: device.placement,
        physicalSensorKeys: device.physicalSensorKeys,
        sensorSummary: 'El anuncio BLE no acepta conexión GATT',
        diagnosticSummary:
            '${device.diagnosticSummary ?? 'Advertisement sin detalle'}; probe omitido: connectable=unavailable',
      );
    }

    StreamSubscription<ConnectionStateUpdate>? subscription;
    try {
      final connected = Completer<void>();
      subscription = _ble
          .connectToDevice(id: device.id, connectionTimeout: connectionTimeout)
          .listen(
            (update) {
              if (update.connectionState == DeviceConnectionState.connected &&
                  !connected.isCompleted) {
                connected.complete();
              }
            },
            onError: (Object error) {
              if (!connected.isCompleted) {
                connected.completeError(error);
              }
            },
          );

      await connected.future.timeout(connectionTimeout);

      // The newer Service API hides characteristic ids, which we need to infer
      // standard physical sensors from GATT characteristics.
      // ignore: deprecated_member_use
      final services = await _ble.discoverServices(device.id);
      final detectedSensors = _physicalSensorsForDiscoveredServices(services);
      final proprietaryProbe = await _probeProprietaryCharacteristicValues(
        deviceId: device.id,
        services: services,
      );
      final diagnosticSummary =
          '${_servicesSummary(services)}\n${proprietaryProbe.diagnosticSummary}';
      debugPrint('WindWisher BLE ${device.id}: $diagnosticSummary');
      final physicalSensorKeys = <String>{
        ...device.physicalSensorKeys,
        ...detectedSensors,
        ...proprietaryProbe.physicalSensorKeys,
      }.toList(growable: false)..sort();
      final family = _resolvedFamilyAfterProbe(
        currentFamily: device.family,
        physicalSensorKeys: physicalSensorKeys,
      );

      return _copyDeviceWithProbeResult(
        device: device,
        family: family,
        placement: _placementForFamily(family),
        physicalSensorKeys: physicalSensorKeys,
        diagnosticSummary: diagnosticSummary,
      );
    } catch (error) {
      debugPrint('WindWisher BLE ${device.id}: probe failed $error');
      return _copyDeviceWithProbeResult(
        device: device,
        family: device.family,
        placement: device.placement,
        physicalSensorKeys: device.physicalSensorKeys,
        sensorSummary: 'No se han podido comprobar sensores compatibles',
        diagnosticSummary: 'Probe BLE fallido: ${error.runtimeType}',
      );
    } finally {
      await subscription?.cancel();
    }
  }

  SessionDetectedCompatibleDeviceData? _mapDetectedDevice(
    DiscoveredDevice device,
  ) {
    final name = device.name.trim();
    final id = device.id;
    final normalizedName = name.toLowerCase();
    final manufacturer = _manufacturerForAdvertisement(device);
    final family = _inferFamily(normalizedName: normalizedName);
    final placement = _placementForFamily(family);
    final physicalSensorKeys = _physicalSensorsForDetectedDevice(
      family: family,
      normalizedName: normalizedName,
    );
    final exposedName = name.isEmpty ? _fallbackDeviceLabel(id) : name;
    final model = name.isEmpty ? id : name;

    return SessionDetectedCompatibleDeviceData(
      id: id,
      defaultName: exposedName,
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
      canConnect: device.connectable != Connectable.unavailable,
      diagnosticSummary: _advertisementSummary(device),
    );
  }

  String _inferFamily({required String normalizedName}) {
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

  String _manufacturerForAdvertisement(DiscoveredDevice device) {
    if (device.name.trim().toLowerCase().startsWith('woo')) {
      return 'WOO Sports';
    }
    return 'Desconocido';
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

  List<String> _physicalSensorsForDiscoveredServices(
    List<DiscoveredService> services,
  ) {
    final sensors = <String>{};
    for (final service in services) {
      final serviceId = service.serviceId.expanded.toString().toLowerCase();
      final characteristicIds = service.characteristics
          .map(
            (item) => item.characteristicId.expanded.toString().toLowerCase(),
          )
          .toSet();

      if (serviceId == _standardBleService('180d')) {
        sensors.add('heart_rate');
      }
      if (serviceId == _standardBleService('1819')) {
        sensors.add('gps');
      }
      if (serviceId == _standardBleService('181a')) {
        if (characteristicIds.contains(_standardBleService('2a6d')) ||
            characteristicIds.contains(_standardBleService('2a6c')) ||
            characteristicIds.contains(_standardBleService('2aa3'))) {
          sensors.add('barometer');
        }
        if (characteristicIds.contains(_standardBleService('2a6e'))) {
          sensors.add('temperature');
        }
        if (characteristicIds.contains(_standardBleService('2a6f'))) {
          sensors.add('humidity');
        }
      }
    }
    return sensors.toList(growable: false)..sort();
  }

  String _standardBleService(String shortUuid) {
    return Uuid.parse(shortUuid).expanded.toString().toLowerCase();
  }

  String _advertisementSummary(DiscoveredDevice device) {
    final services = device.serviceUuids
        .map((uuid) => uuid.expanded.toString().toLowerCase())
        .toList(growable: false);
    final manufacturerHex = _hexBytes(device.manufacturerData);
    final companyId = _manufacturerCompanyId(device.manufacturerData);
    final summary =
        'Advertisement: services=${services.isEmpty ? 'none' : services.join(', ')}, manufacturerBytes=${device.manufacturerData.length}, companyId=${companyId ?? 'none'}, manufacturerData=${manufacturerHex.isEmpty ? 'none' : manufacturerHex}, rssi=${device.rssi}, connectable=${device.connectable.name}';
    debugPrint('WindWisher BLE ${device.id}: $summary');
    return summary;
  }

  String? _manufacturerCompanyId(List<int> bytes) {
    if (bytes.length < 2) {
      return null;
    }
    final value = bytes[0] | (bytes[1] << 8);
    return '0x${value.toRadixString(16).padLeft(4, '0')}';
  }

  String _hexBytes(List<int> bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join(' ');
  }

  String _servicesSummary(List<DiscoveredService> services) {
    if (services.isEmpty) {
      return 'GATT: conectado, sin servicios visibles';
    }
    final sensorServices = services
        .where((service) => _isSensorService(service.serviceId))
        .length;
    final buffer = StringBuffer(
      'GATT completo: services=${services.length}, sensorServices=$sensorServices',
    );
    for (final service in services) {
      final serviceId = service.serviceId.expanded.toString().toLowerCase();
      buffer.write('\nservice $serviceId');
      if (service.characteristics.isEmpty) {
        buffer.write('\n  chars none');
        continue;
      }
      for (final characteristic in service.characteristics) {
        final characteristicId = characteristic.characteristicId.expanded
            .toString()
            .toLowerCase();
        final properties = <String>[
          if (characteristic.isReadable) 'read',
          if (characteristic.isWritableWithResponse) 'write',
          if (characteristic.isWritableWithoutResponse) 'writeNoRsp',
          if (characteristic.isNotifiable) 'notify',
          if (characteristic.isIndicatable) 'indicate',
        ];
        buffer.write(
          '\n  char $characteristicId [${properties.isEmpty ? 'no-props' : properties.join(',')}]',
        );
      }
    }
    return buffer.toString();
  }

  Future<_ProprietaryProbeResult> _probeProprietaryCharacteristicValues({
    required String deviceId,
    required List<DiscoveredService> services,
  }) async {
    final lines = <String>[];
    final physicalSensorKeys = <String>{};
    final notifyProbes = <Future<String>>[];
    var reads = 0;
    var notifies = 0;

    for (final service in services) {
      if (_isGenericOrHidService(service.serviceId)) {
        continue;
      }

      final serviceId = service.serviceId.expanded.toString().toLowerCase();
      for (final characteristic in service.characteristics) {
        final characteristicId = characteristic.characteristicId.expanded
            .toString()
            .toLowerCase();
        final qualified = QualifiedCharacteristic(
          serviceId: characteristic.serviceId,
          characteristicId: characteristic.characteristicId,
          deviceId: deviceId,
        );

        if (characteristic.isReadable && reads < 16) {
          reads += 1;
          try {
            final value = await _ble
                .readCharacteristic(qualified)
                .timeout(const Duration(milliseconds: 900));
            final line =
                'read $serviceId/$characteristicId = ${_limitedHexBytes(value)}';
            lines.add(line);
            debugPrint('WindWisher BLE $deviceId: $line');
          } catch (error) {
            final line =
                'read $serviceId/$characteristicId failed ${error.runtimeType}';
            lines.add(line);
            debugPrint('WindWisher BLE $deviceId: $line');
          }
        }

        if ((characteristic.isNotifiable || characteristic.isIndicatable) &&
            notifies < 4) {
          notifies += 1;
          notifyProbes.add(
            _sampleNotification(
              deviceId: deviceId,
              serviceId: serviceId,
              characteristicId: characteristicId,
              qualified: qualified,
            ),
          );
        }
      }
    }

    if (notifyProbes.isNotEmpty) {
      lines.add(
        'notify: escuchando ${notifyProbes.length} canal(es) propietarios durante 12s',
      );
      lines.addAll(await Future.wait(notifyProbes));
    }

    final fitCloudProbe = await _probeFitCloudHeartRateCommand(
      deviceId: deviceId,
      services: services,
    );
    if (fitCloudProbe != null) {
      lines.add(fitCloudProbe.diagnosticSummary);
      physicalSensorKeys.addAll(fitCloudProbe.physicalSensorKeys);
    }

    if (lines.isEmpty) {
      return const _ProprietaryProbeResult(
        diagnosticSummary:
            'Valores propietarios: no hay características propietarias legibles/notificables',
      );
    }
    return _ProprietaryProbeResult(
      diagnosticSummary: 'Valores propietarios:\n${lines.join('\n')}',
      physicalSensorKeys: physicalSensorKeys,
    );
  }

  Future<String> _sampleNotification({
    required String deviceId,
    required String serviceId,
    required String characteristicId,
    required QualifiedCharacteristic qualified,
  }) async {
    try {
      final value = await _ble
          .subscribeToCharacteristic(qualified)
          .first
          .timeout(const Duration(seconds: 12));
      final line =
          'notify $serviceId/$characteristicId = ${_limitedHexBytes(value)}';
      debugPrint('WindWisher BLE $deviceId: $line');
      return line;
    } catch (error) {
      final line =
          'notify $serviceId/$characteristicId failed ${error.runtimeType}';
      debugPrint('WindWisher BLE $deviceId: $line');
      return line;
    }
  }

  Future<_FitCloudHeartRateProbeResult?> _probeFitCloudHeartRateCommand({
    required String deviceId,
    required List<DiscoveredService> services,
  }) async {
    final fitCloudService = services
        .where((service) => service.serviceId == _fitCloudServiceId)
        .firstOrNull;
    if (fitCloudService == null) {
      return null;
    }

    final hasWrite = fitCloudService.characteristics.any(
      (characteristic) =>
          characteristic.characteristicId == _fitCloudWriteCharacteristicId &&
          (characteristic.isWritableWithResponse ||
              characteristic.isWritableWithoutResponse),
    );
    final hasNotify = fitCloudService.characteristics.any(
      (characteristic) =>
          characteristic.characteristicId == _fitCloudNotifyCharacteristicId &&
          (characteristic.isNotifiable || characteristic.isIndicatable),
    );
    if (!hasWrite || !hasNotify) {
      return _FitCloudHeartRateProbeResult(
        diagnosticSummary:
            'FitCloud HR probe: canal incompleto write=$hasWrite notify=$hasNotify',
      );
    }

    final writeCharacteristic = QualifiedCharacteristic(
      serviceId: _fitCloudServiceId,
      characteristicId: _fitCloudWriteCharacteristicId,
      deviceId: deviceId,
    );
    final notifyCharacteristic = QualifiedCharacteristic(
      serviceId: _fitCloudServiceId,
      characteristicId: _fitCloudNotifyCharacteristicId,
      deviceId: deviceId,
    );
    final notifications = <String>[];
    final heartRateSamples = <int>[];
    final subscription = _ble
        .subscribeToCharacteristic(notifyCharacteristic)
        .listen((value) {
          final bpm = _fitCloudHeartRateBpm(value);
          if (bpm != null) {
            heartRateSamples.add(bpm);
          }
          final line = bpm == null
              ? 'FitCloud HR notify = ${_limitedHexBytes(value)}'
              : 'FitCloud HR notify = ${_limitedHexBytes(value)} ($bpm bpm)';
          notifications.add(line);
          debugPrint('WindWisher BLE $deviceId: $line');
        });

    try {
      debugPrint(
        'WindWisher BLE $deviceId: FitCloud HR start ${_limitedHexBytes(_fitCloudHeartRateStartFrame)}',
      );
      await _ble
          .writeCharacteristicWithResponse(
            writeCharacteristic,
            value: _fitCloudHeartRateStartFrame,
          )
          .timeout(const Duration(seconds: 3));
      await Future<void>.delayed(const Duration(seconds: 20));
      if (notifications.isEmpty) {
        return const _FitCloudHeartRateProbeResult(
          diagnosticSummary:
              'FitCloud HR probe: comando enviado, sin notificaciones en 20s',
        );
      }
      final samplesSummary = heartRateSamples.isEmpty
          ? ''
          : '\nFitCloud HR bpm detectados: ${heartRateSamples.join(', ')}';
      return _FitCloudHeartRateProbeResult(
        diagnosticSummary:
            'FitCloud HR probe:\n${notifications.join('\n')}$samplesSummary',
        physicalSensorKeys: heartRateSamples.isEmpty
            ? const <String>{}
            : const <String>{'heart_rate'},
      );
    } catch (error) {
      return _FitCloudHeartRateProbeResult(
        diagnosticSummary: 'FitCloud HR probe fallido: ${error.runtimeType}',
      );
    } finally {
      try {
        debugPrint(
          'WindWisher BLE $deviceId: FitCloud HR stop ${_limitedHexBytes(_fitCloudHeartRateStopFrame)}',
        );
        await _ble
            .writeCharacteristicWithResponse(
              writeCharacteristic,
              value: _fitCloudHeartRateStopFrame,
            )
            .timeout(const Duration(seconds: 3));
      } catch (error) {
        debugPrint('WindWisher BLE $deviceId: FitCloud HR stop failed $error');
      }
      await subscription.cancel();
    }
  }

  int? _fitCloudHeartRateBpm(List<int> value) {
    if (value.length < 12) {
      return null;
    }
    if (value[0] != 0x05 || value[2] != 0x24) {
      return null;
    }
    final bpm = value[11] & 0xff;
    if (bpm < 30 || bpm > 240) {
      return null;
    }
    return bpm;
  }

  bool _isSensorService(Uuid serviceId) {
    final normalized = serviceId.expanded.toString().toLowerCase();
    return normalized == _standardBleService('180d') ||
        normalized == _standardBleService('1819') ||
        normalized == _standardBleService('181a');
  }

  bool _isGenericOrHidService(Uuid serviceId) {
    final normalized = serviceId.expanded.toString().toLowerCase();
    return normalized == _standardBleService('1800') ||
        normalized == _standardBleService('1801') ||
        normalized == _standardBleService('1812');
  }

  String _limitedHexBytes(List<int> bytes, {int maxBytes = 32}) {
    if (bytes.isEmpty) {
      return 'empty';
    }
    final visible = bytes.length <= maxBytes ? bytes : bytes.take(maxBytes);
    final suffix = bytes.length <= maxBytes
        ? ''
        : ' ... (${bytes.length} bytes)';
    return '${_hexBytes(visible.toList(growable: false))}$suffix';
  }

  String _resolvedFamilyAfterProbe({
    required String currentFamily,
    required List<String> physicalSensorKeys,
  }) {
    if (currentFamily != 'unknown') {
      return currentFamily;
    }
    if (physicalSensorKeys.contains('heart_rate')) {
      return 'watch';
    }
    return currentFamily;
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

  String _fallbackDeviceLabel(String id) {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      return 'Dispositivo BLE sin nombre';
    }

    final compactId = normalizedId.replaceAll(':', '').replaceAll('-', '');
    final suffix = compactId.length <= 8
        ? compactId
        : compactId.substring(compactId.length - 8);
    return 'BLE $suffix';
  }

  SessionDetectedCompatibleDeviceData _copyDeviceWithProbeResult({
    required SessionDetectedCompatibleDeviceData device,
    required String family,
    required String placement,
    required List<String> physicalSensorKeys,
    String? sensorSummary,
    String? diagnosticSummary,
  }) {
    return SessionDetectedCompatibleDeviceData(
      id: device.id,
      defaultName: device.defaultName,
      kind: _kindForFamily(family, device.model),
      status: 'Comprobado',
      sensorSummary: sensorSummary ?? _sensorSummary(physicalSensorKeys),
      family: family,
      placement: placement,
      connectionState: 'Comprobado',
      manufacturer: device.manufacturer,
      model: device.model,
      firmwareVersion: device.firmwareVersion,
      physicalSensorKeys: physicalSensorKeys,
      isSessionEligible: LinkedDevice.isSessionEligibleForDetectedDevice(
        family: family,
        physicalSensorKeys: physicalSensorKeys,
      ),
      canConnect: device.canConnect,
      diagnosticSummary: diagnosticSummary ?? device.diagnosticSummary,
      customName: device.customName,
    );
  }

  String _sensorSummary(List<String> physicalSensorKeys) {
    if (physicalSensorKeys.isEmpty) {
      return 'Sensores físicos aún no identificados';
    }
    return physicalSensorKeys.join(', ');
  }
}

class _ProprietaryProbeResult {
  const _ProprietaryProbeResult({
    required this.diagnosticSummary,
    this.physicalSensorKeys = const <String>{},
  });

  final String diagnosticSummary;
  final Set<String> physicalSensorKeys;
}

class _FitCloudHeartRateProbeResult {
  const _FitCloudHeartRateProbeResult({
    required this.diagnosticSummary,
    this.physicalSensorKeys = const <String>{},
  });

  final String diagnosticSummary;
  final Set<String> physicalSensorKeys;
}
