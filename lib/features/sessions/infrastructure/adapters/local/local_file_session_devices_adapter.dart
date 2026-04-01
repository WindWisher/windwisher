import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_devices_port.dart';

class LocalFileSessionDevicesAdapter implements SessionDevicesPort {
  LocalFileSessionDevicesAdapter({
    String fileName = 'sessions_devices_v1.json',
    List<LinkedDevice>? seedDevices,
    String? seedSelectedDeviceId,
  }) : _file = File(AppStoragePaths.resolve(fileName)),
       _seedDevices = seedDevices == null
           ? _defaultSeedDevices
           : List<LinkedDevice>.from(seedDevices),
       _seedSelectedDeviceId = seedSelectedDeviceId ?? 'phone-1' {
    _load();
  }

  static const List<LinkedDevice> _defaultSeedDevices = [
    LinkedDevice(
      id: 'phone-1',
      name: 'Telefono del usuario',
      kind: 'Dispositivo Android',
      status: 'Listo',
      lastSync: 'Disponible en este dispositivo',
    ),
  ];

  final File _file;
  final List<LinkedDevice> _seedDevices;
  final String? _seedSelectedDeviceId;
  final List<LinkedDevice> _devices = <LinkedDevice>[];
  String? _selectedDeviceId;

  @override
  List<LinkedDevice> getLinkedDevices() {
    return List<LinkedDevice>.unmodifiable(_devices);
  }

  @override
  void saveLinkedDevice(LinkedDevice device) {
    final index = _devices.indexWhere((item) => item.id == device.id);
    if (index >= 0) {
      _devices[index] = device;
    } else {
      _devices.insert(0, device);
    }
    _save();
  }

  @override
  void deleteLinkedDevice(String id) {
    if (id == 'phone-1') {
      return;
    }
    _devices.removeWhere((item) => item.id == id);
    if (_selectedDeviceId == id) {
      _selectedDeviceId = null;
    }
    _save();
  }

  @override
  String? getSelectedDeviceId() {
    return _selectedDeviceId;
  }

  @override
  void saveSelectedDeviceId(String? id) {
    _selectedDeviceId = id;
    _save();
  }

  void _load() {
    if (!_file.existsSync()) {
      _devices
        ..clear()
        ..addAll(_seedDevices);
      _selectedDeviceId = _seedSelectedDeviceId;
      _save();
      return;
    }

    try {
      final raw = _file.readAsStringSync();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final rawDevices = data['devices'] as List<dynamic>? ?? const [];
      _devices
        ..clear()
        ..addAll(
          rawDevices.whereType<Map<String, dynamic>>().map(
            LinkedDevice.fromJson,
          ),
        );
      _selectedDeviceId = data['selectedDeviceId'] as String?;
      if (_devices.isEmpty) {
        _devices.addAll(_seedDevices);
        _selectedDeviceId = _seedSelectedDeviceId;
      }
    } catch (_) {
      _devices
        ..clear()
        ..addAll(_seedDevices);
      _selectedDeviceId = _seedSelectedDeviceId;
      _save();
    }
  }

  void _save() {
    final data = <String, dynamic>{
      'devices': _devices
          .map((entry) => entry.toJson())
          .toList(growable: false),
      'selectedDeviceId': _selectedDeviceId,
    };
    _file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(data));
  }
}
