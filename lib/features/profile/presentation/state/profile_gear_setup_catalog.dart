import 'package:flutter/foundation.dart';

class ProfileGearSetupOption {
  const ProfileGearSetupOption({required this.id, required this.name});

  final String id;
  final String name;
}

class ProfileGearSetupCatalog {
  ProfileGearSetupCatalog._();

  static final ProfileGearSetupCatalog instance = ProfileGearSetupCatalog._();

  final ValueNotifier<List<ProfileGearSetupOption>> _options = ValueNotifier(
    const [],
  );

  List<ProfileGearSetupOption> get options => _options.value;

  void replaceAll(List<ProfileGearSetupOption> next) {
    if (_isSame(_options.value, next)) {
      return;
    }
    _options.value = List<ProfileGearSetupOption>.unmodifiable(next);
  }

  bool _isSame(
    List<ProfileGearSetupOption> current,
    List<ProfileGearSetupOption> next,
  ) {
    if (identical(current, next)) {
      return true;
    }
    if (current.length != next.length) {
      return false;
    }
    for (var i = 0; i < current.length; i++) {
      if (current[i].id != next[i].id || current[i].name != next[i].name) {
        return false;
      }
    }
    return true;
  }
}
