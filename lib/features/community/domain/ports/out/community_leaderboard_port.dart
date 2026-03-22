import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';

abstract class CommunityLeaderboardPort {
  List<CommunityUserSummary> getUsers();

  Future<List<CommunityUserSummary>> loadUsers();
}
