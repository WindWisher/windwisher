import 'dart:async';

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

  test('rejects malformed or out-of-bounds transfer progress', () async {
    final client = GarminConnectIqClient(channel: channel, isAndroid: true);
    for (final response in <Object?>[
      null,
      {'lines': -1, 'bytes': 0, 'active': true},
      {'lines': 1027, 'bytes': 0, 'active': true},
      {'lines': 0, 'bytes': -1, 'active': true},
      {'lines': 0, 'bytes': 2097153, 'active': true},
      {'lines': 0.5, 'bytes': 0, 'active': true},
      {'lines': 0, 'bytes': 0, 'active': 'true'},
    ]) {
      messenger.setMockMethodCallHandler(channel, (_) async => response);
      await expectLater(client.transferProgress(), throwsFormatException);
    }
  });

  test('accepts transfer limits and skips the channel off Android', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {'lines': 1026, 'bytes': 2097152, 'active': false},
    );
    expect(
      await GarminConnectIqClient(
        channel: channel,
        isAndroid: true,
      ).transferProgress(),
      (lines: 1026, bytes: 2097152, active: false),
    );
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw StateError('Unexpected call'),
    );
    expect(
      await GarminConnectIqClient(
        channel: channel,
        isAndroid: false,
      ).transferProgress(),
      (lines: 0, bytes: 0, active: false),
    );
  });

  test('reads progress while a download occupies the request queue', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'downloadSession') {
        entered.complete();
        await release.future;
        return Uint8List.fromList([10]);
      }
      expect(call.method, 'transferProgress');
      return {'lines': 12, 'bytes': 4300, 'active': true};
    });
    final client = GarminConnectIqClient(channel: channel, isAndroid: true);
    final download = client.downloadSession(
      deviceId: '123',
      sourceId: 'session-1',
    );
    await entered.future;
    try {
      expect(
        await client.transferProgress().timeout(const Duration(seconds: 1)),
        (lines: 12, bytes: 4300, active: true),
      );
    } finally {
      release.complete();
      await download;
    }
  });

  test('serializes discovery and inventory across client instances', () async {
    final entered = Completer<void>();
    final release = Completer<void>();
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      if (call.method == 'knownDevices') {
        entered.complete();
        await release.future;
      }
      return <Object?>[];
    });
    final discovery = GarminConnectIqClient(
      channel: channel,
      isAndroid: true,
    ).knownDevices();
    await entered.future;
    final inventory = GarminConnectIqClient(
      channel: channel,
      isAndroid: true,
    ).inspectSessions('123');
    await Future<void>.delayed(Duration.zero);
    expect(calls, ['knownDevices']);
    release.complete();
    await discovery;
    await inventory;
    expect(calls, ['knownDevices', 'inspectSessions']);
  });

  test('continues queued calls after a native failure', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'knownDevices') {
        throw PlatformException(code: 'garmin_unavailable');
      }
      return <Object?>[];
    });
    final client = GarminConnectIqClient(channel: channel, isAndroid: true);
    final failure = expectLater(
      client.knownDevices(),
      throwsA(isA<PlatformException>()),
    );
    final inventory = client.inspectSessions('123');
    await failure;
    expect(await inventory, isEmpty);
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
