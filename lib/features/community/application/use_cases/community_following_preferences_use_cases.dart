import 'package:windwisher/features/community/domain/ports/out/community_following_preferences_port.dart';

class GetFollowingUsernamesUseCase {
  const GetFollowingUsernamesUseCase(this._port);

  final CommunityFollowingPreferencesPort _port;

  Set<String>? call() {
    return _port.getFollowingUsernames();
  }

  Future<Set<String>?> load() {
    return _port.loadFollowingUsernames();
  }
}

class SaveFollowingUsernamesUseCase {
  const SaveFollowingUsernamesUseCase(this._port);

  final CommunityFollowingPreferencesPort _port;

  Future<void> call(Set<String> usernames) {
    return _port.saveFollowingUsernames(usernames);
  }
}
