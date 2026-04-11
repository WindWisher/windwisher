import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_session_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_aux_pages.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/stats/kpi/profile_stats_details_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/summary/profile_public_preview_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/summary/followers_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/summary/following_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/summary/profile_connections_dialog_shell.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/stats/profile_summary_overview_card.dart';
import 'package:windwisher/features/profile/presentation/pages/widgets/profile/profile_summary_card.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

class ProfileOverviewSection extends StatelessWidget {
  const ProfileOverviewSection({
    super.key,
    required this.profile,
    required this.stats,
    required this.onProfileUpdated,
  });

  final UserProfileData profile;
  final ProfileSessionStatsSnapshot stats;
  final ValueChanged<UserProfileData> onProfileUpdated;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey('perfil'),
      children: [
        ProfileSummaryCard(
          profile: profile,
          stats: stats,
          onPublicPreviewPressed: () => _openPublicProfilePreview(context),
          onEditPressed: () => _openEditProfile(context),
          onFollowersPressed: () => _openFollowers(context),
          onFollowingPressed: () => _openFollowing(context),
        ),
        const SizedBox(height: AppSpacing.md),
        ProfileSummaryOverviewCard(
          profile: profile,
          stats: stats,
          onDetailsPressed: () => _openProfileStatsDetails(context),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Actividad reciente', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _StatRow(
                  label: 'Ultima sesion subida',
                  value: profile.latestSession,
                ),
                _StatRow(
                  label: 'Ultimo comentario',
                  value: profile.latestComment,
                ),
                _StatRow(
                  label: 'Hilo destacado',
                  value: profile.featuredThread,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openFollowers(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => FollowersDialog(
        profile: profile,
        behavior: ProfileConnectionsBehavior.followersManage,
      ),
    );
  }

  Future<void> _openFollowing(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => FollowingDialog(
        profile: profile,
        behavior: ProfileConnectionsBehavior.followingManage,
      ),
    );
  }

