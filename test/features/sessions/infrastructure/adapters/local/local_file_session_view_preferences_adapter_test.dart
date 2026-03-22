import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/sessions/domain/entities/session_view_preferences.dart';
import 'package:windwisher/features/sessions/infrastructure/adapters/local/local_file_session_view_preferences_adapter.dart';

void main() {
  test('persists session view preferences across adapter instances', () {
    const fileName = 'sessions_view_preferences_test_v1.json';
    final file = File(AppStoragePaths.resolve(fileName));
    if (file.existsSync()) {
      file.deleteSync();
    }

    final adapter = LocalFileSessionViewPreferencesAdapter(fileName: fileName);
    adapter.saveSessionViewPreferences(
      const SessionViewPreferences(
        selectedTabKey: 'mySessions',
        filterDeviceName: 'Woo Sports 3',
        sortOrder: 'Mas antiguas',
        lastUsedGearSetupId: 'setup-1',
        lastUsedUploadSpot: 'Gandia Harbor',
      ),
    );

    final reloaded = LocalFileSessionViewPreferencesAdapter(fileName: fileName);
    final value = reloaded.getSessionViewPreferences();
    expect(value.selectedTabKey, 'mySessions');
    expect(value.filterDeviceName, 'Woo Sports 3');
    expect(value.sortOrder, 'Mas antiguas');
    expect(value.lastUsedGearSetupId, 'setup-1');
    expect(value.lastUsedUploadSpot, 'Gandia Harbor');

    if (file.existsSync()) {
      file.deleteSync();
    }
  });
}
