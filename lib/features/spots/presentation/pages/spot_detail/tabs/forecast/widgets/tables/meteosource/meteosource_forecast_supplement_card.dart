import 'package:flutter/material.dart';
import 'package:windwisher/core/units/app_units_controller.dart';
import 'package:windwisher/features/spots/application/services/spots_presentation_forecast_support.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/shared/forecast_table_chrome.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final current = snapshot.current;
    final days = snapshot.days.take(7).toList(growable: false);

    return ForecastTableCard(
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
                  ForecastMetricChip(
                    label: 'Temp',
                    value: current.temperatureC == null
                        ? '-'
                        : AppUnitsController.instance.formatTemperature(
                            current.temperatureC!,
                          ),
                  ),
                  ForecastMetricChip(
                    label: 'Viento',
                    value: current.windKnots == null
                        ? '-'
                        : AppUnitsController.instance.formatWindSpeed(
                            current.windKnots!,
                          ),
                  ),
                  ForecastMetricChip(
                    label: 'Dir',
                    value: current.windDeg == null
                        ? '-'
                        : '${current.windDeg}°',
                  ),
                  ForecastMetricChip(
                    label: 'Nubes',
                    value: current.cloudCoverPct == null
                        ? '-'
                        : '${current.cloudCoverPct}%',
                  ),
                  ForecastMetricChip(
                    label: 'Lluvia',
                    value: current.rainMm == null
                        ? '-'
                        : '${current.rainMm!.toStringAsFixed(1)} mm',
                  ),
                  if (current.summary != null && current.summary!.isNotEmpty)
                    ForecastMetricChip(
                      label: 'Estado',
                      value: current.summary!,
                    ),
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
                  final mutedLines = <String>[
                    if (day.summary != null && day.summary!.isNotEmpty)
                      day.summary!,
                  ];

                  return ForecastDailySummaryCard(
                    title: _dayLabel(day.date),
                    width: 172,
                    lines: [
                      'Temp: ${_temperature(day.tempMinC)} / ${_temperature(day.tempMaxC)}',
                      'Viento medio: ${_wind(day.windMeanKnots)}',
                      'Lluvia: ${_fixed(day.precipitationMm)} mm',
                    ],
                    mutedLines: mutedLines,
                  );
                }).toList(),
              ),
          ],
        ],
      ),
    );
  }
}

String _fixed(double? value) => value == null ? '-' : value.toStringAsFixed(1);
String _temperature(double? value) =>
    value == null ? '-' : AppUnitsController.instance.formatTemperature(value);
String _wind(double? value) =>
    value == null ? '-' : AppUnitsController.instance.formatWindSpeed(value);

String _dayLabel(DateTime? value) {
  if (value == null) {
    return '-';
  }
  const weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  return '${weekdays[value.weekday - 1]} ${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}';
}
