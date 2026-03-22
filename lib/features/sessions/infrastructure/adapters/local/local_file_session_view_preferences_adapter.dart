import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/sessions/domain/entities/session_view_preferences.dart';
import 'package:windwisher/features/sessions/domain/ports/out/session_view_preferences_port.dart';

class LocalFileSessionViewPreferencesAdapter
    implements SessionViewPreferencesPort {
  LocalFileSessionViewPreferencesAdapter({
    String fileName = 'sessions_view_preferences_v1.json',
  }) : _file = File(AppStoragePaths.resolve(fileName)) {
    _load();
  }

  final File _file;
  SessionViewPreferences _value = SessionViewPreferences.initial();

  @override
  SessionViewPreferences getSessionViewPreferences() {
    return _value;
  }

  @override
  void saveSessionViewPreferences(SessionViewPreferences value) {
    _value = value;
    _save();
  }

  void _load() {
    if (!_file.existsSync()) {
      _save();
      return;
    }

    try {
      final raw = _file.readAsStringSync();
      final data = jsonDecode(raw) as Map<String, dynamic>;
      _value = SessionViewPreferences.fromJson(data);
    } catch (_) {
      _value = SessionViewPreferences.initial();
      _save();
    }
  }

  void _save() {
    _file.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(_value.toJson()),
    );
  }
}
