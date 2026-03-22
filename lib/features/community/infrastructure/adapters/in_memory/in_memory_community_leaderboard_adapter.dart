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
        highestJumpMeters: 22.4,
        mainSpot: 'Tarifa',
        avatarColorValue: 0xFF1565C0,
      ),
      const CommunityUserSummary(
        username: 'mara_bigair',
        bigAirScore: 972,
        highestJumpMeters: 21.7,
        mainSpot: 'Fuerteventura',
        avatarColorValue: 0xFF6A1B9A,
      ),
      const CommunityUserSummary(
        username: 'nico_loop',
        bigAirScore: 948,
        highestJumpMeters: 20.9,
        mainSpot: 'Tarifa',
        avatarColorValue: 0xFF2E7D32,
      ),
      const CommunityUserSummary(
        username: 'sofi_wind',
        bigAirScore: 931,
        highestJumpMeters: 19.8,
        mainSpot: 'Gandia',
        avatarColorValue: 0xFFEF6C00,
      ),
      const CommunityUserSummary(
        username: 'alex_wave',
        bigAirScore: 924,
        highestJumpMeters: 19.3,
        mainSpot: 'Oliva Norte',
        avatarColorValue: 0xFF00838F,
      ),
      const CommunityUserSummary(
        username: 'you_rider',
        bigAirScore: 886,
        highestJumpMeters: 16.8,
        mainSpot: 'Tarifa',
        avatarColorValue: 0xFF37474F,
      ),
      const CommunityUserSummary(
        username: 'javi_foil',
        bigAirScore: 882,
        highestJumpMeters: 16.4,
        mainSpot: 'El Medano',
        avatarColorValue: 0xFF5D4037,
      ),
      const CommunityUserSummary(
        username: 'lucia_jump',
        bigAirScore: 879,
        highestJumpMeters: 16.1,
        mainSpot: 'Gandia',
        avatarColorValue: 0xFFAD1457,
      ),
      const CommunityUserSummary(
        username: 'kike_wave',
        bigAirScore: 875,
        highestJumpMeters: 15.9,
        mainSpot: 'Tarifa',
        avatarColorValue: 0xFF283593,
      ),
      const CommunityUserSummary(
        username: 'nora_loop',
        bigAirScore: 871,
        highestJumpMeters: 15.7,
        mainSpot: 'Oliva Norte',
        avatarColorValue: 0xFF00695C,
      ),
    ];

    for (var i = 0; i < 260; i++) {
      final score = 860 - (i * 2);
      final jump = 15.8 - ((i % 37) * 0.06);
      users.add(
        CommunityUserSummary(
          username: 'rider_${i + 1}',
          bigAirScore: score,
          highestJumpMeters: jump < 7.2 ? 7.2 : jump,
          mainSpot: _spots[i % _spots.length],
          avatarColorValue: _palette[i % _palette.length],
        ),
      );
    }
    return users;
  }
}
