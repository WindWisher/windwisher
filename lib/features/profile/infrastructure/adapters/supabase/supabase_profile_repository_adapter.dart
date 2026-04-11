import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_repository_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileRepositoryAdapter implements ProfileRepositoryPort {
  SupabaseProfileRepositoryAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  UserProfileData _profile = UserProfileData.initial();

  @override
  UserProfileData getProfile() {
    return _profile;
  }

  @override
  Future<UserProfileData> loadProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _profile = UserProfileData.initial();
      return _profile;
    }

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      _profile = UserProfileData.initial().copyWith(
        displayName: user.email?.split('@').first ?? 'Rider',
        handle: '@${user.email?.split('@').first ?? 'rider'}',
      );
      return _profile;
    }

    _profile = _mapProfile(response);
    return _profile;
  }

  @override
  Future<void> saveProfile(UserProfileData value) async {
    _profile = value;
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    await _client.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'display_name': value.displayName,
      'handle': _normalizeHandle(value.handle),
      'public_tagline': value.publicTagline,
      'bio': value.bio,
      'user_role': value.userRole,
      'level': value.userRole,
      'base_spot': value.baseSpot,
      'avatar_path': value.avatarLocalPath,
      'banner_path': value.bannerLocalPath,
      'total_sessions': _parseInt(value.totalSessions),
      'water_hours': _parseNumericLabel(value.waterHours),
      'jumps': _parseInt(value.jumps),
      'top_jump_m': _parseNumericLabel(value.topJump),
      'best_spot': value.bestSpot,
      'latest_session_label': value.latestSession,
      'latest_comment_label': value.latestComment,
      'featured_thread_label': value.featuredThread,
      'ranking_label': value.ranking,
    });
  }

  UserProfileData _mapProfile(Map<String, dynamic> row) {
    return UserProfileData(
      displayName: (row['display_name'] as String?) ?? '',
      handle: _displayHandle((row['handle'] as String?) ?? ''),
      publicTagline: (row['public_tagline'] as String?) ?? '',
      bio: (row['bio'] as String?) ?? '',
      userRole: (row['user_role'] as String? ?? row['level'] as String?) ?? '',
      sessions: ((row['total_sessions'] as num?)?.toInt() ?? 0).toString(),
      followers: ((row['followers_count'] as num?)?.toInt() ?? 0).toString(),
      following: ((row['following_count'] as num?)?.toInt() ?? 0).toString(),
      ranking: (row['ranking_label'] as String?) ?? '',
      baseSpot: (row['base_spot'] as String?) ?? '',
      totalSessions: ((row['total_sessions'] as num?)?.toInt() ?? 0).toString(),
      waterHours: _formatHours(row['water_hours']),
      jumps: ((row['jumps'] as num?)?.toInt() ?? 0).toString(),
      topJump: _formatMeters(row['top_jump_m']),
      maxHangtime: _formatSeconds(row['hangtime_max_s'] ?? row['hangtime_max']),
      bestSpot: (row['best_spot'] as String?) ?? '',
      latestSession: (row['latest_session_label'] as String?) ?? '',
      latestComment: (row['latest_comment_label'] as String?) ?? '',
      featuredThread: (row['featured_thread_label'] as String?) ?? '',
      avatarLocalPath: row['avatar_path'] as String?,
      bannerLocalPath: row['banner_path'] as String?,
    );
  }

  int _parseInt(String raw) {
    return int.tryParse(raw.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
  }

  double _parseNumericLabel(String raw) {
    final normalized = raw.replaceAll(',', '.');
    final match = RegExp(r'-?[0-9]+(?:\.[0-9]+)?').firstMatch(normalized);
    return double.tryParse(match?.group(0) ?? '') ?? 0;
  }

  String _formatHours(Object? value) {
    final numeric = (value as num?)?.toDouble() ?? 0;
    return '${numeric.toStringAsFixed(numeric.truncateToDouble() == numeric ? 0 : 1)}h';
  }

  String _formatMeters(Object? value) {
    final numeric = (value as num?)?.toDouble() ?? 0;
    return '${numeric.toStringAsFixed(1)}m';
  }

  String _formatSeconds(Object? value) {
    final numeric = (value as num?)?.toDouble() ?? 0;
    return '${numeric.toStringAsFixed(1)}s';
  }

  String _normalizeHandle(String value) {
    final trimmed = value.trim().replaceFirst('@', '');
    return trimmed.isEmpty ? 'rider' : trimmed;
  }

  String _displayHandle(String value) {
    if (value.isEmpty) {
      return '@rider';
    }
    return value.startsWith('@') ? value : '@$value';
  }
}
