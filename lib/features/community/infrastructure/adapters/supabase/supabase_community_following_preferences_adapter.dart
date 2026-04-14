import 'package:windwisher/features/community/domain/ports/out/community_following_preferences_port.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseCommunityFollowingPreferencesAdapter
    implements CommunityFollowingPreferencesPort {
  SupabaseCommunityFollowingPreferencesAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  Set<String>? _cachedFollowingUsernames;
  Set<String>? _cachedFollowerUsernames;

  @override
  Set<String>? getFollowingUsernames() {
    final usernames = _cachedFollowingUsernames;
    return usernames == null ? null : Set<String>.from(usernames);
  }

  @override
  Future<Set<String>?> loadFollowingUsernames() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _cachedFollowingUsernames = null;
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

    _cachedFollowingUsernames = await _loadHandlesForIds(followedIds);
    return getFollowingUsernames();
  }

  @override
  Set<String>? getFollowerUsernames() {
    final usernames = _cachedFollowerUsernames;
    return usernames == null ? null : Set<String>.from(usernames);
  }

  @override
  Future<Set<String>?> loadFollowerUsernames() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      _cachedFollowerUsernames = null;
      return null;
    }

    final followRows = await _client
        .from('user_follows')
        .select('follower_user_id')
        .eq('followed_user_id', user.id);
    final followerIds = (followRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => row['follower_user_id'] as String?)
        .whereType<String>()
        .toList(growable: false);

    _cachedFollowerUsernames = await _loadHandlesForIds(followerIds);
    return getFollowerUsernames();
  }

  @override
  Future<void> saveFollowingUsernames(Set<String> usernames) async {
    if (_client.auth.currentUser == null) {
      _cachedFollowingUsernames = Set<String>.from(usernames);
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
      _cachedFollowingUsernames = wanted;
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

    _cachedFollowingUsernames = wanted;
    await loadFollowerUsernames();
  }

  Future<Set<String>> _loadHandlesForIds(List<String> userIds) async {
    if (userIds.isEmpty) {
      return <String>{};
    }

    final profileRows = await _client
        .from('public_profiles')
        .select('id, handle')
        .inFilter('id', userIds);
    return (profileRows as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((row) => (row['handle'] as String? ?? '').trim())
        .where((handle) => handle.isNotEmpty)
        .toSet();
  }
}
