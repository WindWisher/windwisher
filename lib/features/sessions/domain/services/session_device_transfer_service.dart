import 'package:windwisher/features/sessions/domain/entities/device_session_transfer.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/ports/out/private_canonical_inbox_port.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_device_transfer_port.dart';
import 'package:windwisher/features/sessions/domain/services/private_canonical_validator.dart';

class DeviceSessionDownloadResult {
  const DeviceSessionDownloadResult({
    required this.receivedCount,
    required this.importedCount,
    required this.duplicateCount,
    required this.inboxSessions,
  });

  final int receivedCount;
  final int importedCount;
  final int duplicateCount;
  final List<PrivateCanonicalSession> inboxSessions;
}

class SessionDeviceTransferService {
  const SessionDeviceTransferService(this._transport);

  static const int maxSessionsPerTransfer = 32;

  final SessionDeviceTransferPort _transport;

  Future<DeviceSessionInventory> inspect(LinkedDevice device) async {
    final inventory = await _transport.inspect(device);
    if (!inventory.isSupported) {
      return inventory;
    }
    _validateReferences(inventory.sessions);
    return inventory;
  }

  Future<DeviceSessionDownloadResult> downloadIntoInbox({
    required LinkedDevice device,
    required List<DeviceSessionReference> sessions,
    required PrivateCanonicalInboxPort inbox,
  }) async {
    _validateReferences(sessions);
    final requestedIds = sessions.map((session) => session.sourceId).toSet();
    final downloaded = await _transport.download(
      device: device,
      sessions: List<DeviceSessionReference>.unmodifiable(sessions),
    );
    if (downloaded.length != requestedIds.length) {
      throw const FormatException(
        'La descarga del dispositivo esta incompleta.',
      );
    }

    final downloadedIds = <String>{};
    final validated =
        <
          ({DownloadedDeviceSession download, PrivateCanonicalSession session})
        >[];
    for (final item in downloaded) {
      final transportId = item.reference.sourceId.trim();
      if (!requestedIds.contains(transportId) ||
          !downloadedIds.add(transportId)) {
        throw const FormatException(
          'La descarga contiene una identidad de sesion inesperada.',
        );
      }
      final canonical = await inbox.validateBytes(item.canonicalBytes);
      if (canonical.sourceId != transportId) {
        throw const FormatException(
          'La identidad de la sesion no coincide con su contenido.',
        );
      }
      validated.add((download: item, session: canonical));
    }

    var importedCount = 0;
    var duplicateCount = 0;
    for (final item in validated) {
      if (await inbox.importBytes(item.download.canonicalBytes)) {
        importedCount++;
      } else {
        duplicateCount++;
      }
    }

    return DeviceSessionDownloadResult(
      receivedCount: downloaded.length,
      importedCount: importedCount,
      duplicateCount: duplicateCount,
      inboxSessions: await inbox.list(),
    );
  }

  void _validateReferences(List<DeviceSessionReference> sessions) {
    if (sessions.length > maxSessionsPerTransfer) {
      throw const FormatException('Hay demasiadas sesiones pendientes.');
    }
    final ids = <String>{};
    for (final session in sessions) {
      final id = session.sourceId.trim();
      if (id.isEmpty || !ids.add(id) || session.duration.isNegative) {
        throw const FormatException(
          'El dispositivo ha devuelto una lista de sesiones invalida.',
        );
      }
    }
  }
}
