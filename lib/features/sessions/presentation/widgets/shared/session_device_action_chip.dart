import 'package:flutter/material.dart';

class SessionDeviceActionChip extends StatelessWidget {
  const SessionDeviceActionChip({
    super.key,
    required this.deviceName,
    required this.deviceKind,
    required this.onPressed,
  });

  final String deviceName;
  final String deviceKind;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(_deviceChipIcon(deviceKind), size: 16),
      label: Text(deviceName),
      onPressed: onPressed,
    );
  }

  static IconData deviceChipIcon(String kind) => _deviceChipIcon(kind);

  static IconData _deviceChipIcon(String kind) {
    final normalized = kind.toLowerCase();
    if (normalized.contains('watch') || normalized.contains('smartwatch')) {
      return Icons.watch_rounded;
    }
    if (normalized.contains('android') ||
        normalized.contains('iphone') ||
        normalized.contains('telefono')) {
      return Icons.phone_android_rounded;
    }
    return Icons.memory_rounded;
  }
}
