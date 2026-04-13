import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

class ProfileAlarmItemCard extends StatelessWidget {
  const ProfileAlarmItemCard({
    super.key,
    required this.alarm,
    required this.onEdit,
    required this.onDelete,
  });

  final SpotAlarmRecord alarm;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final catalog = SpotAlarmCatalog.instance;
    final spotEnabled = catalog.isSpotEnabled(alarm.spotKey);
    final spotColor = spotEnabled
        ? const Color(0xFF2E7D32)
        : colorScheme.onSurfaceVariant;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.spotName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.stationName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar alarma',
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: 'Eliminar alarma',
                    onPressed: () => onDelete(),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: spotColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  spotEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_rounded,
                  size: 16,
                  color: spotColor,
                ),
                const SizedBox(width: 6),
                Text(
                  spotEnabled ? 'Spot activo' : 'Spot desactivado',
                  style: textTheme.bodySmall?.copyWith(
                    color: spotColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _ProfileAlarmMetaChip(
                icon: Icons.air_rounded,
                label:
                    '${alarm.windRange.start.round()}-${alarm.windRange.end.round()} kt',
              ),
              _ProfileAlarmMetaChip(
                icon: Icons.schedule_rounded,
                label:
                    '${formatAlarmTime(alarm.startHour, alarm.startMinute)}-${formatAlarmTime(alarm.endHour, alarm.endMinute)}',
              ),
              _ProfileAlarmMetaChip(
                icon: Icons.navigation_rounded,
                label: alarm.directions.join('/'),
              ),
              _ProfileAlarmMetaChip(
                icon: Icons.repeat_rounded,
                label: alarmRepeatWindowLabel(alarm.repeatWindow),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAlarmMetaChip extends StatelessWidget {
  const _ProfileAlarmMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

String formatAlarmTime(int hour, int minute) {
  final normalizedHour = hour.clamp(0, 23);
  final normalizedMinute = minute.clamp(0, 59);
  final hourLabel = normalizedHour.toString().padLeft(2, '0');
  final minuteLabel = normalizedMinute.toString().padLeft(2, '0');
  return '$hourLabel:$minuteLabel';
}

String alarmRepeatWindowLabel(AlarmRepeatWindow repeatWindow) {
  return switch (repeatWindow) {
    AlarmRepeatWindow.min1 => 'Cada 1 min',
    AlarmRepeatWindow.min5 => 'Cada 5 min',
    AlarmRepeatWindow.min10 => 'Cada 10 min',
    AlarmRepeatWindow.min15 => 'Cada 15 min',
    AlarmRepeatWindow.min30 => 'Cada 30 min',
  };
}
