import 'package:flutter/material.dart';
import 'package:windwisher/features/spots/application/services/spots_presentation_forecast_support.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/shared/forecast_table_chrome.dart';

class MeteoblueForecastSupplementCard extends StatelessWidget {
  const MeteoblueForecastSupplementCard({
    super.key,
    required this.snapshot,
    this.message,
    this.showCurrent = true,
    this.showSea = true,
    this.showDay = true,
    this.seaVisibleHours = 6,
    this.onSeaVisibleHoursChanged,
    this.showFullscreenButton = false,
    this.expandToFill = false,
    this.onOpenFullscreen,
    this.showSeaHeader = true,
    this.showSeaControls = true,
  });

  final MeteoblueCurrentDaySnapshot snapshot;
  final String? message;
  final bool showCurrent;
  final bool showSea;
  final bool showDay;
  final int seaVisibleHours;
  final ValueChanged<int>? onSeaVisibleHoursChanged;
  final bool showFullscreenButton;
  final bool expandToFill;
  final VoidCallback? onOpenFullscreen;
  final bool showSeaHeader;
  final bool showSeaControls;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final current = snapshot.current;
    final seaRows = snapshot.sea.take(seaVisibleHours).toList(growable: false);
    final days = snapshot.days.take(5).toList(growable: false);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;

