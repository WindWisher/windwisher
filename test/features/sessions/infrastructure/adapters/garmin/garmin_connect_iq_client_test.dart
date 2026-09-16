import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/garmin/garmin_connect_iq_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('windwisher/garmin_connect_iq_test');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test(
    'maps known Garmin Connect IQ devices without changing opaque ids',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'knownDevices');
        return <Map<String, Object?>>[
          <String, Object?>{
            'id': '987654321012345678',
            'name': 'fēnix 7S',
            'status': 'CONNECTED',
            'partNumber': '006-B3998-00',
            'sessionAppId': GarminConnectIqClient.sessionAppId,
          },
        ];
      });

      final devices = await GarminConnectIqClient(
        channel: channel,
        isAndroid: true,
      ).knownDevices();

      expect(devices, hasLength(1));
      expect(devices.single.id, '987654321012345678');
      expect(devices.single.name, 'fēnix 7S');
      expect(devices.single.isConnected, isTrue);
      expect(devices.single.partNumber, '006-B3998-00');
    },
  );

  test('rejects a response for a different Connect IQ application', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      return <Map<String, Object?>>[
        <String, Object?>{
          'id': '42',
          'name': 'Garmin',
          'status': 'CONNECTED',
          'sessionAppId': 'another-app',
        },
      ];
    });

    expect(
      GarminConnectIqClient(channel: channel, isAndroid: true).knownDevices(),
      throwsFormatException,
    );
  });

  test('parses session inventory and downloads envelope bytes', () async {
    final envelope = Uint8List.fromList(<int>[123, 125, 10]);
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'inspectSessions') {
        expect(call.arguments, <String, Object?>{'deviceId': '123'});
        return <Map<String, Object?>>[
          <String, Object?>{
            'sourceId': 'session-1',
            'startedAtEpochSeconds': 1700000000,
            'endedAtEpochSeconds': 1700000060,
            'durationMilliseconds': 60000,
            'frameCount': 12,
          },
        ];
      }
      if (call.method == 'downloadSession') {
        expect(call.arguments, <String, Object?>{
          'deviceId': '123',
          'sourceId': 'session-1',
        });
        return envelope;
      }
      return null;
    });
    final client = GarminConnectIqClient(channel: channel, isAndroid: true);

    final sessions = await client.inspectSessions('123');
    expect(sessions.single.sourceId, 'session-1');
    expect(sessions.single.duration, const Duration(minutes: 1));
    expect(sessions.single.recordCount, 12);
    expect(
      await client.downloadSession(deviceId: '123', sourceId: 'session-1'),
      envelope,
    );
  });
}
