import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';

class GearUsageDetailsPage extends StatelessWidget {
  final List<GearSetup> setups;
  final List<KiteItem> kites;
  final List<BoardItem> boards;
  final List<BarItem> bars;
  final List<HarnessItem> harnesses;
  final List<WetsuitItem> wetsuits;
  final List<HelmetItem> helmets;
  final List<VestItem> vests;

  const GearUsageDetailsPage({
    super.key,
    required this.setups,
    required this.kites,
    required this.boards,
    required this.bars,
    required this.harnesses,
    required this.wetsuits,
    required this.helmets,
    required this.vests,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final total = setups.length;
    final complete = setups
        .where(
          (s) =>
              s.barId != null &&
              s.harnessId != null &&
              s.wetsuitId != null &&
              s.helmetId != null &&
              s.vestId != null,
        )
        .length;

    int countWhere(bool Function(GearSetup) predicate) =>
        setups.where(predicate).length;

    final withBar = countWhere((s) => s.barId != null);
    final withHarness = countWhere((s) => s.harnessId != null);
    final withWetsuit = countWhere((s) => s.wetsuitId != null);
    final withHelmet = countWhere((s) => s.helmetId != null);
    final withVest = countWhere((s) => s.vestId != null);

    String percent(int value) {
      if (total == 0) return '0%';
      final p = ((value / total) * 100).round();
      return '$p%';
    }

    String percentOf(int value, int base) {
      if (base == 0) return '0%';
      return '${((value / base) * 100).round()}%';
    }

    double? parseDouble(String value) =>
        double.tryParse(value.replaceAll(',', '.'));

    int? parseYear(String value) => int.tryParse(value.trim());

    final kiteUsage = <String, int>{};
    final boardUsage = <String, int>{};
    final barUsage = <String, int>{};
    final harnessUsage = <String, int>{};
    final wetsuitUsage = <String, int>{};
    final helmetUsage = <String, int>{};
    final vestUsage = <String, int>{};

    for (final setup in setups) {
      kiteUsage[setup.kiteId] = (kiteUsage[setup.kiteId] ?? 0) + 1;
      boardUsage[setup.boardId] = (boardUsage[setup.boardId] ?? 0) + 1;
      if (setup.barId != null) {
        barUsage[setup.barId!] = (barUsage[setup.barId!] ?? 0) + 1;
      }
      if (setup.harnessId != null) {
        harnessUsage[setup.harnessId!] =
            (harnessUsage[setup.harnessId!] ?? 0) + 1;
      }
      if (setup.wetsuitId != null) {
        wetsuitUsage[setup.wetsuitId!] =
            (wetsuitUsage[setup.wetsuitId!] ?? 0) + 1;
      }
      if (setup.helmetId != null) {
        helmetUsage[setup.helmetId!] = (helmetUsage[setup.helmetId!] ?? 0) + 1;
      }
      if (setup.vestId != null) {
        vestUsage[setup.vestId!] = (vestUsage[setup.vestId!] ?? 0) + 1;
      }
    }

    String labelFromKiteId(String id) {
      for (final item in kites) {
        if (item.id == id) {
          return '${item.brand} ${item.model}';
        }
      }
      return id;
    }

    String labelFromBoardId(String id) {
      for (final item in boards) {
        if (item.id == id) {
          return '${item.brand} ${item.model}';
        }
      }
      return id;
    }

    List<String> topUsage(
      Map<String, int> usage,
      String Function(String id) labelOf,
    ) {
      final sorted = usage.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return sorted
          .take(3)
          .map((e) => '${labelOf(e.key)} (${e.value})')
          .toList();
    }

    final uniqueCombinations = setups
        .map(
          (s) =>
              '${s.kiteId}|${s.boardId}|${s.barId ?? '-'}|${s.harnessId ?? '-'}|${s.wetsuitId ?? '-'}|${s.helmetId ?? '-'}|${s.vestId ?? '-'}',
        )
        .toSet()
        .length;

    final maxKiteUse = kiteUsage.values.isEmpty
        ? 0
        : kiteUsage.values.reduce((a, b) => a > b ? a : b);
    final maxBoardUse = boardUsage.values.isEmpty
        ? 0
        : boardUsage.values.reduce((a, b) => a > b ? a : b);
    final maxBarUse = barUsage.values.isEmpty
        ? 0
        : barUsage.values.reduce((a, b) => a > b ? a : b);
    final maxHarnessUse = harnessUsage.values.isEmpty
        ? 0
        : harnessUsage.values.reduce((a, b) => a > b ? a : b);
    final maxWetsuitUse = wetsuitUsage.values.isEmpty
        ? 0
        : wetsuitUsage.values.reduce((a, b) => a > b ? a : b);
    final maxHelmetUse = helmetUsage.values.isEmpty
        ? 0
        : helmetUsage.values.reduce((a, b) => a > b ? a : b);
    final maxVestUse = vestUsage.values.isEmpty
        ? 0
        : vestUsage.values.reduce((a, b) => a > b ? a : b);

    final allYears = <int>[
      ...kites.map((e) => parseYear(e.year)).whereType<int>(),
      ...boards.map((e) => parseYear(e.year)).whereType<int>(),
      ...bars.map((e) => parseYear(e.year)).whereType<int>(),
      ...harnesses.map((e) => parseYear(e.year)).whereType<int>(),
      ...wetsuits.map((e) => parseYear(e.year)).whereType<int>(),
      ...helmets.map((e) => parseYear(e.year)).whereType<int>(),
      ...vests.map((e) => parseYear(e.year)).whereType<int>(),
    ];

    String averageYear(Iterable<int> years) {
      final list = years.toList();
      if (list.isEmpty) return '-';
      final avg = list.reduce((a, b) => a + b) / list.length;
      return avg.toStringAsFixed(1);
    }

    String distributionLabel(Iterable<String> rawValues) {
      final map = <String, int>{};
      for (final raw in rawValues) {
        final key = raw.trim().toUpperCase();
        if (key.isEmpty) continue;
        map[key] = (map[key] ?? 0) + 1;
      }
      if (map.isEmpty) return '-';
      final entries = map.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      return entries.map((e) => '${e.key}:${e.value}').join(' · ');
    }

    final smallKites = kites.where((k) {
      final size = parseDouble(k.sizeMeters);
      return size != null && size <= 9;
    }).length;
    final mediumKites = kites.where((k) {
      final size = parseDouble(k.sizeMeters);
      return size != null && size > 9 && size <= 13;
    }).length;
    final largeKites = kites.where((k) {
      final size = parseDouble(k.sizeMeters);
      return size != null && size > 13;
    }).length;

    final boardTypeMap = <String, int>{};
    for (final b in boards) {
      boardTypeMap[b.type] = (boardTypeMap[b.type] ?? 0) + 1;
    }

    final minimalSetups = setups
        .where(
          (s) =>
              s.barId == null &&
              s.harnessId == null &&
              s.wetsuitId == null &&
              s.helmetId == null &&
              s.vestId == null,
        )
        .length;
    final mediumSetups = (total - complete - minimalSetups).clamp(0, total);

    DateTime? latest(Iterable<DateTime> dates) {
      if (dates.isEmpty) return null;
      return dates.reduce((a, b) => a.isAfter(b) ? a : b);
    }

    String daysSinceLabel(DateTime? date) {
      if (date == null) return '-';
      final days = DateTime.now().difference(date).inDays;
      return 'hace ${days}d';
    }

    final lastKite = daysSinceLabel(latest(setups.map((s) => s.createdAt)));
    final lastBoard = daysSinceLabel(latest(setups.map((s) => s.createdAt)));
    final lastBar = daysSinceLabel(
      latest(setups.where((s) => s.barId != null).map((s) => s.createdAt)),
    );
    final lastHarness = daysSinceLabel(
      latest(setups.where((s) => s.harnessId != null).map((s) => s.createdAt)),
    );
    final lastWetsuit = daysSinceLabel(
      latest(setups.where((s) => s.wetsuitId != null).map((s) => s.createdAt)),
    );
    final lastHelmet = daysSinceLabel(
      latest(setups.where((s) => s.helmetId != null).map((s) => s.createdAt)),
    );
    final lastVest = daysSinceLabel(
      latest(setups.where((s) => s.vestId != null).map((s) => s.createdAt)),
    );

    bool isSetupReused(GearSetup s) {
      bool reused(String? id, Map<String, int> map) =>
          id != null && (map[id] ?? 0) > 1;
      return reused(s.kiteId, kiteUsage) ||
          reused(s.boardId, boardUsage) ||
          reused(s.barId, barUsage) ||
          reused(s.harnessId, harnessUsage) ||
          reused(s.wetsuitId, wetsuitUsage) ||
          reused(s.helmetId, helmetUsage) ||
          reused(s.vestId, vestUsage);
    }

    final reusedSetups = setups.where(isSetupReused).length;

    int inconsistentItems = 0;
    inconsistentItems += kites
        .where((e) => e.year.trim().isEmpty || e.sizeMeters.trim().isEmpty)
        .length;
    inconsistentItems += boards.where((e) => e.year.trim().isEmpty).length;
    inconsistentItems += bars
        .where(
          (e) =>
              e.year.trim().isEmpty ||
              e.lineLengthMeters.trim().isEmpty ||
              e.widthCm.trim().isEmpty,
        )
        .length;
    inconsistentItems += harnesses
        .where((e) => e.year.trim().isEmpty || e.size.trim().isEmpty)
        .length;
    inconsistentItems += wetsuits
        .where(
          (e) =>
              e.year.trim().isEmpty ||
              e.size.trim().isEmpty ||
              e.thickness.trim().isEmpty,
        )
        .length;
    inconsistentItems += helmets.where((e) => e.year.trim().isEmpty).length;
    inconsistentItems += vests
        .where((e) => e.year.trim().isEmpty || e.size.trim().isEmpty)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalles de equipacion')),
      body: ListView(
        physics: kAppBouncingScrollPhysics,
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen general', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow('Equipaciones totales', '$total'),
                  _buildDetailRow('Equipaciones completas', '$complete'),
                  _buildDetailRow(
                    'Equipaciones completas (%)',
                    total == 0
                        ? '0%'
                        : '${((complete / total) * 100).round()}%',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Inventario guardado', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _buildInventoryRow(
                    label: 'Cometas',
                    value: '${kites.length}',
                    onTap: () => _openInventoryChartDialog(
                      context,
                      title: 'Cometas',
                      data: kites
                          .map(
                            (item) => _UsageDatum(
                              label: '${item.brand} ${item.model}',
                              sessions: setups
                                  .where((setup) => setup.kiteId == item.id)
                                  .length,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildInventoryRow(
                    label: 'Tablas',
                    value: '${boards.length}',
                    onTap: () => _openInventoryChartDialog(
                      context,
                      title: 'Tablas',
                      data: boards
                          .map(
                            (item) => _UsageDatum(
                              label: '${item.brand} ${item.model}',
                              sessions: setups
                                  .where((setup) => setup.boardId == item.id)
                                  .length,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildInventoryRow(
                    label: 'Barras',
                    value: '${bars.length}',
                    onTap: () => _openInventoryChartDialog(
                      context,
                      title: 'Barras',
                      data: bars
                          .map(
                            (item) => _UsageDatum(
                              label: '${item.brand} ${item.model}',
                              sessions: setups
                                  .where((setup) => setup.barId == item.id)
                                  .length,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildInventoryRow(
                    label: 'Arneses',
                    value: '${harnesses.length}',
                    onTap: () => _openInventoryChartDialog(
                      context,
                      title: 'Arneses',
                      data: harnesses
                          .map(
                            (item) => _UsageDatum(
                              label: '${item.brand} ${item.model}',
                              sessions: setups
                                  .where((setup) => setup.harnessId == item.id)
                                  .length,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildInventoryRow(
                    label: 'Trajes',
                    value: '${wetsuits.length}',
                    onTap: () => _openInventoryChartDialog(
                      context,
                      title: 'Trajes',
                      data: wetsuits
                          .map(
                            (item) => _UsageDatum(
                              label: '${item.brand} ${item.model}',
                              sessions: setups
                                  .where((setup) => setup.wetsuitId == item.id)
                                  .length,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildInventoryRow(
                    label: 'Cascos',
                    value: '${helmets.length}',
                    onTap: () => _openInventoryChartDialog(
                      context,
                      title: 'Cascos',
                      data: helmets
                          .map(
                            (item) => _UsageDatum(
                              label: '${item.brand} ${item.model}',
                              sessions: setups
                                  .where((setup) => setup.helmetId == item.id)
                                  .length,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  _buildInventoryRow(
                    label: 'Chalecos',
                    value: '${vests.length}',
                    onTap: () => _openInventoryChartDialog(
                      context,
                      title: 'Chalecos',
                      data: vests
                          .map(
                            (item) => _UsageDatum(
                              label: '${item.brand} ${item.model}',
                              sessions: setups
                                  .where((setup) => setup.vestId == item.id)
                                  .length,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Uso por componente', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _buildComponentUsageRow(
                    context,
                    label: 'Con barra',
                    count: withBar,
                    total: total,
                    percentLabel: percent(withBar),
                  ),
                  _buildComponentUsageRow(
                    context,
                    label: 'Con arnes',
                    count: withHarness,
                    total: total,
                    percentLabel: percent(withHarness),
                  ),
                  _buildComponentUsageRow(
                    context,
                    label: 'Con traje',
                    count: withWetsuit,
                    total: total,
                    percentLabel: percent(withWetsuit),
                  ),
                  _buildComponentUsageRow(
                    context,
                    label: 'Con casco',
                    count: withHelmet,
                    total: total,
                    percentLabel: percent(withHelmet),
                  ),
                  _buildComponentUsageRow(
                    context,
                    label: 'Con chaleco',
                    count: withVest,
                    total: total,
                    percentLabel: percent(withVest),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Rotacion y diversidad', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    'Top cometas',
                    topUsage(kiteUsage, labelFromKiteId).isEmpty
                        ? '-'
                        : topUsage(kiteUsage, labelFromKiteId).join(' · '),
                  ),
                  _buildDetailRow(
                    'Top tablas',
                    topUsage(boardUsage, labelFromBoardId).isEmpty
                        ? '-'
                        : topUsage(boardUsage, labelFromBoardId).join(' · '),
                  ),
                  _buildDetailRow(
                    'Combinaciones unicas',
                    '$uniqueCombinations',
                  ),
                  _buildDetailRow(
                    'Diversidad del quiver',
                    percentOf(uniqueCombinations, total),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dependencia y actualizacion',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    'Dependencia cometa top',
                    percentOf(maxKiteUse, total),
                  ),
                  _buildDetailRow(
                    'Dependencia tabla top',
                    percentOf(maxBoardUse, total),
                  ),
                  _buildDetailRow(
                    'Dependencia barra top',
                    percentOf(maxBarUse, total),
                  ),
                  _buildDetailRow(
                    'Dependencia arnes top',
                    percentOf(maxHarnessUse, total),
                  ),
                  _buildDetailRow(
                    'Dependencia traje top',
                    percentOf(maxWetsuitUse, total),
                  ),
                  _buildDetailRow(
                    'Dependencia casco top',
                    percentOf(maxHelmetUse, total),
                  ),
                  _buildDetailRow(
                    'Dependencia chaleco top',
                    percentOf(maxVestUse, total),
                  ),
                  _buildDetailRow('Ultima actualizacion cometa', lastKite),
                  _buildDetailRow('Ultima actualizacion tabla', lastBoard),
                  _buildDetailRow('Ultima actualizacion barra', lastBar),
                  _buildDetailRow('Ultima actualizacion arnes', lastHarness),
                  _buildDetailRow('Ultima actualizacion traje', lastWetsuit),
                  _buildDetailRow('Ultima actualizacion casco', lastHelmet),
                  _buildDetailRow('Ultima actualizacion chaleco', lastVest),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Material y tallas', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    'Antigüedad media global',
                    averageYear(allYears),
                  ),
                  _buildDetailRow(
                    'Año medio cometas',
                    averageYear(
                      kites.map((e) => parseYear(e.year)).whereType<int>(),
                    ),
                  ),
                  _buildDetailRow(
                    'Año medio tablas',
                    averageYear(
                      boards.map((e) => parseYear(e.year)).whereType<int>(),
                    ),
                  ),
                  _buildDetailRow(
                    'Tallas arnes',
                    distributionLabel(harnesses.map((e) => e.size)),
                  ),
                  _buildDetailRow(
                    'Tallas traje',
                    distributionLabel(wetsuits.map((e) => e.size)),
                  ),
                  _buildDetailRow(
                    'Tallas chaleco',
                    distributionLabel(vests.map((e) => e.size)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Perfiles tecnicos', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow('Cometas <=9m', '$smallKites'),
                  _buildDetailRow('Cometas 10-13m', '$mediumKites'),
                  _buildDetailRow('Cometas >13m', '$largeKites'),
                  _buildDetailRow(
                    'Balance tablas',
                    boardTypeMap.isEmpty
                        ? '-'
                        : boardTypeMap.entries
                              .map((e) => '${e.key}:${e.value}')
                              .join(' · '),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calidad de configuracion',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _buildDetailRow(
                    'Version minima',
                    '$minimalSetups (${percentOf(minimalSetups, total)})',
                  ),
                  _buildDetailRow(
                    'Version media',
                    '$mediumSetups (${percentOf(mediumSetups, total)})',
                  ),
                  _buildDetailRow(
                    'Version completa',
                    '$complete (${percentOf(complete, total)})',
                  ),
                  _buildDetailRow(
                    'Indice de reutilizacion',
                    percentOf(reusedSetups, total),
                  ),
                  _buildDetailRow('Items inconsistentes', '$inconsistentItems'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInventoryRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: AppSpacing.xs),
          TextButton(onPressed: onTap, child: const Text('Detalles')),
        ],
      ),
    );
  }

  Widget _buildComponentUsageRow(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required String percentLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            percentLabel,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: AppSpacing.xs),
          TextButton(
            onPressed: () => _openComponentDetailsDialog(
              context,
              label: label,
              count: count,
              total: total,
              percentLabel: percentLabel,
            ),
            child: const Text('Detalles'),
          ),
        ],
      ),
    );
  }

  Future<void> _openComponentDetailsDialog(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required String percentLabel,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Detalle: $label'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Porcentaje de uso: $percentLabel'),
              const SizedBox(height: AppSpacing.xs),
              Text('Equipaciones con este componente: $count'),
              const SizedBox(height: AppSpacing.xs),
              Text('Equipaciones totales analizadas: $total'),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openInventoryChartDialog(
    BuildContext context, {
    required String title,
    required List<_UsageDatum> data,
  }) async {
    var metric = 'Numero de sesiones';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final values = data
                .map(
                  (item) => metric == 'Numero de sesiones'
                      ? item.sessions.toDouble()
                      : item.sessions * 2.0,
                )
                .toList();
            final maxValue = values.isEmpty
                ? 1.0
                : values.reduce((a, b) => a > b ? a : b).clamp(1.0, 9999.0);

            return AlertDialog(
              title: Text('Uso de $title'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey('inventory-metric-$metric'),
                      initialValue: metric,
                      decoration: const InputDecoration(labelText: 'Parametro'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Numero de sesiones',
                          child: Text('Numero de sesiones'),
                        ),
                        DropdownMenuItem(
                          value: 'Tiempo total de uso',
                          child: Text('Tiempo total de uso'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => metric = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (data.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        child: Text(
                          'No hay elementos guardados para este tipo.',
                        ),
                      )
                    else
                      ...List.generate(data.length, (index) {
                        final item = data[index];
                        final value = metric == 'Numero de sesiones'
                            ? item.sessions.toDouble()
                            : item.sessions * 2.0;
                        final ratio = value / maxValue;
                        final valueLabel = metric == 'Numero de sesiones'
                            ? '${value.toInt()} sesiones'
                            : '${value.toStringAsFixed(1)} h';

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 130,
                                child: Text(
                                  item.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 14,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              SizedBox(
                                width: 80,
                                child: Text(
                                  valueLabel,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _UsageDatum {
  final String label;
  final int sessions;

  _UsageDatum({required this.label, required this.sessions});
}
