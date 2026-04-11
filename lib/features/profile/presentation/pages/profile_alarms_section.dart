import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

class ProfileAlarmsSection extends StatelessWidget {
  const ProfileAlarmsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
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
                          return _ProfileAlarmItem(alarm: alarm);
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

class _ProfileAlarmItem extends StatelessWidget {
  const _ProfileAlarmItem({required this.alarm});

  final SpotAlarmRecord alarm;

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

const List<String> _profileAlarmDirectionOptions = [
  'N',
  'NE',
  'E',
  'SE',
  'S',
  'SW',
  'W',
  'NW',
];

String _formatAlarmTime(int hour, int minute) {
  final normalizedHour = hour.clamp(0, 23);
  final normalizedMinute = minute.clamp(0, 59);
  final hourLabel = normalizedHour.toString().padLeft(2, '0');
  final minuteLabel = normalizedMinute.toString().padLeft(2, '0');
  return '$hourLabel:$minuteLabel';
}

String _alarmRepeatWindowLabel(AlarmRepeatWindow repeatWindow) {
  return switch (repeatWindow) {
    AlarmRepeatWindow.min1 => 'Cada 1 min',
    AlarmRepeatWindow.min5 => 'Cada 5 min',
    AlarmRepeatWindow.min10 => 'Cada 10 min',
    AlarmRepeatWindow.min15 => 'Cada 15 min',
    AlarmRepeatWindow.min30 => 'Cada 30 min',
  };
}

Future<bool> _confirmDeleteAlarm(
  BuildContext context,
  SpotAlarmRecord alarm,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Eliminar alarma'),
      content: Text(
        'Se eliminara la alarma de ${alarm.spotName} para ${alarm.stationName}.',
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
    ),
  );
  return result ?? false;
}

int _sanitizeAlarmHour(int hour) {
  return hour.clamp(0, 23);
}

int _sanitizeAlarmMinute(int minute) {
  return minute.clamp(0, 59);
}

Widget _buildProfileAlarmDirectionRow({
  required List<String> row,
  required Set<String> directions,
  required ColorScheme colorScheme,
  required void Function(String direction, bool value) onToggleDirection,
}) {
  return Row(
    children: row
        .map(
          (direction) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FilterChip(
                label: Text(direction),
                selected: directions.contains(direction),
                showCheckmark: false,
                selectedColor: colorScheme.primaryContainer,
                onSelected: (value) => onToggleDirection(direction, value),
              ),
            ),
          ),
        )
        .toList(growable: false),
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
                  final updated = alarm.copyWith(
                    windRange: windRange,
                    startHour: startHour,
                    endHour: endHour,
                    startMinute: startMinute,
                    endMinute: endMinute,
                    directions: directions,
                    repeatWindow: repeatWindow,
                  );
                  final saved = await catalog.saveAlarm(updated);
                  if (!dialogContext.mounted) {
                    return;
                  }
                  if (!saved) {
                    setDialogState(() {
                      errorText =
                          catalog.lastSyncError ??
                          'No se pudo guardar la alarma en este momento.';
                    });
                    return;
                  }
                  Navigator.of(dialogContext).pop();
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Guardar'),
              ),
            ],
          );
        },
      );
    },
  );
}
