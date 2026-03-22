import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/ports/out/community_following_feed_port.dart';

class GetCommunityFollowingSessionsUseCase {
  const GetCommunityFollowingSessionsUseCase(this._port);

  final CommunityFollowingFeedPort _port;

  List<FollowingSession> call() {
    return _port.getFollowingSessions();
  }

  Future<List<FollowingSession>> load() {
    return _port.loadFollowingSessions();
  }
}
