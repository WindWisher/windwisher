import 'dart:convert';
import 'dart:io';

import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_repository_port.dart';

class LocalFileProfileRepositoryAdapter implements ProfileRepositoryPort {
  LocalFileProfileRepositoryAdapter()
    : _file = File(AppStoragePaths.resolve('profile_user_v1.json')) {
    _load();
  }

  final File _file;
  UserProfileData _profile = UserProfileData.initial();

  @override
  UserProfileData getProfile() {
    return _profile;
  }

  @override
  Future<UserProfileData> loadProfile() async {
    return _profile;
  }

  @override
  Future<void> saveProfile(UserProfileData value) async {
    _profile = value;
    _save();
  }

  void _load() {
    if (!_file.existsSync()) {
      _save();
      return;
    }

    try {
      final raw = _file.readAsStringSync();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      _profile = UserProfileData.fromJson(json);
    } catch (_) {
      _profile = UserProfileData.initial();
      _save();
    }
  }

  void _save() {
    final json = const JsonEncoder.withIndent('  ').convert(_profile.toJson());
    _file.writeAsStringSync(json);
  }
}
