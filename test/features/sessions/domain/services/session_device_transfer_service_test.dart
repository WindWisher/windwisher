import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/sessions/domain/entities/device_session_transfer.dart';
import 'package:windwisher/features/sessions/domain/entities/linked_device.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_device_transfer_port.dart';
import 'package:windwisher/features/sessions/domain/services/private_canonical_validator.dart';
import 'package:windwisher/features/sessions/domain/services/session_device_transfer_service.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/device_transfer/unsupported_session_device_transfer_adapter.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/private_canonical_inbox.dart';

void main() {
  const device = LinkedDevice(
    id: 'watch-device-1',
    name: 'WindWisher Watch',
    kind: 'Garmin Watch',
    status: 'Listo',
    lastSync: 'Nunca',
    family: 'watch',
    placement: 'wrist',
    physicalSensorKeys: <String>['gps'],
    isSessionEligible: true,
  );
  final bytes = File('test/fixtures/private_canonical.jsonl').readAsBytesSync();
  final reference = DeviceSessionReference(
    sourceId: 'synthetic-inbox-session',
    endedAt: DateTime.parse('2025-01-01T00:00:01Z'),
    duration: const Duration(seconds: 1),
    recordCount: 7,
  );
  final schema =
      jsonDecode(
            File(
              'assets/contracts/canonical-session-record.schema.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  test('unsupported adapter never exposes download actions', () async {
    const adapter = UnsupportedSessionDeviceTransferAdapter();
    final inventory = await adapter.inspect(device);

    expect(inventory.isSupported, isFalse);
    expect(inventory.sessions, isEmpty);
    await expectLater(
      adapter.download(device: device, sessions: [reference]),
      throwsUnsupportedError,
    );
  });

  test('downloads validated canonical bytes into the private inbox', () async {
    final root = await Directory.systemTemp.createTemp('ww-transfer-test-');
    addTearDown(() => root.delete(recursive: true));
    final inbox = PrivateCanonicalInbox(
      root,
      PrivateCanonicalValidator(schema),
    );
    final service = SessionDeviceTransferService(
      _FakeTransferPort(
        inventory: DeviceSessionInventory.supported([reference]),
        downloads: [
          DownloadedDeviceSession(reference: reference, canonicalBytes: bytes),
        ],
      ),
    );

    final inventory = await service.inspect(device);
    final first = await service.downloadIntoInbox(
      device: device,
      sessions: inventory.sessions,
      inbox: inbox,
    );
    final retry = await service.downloadIntoInbox(
      device: device,
      sessions: inventory.sessions,
      inbox: inbox,
    );

    expect(first.receivedCount, 1);
    expect(first.importedCount, 1);
    expect(first.duplicateCount, 0);
    expect(first.inboxSessions.single.sourceId, reference.sourceId);
    expect(retry.importedCount, 0);
    expect(retry.duplicateCount, 1);
    expect(retry.inboxSessions, hasLength(1));
  });

  test(
    'rejects a transport identity that differs from canonical content',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'ww-transfer-id-test-',
      );
      addTearDown(() => root.delete(recursive: true));
      final inbox = PrivateCanonicalInbox(
        root,
        PrivateCanonicalValidator(schema),
      );
      final wrongReference = DeviceSessionReference(
        sourceId: 'another-session-id',
        endedAt: reference.endedAt,
        duration: reference.duration,
      );
      final service = SessionDeviceTransferService(
        _FakeTransferPort(
          inventory: DeviceSessionInventory.supported([wrongReference]),
          downloads: [
            DownloadedDeviceSession(
              reference: wrongReference,
              canonicalBytes: bytes,
            ),
          ],
        ),
      );

      await expectLater(
        service.downloadIntoInbox(
          device: device,
          sessions: [wrongReference],
          inbox: inbox,
        ),
        throwsFormatException,
      );
      expect(await inbox.list(), isEmpty);
    },
  );

  test('rejects duplicate opaque IDs before contacting download', () async {
    final port = _FakeTransferPort(
      inventory: DeviceSessionInventory.supported([reference, reference]),
      downloads: const <DownloadedDeviceSession>[],
    );
    final service = SessionDeviceTransferService(port);

    await expectLater(service.inspect(device), throwsFormatException);
    expect(port.downloadCalls, 0);
  });
}

class _FakeTransferPort implements SessionDeviceTransferPort {
  _FakeTransferPort({required this.inventory, required this.downloads});

  final DeviceSessionInventory inventory;
  final List<DownloadedDeviceSession> downloads;
  int downloadCalls = 0;

  @override
  Future<DeviceSessionInventory> inspect(LinkedDevice device) async =>
      inventory;

  @override
  Future<List<DownloadedDeviceSession>> download({
    required LinkedDevice device,
    required List<DeviceSessionReference> sessions,
  }) async {
    downloadCalls++;
    return downloads;
  }
}
