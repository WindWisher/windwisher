import 'package:windwisher/features/profile/domain/entities/profile_session_stats_snapshot.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

class ProfileSessionStatsAggregator {
  const ProfileSessionStatsAggregator._();

  static ProfileSessionStatsSnapshot build(Iterable<RecordedSession> sessions) {
    final items = sessions.toList(growable: false);
    if (items.isEmpty) {
      return ProfileSessionStatsSnapshot.empty;
    }

    var totalWaterHours = 0.0;
    var totalJumps = 0;
    var sessionsWithJumps = 0;
    double? highestJumpMeters;
    double? maxHangtimeSeconds;
    double? maxSpeedKnots;
    final activeDays = <String>{};
    final spotCounts = <String, int>{};
    final sessionsByMonth = <String, int>{};
    DateTime? latestRecordAt;
    String? latestRecordLabel;

    for (final session in items) {
      totalWaterHours += session.duration.inSeconds / 3600;
      activeDays.add(_dayKey(session.endedAt));

      final spotName = session.spotName?.trim();
      if (spotName != null && spotName.isNotEmpty) {
        spotCounts.update(spotName, (value) => value + 1, ifAbsent: () => 1);
      }
      final monthKey = _monthKey(session.endedAt);
      sessionsByMonth.update(monthKey, (value) => value + 1, ifAbsent: () => 1);

      final insights = _decodeInsights(session.insights);
      final jumps = insights.resolvedJumpsCount ?? 0;
      totalJumps += jumps;
      if (jumps > 0) {
        sessionsWithJumps += 1;
      }

      final jump = insights.resolvedMaxJumpHeightMeters;
      if (jump != null &&
          (highestJumpMeters == null || jump > highestJumpMeters)) {
        highestJumpMeters = jump;
        latestRecordAt = session.endedAt;
        latestRecordLabel = 'Salto más alto · ${_formatDate(session.endedAt)}';
      }

      final hangtime = insights.resolvedMaxHangtimeSeconds;
      if (hangtime != null &&
          (maxHangtimeSeconds == null || hangtime > maxHangtimeSeconds)) {
        maxHangtimeSeconds = hangtime;
        if (latestRecordAt == null || session.endedAt.isAfter(latestRecordAt)) {
          latestRecordAt = session.endedAt;
          latestRecordLabel = 'Max hangtime · ${_formatDate(session.endedAt)}';
        }
      }

      final speed = insights.resolvedMaxSpeedKnots;
      if (speed != null && (maxSpeedKnots == null || speed > maxSpeedKnots)) {
        maxSpeedKnots = speed;
      }
    }

    final totalSessions = items.length;
    final now = DateTime.now();
    final sessionsThisMonth = items
        .where(
          (session) =>
              session.endedAt.year == now.year &&
              session.endedAt.month == now.month,
        )
        .length;
    final avgSessionHours = totalSessions == 0
        ? 0.0
        : totalWaterHours / totalSessions;
    final avgJumpsPerSession = totalSessions == 0
        ? 0.0
        : totalJumps / totalSessions.toDouble();

    return ProfileSessionStatsSnapshot(
      totalSessions: totalSessions,
      totalWaterHours: totalWaterHours,
      totalJumps: totalJumps,
      activeDays: activeDays.length,
      sessionsWithJumps: sessionsWithJumps,
      highestJumpMeters: highestJumpMeters,
      maxHangtimeSeconds: maxHangtimeSeconds,
      maxSpeedKnots: maxSpeedKnots,
      avgSessionHours: avgSessionHours,
      avgJumpsPerSession: avgJumpsPerSession,
      sessionsThisMonth: sessionsThisMonth,
      mostUsedSpot: _topKeyByCount(spotCounts),
      bestMonthLabel: _topKeyByCount(sessionsByMonth),
      latestRecordLabel: latestRecordLabel,
    );
  }

  static SessionInsightData _decodeInsights(Object raw) {
    if (raw is SessionInsightData) {
      return raw;
    }
    if (raw is Map<String, dynamic>) {
      return SessionInsightData.fromJson(raw);
    }
    return SessionInsightData.empty(deviceKind: 'Dispositivo Android');
  }

  static String _dayKey(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static String _monthKey(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}';

  static String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  static String? _topKeyByCount(Map<String, int> source) {
    if (source.isEmpty) {
      return null;
    }
    final entries = source.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }
}
