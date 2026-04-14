import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';
import 'package:windwisher/features/community/domain/ports/out/community_leaderboard_port.dart';

class InMemoryCommunityLeaderboardAdapter implements CommunityLeaderboardPort {
  static const _spots = [
    'Tarifa',
    'Fuerteventura',
    'Gandia',
    'Oliva Norte',
    'El Medano',
  ];
  static const _palette = [
    0xFF1565C0,
    0xFF6A1B9A,
    0xFF2E7D32,
    0xFFEF6C00,
    0xFF00838F,
    0xFF37474F,
    0xFF5D4037,
    0xFFAD1457,
    0xFF283593,
    0xFF00695C,
  ];

  final List<CommunityUserSummary> _users = <CommunityUserSummary>[];

  InMemoryCommunityLeaderboardAdapter() {
    _users.addAll(_buildSeedUsers());
  }

  @override
  List<CommunityUserSummary> getUsers() {
    return List<CommunityUserSummary>.unmodifiable(_users);
  }

  @override
  Future<List<CommunityUserSummary>> loadUsers() async {
    return getUsers();
  }

  List<CommunityUserSummary> _buildSeedUsers() {
    final users = <CommunityUserSummary>[
      const CommunityUserSummary(
        username: 'air_lucas',
        bigAirScore: 987,
        activityScore: 4120,
        highestJumpMeters: 22.4,
        mainSpot: 'Tarifa',
        avatarColorValue: 0xFF1565C0,
        displayName: 'Air Lucas',
        handle: '@air_lucas',
      ),
      const CommunityUserSummary(
        username: 'mara_bigair',
        bigAirScore: 972,
        activityScore: 3980,
        highestJumpMeters: 21.7,
        mainSpot: 'Fuerteventura',
        avatarColorValue: 0xFF6A1B9A,
        displayName: 'Mara Bigair',
        handle: '@mara_bigair',
      ),
      const CommunityUserSummary(
        username: 'nico_loop',
        bigAirScore: 948,
        activityScore: 3760,
        highestJumpMeters: 20.9,
        mainSpot: 'Tarifa',
        avatarColorValue: 0xFF2E7D32,
        displayName: 'Nico Loop',
        handle: '@nico_loop',
      ),
      const CommunityUserSummary(
        username: 'sofi_wind',
        bigAirScore: 931,
        activityScore: 3610,
        highestJumpMeters: 19.8,
        mainSpot: 'Gandia',
        avatarColorValue: 0xFFEF6C00,
        displayName: 'Sofi Wind',
        handle: '@sofi_wind',
      ),
      const CommunityUserSummary(
        username: 'alex_wave',
        bigAirScore: 924,
        activityScore: 3495,
        highestJumpMeters: 19.3,
        mainSpot: 'Oliva Norte',
        avatarColorValue: 0xFF00838F,
        displayName: 'Alex Wave',
        handle: '@alex_wave',
      ),
      const CommunityUserSummary(
        username: 'you_rider',
        bigAirScore: 886,
        activityScore: 2875,
        highestJumpMeters: 16.8,
        mainSpot: 'Tarifa',
        avatarColorValue: 0xFF37474F,
        displayName: 'You Rider',
        handle: '@you_rider',
      ),
      const CommunityUserSummary(
        username: 'javi_foil',
        bigAirScore: 882,
        activityScore: 2810,
        highestJumpMeters: 16.4,
        mainSpot: 'El Medano',
        avatarColorValue: 0xFF5D4037,
        displayName: 'Javi Foil',
        handle: '@javi_foil',
      ),
      const CommunityUserSummary(
        username: 'lucia_jump',
        bigAirScore: 879,
        activityScore: 2760,
        highestJumpMeters: 16.1,
        mainSpot: 'Gandia',
        avatarColorValue: 0xFFAD1457,
        displayName: 'Lucia Jump',
        handle: '@lucia_jump',
      ),
      const CommunityUserSummary(
        username: 'kike_wave',
        bigAirScore: 875,
        activityScore: 2710,
        highestJumpMeters: 15.9,
        mainSpot: 'Tarifa',
        avatarColorValue: 0xFF283593,
        displayName: 'Kike Wave',
        handle: '@kike_wave',
      ),
      const CommunityUserSummary(
        username: 'nora_loop',
        bigAirScore: 871,
        activityScore: 2660,
        highestJumpMeters: 15.7,
        mainSpot: 'Oliva Norte',
        avatarColorValue: 0xFF00695C,
        displayName: 'Nora Loop',
        handle: '@nora_loop',
      ),
    ];

    for (var i = 0; i < 260; i++) {
      final score = 860 - (i * 2);
      final jump = 15.8 - ((i % 37) * 0.06);
      users.add(
        CommunityUserSummary(
          username: 'rider_${i + 1}',
          bigAirScore: score,
          activityScore: score * 4,
          highestJumpMeters: jump < 7.2 ? 7.2 : jump,
          mainSpot: _spots[i % _spots.length],
          avatarColorValue: _palette[i % _palette.length],
          displayName: 'Rider ${i + 1}',
          handle: '@rider_${i + 1}',
        ),
      );
    }
    return users;
  }
}
