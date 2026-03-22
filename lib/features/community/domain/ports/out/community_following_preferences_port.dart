abstract class CommunityFollowingPreferencesPort {
  Set<String>? getFollowingUsernames();

  Future<Set<String>?> loadFollowingUsernames();

  Future<void> saveFollowingUsernames(Set<String> usernames);
}
