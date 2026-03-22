import 'package:windwisher/features/sessions/domain/entities/session_view_preferences.dart';

abstract class SessionViewPreferencesPort {
  SessionViewPreferences getSessionViewPreferences();

  void saveSessionViewPreferences(SessionViewPreferences value);
}
