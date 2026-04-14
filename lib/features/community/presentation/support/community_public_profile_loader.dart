import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/features/community/presentation/support/community_identity_mapper.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

class CommunityPublicProfileLoader {
  CommunityPublicProfileLoader({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<UserProfileData?> loadByUsername(String username) async {
    final normalizedHandle = CommunityIdentityMapper.normalizedUsername(
      username,
    );
    final row = await _selectProfileRow(normalizedHandle);
    if (row == null) {
      return null;
    }
    return _mapProfile(row, normalizedHandle);
  }

  Future<Map<String, dynamic>?> _selectProfileRow(String normalizedHandle) async {
    const columns = <String>[
      'display_name',
      'handle',
      'public_tagline',
      'total_sessions',
      'water_hours',
      'jumps',
      'top_jump_m',
      'avatar_path',
      'banner_path',
    ];

    for (var length = columns.length; length >= 3; length--) {
      final select = columns.take(length).join(',');
      try {
        final row = await _client
            .from('public_profiles')
            .select(select)
            .ilike('handle', normalizedHandle)
            .maybeSingle();
        return row;
      } catch (_) {
        continue;
      }
    }

    final fallback = await _client
        .from('public_profiles')
        .select('display_name, handle, avatar_path')
        .ilike('handle', normalizedHandle)
        .maybeSingle();
    return fallback;
  }

  UserProfileData _mapProfile(Map<String, dynamic> row, String normalizedHandle) {
    return UserProfileData(
      displayName:
          ((row['display_name'] as String?)?.trim().isNotEmpty ?? false)
          ? (row['display_name'] as String).trim()
          : CommunityIdentityMapper.displayNameFromUsername(normalizedHandle),
      handle: _displayHandle((row['handle'] as String?) ?? normalizedHandle),
      publicTagline: (row['public_tagline'] as String?) ?? '',
      totalSessions: ((row['total_sessions'] as num?)?.toInt() ?? 0).toString(),
      waterHours: _formatHours(row['water_hours']),
      jumps: ((row['jumps'] as num?)?.toInt() ?? 0).toString(),
      topJump: _formatMeters(row['top_jump_m']),
      maxHangtime: '--',
      avatarLocalPath: row['avatar_path'] as String?,
      bannerLocalPath: row['banner_path'] as String?,
    );
  }

  String _displayHandle(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return '@';
    }
    return trimmed.startsWith('@') ? trimmed : '@$trimmed';
  }

  String _formatHours(dynamic value) {
    final numeric = (value as num?)?.toDouble();
    if (numeric == null) {
      return '0h';
    }
    if (numeric % 1 == 0) {
      return '${numeric.toInt()}h';
    }
    return '${numeric.toStringAsFixed(1)}h';
  }

  String _formatMeters(dynamic value) {
    final numeric = (value as num?)?.toDouble();
    if (numeric == null) {
      return '0.0m';
    }
    return '${numeric.toStringAsFixed(1)}m';
  }
}
