import 'package:windwisher/features/community/domain/ports/out/community_following_preferences_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCommunityFollowingPreferencesAdapter
    implements CommunityFollowingPreferencesPort {
  SupabaseCommunityFollowingPreferencesAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  Set<String>? _cachedUsernames;

  @override
  Set<String>? getFollowingUsernames() {
    final usernames = _cachedUsernames;
    return usernames == null ? null : Set<String>.from(usernames);
  }

  @override
  Future<Set<String>?> loadFollowingUsernames() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _cachedUsernames = null;
      return null;
    }

    final followRows = await _client
        .from('user_follows')
        .select('followed_user_id')
        .eq('follower_user_id', user.id);
    final followedIds = (followRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['followed_user_id'] as String?)
        .whereType<String>()
        .toList(growable: false);

    if (followedIds.isEmpty) {
      _cachedUsernames = <String>{};
      return getFollowingUsernames();
    }

    final profileRows = await _client
        .from('public_profiles')
        .select('id, handle')
        .inFilter('id', followedIds);
    _cachedUsernames = (profileRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => (row['handle'] as String? ?? '').trim())
        .where((handle) => handle.isNotEmpty)
        .toSet();
    return getFollowingUsernames();
  }

  @override
  Future<void> saveFollowingUsernames(Set<String> usernames) async {
    if (_client.auth.currentUser == null) {
      _cachedUsernames = Set<String>.from(usernames);
      return;
    }

    final current = await loadFollowingUsernames() ?? <String>{};
    final wanted = usernames
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toSet();

    final toFollow = wanted.difference(current);
    final toUnfollow = current.difference(wanted);
    final affectedHandles = <String>{...toFollow, ...toUnfollow};
    if (affectedHandles.isEmpty) {
      _cachedUsernames = wanted;
      return;
    }

    final profiles = await _client
        .from('public_profiles')
        .select('id, handle')
        .inFilter('handle', affectedHandles.toList(growable: false));
    final idByHandle = <String, String>{};
    for (final row
        in (profiles as List<dynamic>).whereType<Map<String, dynamic>>()) {
      final handle = (row['handle'] as String? ?? '').trim();
      final id = row['id'] as String?;
      if (handle.isNotEmpty && id != null && id.isNotEmpty) {
        idByHandle[handle] = id;
      }
    }

    for (final handle in toFollow) {
      final targetId = idByHandle[handle];
      if (targetId != null) {
        await _client.rpc(
          'follow_user',
          params: <String, dynamic>{'target_user_id': targetId},
        );
      }
    }
    for (final handle in toUnfollow) {
      final targetId = idByHandle[handle];
      if (targetId != null) {
        await _client.rpc(
          'unfollow_user',
          params: <String, dynamic>{'target_user_id': targetId},
        );
      }
    }

    _cachedUsernames = wanted;
  }
}
