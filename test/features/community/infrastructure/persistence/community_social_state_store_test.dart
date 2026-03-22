import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/core/persistence/app_storage_paths.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/infrastructure/persistence/community_social_state_store.dart';

void main() {
  test('persists following usernames across store instances', () {
    final file = File(
      AppStoragePaths.resolve('community_social_state_v1.json'),
    );
    if (file.existsSync()) {
      file.deleteSync();
    }

    final store = CommunitySocialStateStore(seedSessions: [_seedSession()]);
    store.saveFollowingUsernames({'sofi_wind', 'air_lucas'});

    final reloadedStore = CommunitySocialStateStore(
      seedSessions: [_seedSession()],
    );
    final persisted = reloadedStore.getFollowingUsernames();

    expect(persisted, isNotNull);
    expect(persisted, containsAll(<String>['sofi_wind', 'air_lucas']));

    if (file.existsSync()) {
      file.deleteSync();
    }
  });
}

FollowingSession _seedSession() {
  return FollowingSession(
    id: 'seed-session-1',
    username: 'air_lucas',
    title: 'Seed Session',
    spot: 'Tarifa',
    dateLabel: 'Hoy',
    endedAt: DateTime(2026, 3, 3, 18, 0),
    bigAirScore: 100,
    highestJumpMeters: 10.2,
    distanceKm: 12.5,
    durationLabel: '1h 10m',
    equipmentLabel: '12m + twintip',
    likesCount: 15,
    hasSessionPhoto: true,
  );
}
