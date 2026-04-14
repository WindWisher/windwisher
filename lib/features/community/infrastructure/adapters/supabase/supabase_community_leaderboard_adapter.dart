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
        .order('big_air_score', ascending: false)
        .order('activity_score', ascending: false);

    final rows = (response as List<dynamic>).whereType<Map<String, dynamic>>().toList(
      growable: false,
    );
    final handles = rows
        .map((row) => (row['username'] as String? ?? '').trim())
        .where((handle) => handle.isNotEmpty)
        .toSet()
        .toList(growable: false);

    final profileByHandle = <String, Map<String, dynamic>>{};
    if (handles.isNotEmpty) {
      final profiles = await _client
          .from('public_profiles')
          .select('handle, display_name, avatar_path, banner_path')
          .inFilter('handle', handles);
      for (final row in (profiles as List<dynamic>).whereType<Map<String, dynamic>>()) {
        final handle = (row['handle'] as String? ?? '').trim();
        if (handle.isNotEmpty) {
          profileByHandle[handle] = row;
        }
      }
    }

    _users
      ..clear()
      ..addAll(rows.map((row) => _fromRow(row, profileByHandle)));
    return getUsers();
  }

  CommunityUserSummary _fromRow(
    Map<String, dynamic> row,
    Map<String, Map<String, dynamic>> profileByHandle,
  ) {
    final username = (row['username'] as String? ?? 'unknown').trim();
    final profile = profileByHandle[username];
    return CommunityUserSummary(
      username: username,
      bigAirScore: (row['big_air_score'] as num?)?.toInt() ?? 0,
      activityScore: (row['activity_score'] as num?)?.toInt() ?? 0,
      highestJumpMeters: (row['highest_jump_meters'] as num?)?.toDouble() ?? 0,
      mainSpot: row['main_spot'] as String? ?? '',
      avatarColorValue: _avatarColorValueForUsername(username),
      displayName: (profile?['display_name'] as String?)?.trim(),
      handle: _displayHandle((profile?['handle'] as String?)?.trim() ?? username),
      avatarPath: (profile?['avatar_path'] as String?)?.trim(),
      bannerPath: (profile?['banner_path'] as String?)?.trim(),
    );
  }

  String _displayHandle(String value) {
    if (value.isEmpty) {
      return '@unknown';
    }
    return value.startsWith('@') ? value : '@$value';
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
