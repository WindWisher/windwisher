import 'dart:typed_data';

class DeviceSessionReference {
  const DeviceSessionReference({
    required this.sourceId,
    required this.endedAt,
    required this.duration,
    this.recordCount,
  });

  final String sourceId;
  final DateTime endedAt;
  final Duration duration;
  final int? recordCount;
}

class DeviceSessionInventory {
  const DeviceSessionInventory.supported(this.sessions)
    : isSupported = true,
      unavailableReason = null;

  const DeviceSessionInventory.unsupported({required String reason})
    : isSupported = false,
      sessions = const <DeviceSessionReference>[],
      unavailableReason = reason;

  final bool isSupported;
  final List<DeviceSessionReference> sessions;
  final String? unavailableReason;
}

class DownloadedDeviceSession {
  const DownloadedDeviceSession({
    required this.reference,
    required this.canonicalBytes,
  });

  final DeviceSessionReference reference;
  final Uint8List canonicalBytes;
}
