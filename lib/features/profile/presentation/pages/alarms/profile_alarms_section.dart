import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/dialogs/profile_edit_alarm_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/widgets/profile_alarm_spot_group_card.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/widgets/profile_alarms_empty_state.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/widgets/profile_alarms_header.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/widgets/profile_alarms_summary.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/widgets/profile_alarms_sync_warning.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

class ProfileAlarmsSection extends StatelessWidget {
  const ProfileAlarmsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SpotAlarmCatalog.instance,
      builder: (context, _) {
        final catalog = SpotAlarmCatalog.instance;
        final alarms = catalog.alarms;
        final groupedAlarms = <String, List<SpotAlarmRecord>>{};
        for (final alarm in alarms) {
          groupedAlarms.putIfAbsent(alarm.spotKey, () => <SpotAlarmRecord>[]).add(alarm);
        }
        final sortedSpotKeys = groupedAlarms.keys.toList(growable: false)
          ..sort((left, right) {
            final leftAlarm = groupedAlarms[left]!.first;
            final rightAlarm = groupedAlarms[right]!.first;
            final byArea = leftAlarm.spotArea.compareTo(rightAlarm.spotArea);
            if (byArea != 0) {
              return byArea;
            }
            return leftAlarm.spotName.compareTo(rightAlarm.spotName);
          });
        final activeSpotCount = sortedSpotKeys
            .where((spotKey) => catalog.isSpotEnabled(spotKey))
            .length;
        final triggeredCount = alarms
            .where(
              (alarm) =>
                  alarm.triggerCount > 0 || alarm.lastTriggeredAt != null,
            )
            .length;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProfileAlarmsHeader(
                  globalEnabled: catalog.globalEnabled,
                  onChanged: (value) async {
                    await catalog.setGlobalEnabled(value);
                    if (!context.mounted || catalog.lastSyncError == null) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'No se pudo sincronizar el estado global de alarmas: ${catalog.lastSyncError}',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                ProfileAlarmsSummary(
                  total: alarms.length,
                  activeSpots: activeSpotCount,
                  withActivity: triggeredCount,
                ),
                if (catalog.lastSyncError != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ProfileAlarmsSyncWarning(message: catalog.lastSyncError!),
                ],
                const SizedBox(height: AppSpacing.sm),
                if (alarms.isEmpty)
                  const ProfileAlarmsEmptyState()
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 420),
                    child: ScrollConfiguration(
                      behavior: const MaterialScrollBehavior().copyWith(
                        overscroll: false,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: sortedSpotKeys.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final spotKey = sortedSpotKeys[index];
                          final spotAlarms = groupedAlarms[spotKey]!;
                          final leadAlarm = spotAlarms.first;
                          return ProfileAlarmSpotGroupCard(
                            spotKey: spotKey,
                            spotName: leadAlarm.spotName,
                            spotArea: leadAlarm.spotArea,
                            alarms: spotAlarms,
                            spotEnabled: catalog.isSpotEnabled(spotKey),
                            onSpotToggle: (value) async {
                              await catalog.setSpotEnabled(spotKey, value);
                              if (!context.mounted || catalog.lastSyncError == null) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'No se pudo sincronizar el estado del spot: ${catalog.lastSyncError}',
                                  ),
                                ),
                              );
                            },
                            onAlarmToggle: (alarm, value) async {
                              await catalog.setAlarmEnabled(alarm.id, value);
                              if (!context.mounted || catalog.lastSyncError == null) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'No se pudo sincronizar el estado de la alarma: ${catalog.lastSyncError}',
                                  ),
                                ),
                              );
                            },
                            onEditAlarm: (alarm) =>
                                ProfileEditAlarmDialog.show(context, alarm),
                            onDeleteAlarm: (alarm) async {
                              final confirmed = await confirmDeleteAlarm(
                                context,
                                alarm,
                              );
                              if (!confirmed) {
                                return;
                              }
                              final deleted = await catalog.deleteAlarm(
                                alarm.id,
                              );
                              if (!context.mounted ||
                                  deleted ||
                                  catalog.lastSyncError == null) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'La alarma se elimino localmente, pero no se pudo sincronizar: ${catalog.lastSyncError}',
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
