import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/widgets/profile_alarm_item_card.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

class ProfileAlarmSpotGroupCard extends StatelessWidget {
  const ProfileAlarmSpotGroupCard({
    super.key,
    required this.spotKey,
    required this.spotName,
    required this.spotArea,
    required this.alarms,
    required this.spotEnabled,
    required this.onSpotToggle,
    required this.onAlarmToggle,
    required this.onEditAlarm,
    required this.onDeleteAlarm,
  });

  final String spotKey;
  final String spotName;
  final String spotArea;
  final List<SpotAlarmRecord> alarms;
  final bool spotEnabled;
  final ValueChanged<bool> onSpotToggle;
  final Future<void> Function(SpotAlarmRecord alarm, bool value) onAlarmToggle;
  final void Function(SpotAlarmRecord alarm) onEditAlarm;
  final Future<void> Function(SpotAlarmRecord alarm) onDeleteAlarm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final enabledAlarmCount = alarms.where((alarm) => alarm.enabled).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
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
                      spotName,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      spotArea,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$enabledAlarmCount de ${alarms.length} alarmas activas',
                      style: textTheme.bodySmall?.copyWith(
                        color: spotEnabled
                            ? const Color(0xFF2E7D32)
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(value: spotEnabled, onChanged: onSpotToggle),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...List.generate(alarms.length, (index) {
            final alarm = alarms[index];
            return Padding(
              padding: EdgeInsets.only(
                top: index == 0 ? 0 : AppSpacing.sm,
              ),
              child: ProfileAlarmItemCard(
                alarm: alarm,
                spotEnabled: spotEnabled,
                onToggle: (value) => onAlarmToggle(alarm, value),
                onEdit: () => onEditAlarm(alarm),
                onDelete: () => onDeleteAlarm(alarm),
              ),
            );
          }),
        ],
      ),
    );
  }
}
