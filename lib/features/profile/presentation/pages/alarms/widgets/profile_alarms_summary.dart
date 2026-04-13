import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/widgets/profile_alarm_summary_tile.dart';

class ProfileAlarmsSummary extends StatelessWidget {
  const ProfileAlarmsSummary({
    super.key,
    required this.total,
    required this.activeSpots,
    required this.withActivity,
  });

  final int total;
  final int activeSpots;
  final int withActivity;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ProfileAlarmSummaryTile(
          label: 'Total',
          value: total.toString(),
          icon: Icons.alarm_rounded,
        ),
        ProfileAlarmSummaryTile(
          label: 'Spots activos',
          value: activeSpots.toString(),
          icon: Icons.place_rounded,
        ),
        ProfileAlarmSummaryTile(
          label: 'Con actividad',
          value: withActivity.toString(),
          icon: Icons.notifications_active_rounded,
        ),
      ],
    );
  }
}
