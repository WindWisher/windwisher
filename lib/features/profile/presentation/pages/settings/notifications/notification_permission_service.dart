import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

enum NotificationPermissionState {
  unknown,
  granted,
  denied,
  permanentlyDenied,
  restricted,
  unsupported,
}

class NotificationPermissionService {
  const NotificationPermissionService();

  Future<NotificationPermissionState> currentState() async {
    if (kIsWeb) {
      return NotificationPermissionState.unsupported;
    }
    return _mapStatus(await permissions.Permission.notification.status);
  }

  Future<NotificationPermissionState> request() async {
    if (kIsWeb) {
      return NotificationPermissionState.unsupported;
    }
    return _mapStatus(await permissions.Permission.notification.request());
  }

  Future<bool> openSystemSettings() => permissions.openAppSettings();

  NotificationPermissionState _mapStatus(permissions.PermissionStatus status) {
    if (status.isGranted || status.isProvisional || status.isLimited) {
      return NotificationPermissionState.granted;
    }
    if (status.isPermanentlyDenied) {
      return NotificationPermissionState.permanentlyDenied;
    }
    if (status.isRestricted) {
      return NotificationPermissionState.restricted;
    }
    return NotificationPermissionState.denied;
  }
}
