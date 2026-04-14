import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';

class CommunityLeaderboardRowData {
  const CommunityLeaderboardRowData({
    required this.user,
    required this.score,
    required this.metricValue,
  });

  final CommunityUserSummary user;
  final int score;
  final double metricValue;
}

class CommunityOrchestrationService {
  const CommunityOrchestrationService();

  List<CommunityUserSummary> followedUsers({
    required List<CommunityUserSummary> users,
    required Set<String> followingUsernames,
  }) {
    return users
        .where((user) => followingUsernames.contains(user.username))
        .toList(growable: false);
  }

  List<FollowingSession> followingSessions({
    required List<FollowingSession> sessions,
    required Set<String> followingUsernames,
  }) {
    return sessions
        .where((session) => followingUsernames.contains(session.username))
        .toList(growable: false);
  }

  List<CommunityLeaderboardRowData> buildLeaderboardRows({
    required List<CommunityUserSummary> users,
    required Set<String> followingUsernames,
    required String appliedPeriod,
    required String appliedSpot,
    required String appliedScope,
    required String appliedOrder,
    required String appliedOrderUnit,
  }) {
    Iterable<CommunityUserSummary> filtered = users;

    if (appliedScope == 'Friends') {
      filtered = filtered.where(
        (user) => followingUsernames.contains(user.username),
      );
    }
    if (appliedSpot != 'Todos') {
      filtered = filtered.where((user) => user.mainSpot == appliedSpot);
    }

    final rows = filtered
        .map((user) {
          final score = user.bigAirScore;
          final metricValue = _metricSortValue(
            user: user,
            score: score,
            appliedOrder: appliedOrder,
          );
          return CommunityLeaderboardRowData(
            user: user,
            score: score,
            metricValue: metricValue,
          );
        })
        .toList(growable: false);

    rows.sort((a, b) {
      final metricCompare = b.metricValue.compareTo(a.metricValue);
      if (metricCompare != 0) {
        return metricCompare;
      }
      final bigAirCompare = b.user.bigAirScore.compareTo(a.user.bigAirScore);
      if (bigAirCompare != 0) {
        return bigAirCompare;
      }
      final activityCompare = b.user.activityScore.compareTo(a.user.activityScore);
      if (activityCompare != 0) {
        return activityCompare;
      }
      final jumpCompare = b.user.highestJumpMeters.compareTo(a.user.highestJumpMeters);
      if (jumpCompare != 0) {
        return jumpCompare;
      }
      return a.user.username.compareTo(b.user.username);
    });
    return rows;
  }

  String formatMetricValue({required double value, required String unit}) {
    if (unit == 'pts') {
      return '${value.toStringAsFixed(0)} pts';
    }
    return '${value.toStringAsFixed(1)} $unit';
  }

  int rankForUser({
    required List<CommunityLeaderboardRowData> rows,
    required String username,
  }) {
    for (var index = 0; index < rows.length; index++) {
      if (rows[index].user.username == username) {
        return index + 1;
      }
    }
    return -1;
  }

  double _metricSortValue({
    required CommunityUserSummary user,
    required int score,
    required String appliedOrder,
  }) {
    switch (appliedOrder) {
      case 'activity_score':
        return user.activityScore.toDouble();
      case 'big_air_score':
        return score.toDouble();
      case 'salto_mas_alto':
      default:
        return user.highestJumpMeters;
    }
  }
}
