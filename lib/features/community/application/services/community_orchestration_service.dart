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
          final score = _scoreForPeriod(user.bigAirScore, appliedPeriod);
          final metricValue = _metricSortValue(
            user: user,
            score: score,
            appliedOrder: appliedOrder,
            appliedOrderUnit: appliedOrderUnit,
          );
          return CommunityLeaderboardRowData(
            user: user,
            score: score,
            metricValue: metricValue,
          );
        })
        .toList(growable: false);

    rows.sort((a, b) => b.metricValue.compareTo(a.metricValue));
    return rows;
  }

  String formatMetricValue({required double value, required String unit}) {
    if (unit == 'count' || unit == 'count/h') {
      return unit == 'count'
          ? value.toStringAsFixed(0)
          : '${value.toStringAsFixed(1)} $unit';
    }
    if (unit == '%') {
      return '${value.toStringAsFixed(0)} %';
    }
    if (unit == 'min') {
      return '${value.toStringAsFixed(0)} min';
    }
    if (unit == 'pts') {
      return '${value.toStringAsFixed(0)} pts';
    }
    if (unit == 'bin') {
      return value >= 0.5 ? 'si' : 'no';
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

  int _scoreForPeriod(int baseScore, String appliedPeriod) {
    switch (appliedPeriod) {
      case '24h':
        return baseScore - 22;
      case '7d':
        return baseScore;
      case '30d':
        return baseScore - 11;
      case 'All time':
      default:
        return baseScore + 7;
    }
  }

  double _metricSortValue({
    required CommunityUserSummary user,
    required int score,
    required String appliedOrder,
    required String appliedOrderUnit,
  }) {
    final seed = _userSeed(user);
    switch (appliedOrder) {
      case 'big_air_score':
        return score.toDouble();
      case 'salto_mas_alto':
        return user.highestJumpMeters;
      case 'numero_saltos':
        return 18 + (seed % 110);
      case 'hangtime_max':
        return (user.highestJumpMeters * 0.43) + ((seed % 9) * 0.05);
      case 'velocidad_max':
        return 21 + (seed % 160) / 10;
      case 'viento_medio':
        return 14 + (seed % 90) / 10;
      case 'distancia_total':
        return 6 + (seed % 190) / 10;
      case 'duracion_total':
        return 35 + (seed % 160);
      case 'consistencia_alturas':
        return 60 + (seed % 40);
      case 'vmg_upwind':
        return 10 + (seed % 90) / 10;
      case 'vmg_downwind':
        return 12 + (seed % 105) / 10;
      case 'lluvia':
        return seed % 2 == 0 ? 1 : 0;
      default:
        return _defaultMetricValueForUnit(appliedOrderUnit, seed, score);
    }
  }

  double _defaultMetricValueForUnit(String unit, int seed, int score) {
    if (unit == '%') {
      return 50 + (seed % 50);
    }
    if (unit == 'kt') {
      return 10 + (seed % 220) / 10;
    }
    if (unit == 'km' || unit == 'km2') {
      return 1 + (seed % 180) / 10;
    }
    if (unit == 's') {
      return 1 + (seed % 120) / 10;
    }
    if (unit == 'min') {
      return 20 + (seed % 190);
    }
    if (unit == 'deg') {
      return (seed % 360).toDouble();
    }
    if (unit == '/10') {
      return 4 + (seed % 60) / 10;
    }
    if (unit == 'x') {
      return 1 + (seed % 35) / 10;
    }
    if (unit == 'hPa') {
      return 1000 + (seed % 40);
    }
    if (unit == 'C') {
      return 10 + (seed % 25);
    }
    if (unit == 'count') {
      return 1 + (seed % 200);
    }
    return score.toDouble();
  }

  int _userSeed(CommunityUserSummary user) {
    return user.username.codeUnits.fold(0, (sum, codeUnit) => sum + codeUnit);
  }
}
