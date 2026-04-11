import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

class ProfileSessionStatsSnapshot {
  const ProfileSessionStatsSnapshot({
    required this.totalSessions,
    required this.totalWaterHours,
    required this.totalJumps,
    required this.activeDays,
    required this.sessionsWithJumps,
    required this.highestJumpMeters,
    required this.maxHangtimeSeconds,
    required this.maxSpeedKnots,
    required this.avgSessionHours,
    required this.avgJumpsPerSession,
    required this.sessionsThisMonth,
    required this.mostUsedSpot,
    required this.bestMonthLabel,
    required this.latestRecordLabel,
  });

  final int totalSessions;
  final double totalWaterHours;
  final int totalJumps;
  final int activeDays;
  final int sessionsWithJumps;
  final double? highestJumpMeters;
  final double? maxHangtimeSeconds;
  final double? maxSpeedKnots;
  final double avgSessionHours;
  final double avgJumpsPerSession;
  final int sessionsThisMonth;
  final String? mostUsedSpot;
  final String? bestMonthLabel;
  final String? latestRecordLabel;

  static const empty = ProfileSessionStatsSnapshot(
    totalSessions: 0,
    totalWaterHours: 0,
    totalJumps: 0,
    activeDays: 0,
    sessionsWithJumps: 0,
    highestJumpMeters: null,
    maxHangtimeSeconds: null,
    maxSpeedKnots: null,
    avgSessionHours: 0,
    avgJumpsPerSession: 0,
    sessionsThisMonth: 0,
    mostUsedSpot: null,
    bestMonthLabel: null,
    latestRecordLabel: null,
  );

  factory ProfileSessionStatsSnapshot.fromLegacyProfile(
    UserProfileData profile,
  ) {
    final totalSessions = _parseInt(profile.totalSessions);
    final totalWaterHours = _parseDouble(profile.waterHours);
    final totalJumps = _parseInt(profile.jumps);
    final highestJumpMeters = _parseNullableDouble(profile.topJump);
    final maxHangtimeSeconds = _parseNullableDouble(profile.maxHangtime);
    return ProfileSessionStatsSnapshot(
      totalSessions: totalSessions,
      totalWaterHours: totalWaterHours,
      totalJumps: totalJumps,
      activeDays: 0,
      sessionsWithJumps: 0,
      highestJumpMeters: highestJumpMeters,
      maxHangtimeSeconds: maxHangtimeSeconds,
      maxSpeedKnots: null,
      avgSessionHours: totalSessions == 0 ? 0 : totalWaterHours / totalSessions,
      avgJumpsPerSession: totalSessions == 0 ? 0 : totalJumps / totalSessions,
      sessionsThisMonth: 0,
      mostUsedSpot: null,
      bestMonthLabel: null,
      latestRecordLabel: null,
    );
  }

  String get totalSessionsLabel => '$totalSessions';

  String get waterHoursLabel {
    final numeric = totalWaterHours;
    return '${numeric.toStringAsFixed(numeric.truncateToDouble() == numeric ? 0 : 1)}h';
  }

  String get totalJumpsLabel => '$totalJumps';

  String get highestJumpLabel => highestJumpMeters == null
      ? '--'
      : '${highestJumpMeters!.toStringAsFixed(1)}m';

  String get maxHangtimeLabel => maxHangtimeSeconds == null
      ? '--'
      : '${maxHangtimeSeconds!.toStringAsFixed(1)}s';

  String get maxSpeedLabel =>
      maxSpeedKnots == null ? '--' : '${maxSpeedKnots!.toStringAsFixed(1)} kt';

  String get avgSessionHoursLabel => '${avgSessionHours.toStringAsFixed(1)}h';

  String get avgJumpsPerSessionLabel => avgJumpsPerSession.toStringAsFixed(1);

  String get activeDaysLabel => '$activeDays';

  String get sessionsThisMonthLabel => '$sessionsThisMonth';

  String get sessionsWithJumpsPercentLabel {
    if (totalSessions == 0) {
      return '--%';
    }
    final percent = (sessionsWithJumps / totalSessions) * 100;
    return '${percent.toStringAsFixed(0)}%';
  }

  static int _parseInt(String raw) {
    return int.tryParse(raw.replaceAll(RegExp(r'[^0-9-]'), '')) ?? 0;
  }

  static double _parseDouble(String raw) {
    final normalized = raw.replaceAll(',', '.');
    final match = RegExp(r'-?[0-9]+(?:\.[0-9]+)?').firstMatch(normalized);
    return double.tryParse(match?.group(0) ?? '') ?? 0;
  }

  static double? _parseNullableDouble(String raw) {
    final value = _parseDouble(raw);
    return value == 0 ? null : value;
  }
}
