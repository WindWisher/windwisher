import 'package:windwisher/features/sessions/domain/entities/session_view_preferences.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_view_preferences_port.dart';

class GetSessionViewPreferencesUseCase {
  const GetSessionViewPreferencesUseCase(this._port);

  final SessionViewPreferencesPort _port;

  SessionViewPreferences call() {
    return _port.getSessionViewPreferences();
  }
}

class SaveSessionViewPreferencesUseCase {
  const SaveSessionViewPreferencesUseCase(this._port);

  final SessionViewPreferencesPort _port;

  void call(SessionViewPreferences value) {
    _port.saveSessionViewPreferences(value);
  }
}
