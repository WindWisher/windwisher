import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/notifications/push_notification_preferences.dart';

void main() {
  test('defaults to disabled and isolates each account', () {
    final preferences = PushNotificationPreferences();

    expect(preferences.enabledFor('user-a'), isFalse);
    preferences.setEnabled('user-a', true);

    expect(preferences.enabledFor('user-a'), isTrue);
    expect(preferences.enabledFor('user-b'), isFalse);
  });

  test('round-trips version 2 account preferences', () {
    final preferences = PushNotificationPreferences()
      ..setEnabled('user-a', true)
      ..setEnabled('user-b', false);
    final restored = PushNotificationPreferences()
      ..load(<String, dynamic>{
        'enabledByAccount': preferences.toJson(),
      }, legacyAccountKey: 'ignored');

    expect(restored.enabledFor('user-a'), isTrue);
    expect(restored.enabledFor('user-b'), isFalse);
  });

  test('categories default to enabled and remain isolated by account', () {
    final preferences = PushNotificationPreferences();

    expect(
      preferences.categoryEnabledFor(
        'user-a',
        PushNotificationCategory.spotAlarms,
      ),
      isTrue,
    );

    preferences.setCategoryEnabled(
      'user-a',
      PushNotificationCategory.spotAlarms,
      false,
    );

    expect(
      preferences.categoryEnabledFor(
        'user-a',
        PushNotificationCategory.spotAlarms,
      ),
      isFalse,
    );
    expect(
      preferences.categoryEnabledFor(
        'user-b',
        PushNotificationCategory.spotAlarms,
      ),
      isTrue,
    );
  });

  test('round-trips category preferences', () {
    final preferences = PushNotificationPreferences()
      ..setCategoryEnabled(
        'user-a',
        PushNotificationCategory.directMessages,
        false,
      );
    final restored = PushNotificationPreferences()
      ..load(<String, dynamic>{
        'categoriesByAccount': preferences.categoriesToJson(),
      }, legacyAccountKey: 'ignored');

    expect(
      restored.categoryEnabledFor(
        'user-a',
        PushNotificationCategory.directMessages,
      ),
      isFalse,
    );
    expect(
      restored.categoryEnabledFor(
        'user-a',
        PushNotificationCategory.spotChatMentions,
      ),
      isTrue,
    );
  });

  test('migrates the legacy device preference to the active account', () {
    final preferences = PushNotificationPreferences()
      ..load(<String, dynamic>{'enabled': true}, legacyAccountKey: 'user-a');

    expect(preferences.enabledFor('user-a'), isTrue);
    expect(preferences.enabledFor('user-b'), isFalse);
  });
}