  // Kept temporarily to preserve the alarm editing helpers while alarms live in their own tab.
  // ignore: unused_element
  Widget _buildAlarmCard(BuildContext context, TextTheme textTheme) {
    return AnimatedBuilder(
      animation: SpotAlarmCatalog.instance,
      builder: (context, _) {
        final catalog = SpotAlarmCatalog.instance;
        final alarms = catalog.alarms;
        final colorScheme = Theme.of(context).colorScheme;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withValues(alpha: 0.72),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.alarm_add_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Alarmas',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              catalog.globalEnabled
                                  ? 'Alarmas globales activas'
                                  : 'Alarmas globales desactivadas',
                              style: textTheme.bodySmall?.copyWith(
                                color: catalog.globalEnabled
                                    ? const Color(0xFF2E7D32)
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: catalog.globalEnabled,
                        onChanged: (value) async {
                          await catalog.setGlobalEnabled(value);
                          if (!context.mounted ||
                              catalog.lastSyncError == null) {
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
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                if (alarms.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.35,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.45,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_none_rounded,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Todavia no hay alarmas guardadas.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
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
                          return _buildProfileAlarmItem(
                            context,
                            textTheme,
                            catalog,
                            alarm,
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

  Widget _buildProfileAlarmItem(
    BuildContext context,
    TextTheme textTheme,
    SpotAlarmCatalog catalog,
    SpotAlarmRecord alarm,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
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
                    onPressed: () => _showEditAlarmDialog(context, alarm),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: 'Eliminar alarma',
                    onPressed: () async {
                      final confirmed = await _confirmDeleteAlarm(
                        context,
                        alarm,
                      );
                      if (!confirmed) {
                        return;
                      }
                      final deleted = await catalog.deleteAlarm(alarm.id);
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
                    '${_formatAlarmTime(alarm.startHour, alarm.startMinute)}-${_formatAlarmTime(alarm.endHour, alarm.endMinute)}',
              ),
              _ProfileAlarmMetaChip(
                icon: Icons.navigation_rounded,
                label: alarm.directions.join('/'),
              ),
              _ProfileAlarmMetaChip(
                icon: Icons.repeat_rounded,
                label: _alarmRepeatWindowLabel(alarm.repeatWindow),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final updated = await Navigator.of(context).push<UserProfileData>(
      MaterialPageRoute(builder: (_) => EditProfilePage(initialData: profile)),
    );
    if (updated == null || !context.mounted) {
      return;
    }
    onProfileUpdated(updated);
  }

  Future<void> _openPublicProfilePreview(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ProfilePublicPreviewDialog(profile: profile),
    );
  }

  Future<void> _openProfileStatsDetails(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ProfileStatsDetailsDialog(profile: profile, stats: stats),
    );
  }

  Future<void> _showEditAlarmDialog(
    BuildContext context,
    SpotAlarmRecord alarm,
  ) async {
    final catalog = SpotAlarmCatalog.instance;
    RangeValues windRange = alarm.windRange;
    int startHour = _sanitizeAlarmHour(alarm.startHour);
    int endHour = _sanitizeAlarmHour(alarm.endHour);
    int startMinute = _sanitizeAlarmMinute(alarm.startMinute);
    int endMinute = _sanitizeAlarmMinute(alarm.endMinute);
    Set<String> directions = <String>{...alarm.directions};
    AlarmRepeatWindow repeatWindow = alarm.repeatWindow;
    String? errorText;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final colorScheme = Theme.of(dialogContext).colorScheme;
            return AlertDialog(
              title: const Text('Editar alarma'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alarm.spotName} - ${alarm.stationName}',
                      style: Theme.of(dialogContext).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Rango de viento · ${windRange.start.round()} - ${windRange.end.round()} kt',
                    ),
                    RangeSlider(
                      min: 4,
                      max: 40,
                      divisions: 36,
                      values: windRange,
                      labels: RangeLabels(
                        '${windRange.start.round()} kt',
                        '${windRange.end.round()} kt',
                      ),
                      onChanged: (values) {
                        setDialogState(() {
                          windRange = values;
                        });
                      },
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: TimeOfDay(
                                  hour: startHour,
                                  minute: startMinute,
                                ),
                              );
                              if (picked == null) {
                                return;
                              }
                              setDialogState(() {
                                startHour = picked.hour;
                                startMinute = picked.minute;
                              });
                            },
                            icon: const Icon(Icons.schedule_rounded),
                            label: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Desde'),
                                Text(_formatAlarmTime(startHour, startMinute)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final picked = await showTimePicker(
                                context: dialogContext,
                                initialTime: TimeOfDay(
                                  hour: endHour,
                                  minute: endMinute,
                                ),
                              );
                              if (picked == null) {
                                return;
                              }
                              setDialogState(() {
                                endHour = picked.hour;
                                endMinute = picked.minute;
                              });
                            },
                            icon: const Icon(Icons.schedule_rounded),
                            label: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Hasta'),
                                Text(_formatAlarmTime(endHour, endMinute)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    FilterChip(
                      label: const Text('Todas'),
                      selected:
                          directions.length ==
                          _profileAlarmDirectionOptions.length,
                      showCheckmark: false,
                      onSelected: (_) {
                        setDialogState(() {
                          final allSelected =
                              directions.length ==
                              _profileAlarmDirectionOptions.length;
                          directions = allSelected
                              ? <String>{}
                              : _profileAlarmDirectionOptions.toSet();
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Column(
                      children: [
                        _buildProfileAlarmDirectionRow(
                          row: _profileAlarmDirectionOptions.sublist(0, 4),
                          directions: directions,
                          colorScheme: colorScheme,
                          onToggleDirection: (direction, value) {
                            setDialogState(() {
                              if (value) {
                                directions = <String>{...directions, direction};
                              } else {
                                directions = directions
                                    .where((entry) => entry != direction)
                                    .toSet();
                              }
                            });
                          },
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        _buildProfileAlarmDirectionRow(
                          row: _profileAlarmDirectionOptions.sublist(4, 8),
                          directions: directions,
                          colorScheme: colorScheme,
                          onToggleDirection: (direction, value) {
                            setDialogState(() {
                              if (value) {
                                directions = <String>{...directions, direction};
                              } else {
                                directions = directions
                                    .where((entry) => entry != direction)
                                    .toSet();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<AlarmRepeatWindow>(
                      initialValue: repeatWindow,
                      decoration: const InputDecoration(
                        labelText: 'Repetir cada',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: AlarmRepeatWindow.min1,
                          child: Text('1 min'),
                        ),
                        DropdownMenuItem(
                          value: AlarmRepeatWindow.min5,
                          child: Text('5 min'),
                        ),
                        DropdownMenuItem(
                          value: AlarmRepeatWindow.min10,
                          child: Text('10 min'),
                        ),
                        DropdownMenuItem(
                          value: AlarmRepeatWindow.min15,
                          child: Text('15 min'),
                        ),
                        DropdownMenuItem(
                          value: AlarmRepeatWindow.min30,
                          child: Text('30 min'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() {
                          repeatWindow = value;
                        });
                      },
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        errorText!,
                        style: Theme.of(dialogContext).textTheme.bodySmall
                            ?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton.icon(
                  onPressed: () async {
                    if (directions.isEmpty) {
                      setDialogState(() {
                        errorText =
                            'Selecciona al menos una direccion para la alarma.';
                      });
                      return;
                    }
                    final updated = SpotAlarmRecord(
                      id: alarm.id,
                      spotKey: alarm.spotKey,
                      spotName: alarm.spotName,
                      spotArea: alarm.spotArea,
                      stationProvider: alarm.stationProvider,
                      stationKey: alarm.stationKey,
                      stationName: alarm.stationName,
                      windRange: windRange,
                      startHour: startHour,
                      endHour: endHour,
                      startMinute: startMinute,
                      endMinute: endMinute,
                      directions: directions,
                      repeatWindow: repeatWindow,
                      maxRepeats: alarm.maxRepeats,
                    );
                    if (catalog.hasEquivalentAlarm(
                      updated,
                      excludingId: alarm.id,
                    )) {
                      setDialogState(() {
                        errorText =
                            'Ya existe una alarma identica para esta estacion.';
                      });
                      return;
                    }
                    final saved = await catalog.saveAlarm(updated);
                    if (!dialogContext.mounted) {
                      return;
                    }
                    if (!saved) {
                      setDialogState(() {
                        errorText =
                            'Guardada localmente, pero fallo la sincronizacion remota.';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  icon: const Icon(Icons.alarm_add_rounded),
                  label: const Text('Guardar cambios'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool> _confirmDeleteAlarm(
    BuildContext context,
    SpotAlarmRecord alarm,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar alarma'),
          content: Text(
            'Se eliminara la alarma de ${alarm.spotName} - ${alarm.stationName}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  String _formatAlarmTime(int hour, int minute) {
    final safeHour = _sanitizeAlarmHour(hour);
    final safeMinute = _sanitizeAlarmMinute(minute);
    return '${safeHour.toString().padLeft(2, '0')}:${safeMinute.toString().padLeft(2, '0')}';
  }

  Widget _buildProfileAlarmDirectionRow({
    required List<String> row,
    required Set<String> directions,
    required ColorScheme colorScheme,
    required void Function(String direction, bool value) onToggleDirection,
  }) {
    return Row(
      children: row
          .map((direction) {
            final selected = directions.contains(direction);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: direction == row.last ? 0 : AppSpacing.xs,
                ),
                child: FilterChip(
                  selected: selected,
                  showCheckmark: false,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                  label: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.rotate(
                        angle: _profileAlarmDirectionRotation(direction),
                        child: Icon(
                          Icons.navigation_rounded,
                          size: 14,
                          color: selected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(direction, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  onSelected: (value) => onToggleDirection(direction, value),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }

  int _sanitizeAlarmHour(int hour) => hour.clamp(0, 23);

  int _sanitizeAlarmMinute(int minute) => minute.clamp(0, 59);

  double _profileAlarmDirectionRotation(String direction) {
    switch (direction) {
      case 'N':
        return 0;
      case 'NE':
        return math.pi / 4;
      case 'E':
        return math.pi / 2;
      case 'SE':
        return (3 * math.pi) / 4;
      case 'S':
        return math.pi;
      case 'SW':
        return (5 * math.pi) / 4;
      case 'W':
        return (3 * math.pi) / 2;
      case 'NW':
        return (7 * math.pi) / 4;
    }
    return 0;
  }

  String _alarmRepeatWindowLabel(AlarmRepeatWindow window) {
    switch (window) {
      case AlarmRepeatWindow.min1:
        return '1 min';
      case AlarmRepeatWindow.min5:
        return '5 min';
      case AlarmRepeatWindow.min10:
        return '10 min';
      case AlarmRepeatWindow.min15:
        return '15 min';
      case AlarmRepeatWindow.min30:
        return '30 min';
    }
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

const List<String> _profileAlarmDirectionOptions = <String>[
  'N',
  'NE',
  'E',
  'SE',
  'S',
  'SW',
  'W',
  'NW',
];

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
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
