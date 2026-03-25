// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;

StreamController<double?>? _controller;
StreamSubscription<html.DeviceOrientationEvent>? _subscription;

Future<bool> ensureWebCompassPermission() async {
  final constructor = js.context['DeviceOrientationEvent'];
  if (constructor == null) {
    return false;
  }
  final constructorObject = js.JsObject.fromBrowserObject(constructor);
  final requestPermission = constructorObject['requestPermission'];
  if (requestPermission == null) {
    return true;
  }
  try {
    final promise = constructorObject.callMethod('requestPermission');
    if (promise is! js.JsObject) {
      return false;
    }
    final completer = Completer<Object?>();
    promise.callMethod('then', [
      js.JsFunction.withThis((_, Object? value) {
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      }),
      js.JsFunction.withThis((_, Object? error) {
        if (!completer.isCompleted) {
          completer.completeError(error ?? 'requestPermission failed');
        }
      }),
    ]);
    final result = await completer.future;
    return result?.toString().toLowerCase() == 'granted';
  } catch (_) {
    return false;
  }
}

Stream<double?> get webCompassHeadingStream {
  _controller ??= StreamController<double?>.broadcast(
    onListen: _startListening,
    onCancel: _stopListeningIfIdle,
  );
  return _controller!.stream;
}

void _startListening() {
  _subscription ??= html.window.onDeviceOrientation.listen((event) {
    _controller?.add(_extractHeading(event));
  });
}

void _stopListeningIfIdle() {
  if (_controller?.hasListener ?? false) {
    return;
  }
  _subscription?.cancel();
  _subscription = null;
}

double? _extractHeading(html.DeviceOrientationEvent event) {
  final eventObject = js.JsObject.fromBrowserObject(event);
  final webkitHeading = eventObject['webkitCompassHeading'];
  if (webkitHeading is num) {
    return _normalizeDegrees(webkitHeading.toDouble());
  }
  final alpha = event.alpha;
  if (alpha == null) {
    return null;
  }
  return _normalizeDegrees(360.0 - alpha);
}

double _normalizeDegrees(double value) {
  final normalized = value % 360.0;
  return normalized < 0 ? normalized + 360.0 : normalized;
}
