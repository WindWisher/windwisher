import 'package:windwisher/features/community/domain/ports/out/community_following_preferences_port.dart';
import 'package:windwisher/features/community/infrastructure/persistence/community_social_state_store.dart';

class LocalFileCommunityFollowingPreferencesAdapter
    implements CommunityFollowingPreferencesPort {
  LocalFileCommunityFollowingPreferencesAdapter(this._store);

  final CommunitySocialStateStore _store;

  @override
  Set<String>? getFollowingUsernames() {
    return _store.getFollowingUsernames();
  }

  @override
  Future<Set<String>?> loadFollowingUsernames() async {
    return getFollowingUsernames();
  }

  @override
  Set<String>? getFollowerUsernames() {
    return const <String>{};
  }

  @override
  Future<Set<String>?> loadFollowerUsernames() async {
    return getFollowerUsernames();
  }

  @override
  Future<void> saveFollowingUsernames(Set<String> usernames) async {
    _store.saveFollowingUsernames(usernames);
  }
}
