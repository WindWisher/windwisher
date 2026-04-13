import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/widgets/profile_alarm_item_card.dart';

const List<String> profileAlarmDirectionOptions = [
  'N',
  'NE',
  'E',
  'SE',
  'S',
  'SW',
  'W',
  'NW',
];

class ProfileEditAlarmDialog {
  static Future<void> show(BuildContext context, SpotAlarmRecord alarm) async {
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
                                Text(formatAlarmTime(startHour, startMinute)),
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
                                Text(formatAlarmTime(endHour, endMinute)),
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
                          profileAlarmDirectionOptions.length,
                      showCheckmark: false,
                      onSelected: (_) {
                        setDialogState(() {
                          final allSelected =
                              directions.length ==
                              profileAlarmDirectionOptions.length;
                          directions = allSelected
                              ? <String>{}
                              : profileAlarmDirectionOptions.toSet();
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Column(
                      children: [
                        _buildProfileAlarmDirectionRow(
                          row: profileAlarmDirectionOptions.sublist(0, 4),
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
                          row: profileAlarmDirectionOptions.sublist(4, 8),
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
}

Future<bool> confirmDeleteAlarm(
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
