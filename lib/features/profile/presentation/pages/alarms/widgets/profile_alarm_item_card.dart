import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/spots/presentation/state/spot_alarm_catalog.dart';

class ProfileAlarmItemCard extends StatelessWidget {
  const ProfileAlarmItemCard({
    super.key,
    required this.alarm,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
    required this.spotEnabled,
  });

  final SpotAlarmRecord alarm;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;
  final ValueChanged<bool> onToggle;
  final bool spotEnabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final catalog = SpotAlarmCatalog.instance;
    final evaluation = _profileAlarmEvaluation(catalog, alarm, spotEnabled);
    final evaluationColor = _profileAlarmEvaluationColor(context, evaluation);
    final statusBackground = evaluationColor.withValues(alpha: 0.12);

    return Container(
      width: double.infinity,
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
                      alarm.stationName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.spotName,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusBackground,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  switch (evaluation.state) {
                                    _ProfileAlarmEvaluationState.ready =>
                                      Icons.notifications_active_rounded,
                                    _ProfileAlarmEvaluationState.disabled =>
                                      Icons.notifications_off_rounded,
                                    _ProfileAlarmEvaluationState.triggered =>
                                      Icons.history_toggle_off_rounded,
                                  },
                                  size: 16,
                                  color: evaluationColor,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    evaluation.label,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: evaluationColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Switch.adaptive(
                          value: alarm.enabled,
                          onChanged: onToggle,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
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
          Text(
            _alarmTriggerSummary(alarm),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
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
              _ProfileAlarmMetaChip(
                icon: Icons.filter_3_rounded,
                label: '${alarm.maxRepeats} avisos',
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

enum _ProfileAlarmEvaluationState { ready, disabled, triggered }

class _ProfileAlarmEvaluation {
  const _ProfileAlarmEvaluation({required this.state, required this.label});

  final _ProfileAlarmEvaluationState state;
  final String label;
}

_ProfileAlarmEvaluation _profileAlarmEvaluation(
  SpotAlarmCatalog catalog,
  SpotAlarmRecord alarm,
  bool spotEnabled,
) {
  if (!catalog.globalEnabled) {
    return const _ProfileAlarmEvaluation(
      state: _ProfileAlarmEvaluationState.disabled,
      label: 'Alarmas globales desactivadas',
    );
  }
  if (!spotEnabled) {
    return const _ProfileAlarmEvaluation(
      state: _ProfileAlarmEvaluationState.disabled,
      label: 'Spot desactivado para alertas',
    );
  }
  if (!alarm.enabled) {
    return const _ProfileAlarmEvaluation(
      state: _ProfileAlarmEvaluationState.disabled,
      label: 'Alarma desactivada',
    );
  }
  if (alarm.lastTriggeredAt != null || alarm.triggerCount > 0) {
    return _ProfileAlarmEvaluation(
      state: _ProfileAlarmEvaluationState.triggered,
      label: 'Con actividad reciente ${alarm.triggerCount}/${alarm.maxRepeats}',
    );
  }
  return const _ProfileAlarmEvaluation(
    state: _ProfileAlarmEvaluationState.ready,
    label: 'Lista para disparar',
  );
}

Color _profileAlarmEvaluationColor(
  BuildContext context,
  _ProfileAlarmEvaluation evaluation,
) {
  switch (evaluation.state) {
    case _ProfileAlarmEvaluationState.ready:
      return const Color(0xFF2E7D32);
    case _ProfileAlarmEvaluationState.disabled:
      return Theme.of(context).colorScheme.onSurfaceVariant;
    case _ProfileAlarmEvaluationState.triggered:
      return const Color(0xFFEF6C00);
  }
}

String _alarmTriggerSummary(SpotAlarmRecord alarm) {
  final lastTriggeredAt = alarm.lastTriggeredAt;
  if (lastTriggeredAt == null) {
    return 'Aun no ha disparado';
  }
  return 'Ultimo aviso ${_relativeTimeLabel(lastTriggeredAt)} · ${alarm.triggerCount}/${alarm.maxRepeats}';
}

String _relativeTimeLabel(DateTime timestamp) {
  final difference = DateTime.now().difference(timestamp);
  if (difference.inMinutes < 1) {
    return 'ahora';
  }
  if (difference.inHours < 1) {
    return 'hace ${difference.inMinutes} min';
  }
  if (difference.inDays < 1) {
    return 'hace ${difference.inHours} h';
  }
  return 'hace ${difference.inDays} d';
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
