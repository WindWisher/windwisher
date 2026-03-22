import 'package:windwisher/features/community/domain/ports/out/community_following_preferences_port.dart';

class InMemoryCommunityFollowingPreferencesAdapter
    implements CommunityFollowingPreferencesPort {
  Set<String>? _followingUsernames;

  @override
  Set<String>? getFollowingUsernames() {
    final usernames = _followingUsernames;
    return usernames == null ? null : Set<String>.from(usernames);
  }

  @override
  Future<Set<String>?> loadFollowingUsernames() async {
    return getFollowingUsernames();
  }

  @override
  Future<void> saveFollowingUsernames(Set<String> usernames) async {
    _followingUsernames = Set<String>.from(usernames);
  }
}
