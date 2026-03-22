import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';
import 'package:windwisher/features/community/domain/ports/out/community_leaderboard_port.dart';

class GetCommunityUsersUseCase {
  const GetCommunityUsersUseCase(this._port);

  final CommunityLeaderboardPort _port;

  List<CommunityUserSummary> call() {
    return _port.getUsers();
  }

  Future<List<CommunityUserSummary>> load() {
    return _port.loadUsers();
  }
}
