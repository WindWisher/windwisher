part of '../../../spot_detail_page.dart';

class _LiveAlarmsHeader extends StatelessWidget {
  const _LiveAlarmsHeader({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.9),
            colorScheme.secondaryContainer.withValues(alpha: 0.75),
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
              Icons.notifications_active_rounded,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alarmas personalizadas',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  enabled
                      ? 'Spot activo para alertas'
                      : 'Spot desactivado para alertas',
                  style: textTheme.bodySmall?.copyWith(
                    color: enabled
                        ? const Color(0xFF2E7D32)
                        : colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _LiveNewAlarmCard extends StatelessWidget {
  const _LiveNewAlarmCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Nueva alarma',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class _LiveAlarmStationDropdown extends StatelessWidget {
  const _LiveAlarmStationDropdown({
    required this.stationKeys,
    required this.selectedStationKey,
    required this.stationLabelForKey,
    required this.onChanged,
  });

  final List<String> stationKeys;
  final String selectedStationKey;
  final String Function(String stationKey) stationLabelForKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedStationKey,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Estacion meteorologica',
        border: OutlineInputBorder(),
      ),
      items: stationKeys
          .map(
            (station) => DropdownMenuItem(
              value: station,
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  stationLabelForKey(station),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) {
        return stationKeys
            .map(
              (station) => Text(
                stationLabelForKey(station),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
            .toList();
      },
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}
