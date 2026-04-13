import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/dialogs/profile_edit_alarm_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/widgets/profile_alarm_item_card.dart';
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
        final activeSpotCount = alarms
            .map((alarm) => alarm.spotKey)
            .where((spotKey) => catalog.isSpotEnabled(spotKey))
            .toSet()
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
                        itemCount: alarms.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final alarm = alarms[index];
                          return ProfileAlarmItemCard(
                            alarm: alarm,
                            onEdit: () =>
                                ProfileEditAlarmDialog.show(context, alarm),
                            onDelete: () async {
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