        return Stack(
          fit: expandToFill ? StackFit.expand : StackFit.loose,
          children: [
            ForecastTableCard(
              padding: EdgeInsets.all(isNarrow ? 10 : 12),
              borderRadius: expandToFill ? 0 : 16,
              child: _buildCardBody(
                context,
                isNarrow: isNarrow,
                current: current,
                seaRows: seaRows,
                days: days,
                textTheme: textTheme,
                colorScheme: colorScheme,
              ),
            ),
            if (showFullscreenButton && showSea)
              Positioned(
                right: 8,
                bottom: 8,
                child: IconButton(
                  onPressed: onOpenFullscreen,
                  tooltip: 'Ampliar tabla',
                  icon: const Icon(Icons.fullscreen_rounded),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildCardBody(
    BuildContext context, {
    required bool isNarrow,
    required MeteoblueCurrentData? current,
    required List<MeteoblueSeaData> seaRows,
    required List<MeteoblueDayData> days,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showCurrent) ...[
          _sectionHeader(
            context,
            title: 'Meteoblue Current',
            subtitle: 'Instantanea del paquete actual del proveedor',
            icon: Icons.my_location_rounded,
          ),
          const SizedBox(height: 8),
          if (current == null)
            Text(
              message ?? 'Current no disponible.',
              style: textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: isNarrow ? 6 : 8,
              runSpacing: isNarrow ? 6 : 8,
              children: [
                _metricChip(
                  context,
                  'Hora',
                  _formatDateTimeCompact(current.time),
                ),
                _metricChip(
                  context,
                  'Temperatura',
                  current.temperatureC == null
                      ? '-'
                      : '${current.temperatureC!.toStringAsFixed(1)} C',
                ),
                _metricChip(
                  context,
                  'Viento',
                  current.windKnots == null
                      ? '-'
                      : '${current.windKnots!.toStringAsFixed(1)} kt',
                ),
                _metricChip(
                  context,
                  'Direccion',
                  current.windDeg == null
                      ? '-'
                      : '${current.windDeg}° ${_degreesToCardinal(current.windDeg!.toDouble())}',
                ),
                _metricChip(
                  context,
                  'Presion',
                  current.pressureHpa == null
                      ? '-'
                      : '${current.pressureHpa} hPa',
                ),
                _metricChip(
                  context,
                  'Nubes',
                  current.cloudCoverPct == null
                      ? '-'
                      : '${current.cloudCoverPct}%',
                ),
                _metricChip(
                  context,
                  'Fuente',
                  current.isObservedData == null
                      ? '-'
                      : current.isObservedData!
                      ? 'Observado'
                      : 'Estimado',
                ),
              ],
            ),
        ],
        if (showSea) ...[
          SizedBox(height: showSeaHeader || showSeaControls ? 12 : 0),
          if (showSeaHeader) ...[
            _sectionHeader(
              context,
              title: 'Meteoblue Sea (1h)',
              subtitle: 'Variables marinas horarias del proveedor',
              icon: Icons.waves_rounded,
            ),
            const SizedBox(height: 8),
          ],
          if (showSeaControls) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(value: 6, label: Text('6h')),
                  ButtonSegment<int>(value: 12, label: Text('12h')),
                  ButtonSegment<int>(value: 24, label: Text('24h')),
                ],
                selected: <int>{seaVisibleHours},
                showSelectedIcon: false,
                onSelectionChanged: onSeaVisibleHoursChanged == null
                    ? null
                    : (selection) {
                        final next = selection.first;
                        onSeaVisibleHoursChanged!(next);
                      },
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (seaRows.isEmpty)
            Text(message ?? 'Sea no disponible.', style: textTheme.bodySmall)
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                defaultColumnWidth: FixedColumnWidth(isNarrow ? 78 : 86),
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.7),
                    width: 0.6,
                  ),
                  verticalInside: BorderSide(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                    width: 0.5,
                  ),
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      ),
                    ),
                    children: [
                      const ForecastCompactLabelCell('Hora'),
                      ...seaRows.map(
                        (row) => ForecastCompactValueCell(
                          row.time == null
                              ? '-'
                              : row.time!.hour.toString().padLeft(2, '0'),
                          bold: true,
                        ),
                      ),
                    ],
                  ),
                  _buildSeaRow(
                    label: 'Agua º',
                    values: seaRows
                        .map((row) => _formatFixed(row.surfaceWaterTempC))
                        .toList(),
                  ),
                  _buildSeaRow(
                    label: 'Surf(wave)',
                    values: seaRows
                        .map((row) => _formatFixed(row.surfWaveHeightM))
                        .toList(),
                    color: const Color(0xFFB3E5FC).withValues(alpha: 0.75),
                  ),
                  _buildSeaRow(
                    label: 'Oleaje(m)',
                    values: seaRows
                        .map((row) => _formatFixed(row.significantWaveHeightM))
                        .toList(),
                    color: const Color(0xFF80DEEA).withValues(alpha: 0.75),
                  ),
                  _buildSeaRow(
                    label: 'Mar de fondo',
                    values: seaRows
                        .map((row) => _formatFixed(row.swellWaveHeightM))
                        .toList(),
                    color: const Color(0xFFBBDEFB).withValues(alpha: 0.75),
                  ),
                  _buildSeaRow(
                    label: 'Windsea',
                    values: seaRows
                        .map((row) => _formatFixed(row.windWaveHeightM))
                        .toList(),
                    color: const Color(0xFFC8E6C9).withValues(alpha: 0.75),
                  ),
                  _buildSeaRow(
                    label: 'Periodo(oleaje)',
                    values: seaRows
                        .map((row) => _formatFixed(row.meanWavePeriodS))
                        .toList(),
                  ),
                  _buildSeaRow(
                    label: 'Periodo(mar de viento)',
                    values: seaRows
                        .map((row) => _formatFixed(row.windWaveMeanPeriodS))
                        .toList(),
                  ),
                  TableRow(
                    children: [
                      const ForecastCompactLabelCell('Sea dir.'),
                      ...seaRows.map(
                        (row) => ForecastCompactDirectionCell(
                          degrees: row.meanWaveDirectionDeg,
                          cardinalLabel: _degreesToCardinal,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const ForecastCompactLabelCell('Dir(Mar de fondo)'),
                      ...seaRows.map(
                        (row) => ForecastCompactDirectionCell(
                          degrees: row.swellMeanDirectionDeg,
                          cardinalLabel: _degreesToCardinal,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const ForecastCompactLabelCell('Dir(Wind)'),
                      ...seaRows.map(
                        (row) => ForecastCompactDirectionCell(
                          degrees: row.windWaveDirectionDeg,
                          cardinalLabel: _degreesToCardinal,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      const ForecastCompactLabelCell('Sea status'),
                      ...seaRows.map(
                        (row) => ForecastCompactValueCell(
                          row.douglasSeaState == null
                              ? '-'
                              : _douglasSeaStateLabel(row.douglasSeaState!),
                          color: row.douglasSeaState == null
                              ? null
                              : colorScheme.secondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
        if (showDay) ...[
          const SizedBox(height: 12),
          _sectionHeader(
            context,
            title: 'Meteoblue Day',
            subtitle: 'Resumen diario agregado por Meteoblue',
            icon: Icons.calendar_view_week_rounded,
          ),
          const SizedBox(height: 8),
          if (days.isEmpty)
            Text(message ?? 'Day no disponible.', style: textTheme.bodySmall)
          else
            Wrap(
              spacing: isNarrow ? 6 : 8,
              runSpacing: isNarrow ? 6 : 8,
              children: days.map((day) {
                return ForecastDailySummaryCard(
                  title: _dayLabel(day.date),
                  width: isNarrow ? 144 : 156,
                  padding: EdgeInsets.all(isNarrow ? 8 : 10),
                  lines: [
                    'Temp: ${_formatFixed(day.tempMinC)} / ${_formatFixed(day.tempMaxC)} C',
                    'Viento medio: ${_formatFixed(day.windMeanKnots)} kt',
                    'Lluvia: ${_formatFixed(day.precipitationMm)} mm',
                  ],
                  mutedLines: [
                    'Predict.: ${day.predictabilityPct == null ? '-' : '${day.predictabilityPct}%'}',
                  ],
                );
              }).toList(),
            ),
        ],
      ],
    );

    if (!expandToFill) {
      return body;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 56),
      child: body,
    );
  }

  TableRow _buildSeaRow({
    required String label,
    required List<String> values,
    Color? color,
  }) {
    return TableRow(
      children: [
        ForecastCompactLabelCell(label),
        ...values.map(
          (value) => ForecastCompactValueCell(
            value,
            color: value == '-' ? null : color,
          ),
        ),
      ],
    );
  }
}

Widget _sectionHeader(
  BuildContext context, {
  required String title,
  required String subtitle,
  required IconData icon,
}) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  return Row(
    children: [
      Icon(icon, size: 18, color: colorScheme.primary),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleSmall),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _metricChip(BuildContext context, String label, String value) {
  return ForecastMetricChip(label: label, value: value);
}

String _formatDateTimeCompact(DateTime? value) {
  if (value == null) {
    return '-';
  }
  String two(int input) => input.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)} ${two(value.hour)}:${two(value.minute)}';
}

String _formatShortDate(DateTime? value) {
  if (value == null) {
    return '-';
  }
  String two(int input) => input.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}';
}

String _dayLabel(DateTime? value) {
  if (value == null) {
    return '-';
  }
  const weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
  final weekday = weekdays[value.weekday - 1];
  return '$weekday ${_formatShortDate(value)}';
}

String _formatFixed(double? value) =>
    value == null ? '-' : value.toStringAsFixed(1);

String _degreesToCardinal(double degrees) {
  const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
  final normalized = ((degrees % 360) + 360) % 360;
  final index = ((normalized + 22.5) ~/ 45) % directions.length;
  return directions[index];
}

String _douglasSeaStateLabel(int state) {
  const labels = {
    0: 'Calma',
    1: 'Rizada',
    2: 'Marejadilla',
    3: 'Marejada',
    4: 'Fuerte marejada',
    5: 'Gruesa',
    6: 'Muy gruesa',
    7: 'Arbolada',
    8: 'Montanosa',
    9: 'Enorme',
  };
  return labels[state] ?? 'Estado $state';
}
