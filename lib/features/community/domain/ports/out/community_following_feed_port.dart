import 'package:windwisher/features/community/domain/entities/following_session.dart';

abstract class CommunityFollowingFeedPort {
  List<FollowingSession> getFollowingSessions();

  Future<List<FollowingSession>> loadFollowingSessions();
}
