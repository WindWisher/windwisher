import 'package:flutter/material.dart';
import 'package:windwisher/core/units/app_units_controller.dart';
import 'package:windwisher/features/spots/application/services/spots_presentation_forecast_support.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/shared/forecast_table_chrome.dart';

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
    final textTheme = Theme.of(context).textTheme;
    final days = snapshot.days.take(7).toList(growable: false);

    return ForecastTableCard(
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
                return ForecastDailySummaryCard(
                  title: _dayLabel(day.date),
                  width: 176,
                  lines: [
                    'Temp: ${_temperature(day.tempMinC)} / ${_temperature(day.tempMaxC)}',
                    'Media: ${_temperature(day.tempAvgC)}',
                    'Viento medio: ${_wind(day.windMeanKnots)}',
                    'Racha: ${_wind(day.gustKnots)}',
                    'Presion: ${_fixed(day.pressureHpa)} hPa',
                    'Lluvia: ${_fixed(day.precipitationMm)} mm',
                  ],
                  mutedLines: [
                    'Sol: ${day.sunshineMinutes == null ? '-' : '${day.sunshineMinutes} min'}',
                  ],
                );
              }).toList(),
            ),
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
