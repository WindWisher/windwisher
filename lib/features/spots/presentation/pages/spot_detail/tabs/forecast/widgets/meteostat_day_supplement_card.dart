import 'package:flutter/material.dart';
import 'package:windwisher/features/spots/application/services/spots_presentation_forecast_support.dart';

class MeteostatDaySupplementCard extends StatelessWidget {
  const MeteostatDaySupplementCard({
    super.key,
    required this.snapshot,
    this.message,
  });

  final MeteostatDaySnapshot snapshot;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
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
          Text('Meteostat Day', style: textTheme.titleSmall),
          const SizedBox(height: 8),
          if (days.isEmpty)
            Text(message ?? 'Day no disponible.', style: textTheme.bodySmall)
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: days.map((day) {
                return Container(
                  width: 176,
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
                        'Media: ${_fixed(day.tempAvgC)} C',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Viento medio: ${_fixed(day.windMeanKnots)} kt',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Racha: ${_fixed(day.gustKnots)} kt',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Presion: ${_fixed(day.pressureHpa)} hPa',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lluvia: ${_fixed(day.precipitationMm)} mm',
                        style: textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sol: ${day.sunshineMinutes == null ? '-' : '${day.sunshineMinutes} min'}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

String _fixed(double? value) => value == null ? '-' : value.toStringAsFixed(1);

String _dayLabel(DateTime? value) {
  if (value == null) {
    return '-';
  }
  const weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  return '${weekdays[value.weekday - 1]} ${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
}
