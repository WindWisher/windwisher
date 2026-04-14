abstract class CommunityFollowingPreferencesPort {
  Set<String>? getFollowingUsernames();

  Future<Set<String>?> loadFollowingUsernames();

  Set<String>? getFollowerUsernames();

  Future<Set<String>?> loadFollowerUsernames();

  Future<void> saveFollowingUsernames(Set<String> usernames);
}
