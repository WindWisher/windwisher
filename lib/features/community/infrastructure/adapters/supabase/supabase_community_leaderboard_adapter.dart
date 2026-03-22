import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';
import 'package:windwisher/features/community/domain/ports/out/community_leaderboard_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCommunityLeaderboardAdapter implements CommunityLeaderboardPort {
  SupabaseCommunityLeaderboardAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final List<CommunityUserSummary> _users = <CommunityUserSummary>[];

  @override
  List<CommunityUserSummary> getUsers() {
    return List<CommunityUserSummary>.unmodifiable(_users);
  }

  @override
  Future<List<CommunityUserSummary>> loadUsers() async {
    final response = await _client
        .from('community_leaderboard')
        .select()
        .order('big_air_score', ascending: false);

    _users
      ..clear()
      ..addAll(
        (response as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(_fromRow),
      );
    return getUsers();
  }

  CommunityUserSummary _fromRow(Map<String, dynamic> row) {
    final username = row['username'] as String? ?? 'unknown';
    return CommunityUserSummary(
      username: username,
      bigAirScore: (row['big_air_score'] as num?)?.toInt() ?? 0,
      highestJumpMeters: (row['highest_jump_meters'] as num?)?.toDouble() ?? 0,
      mainSpot: row['main_spot'] as String? ?? '',
      avatarColorValue: _avatarColorValueForUsername(username),
    );
  }

  int _avatarColorValueForUsername(String username) {
    const palette = <int>[
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
    final seed = username.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return palette[seed % palette.length];
  }
}
