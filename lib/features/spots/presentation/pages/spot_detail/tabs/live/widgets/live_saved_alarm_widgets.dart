part of '../../../spot_detail_page.dart';

class _LiveSavedAlarmsHeader extends StatelessWidget {
  const _LiveSavedAlarmsHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(Icons.alarm_add_rounded, size: 18, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          'Alarmas guardadas',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _LiveSavedAlarmsEmptyState extends StatelessWidget {
  const _LiveSavedAlarmsEmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.45),
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
              'Todavia no hay alarmas guardadas para este spot.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveSavedAlarmCard extends StatelessWidget {
  const _LiveSavedAlarmCard({
    required this.alarm,
    required this.evaluation,
    required this.evaluationColor,
    required this.triggerSummary,
    required this.windRangeLabel,
    required this.timeRangeLabel,
    required this.repeatWindowLabel,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  final SpotAlarmRecord alarm;
  final _AlarmEvaluation evaluation;
  final Color evaluationColor;
  final String triggerSummary;
  final String windRangeLabel;
  final String timeRangeLabel;
  final String repeatWindowLabel;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final statusBackground = evaluationColor.withValues(alpha: 0.12);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
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
                child: _LiveSavedAlarmTitle(
                  stationName: alarm.stationName,
                  evaluation: evaluation,
                  evaluationColor: evaluationColor,
                  statusBackground: statusBackground,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _LiveSavedAlarmActions(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            triggerSummary,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LiveSavedAlarmMetaChips(
            windRangeLabel: windRangeLabel,
            timeRangeLabel: timeRangeLabel,
            directionsLabel: alarm.directions.join('/'),
            repeatWindowLabel: repeatWindowLabel,
            maxRepeatsLabel: '${alarm.maxRepeats} avisos',
          ),
        ],
      ),
    );
  }
}

class _LiveSavedAlarmActions extends StatelessWidget {
  const _LiveSavedAlarmActions({required this.onEdit, required this.onDelete});

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          tooltip: 'Editar',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_rounded),
        ),
        IconButton(
          tooltip: 'Eliminar',
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ],
    );
  }
}

class _LiveSavedAlarmMetaChips extends StatelessWidget {
  const _LiveSavedAlarmMetaChips({
    required this.windRangeLabel,
    required this.timeRangeLabel,
    required this.directionsLabel,
    required this.repeatWindowLabel,
    required this.maxRepeatsLabel,
  });

  final String windRangeLabel;
  final String timeRangeLabel;
  final String directionsLabel;
  final String repeatWindowLabel;
  final String maxRepeatsLabel;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        _AlarmMetaChip(icon: Icons.air_rounded, label: windRangeLabel),
        _AlarmMetaChip(icon: Icons.schedule_rounded, label: timeRangeLabel),
        _AlarmMetaChip(icon: Icons.navigation_rounded, label: directionsLabel),
        _AlarmMetaChip(icon: Icons.repeat_rounded, label: repeatWindowLabel),
        _AlarmMetaChip(icon: Icons.filter_3_rounded, label: maxRepeatsLabel),
      ],
    );
  }
}

class _LiveSavedAlarmTitle extends StatelessWidget {
  const _LiveSavedAlarmTitle({
    required this.stationName,
    required this.evaluation,
    required this.evaluationColor,
    required this.statusBackground,
  });

  final String stationName;
  final _AlarmEvaluation evaluation;
  final Color evaluationColor;
  final Color statusBackground;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stationName,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
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
                _alarmEvaluationIcon(evaluation.state),
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
      ],
    );
  }
}
