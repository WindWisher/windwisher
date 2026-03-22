import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter.dart';

void main() {
  test('persists profile changes across repository instances', () {
    final file = File(AppStoragePaths.resolve('profile_user_v1.json'));
    if (file.existsSync()) {
      file.deleteSync();
    }

    final repository = LocalFileProfileRepositoryAdapter();
    final updated = repository.getProfile().copyWith(
      displayName: 'Persist User',
      handle: '@persist_user',
    );
    repository.saveProfile(updated);

    final reloadedRepository = LocalFileProfileRepositoryAdapter();
    final persisted = reloadedRepository.getProfile();

    expect(persisted.displayName, 'Persist User');
    expect(persisted.handle, '@persist_user');

    if (file.existsSync()) {
      file.deleteSync();
    }
  });
}
