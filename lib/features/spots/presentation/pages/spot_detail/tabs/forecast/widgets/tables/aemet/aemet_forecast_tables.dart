import 'package:flutter/material.dart';
import 'package:windwisher/features/spots/application/services/spots_presentation_forecast_support.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/forecast/widgets/tables/shared/forecast_table_chrome.dart';

class AemetBeachForecastTable extends StatelessWidget {
  const AemetBeachForecastTable({super.key, required this.data});

  final AemetBeachForecastData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget dayHeader(AemetBeachForecastDay day) {
      return Container(
        width: 148,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatShortDate(day.date),
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text('Manana / Tarde', style: textTheme.labelSmall),
          ],
        ),
      );
    }

    Widget rowLabel(String label) {
      return SizedBox(
        width: 116,
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
    }

    Widget valueCell(String primary, [String? secondary]) {
      return Container(
        width: 148,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: secondary == null
            ? Text(primary, style: textTheme.bodySmall)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(primary, style: textTheme.bodySmall),
                  const SizedBox(height: 4),
                  Text(
                    secondary,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
      );
    }

    Widget dataRow(String label, List<Widget> values) {
      final rowChildren = <Widget>[rowLabel(label), const SizedBox(width: 8)];
      for (var i = 0; i < values.length; i++) {
        rowChildren.add(values[i]);
        if (i != values.length - 1) {
          rowChildren.add(const SizedBox(width: 8));
        }
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      );
    }

    return ForecastTableCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tabla Playa AEMET', style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(data.beachName, style: textTheme.bodySmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${data.days.length} dia(s)',
                        style: textTheme.labelSmall,
                      ),
                    ),
                    if (data.issuedAt != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Emitido: ${_formatShortDate(data.issuedAt)}',
                          style: textTheme.labelSmall,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: 124),
                      ...(() {
                        final children = <Widget>[];
                        for (var i = 0; i < data.days.length; i++) {
                          children.add(dayHeader(data.days[i]));
                          if (i != data.days.length - 1) {
                            children.add(const SizedBox(width: 8));
                          }
                        }
                        return children;
                      })(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  dataRow(
                    'Cielo',
                    data.days
                        .map(
                          (day) => valueCell(
                            'Manana: ${day.skyMorning}',
                            'Tarde: ${day.skyAfternoon}',
                          ),
                        )
                        .toList(growable: false),
                  ),
                  dataRow(
                    'Viento',
                    data.days
                        .map(
                          (day) => valueCell(
                            'Manana: ${day.windMorning}',
                            'Tarde: ${day.windAfternoon}',
                          ),
                        )
                        .toList(growable: false),
                  ),
                  dataRow(
                    'Oleaje',
                    data.days
                        .map(
                          (day) => valueCell(
                            'Manana: ${day.waveMorning}',
                            'Tarde: ${day.waveAfternoon}',
                          ),
                        )
                        .toList(growable: false),
                  ),
                  dataRow(
                    'Temp. max',
                    data.days
                        .map(
                          (day) => valueCell(
                            day.maxTempC == null ? '-' : '${day.maxTempC} C',
                          ),
                        )
                        .toList(growable: false),
                  ),
                  dataRow(
                    'Temp. agua',
                    data.days
                        .map(
                          (day) => valueCell(
                            day.waterTempC == null
                                ? '-'
                                : '${day.waterTempC} C',
                          ),
                        )
                        .toList(growable: false),
                  ),
                  dataRow(
                    'Sens. termica',
                    data.days
                        .map((day) => valueCell(day.thermalSensation))
                        .toList(growable: false),
                  ),
                  dataRow(
                    'UV max',
                    data.days
                        .map((day) => valueCell(day.uvMax?.toString() ?? '-'))
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AemetCoastalForecastTable extends StatelessWidget {
  const AemetCoastalForecastTable({super.key, required this.data});

  final AemetCoastalForecastData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget bulletPoint(String text) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      );
    }

    final validity = _formatDateTimeRange(data.validFrom, data.validTo);
    final issued = data.issuedAt == null
        ? 'No disponible'
        : _formatDateTimeRange(data.issuedAt, data.issuedAt);

    return ForecastTableCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tabla Costera AEMET', style: textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(data.bulletinName, style: textTheme.bodySmall),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ForecastPillChip(label: 'Validez: $validity'),
                    ForecastPillChip(label: 'Emitido: $issued'),
                    ForecastPillChip(label: '${data.zones.length} zona(s)'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ForecastInfoCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Aviso',
                  value: data.noticeText,
                  tint: colorScheme.error,
                ),
                const SizedBox(height: 10),
                ForecastInfoCard(
                  icon: Icons.public_rounded,
                  title: 'Situacion general',
                  value: data.situationText,
                  tint: colorScheme.primary,
                ),
                const SizedBox(height: 10),
                ForecastInfoCard(
                  icon: Icons.trending_up_rounded,
                  title: 'Tendencia',
                  value: data.trendText,
                  tint: colorScheme.tertiary,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tramos costeros',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...data.zones.map((zone) {
                  final sentences = zone.text
                      .split('.')
                      .map((entry) => entry.trim())
                      .where((entry) => entry.isNotEmpty)
                      .toList(growable: false);
                  final tags = _extractAemetCoastalTags(zone.text);

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          zone.name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: tags
                                .map(
                                  (tag) => ForecastPillChip(
                                    label: tag,
                                    backgroundColor:
                                        colorScheme.secondaryContainer,
                                    foregroundColor:
                                        colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ],
                        const SizedBox(height: 10),
                        ...sentences.map(bulletPoint),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatShortDate(DateTime? value) {
  if (value == null) {
    return '-';
  }
  String two(int input) => input.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}';
}

String _formatDateTimeRange(DateTime? start, DateTime? end) {
  if (start == null || end == null) {
    return 'No disponible';
  }
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(start.day)}/${two(start.month)} ${two(start.hour)}:${two(start.minute)} - ${two(end.day)}/${two(end.month)} ${two(end.hour)}:${two(end.minute)}';
}

List<String> _extractAemetCoastalTags(String text) {
  final normalized = text.toLowerCase();
  final tags = <String>[];

  void addIfContains(String needle, String label) {
    if (normalized.contains(needle) && !tags.contains(label)) {
      tags.add(label);
    }
  }

  addIfContains('marejadilla', 'Marejadilla');
  addIfContains('marejada', 'Marejada');
  addIfContains('rizada', 'Rizada');
  addIfContains('fuerte marejada', 'Fuerte marejada');
  addIfContains('aguacero', 'Aguaceros');
  addIfContains('torment', 'Tormenta');
  addIfContains('niebla', 'Niebla');
  addIfContains('n 2 a 4', 'N 2-4');
  addIfContains('ne', 'NE');
  addIfContains('se', 'SE');
  addIfContains('sw', 'SW');
  addIfContains('nw', 'NW');

  return tags;
}
