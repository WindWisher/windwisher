import 'package:intl/intl.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/ports/out/community_following_feed_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCommunityFollowingFeedAdapter
    implements CommunityFollowingFeedPort {
  SupabaseCommunityFollowingFeedAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final List<FollowingSession> _sessions = <FollowingSession>[];
  final DateFormat _dateFormat = DateFormat('dd/MM HH:mm');

  @override
  List<FollowingSession> getFollowingSessions() {
    return List<FollowingSession>.unmodifiable(_sessions);
  }

  @override
  Future<List<FollowingSession>> loadFollowingSessions() async {
    if (_client.auth.currentUser == null) {
      _sessions.clear();
      return getFollowingSessions();
    }

    final response = await _client.rpc(
      'get_following_feed',
      params: <String, dynamic>{'limit_count': 100, 'offset_count': 0},
    );

    _sessions
      ..clear()
      ..addAll(
        (response as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(_fromRow),
      );
    return getFollowingSessions();
  }

  FollowingSession _fromRow(Map<String, dynamic> row) {
    final endedAt =
        DateTime.tryParse(row['ended_at'] as String? ?? '') ?? DateTime.now();
    final durationSeconds = (row['duration_seconds'] as num?)?.toInt() ?? 0;

    return FollowingSession(
      id: row['id'] as String? ?? '',
      username: row['username'] as String? ?? 'unknown',
      title: row['title'] as String? ?? 'Sesion',
      spot: row['spot'] as String? ?? '',
      dateLabel: _dateFormat.format(endedAt.toLocal()),
      endedAt: endedAt,
      bigAirScore: (row['big_air_score'] as num?)?.toInt() ?? 0,
      highestJumpMeters: (row['highest_jump_meters'] as num?)?.toDouble() ?? 0,
      distanceKm: (row['distance_km'] as num?)?.toDouble() ?? 0,
      durationLabel: _formatDuration(Duration(seconds: durationSeconds)),
      equipmentLabel: row['equipment_label'] as String? ?? '',
      likesCount: (row['likes_count'] as num?)?.toInt() ?? 0,
      hasSessionPhoto: row['has_session_photo'] as bool? ?? false,
    );
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours.toString().padLeft(2, '0');
    final minutes = (value.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (value.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
