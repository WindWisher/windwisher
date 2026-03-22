import 'package:windwisher/features/sessions/domain/entities/session_view_preferences.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_view_preferences_port.dart';

class InMemorySessionViewPreferencesAdapter
    implements SessionViewPreferencesPort {
  SessionViewPreferences _value = SessionViewPreferences.initial();

  @override
  SessionViewPreferences getSessionViewPreferences() {
    return _value;
  }

  @override
  void saveSessionViewPreferences(SessionViewPreferences value) {
    _value = value;
  }
}
