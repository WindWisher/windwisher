import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:windwisher/features/sessions/domain/entities/device_session_transfer.dart';
import 'package:windwisher/features/sessions/domain/entities/garmin_connect_iq_device.dart';

class GarminConnectIqClient {
  GarminConnectIqClient({MethodChannel? channel, bool? isAndroid})
    : _channel = channel ?? const MethodChannel(_channelName),
      _isAndroid =
          isAndroid ??
          (!kIsWeb && defaultTargetPlatform == TargetPlatform.android);

  static const String _channelName = 'windwisher/garmin_connect_iq';
  static const String sessionAppId = 'f25ab89e57f74368b256069658c6d2d8';

  final MethodChannel _channel;
  final bool _isAndroid;

  Future<List<GarminConnectIqDevice>> knownDevices() async {
    if (!_isAndroid) {
      return const <GarminConnectIqDevice>[];
    }
    final rawDevices = await _channel.invokeListMethod<Object?>('knownDevices');
    if (rawDevices == null) {
      return const <GarminConnectIqDevice>[];
    }

    return rawDevices.map(_parseDevice).toList(growable: false);
  }

  Future<List<DeviceSessionReference>> inspectSessions(String deviceId) async {
    if (!_isAndroid) return const <DeviceSessionReference>[];
    final rawSessions = await _channel.invokeListMethod<Object?>(
      'inspectSessions',
      <String, Object?>{'deviceId': deviceId},
    );
    return (rawSessions ?? const <Object?>[])
        .map(_parseSessionReference)
        .toList(growable: false);
  }

  Future<Uint8List> downloadSession({
    required String deviceId,
    required String sourceId,
  }) async {
    if (!_isAndroid) {
      throw UnsupportedError('Connect IQ solo esta disponible en Android.');
    }
    final bytes = await _channel.invokeMethod<Uint8List>(
      'downloadSession',
      <String, Object?>{'deviceId': deviceId, 'sourceId': sourceId},
    );
    if (bytes == null || bytes.isEmpty) {
      throw const FormatException('Garmin ha devuelto una descarga vacia.');
    }
    return bytes;
  }

  GarminConnectIqDevice _parseDevice(Object? rawDevice) {
    if (rawDevice is! Map<Object?, Object?>) {
      throw const FormatException(
        'Garmin ha devuelto un dispositivo invalido.',
      );
    }
    final id = rawDevice['id']?.toString().trim() ?? '';
    final name = rawDevice['name']?.toString().trim() ?? '';
    final status = rawDevice['status']?.toString().trim() ?? '';
    final appId = rawDevice['sessionAppId']?.toString().trim() ?? '';
    if (id.isEmpty || name.isEmpty || status.isEmpty || appId != sessionAppId) {
      throw const FormatException(
        'Garmin ha devuelto un dispositivo invalido.',
      );
    }
    final partNumber = rawDevice['partNumber']?.toString().trim();
    return GarminConnectIqDevice(
      id: id,
      name: name,
      status: status,
      sessionAppId: appId,
      partNumber: partNumber == null || partNumber.isEmpty ? null : partNumber,
    );
  }

  DeviceSessionReference _parseSessionReference(Object? rawSession) {
    if (rawSession is! Map<Object?, Object?>) {
      throw const FormatException('Garmin ha devuelto una sesion invalida.');
    }
    final sourceId = rawSession['sourceId']?.toString().trim() ?? '';
    final started = rawSession['startedAtEpochSeconds'];
    final ended = rawSession['endedAtEpochSeconds'];
    final duration = rawSession['durationMilliseconds'];
    final frameCount = rawSession['frameCount'];
    if (!RegExp(r'^[A-Za-z0-9_-]{1,96}$').hasMatch(sourceId) ||
        started is! int ||
        ended is! int ||
        duration is! int ||
        frameCount is! int ||
        started < 0 ||
        ended < started ||
        duration < 0 ||
        frameCount < 2 ||
        frameCount > 1024) {
      throw const FormatException('Garmin ha devuelto una sesion invalida.');
    }
    return DeviceSessionReference(
      sourceId: sourceId,
      endedAt: DateTime.fromMillisecondsSinceEpoch(ended * 1000, isUtc: true),
      duration: Duration(milliseconds: duration),
      recordCount: frameCount,
    );
  }
}
