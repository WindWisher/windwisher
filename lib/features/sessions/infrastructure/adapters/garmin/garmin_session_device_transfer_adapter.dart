import 'package:windwisher/features/sessions/domain/entities/device_session_transfer.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_device_transfer_port.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/garmin/garmin_connect_iq_client.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/garmin/garmin_session_envelope_converter.dart';

class GarminSessionDeviceTransferAdapter implements SessionDeviceTransferPort {
  const GarminSessionDeviceTransferAdapter(this._client, this._converter);

  static const devicePrefix = 'garmin-connect-iq:';
  final GarminConnectIqClient _client;
  final GarminSessionEnvelopeConverter _converter;

  @override
  Future<DeviceSessionInventory> inspect(LinkedDevice device) async {
    final deviceId = _deviceId(device);
    final sessions = await _client.inspectSessions(deviceId);
    return DeviceSessionInventory.supported(sessions);
  }

  @override
  Future<List<DownloadedDeviceSession>> download({
    required LinkedDevice device,
    required List<DeviceSessionReference> sessions,
  }) async {
    final deviceId = _deviceId(device);
    final output = <DownloadedDeviceSession>[];
    for (final session in sessions) {
      final envelope = await _client.downloadSession(
        deviceId: deviceId,
        sourceId: session.sourceId,
      );
      output.add(
        DownloadedDeviceSession(
          reference: session,
          canonicalBytes: _converter.convert(envelope),
        ),
      );
    }
    return output;
  }

  String _deviceId(LinkedDevice device) {
    if (!device.id.startsWith(devicePrefix)) {
      throw UnsupportedError('El dispositivo no usa Garmin Connect IQ.');
    }
    final id = device.id.substring(devicePrefix.length).trim();
    if (id.isEmpty || int.tryParse(id) == null) {
      throw const FormatException('El identificador Garmin no es valido.');
    }
    return id;
  }
}
