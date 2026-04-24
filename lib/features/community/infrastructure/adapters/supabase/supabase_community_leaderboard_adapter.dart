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
    try {
      final response = await _client
          .from('community_leaderboard')
          .select()
          .order('big_air_score', ascending: false)
          .order('activity_score', ascending: false);

      final rows =
          (response as List<dynamic>).whereType<Map<String, dynamic>>().toList(
            growable: false,
          );
      final profileByHandle = await _loadProfilesByHandles(
        rows
            .map((row) => (row['username'] as String? ?? '').trim())
            .where((handle) => handle.isNotEmpty)
            .toSet()
            .toList(growable: false),
      );

      _users
        ..clear()
        ..addAll(rows.map((row) => _fromRow(row, profileByHandle)));
      return getUsers();
    } catch (_) {
      final fallbackUsers = await _loadUsersFallback();
      _users
        ..clear()
        ..addAll(fallbackUsers);
      return getUsers();
    }
  }

  Future<Map<String, Map<String, dynamic>>> _loadProfilesByHandles(
    List<String> handles,
  ) async {
    final profileByHandle = <String, Map<String, dynamic>>{};
    if (handles.isEmpty) {
      return profileByHandle;
    }
    final profiles = await _client
        .from('public_profiles')
        .select('id, handle, display_name, avatar_path, banner_path')
        .inFilter('handle', handles);
    for (final row in (profiles as List<dynamic>).whereType<Map<String, dynamic>>()) {
      final handle = (row['handle'] as String? ?? '').trim();
      if (handle.isNotEmpty) {
        profileByHandle[handle] = row;
      }
    }
    return profileByHandle;
  }

  Future<List<CommunityUserSummary>> _loadUsersFallback() async {
    final profilesResponse = await _client
        .from('public_profiles')
        .select('id, handle, display_name, avatar_path, banner_path');
    final profileRows =
        (profilesResponse as List<dynamic>).whereType<Map<String, dynamic>>().toList(
          growable: false,
        );
    final profilesById = <String, Map<String, dynamic>>{
      for (final row in profileRows)
        if ((row['id'] as String?)?.isNotEmpty ?? false) row['id'] as String: row,
    };

    final sessionsResponse = await _client
        .from('sessions')
        .select('user_id, big_air_score, highest_jump_m, spot_name')
        .eq('is_public', true);
    final sessionRows =
        (sessionsResponse as List<dynamic>).whereType<Map<String, dynamic>>().toList(
          growable: false,
        );

    final aggregates = <String, _LeaderboardAggregate>{};
    for (final row in sessionRows) {
      final userId = (row['user_id'] as String?)?.trim();
      if (userId == null || userId.isEmpty) {
        continue;
      }
      final aggregate = aggregates.putIfAbsent(userId, _LeaderboardAggregate.new);
      aggregate.add(
        bigAirScore: (row['big_air_score'] as num?)?.toInt() ?? 0,
        highestJumpMeters: (row['highest_jump_m'] as num?)?.toDouble() ?? 0,
        spotName: (row['spot_name'] as String?)?.trim(),
      );
    }

    final users = <CommunityUserSummary>[];
    for (final entry in profilesById.entries) {
      final profile = entry.value;
      final handle = (profile['handle'] as String? ?? '').trim();
      if (handle.isEmpty) {
        continue;
      }
      final aggregate = aggregates[entry.key];
      users.add(
        CommunityUserSummary(
          username: handle,
          bigAirScore: aggregate?.averageBigAirScore.round() ?? 0,
          activityScore: aggregate?.totalBigAirScore ?? 0,
          highestJumpMeters: aggregate?.highestJumpMeters ?? 0,
          mainSpot: aggregate?.mainSpot ?? '',
          avatarColorValue: _avatarColorValueForUsername(handle),
          displayName: (profile['display_name'] as String?)?.trim(),
          handle: _displayHandle(handle),
          avatarPath: (profile['avatar_path'] as String?)?.trim(),
          bannerPath: (profile['banner_path'] as String?)?.trim(),
        ),
      );
    }

    users.sort((a, b) {
      final bigAir = b.bigAirScore.compareTo(a.bigAirScore);
      if (bigAir != 0) {
        return bigAir;
      }
      final activity = b.activityScore.compareTo(a.activityScore);
      if (activity != 0) {
        return activity;
      }
      return a.username.compareTo(b.username);
    });
    return List<CommunityUserSummary>.unmodifiable(users);
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

class _LeaderboardAggregate {
  int totalBigAirScore = 0;
  int publicSessionCount = 0;
  double highestJumpMeters = 0;
  final Map<String, int> _spotCounts = <String, int>{};

  void add({
    required int bigAirScore,
    required double highestJumpMeters,
    required String? spotName,
  }) {
    totalBigAirScore += bigAirScore;
    publicSessionCount += 1;
    if (highestJumpMeters > this.highestJumpMeters) {
      this.highestJumpMeters = highestJumpMeters;
    }
    final normalizedSpot = spotName?.trim();
    if (normalizedSpot != null && normalizedSpot.isNotEmpty) {
      _spotCounts.update(normalizedSpot, (count) => count + 1, ifAbsent: () => 1);
    }
  }

  double get averageBigAirScore =>
      publicSessionCount == 0 ? 0 : totalBigAirScore / publicSessionCount;

  String get mainSpot {
    if (_spotCounts.isEmpty) {
      return '';
    }
    final sortedEntries = _spotCounts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) {
          return byCount;
        }
        return a.key.compareTo(b.key);
      });
    return sortedEntries.first.key;
  }
}
