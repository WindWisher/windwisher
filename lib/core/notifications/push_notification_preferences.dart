enum PushNotificationCategory { spotAlarms, directMessages, spotChatMentions }

class PushNotificationPreferences {
  final Map<String, bool> _enabledByAccount = <String, bool>{};
  final Map<String, Map<PushNotificationCategory, bool>> _categoriesByAccount =
      <String, Map<PushNotificationCategory, bool>>{};

  bool enabledFor(String accountKey) =>
      _enabledByAccount[accountKey.trim()] ?? false;

  void setEnabled(String accountKey, bool enabled) {
    _enabledByAccount[accountKey.trim()] = enabled;
  }

  bool categoryEnabledFor(
    String accountKey,
    PushNotificationCategory category,
  ) => _categoriesByAccount[accountKey.trim()]?[category] ?? true;

  void setCategoryEnabled(
    String accountKey,
    PushNotificationCategory category,
    bool enabled,
  ) {
    final categories = _categoriesByAccount.putIfAbsent(
      accountKey.trim(),
      () => <PushNotificationCategory, bool>{},
    );
    categories[category] = enabled;
  }

  void load(Map<String, dynamic> json, {required String legacyAccountKey}) {
    _enabledByAccount.clear();
    _categoriesByAccount.clear();
    final enabledByAccount = json['enabledByAccount'];
    if (enabledByAccount is Map<String, dynamic>) {
      for (final entry in enabledByAccount.entries) {
        final value = entry.value;
        if (value is bool) {
          _enabledByAccount[entry.key] = value;
        }
      }
    } else {
      final legacyEnabled = json['enabled'];
      if (legacyEnabled is bool) {
        _enabledByAccount[legacyAccountKey] = legacyEnabled;
      }
    }

    final categoriesByAccount = json['categoriesByAccount'];
    if (categoriesByAccount is Map<String, dynamic>) {
      for (final accountEntry in categoriesByAccount.entries) {
        final rawCategories = accountEntry.value;
        if (rawCategories is! Map<String, dynamic>) {
          continue;
        }
        for (final category in PushNotificationCategory.values) {
          final value = rawCategories[category.name];
          if (value is bool) {
            setCategoryEnabled(accountEntry.key, category, value);
          }
        }
      }
    }
  }

  void clear() {
    _enabledByAccount.clear();
    _categoriesByAccount.clear();
  }

  Map<String, bool> toJson() =>
      Map<String, bool>.unmodifiable(_enabledByAccount);

  Map<String, Map<String, bool>> categoriesToJson() {
    return <String, Map<String, bool>>{
      for (final accountEntry in _categoriesByAccount.entries)
        accountEntry.key: <String, bool>{
          for (final categoryEntry in accountEntry.value.entries)
            categoryEntry.key.name: categoryEntry.value,
        },
    };
  }
}
