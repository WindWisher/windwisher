import 'package:geolocator/geolocator.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class StartSessionLocationLogic {
  const StartSessionLocationLogic._();

  static Future<SessionLocationAccessDecision> resolveLocationAccess() async {
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();
    if (!servicesEnabled) {
      return const SessionLocationAccessDecision(
        action: SessionLocationAccessAction.showMessage,
        message: 'Activa la ubicación del teléfono para grabar la sesión.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const SessionLocationAccessDecision(
        action: SessionLocationAccessAction.showMessage,
        message: 'Necesitamos permiso de ubicación para grabar sesiones reales.',
      );
    }

    return const SessionLocationAccessDecision(
      action: SessionLocationAccessAction.startCapture,
    );
  }
}
