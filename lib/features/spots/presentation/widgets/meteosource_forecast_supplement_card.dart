import 'package:flutter/material.dart';
import 'package:windwisher/features/spots/application/services/spots_presentation_forecast_support.dart';

class MeteosourceForecastSupplementCard extends StatelessWidget {
  const MeteosourceForecastSupplementCard({
    super.key,
    required this.snapshot,
    this.message,
    this.showCurrent = true,
    this.showDay = true,
  });

  final MeteosourceCurrentDaySnapshot snapshot;
  final String? message;
  final bool showCurrent;
  final bool showDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final current = snapshot.current;
    final days = snapshot.days.take(7).toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCurrent) ...[
            Text('Meteosource Current', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            if (current == null)
              Text(
                message ?? 'Current no disponible.',
                style: textTheme.bodySmall,
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip(
                    context,
                    'Temp',
                    current.temperatureC == null
                        ? '-'
                        : '${current.temperatureC!.toStringAsFixed(1)} C',
                  ),
                  _chip(
                    context,
                    'Viento',
                    current.windKnots == null
                        ? '-'
                        : '${current.windKnots!.toStringAsFixed(1)} kt',
                  ),
                  _chip(
                    context,
                    'Dir',
                    current.windDeg == null ? '-' : '${current.windDeg}°',
                  ),
                  _chip(
                    context,
                    'Nubes',
                    current.cloudCoverPct == null
                        ? '-'
                        : '${current.cloudCoverPct}%',
                  ),
                  _chip(
                    context,
                    'Lluvia',
                    current.rainMm == null
                        ? '-'
                        : '${current.rainMm!.toStringAsFixed(1)} mm',
                  ),
                  if (current.summary != null && current.summary!.isNotEmpty)
                    _chip(context, 'Estado', current.summary!),
                ],
              ),
          ],
          if (showDay) ...[
            if (showCurrent) const SizedBox(height: 12),
            Text('Meteosource Day', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            if (days.isEmpty)
              Text(message ?? 'Day no disponible.', style: textTheme.bodySmall)
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: days.map((day) {
                  return Container(
                    width: 172,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _dayLabel(day.date),
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Temp: ${_fixed(day.tempMinC)} / ${_fixed(day.tempMaxC)} C',
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Viento medio: ${_fixed(day.windMeanKnots)} kt',
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lluvia: ${_fixed(day.precipitationMm)} mm',
                          style: textTheme.bodySmall,
                        ),
                        if (day.summary != null && day.summary!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            day.summary!,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }
}

Widget _chip(BuildContext context, String label, String value) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

String _fixed(double? value) => value == null ? '-' : value.toStringAsFixed(1);

String _dayLabel(DateTime? value) {
  if (value == null) {
    return '-';
  }
  const weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  return '${weekdays[value.weekday - 1]} ${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
}
