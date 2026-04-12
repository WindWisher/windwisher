import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/details/profile_gear_usage_category_selector.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/details/profile_gear_usage_detail_tile.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/details/profile_gear_usage_dialog_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/details/profile_gear_usage_section_card.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';

class ProfileGearUsageDialog extends StatelessWidget {
  final List<GearSetup> setups;
  final List<KiteItem> kites;
  final List<BoardItem> boards;
  final List<BarItem> bars;
  final List<HarnessItem> harnesses;
  final List<WetsuitItem> wetsuits;
  final List<HelmetItem> helmets;
  final List<VestItem> vests;
  final List<RecordedSession> recordedSessions;

  const ProfileGearUsageDialog({
    super.key,
    required this.setups,
    required this.kites,
    required this.boards,
    required this.bars,
    required this.harnesses,
    required this.wetsuits,
    required this.helmets,
    required this.vests,
    required this.recordedSessions,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
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

    String percentOf(int value, int base) {
      if (base == 0) return '0%';
      return '${((value / base) * 100).round()}%';
    }

    double? parseDouble(String value) =>
        double.tryParse(value.replaceAll(',', '.'));

    int? parseYear(String value) => int.tryParse(value.trim());

    double priceValue(String raw) {
      return double.tryParse(raw.replaceAll(',', '.').trim()) ?? 0.0;
    }

    String formatCurrency(double value) {
      return value <= 0 ? '-' : '${value.toStringAsFixed(0)} EUR';
    }

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

    GearSetup? resolveSetupForSession(RecordedSession session) {
      if (session.gearSetupId != null) {
        for (final setup in setups) {
          if (setup.id == session.gearSetupId) {
            return setup;
          }
        }
      }
      final setupName = session.gearSetupName?.trim();
      if (setupName == null || setupName.isEmpty) {
        return null;
      }
      for (final setup in setups) {
        if (setup.name.trim() == setupName) {
          return setup;
        }
      }
      return null;
    }

    final trackedSessions = <RecordedSession>[];
    final setupSessionUsage = <String, int>{};
    final kiteSessionUsage = <String, int>{};
    final boardSessionUsage = <String, int>{};
    final barSessionUsage = <String, int>{};
    final harnessSessionUsage = <String, int>{};
    final wetsuitSessionUsage = <String, int>{};
    final helmetSessionUsage = <String, int>{};
    final vestSessionUsage = <String, int>{};
    var sessionsWithBar = 0;
    var sessionsWithHarness = 0;
    var sessionsWithWetsuit = 0;
    var sessionsWithHelmet = 0;
    var sessionsWithVest = 0;
    var trackedDuration = Duration.zero;
    DateTime? latestTrackedSessionAt;

    for (final session in recordedSessions) {
      final setup = resolveSetupForSession(session);
      if (setup == null) {
        continue;
      }
      trackedSessions.add(session);
      trackedDuration += session.duration;
      latestTrackedSessionAt =
          latestTrackedSessionAt == null ||
              session.endedAt.isAfter(latestTrackedSessionAt)
          ? session.endedAt
          : latestTrackedSessionAt;
      setupSessionUsage[setup.id] = (setupSessionUsage[setup.id] ?? 0) + 1;
      kiteSessionUsage[setup.kiteId] =
          (kiteSessionUsage[setup.kiteId] ?? 0) + 1;
      boardSessionUsage[setup.boardId] =
          (boardSessionUsage[setup.boardId] ?? 0) + 1;
      if (setup.barId != null) {
        sessionsWithBar += 1;
        barSessionUsage[setup.barId!] =
            (barSessionUsage[setup.barId!] ?? 0) + 1;
      }
      if (setup.harnessId != null) {
        sessionsWithHarness += 1;
        harnessSessionUsage[setup.harnessId!] =
            (harnessSessionUsage[setup.harnessId!] ?? 0) + 1;
      }
      if (setup.wetsuitId != null) {
        sessionsWithWetsuit += 1;
        wetsuitSessionUsage[setup.wetsuitId!] =
            (wetsuitSessionUsage[setup.wetsuitId!] ?? 0) + 1;
      }
      if (setup.helmetId != null) {
        sessionsWithHelmet += 1;
        helmetSessionUsage[setup.helmetId!] =
            (helmetSessionUsage[setup.helmetId!] ?? 0) + 1;
      }
      if (setup.vestId != null) {
        sessionsWithVest += 1;
        vestSessionUsage[setup.vestId!] =
            (vestSessionUsage[setup.vestId!] ?? 0) + 1;
      }
    }

    String labelFromSetupId(String id) {
      for (final setup in setups) {
        if (setup.id == id) {
          return setup.name;
        }
      }
      return id;
    }

    String formatDuration(Duration duration) {
      if (duration.inMinutes <= 0) return '0 min';
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      if (hours == 0) return '${duration.inMinutes} min';
      if (minutes == 0) return '$hours h';
      return '$hours h $minutes min';
    }

    String formatSimpleDate(DateTime date) {
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year.toString();
      return '$day/$month/$year';
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

    String labelFromBarId(String id) {
      for (final item in bars) {
        if (item.id == id) {
          return '${item.brand} ${item.model}';
        }
      }
      return id;
    }

    String labelFromHarnessId(String id) {
      for (final item in harnesses) {
        if (item.id == id) {
          return '${item.brand} ${item.model}';
        }
      }
      return id;
    }

    String labelFromWetsuitId(String id) {
      for (final item in wetsuits) {
        if (item.id == id) {
          return '${item.brand} ${item.model}';
        }
      }
      return id;
    }

    String labelFromHelmetId(String id) {
      for (final item in helmets) {
        if (item.id == id) {
          return '${item.brand} ${item.model}';
        }
      }
      return id;
    }

    String labelFromVestId(String id) {
      for (final item in vests) {
        if (item.id == id) {
          return '${item.brand} ${item.model}';
        }
      }
      return id;
    }

    KiteItem? kiteById(String id) {
      for (final item in kites) {
        if (item.id == id) return item;
      }
      return null;
    }

    BoardItem? boardById(String id) {
      for (final item in boards) {
        if (item.id == id) return item;
      }
      return null;
    }

    BarItem? barById(String? id) {
      if (id == null) return null;
      for (final item in bars) {
        if (item.id == id) return item;
      }
      return null;
    }

    HarnessItem? harnessById(String? id) {
      if (id == null) return null;
      for (final item in harnesses) {
        if (item.id == id) return item;
      }
      return null;
    }

    WetsuitItem? wetsuitById(String? id) {
      if (id == null) return null;
      for (final item in wetsuits) {
        if (item.id == id) return item;
      }
      return null;
    }

    HelmetItem? helmetById(String? id) {
      if (id == null) return null;
      for (final item in helmets) {
        if (item.id == id) return item;
      }
      return null;
    }

    VestItem? vestById(String? id) {
      if (id == null) return null;
      for (final item in vests) {
        if (item.id == id) return item;
      }
      return null;
    }

    double setupCost(GearSetup setup) {
      return priceValue(kiteById(setup.kiteId)?.priceEur ?? '') +
          priceValue(boardById(setup.boardId)?.priceEur ?? '') +
          priceValue(barById(setup.barId)?.priceEur ?? '') +
          priceValue(harnessById(setup.harnessId)?.priceEur ?? '') +
          priceValue(wetsuitById(setup.wetsuitId)?.priceEur ?? '') +
          priceValue(helmetById(setup.helmetId)?.priceEur ?? '') +
          priceValue(vestById(setup.vestId)?.priceEur ?? '');
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

    String topUsageLabel(
      Map<String, int> usage,
      String Function(String id) labelOf,
    ) {
      final labels = topUsage(usage, labelOf);
      return labels.isEmpty ? '-' : labels.join(' · ');
    }

    String averageDoubleLabel(
      Iterable<String> rawValues, {
      required String suffix,
      int decimals = 1,
    }) {
      final values = rawValues.map(parseDouble).whereType<double>().toList();
      if (values.isEmpty) return '-';
      final avg = values.reduce((a, b) => a + b) / values.length;
      return '${avg.toStringAsFixed(decimals)} $suffix';
    }

    String numericRangeLabel(
      Iterable<String> rawValues, {
      required String suffix,
      int decimals = 1,
    }) {
      final values = rawValues.map(parseDouble).whereType<double>().toList();
      if (values.isEmpty) return '-';
      values.sort();
      final min = values.first.toStringAsFixed(decimals);
      final max = values.last.toStringAsFixed(decimals);
      return '$min-$max $suffix';
    }

    int distinctCount(Iterable<String> rawValues) {
      return rawValues
          .map((value) => value.trim().toUpperCase())
          .where((value) => value.isNotEmpty)
          .toSet()
          .length;
    }

    String yearRangeLabel(Iterable<int> years) {
      final list = years.toList()..sort();
      if (list.isEmpty) return '-';
      return '${list.first}-${list.last}';
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
    final totalInventoryItems =
        kites.length +
        boards.length +
        bars.length +
        harnesses.length +
        wetsuits.length +
        helmets.length +
        vests.length;
    final optionalComponentsAverage = total == 0
        ? '0.0/5'
        : '${((withBar + withHarness + withWetsuit + withHelmet + withVest) / total).toStringAsFixed(1)}/5';
    final threePlusExtras = countWhere((setup) {
      var extras = 0;
      if (setup.barId != null) extras++;
      if (setup.harnessId != null) extras++;
      if (setup.wetsuitId != null) extras++;
      if (setup.helmetId != null) extras++;
      if (setup.vestId != null) extras++;
      return extras >= 3;
    });
    final latestGlobal = daysSinceLabel(latest(setups.map((s) => s.createdAt)));
    final uniqueBrandsTotal = distinctCount([
      ...kites.map((item) => item.brand),
      ...boards.map((item) => item.brand),
      ...bars.map((item) => item.brand),
      ...harnesses.map((item) => item.brand),
      ...wetsuits.map((item) => item.brand),
      ...helmets.map((item) => item.brand),
      ...vests.map((item) => item.brand),
    ]);
    final uniqueKiteBrands = distinctCount(kites.map((item) => item.brand));
    final uniqueBoardBrands = distinctCount(boards.map((item) => item.brand));
    final uniqueBoardTypes = distinctCount(boards.map((item) => item.type));

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

    final inventoryCost =
        kites.fold<double>(
          0.0,
          (sum, item) => sum + priceValue(item.priceEur),
        ) +
        boards.fold<double>(
          0.0,
          (sum, item) => sum + priceValue(item.priceEur),
        ) +
        bars.fold<double>(0.0, (sum, item) => sum + priceValue(item.priceEur)) +
        harnesses.fold<double>(
          0.0,
          (sum, item) => sum + priceValue(item.priceEur),
        ) +
        wetsuits.fold<double>(
          0.0,
          (sum, item) => sum + priceValue(item.priceEur),
        ) +
        helmets.fold<double>(
          0.0,
          (sum, item) => sum + priceValue(item.priceEur),
        ) +
        vests.fold<double>(0.0, (sum, item) => sum + priceValue(item.priceEur));
    final setupCosts = <String, double>{};
    for (final setup in setups) {
      setupCosts[setup.id] = setupCost(setup);
    }
    final totalTrackedSetupCost = trackedSessions.fold<double>(0.0, (
      sum,
      session,
    ) {
      final setup = resolveSetupForSession(session);
      if (setup == null) return sum;
      return sum + (setupCosts[setup.id] ?? 0.0);
    });
    final averageTrackedSetupCost = trackedSessions.isEmpty
        ? 0.0
        : totalTrackedSetupCost / trackedSessions.length;
    final inventoryCostPerSession = trackedSessions.isEmpty
        ? 0.0
        : inventoryCost / trackedSessions.length;
    final amortizedSessionCost = trackedSessions.fold<double>(0.0, (
      sum,
      session,
    ) {
      final setup = resolveSetupForSession(session);
      if (setup == null) return sum;
      final sessionCount = setupSessionUsage[setup.id] ?? 0;
      if (sessionCount == 0) return sum;
      return sum + ((setupCosts[setup.id] ?? 0.0) / sessionCount);
    });
    final averageAmortizedSessionCost = trackedSessions.isEmpty
        ? 0.0
        : amortizedSessionCost / trackedSessions.length;
    final topSetupCostLabel = setupSessionUsage.isEmpty
        ? '-'
        : (() {
            final topId = setupSessionUsage.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final id = topId.first.key;
            return '${labelFromSetupId(id)} (${formatCurrency(setupCosts[id] ?? 0.0)})';
          })();

    final sections = <ProfileGearUsageSectionData>[
      ProfileGearUsageSectionData(
        title: 'Resumen',
        description:
            'Vista rapida del inventario guardado y su grado de completitud.',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Resumen', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _buildDetailRow('Equipaciones totales', '$total'),
                _buildDetailRow('Equipaciones completas', '$complete'),
                _buildDetailRow(
                  'Equipaciones completas (%)',
                  total == 0 ? '0%' : '${((complete / total) * 100).round()}%',
                ),
                _buildDetailRow('Equipaciones minimas', '$minimalSetups'),
                _buildDetailRow('Equipaciones intermedias', '$mediumSetups'),
                _buildDetailRow(
                  'Inventario total de piezas',
                  '$totalInventoryItems',
                ),
                _buildDetailRow(
                  'Cobertura media opcional',
                  optionalComponentsAverage,
                ),
              ],
            ),
          ),
        ),
      ),
      ProfileGearUsageSectionData(
        title: 'Uso en sesiones',
        description:
            'Uso real del material cuando la sesion quedó guardada con equipacion asociada.',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uso en sesiones', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _buildDetailRow(
                  'Sesiones con equipo asignado',
                  '${trackedSessions.length}',
                ),
                _buildDetailRow(
                  'Cobertura sobre sesiones',
                  percentOf(trackedSessions.length, recordedSessions.length),
                ),
                _buildDetailRow(
                  'Tiempo total con equipo',
                  formatDuration(trackedDuration),
                ),
                _buildDetailRow(
                  'Tiempo medio por sesion',
                  trackedSessions.isEmpty
                      ? '0 min'
                      : formatDuration(
                          Duration(
                            minutes:
                                trackedDuration.inMinutes ~/
                                trackedSessions.length,
                          ),
                        ),
                ),
                _buildDetailRow(
                  'Ultima sesion con equipo',
                  latestTrackedSessionAt == null
                      ? '-'
                      : formatSimpleDate(latestTrackedSessionAt),
                ),
                _buildDetailRow(
                  'Equipacion mas usada',
                  topUsageLabel(setupSessionUsage, labelFromSetupId),
                ),
                _buildDetailRow(
                  'Cometa mas usada en sesiones',
                  topUsageLabel(kiteSessionUsage, labelFromKiteId),
                ),
                _buildDetailRow(
                  'Tabla mas usada en sesiones',
                  topUsageLabel(boardSessionUsage, labelFromBoardId),
                ),
              ],
            ),
          ),
        ),
      ),
      ProfileGearUsageSectionData(
        title: 'Coste',
        description:
            'Lectura economica del material guardado y del coste repartido entre las sesiones registradas.',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Coste', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _buildDetailRow(
                  'Valor total del inventario',
                  formatCurrency(inventoryCost),
                ),
                _buildDetailRow(
                  'Coste medio de equipacion usada',
                  formatCurrency(averageTrackedSetupCost),
                ),
                _buildDetailRow(
                  'Inventario por sesion registrada',
                  formatCurrency(inventoryCostPerSession),
                ),
                _buildDetailRow(
                  'Amortizacion media por sesion',
                  formatCurrency(averageAmortizedSessionCost),
                ),
                _buildDetailRow('Equipacion top y su coste', topSetupCostLabel),
              ],
            ),
          ),
        ),
      ),
      ProfileGearUsageSectionData(
        title: 'Inventario',
        description:
            'Conteo de piezas disponibles y acceso al detalle de cada familia de material.',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inventario', style: textTheme.titleMedium),
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
                            sessions: kiteSessionUsage[item.id] ?? 0,
                            price: priceValue(item.priceEur),
                          ),
                        )
                        .toList(),
                    totalCount: trackedSessions.length,
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
                            sessions: boardSessionUsage[item.id] ?? 0,
                            price: priceValue(item.priceEur),
                          ),
                        )
                        .toList(),
                    totalCount: trackedSessions.length,
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
                            sessions: barSessionUsage[item.id] ?? 0,
                            price: priceValue(item.priceEur),
                          ),
                        )
                        .toList(),
                    totalCount: trackedSessions.length,
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
                            sessions: harnessSessionUsage[item.id] ?? 0,
                            price: priceValue(item.priceEur),
                          ),
                        )
                        .toList(),
                    totalCount: trackedSessions.length,
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
                            sessions: wetsuitSessionUsage[item.id] ?? 0,
                            price: priceValue(item.priceEur),
                          ),
                        )
                        .toList(),
                    totalCount: trackedSessions.length,
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
                            sessions: helmetSessionUsage[item.id] ?? 0,
                            price: priceValue(item.priceEur),
                          ),
                        )
                        .toList(),
                    totalCount: trackedSessions.length,
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
                            sessions: vestSessionUsage[item.id] ?? 0,
                            price: priceValue(item.priceEur),
                          ),
                        )
                        .toList(),
                    totalCount: trackedSessions.length,
                  ),
                ),
                _buildDetailRow('Marcas unicas totales', '$uniqueBrandsTotal'),
                _buildDetailRow('Marcas de cometas', '$uniqueKiteBrands'),
                _buildDetailRow('Marcas de tablas', '$uniqueBoardBrands'),
                _buildDetailRow('Tipos de tabla', '$uniqueBoardTypes'),
              ],
            ),
          ),
        ),
      ),
      ProfileGearUsageSectionData(
        title: 'Uso por componente',
        description:
            'Cobertura real de cada componente dentro de las sesiones que quedaron asociadas a una equipacion.',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Uso por componente', style: textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                _buildComponentUsageRow(
                  context,
                  label: 'Sesiones con barra',
                  count: sessionsWithBar,
                  total: trackedSessions.length,
                  percentLabel: percentOf(
                    sessionsWithBar,
                    trackedSessions.length,
                  ),
                ),
                _buildComponentUsageRow(
                  context,
                  label: 'Sesiones con arnes',
                  count: sessionsWithHarness,
                  total: trackedSessions.length,
                  percentLabel: percentOf(
                    sessionsWithHarness,
                    trackedSessions.length,
                  ),
                ),
                _buildComponentUsageRow(
                  context,
                  label: 'Sesiones con traje',
                  count: sessionsWithWetsuit,
                  total: trackedSessions.length,
                  percentLabel: percentOf(
                    sessionsWithWetsuit,
                    trackedSessions.length,
                  ),
                ),
                _buildComponentUsageRow(
                  context,
                  label: 'Sesiones con casco',
                  count: sessionsWithHelmet,
                  total: trackedSessions.length,
                  percentLabel: percentOf(
                    sessionsWithHelmet,
                    trackedSessions.length,
                  ),
                ),
                _buildComponentUsageRow(
                  context,
                  label: 'Sesiones con chaleco',
                  count: sessionsWithVest,
                  total: trackedSessions.length,
                  percentLabel: percentOf(
                    sessionsWithVest,
                    trackedSessions.length,
                  ),
                ),
                _buildDetailRow(
                  'Equipaciones con 3+ extras',
                  '$threePlusExtras',
                ),
                _buildDetailRow(
                  'Base pura sin extras',
                  '$minimalSetups (${percentOf(minimalSetups, total)})',
                ),
              ],
            ),
          ),
        ),
      ),
      ProfileGearUsageSectionData(
        title: 'Rotacion y diversidad',
        description:
            'Como se reparte el material entre las equipaciones guardadas y que piezas se repiten mas.',
        child: Card(
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
                _buildDetailRow('Combinaciones unicas', '$uniqueCombinations'),
                _buildDetailRow(
                  'Diversidad del quiver',
                  percentOf(uniqueCombinations, total),
                ),
                _buildDetailRow(
                  'Top barras',
                  topUsageLabel(barUsage, labelFromBarId),
                ),
                _buildDetailRow(
                  'Top arneses',
                  topUsageLabel(harnessUsage, labelFromHarnessId),
                ),
                _buildDetailRow(
                  'Top trajes',
                  topUsageLabel(wetsuitUsage, labelFromWetsuitId),
                ),
                _buildDetailRow(
                  'Top cascos',
                  topUsageLabel(helmetUsage, labelFromHelmetId),
                ),
                _buildDetailRow(
                  'Top chalecos',
                  topUsageLabel(vestUsage, labelFromVestId),
                ),
              ],
            ),
          ),
        ),
      ),
      ProfileGearUsageSectionData(
        title: 'Dependencia y actualizacion',
        description:
            'Cuanto depende el inventario de piezas top y lo reciente que esta cada bloque.',
        child: Card(
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
                _buildDetailRow('Ultima actualizacion global', latestGlobal),
              ],
            ),
          ),
        ),
      ),
      ProfileGearUsageSectionData(
        title: 'Material y tallas',
        description:
            'Resumen tecnico de antiguedad media y distribucion de tallas.',
        child: Card(
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
                _buildDetailRow(
                  'Año mas antiguo',
                  yearRangeLabel(allYears).split('-').first,
                ),
                _buildDetailRow(
                  'Año mas nuevo',
                  yearRangeLabel(allYears).split('-').last,
                ),
                _buildDetailRow('Rango de años', yearRangeLabel(allYears)),
                _buildDetailRow(
                  'Año medio barras',
                  averageYear(
                    bars.map((e) => parseYear(e.year)).whereType<int>(),
                  ),
                ),
                _buildDetailRow(
                  'Año medio trajes',
                  averageYear(
                    wetsuits.map((e) => parseYear(e.year)).whereType<int>(),
                  ),
                ),
                _buildDetailRow(
                  'Grosor trajes',
                  distributionLabel(wetsuits.map((e) => e.thickness)),
                ),
              ],
            ),
          ),
        ),
      ),
      ProfileGearUsageSectionData(
        title: 'Perfiles tecnicos',
        description:
            'Lectura rapida del reparto de medidas y tipos dentro del quiver.',
        child: Card(
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
                _buildDetailRow(
                  'Tamano medio cometa',
                  averageDoubleLabel(
                    kites.map((e) => e.sizeMeters),
                    suffix: 'm',
                  ),
                ),
                _buildDetailRow(
                  'Rango tamano cometa',
                  numericRangeLabel(
                    kites.map((e) => e.sizeMeters),
                    suffix: 'm',
                  ),
                ),
                _buildDetailRow(
                  'Longitud media lineas',
                  averageDoubleLabel(
                    bars.map((e) => e.lineLengthMeters),
                    suffix: 'm',
                  ),
                ),
                _buildDetailRow(
                  'Rango lineas',
                  numericRangeLabel(
                    bars.map((e) => e.lineLengthMeters),
                    suffix: 'm',
                  ),
                ),
                _buildDetailRow(
                  'Ancho medio barra',
                  averageDoubleLabel(
                    bars.map((e) => e.widthCm),
                    suffix: 'cm',
                    decimals: 0,
                  ),
                ),
                _buildDetailRow(
                  'Rango ancho barra',
                  numericRangeLabel(
                    bars.map((e) => e.widthCm),
                    suffix: 'cm',
                    decimals: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ProfileGearUsageSectionData(
        title: 'Calidad de configuracion',
        description:
            'Nivel de completitud y consistencia del material configurado.',
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Calidad de configuracion', style: textTheme.titleMedium),
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
                _buildDetailRow('Equipaciones reutilizadas', '$reusedSetups'),
                _buildDetailRow('Items inconsistentes', '$inconsistentItems'),
                _buildDetailRow(
                  'Inconsistencia del inventario',
                  totalInventoryItems == 0
                      ? '0%'
                      : '${((inconsistentItems / totalInventoryItems) * 100).round()}%',
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    var selectedIndex = 0;

    return StatefulBuilder(
      builder: (context, setDialogState) {
        final activeSection =
            sections[selectedIndex.clamp(0, sections.length - 1)];

        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 760),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Detalle estadisticas del equipo',
                              style: textTheme.titleLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Resumen extendido del material guardado y del uso real detectado cuando la sesion tiene equipacion asociada.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: 'Cerrar',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ProfileGearUsageCategorySelector(
                    sections: sections,
                    selectedIndex: selectedIndex,
                    onSelected: (index) {
                      setDialogState(() => selectedIndex = index);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Flexible(
                    child: SingleChildScrollView(
                      child: ProfileGearUsageSectionCard(
                        section: activeSection,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return ProfileGearUsageDetailTile(label: label, value: value);
  }

  Widget _buildInventoryRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ProfileGearUsageDetailTile(
      label: label,
      value: value,
      action: TextButton(onPressed: onTap, child: const Text('Detalles')),
    );
  }

  Widget _buildComponentUsageRow(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required String percentLabel,
  }) {
    return ProfileGearUsageDetailTile(
      label: label,
      value: percentLabel,
      action: TextButton(
        onPressed: () => _openComponentDetailsDialog(
          context,
          label: label,
          count: count,
          total: total,
          percentLabel: percentLabel,
        ),
        child: const Text('Detalles'),
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
              Text('Sesiones con este componente: $count'),
              const SizedBox(height: AppSpacing.xs),
              Text('Sesiones analizadas: $total'),
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
    required int totalCount,
  }) async {
    var metric = 'Numero de sesiones';

    String formatMetricCurrency(double value) {
      return value <= 0 ? '-' : '${value.toStringAsFixed(0)} EUR';
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final values = data.map((item) {
              switch (metric) {
                case 'Numero de sesiones':
                  return item.sessions.toDouble();
                case 'Porcentaje de sesiones':
                  return totalCount == 0
                      ? 0.0
                      : (item.sessions / totalCount) * 100;
                case 'Precio':
                  return item.price;
                case 'Coste por sesion':
                  return item.sessions == 0 ? 0.0 : item.price / item.sessions;
              }
              return 0.0;
            }).toList();
            final maxValue = values.isEmpty
                ? 1.0
                : values.reduce((a, b) => a > b ? a : b).clamp(1.0, 9999.0);

            return AlertDialog(
              title: Text('Uso y coste de $title'),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey('inventory-metric-$metric'),
                      initialValue: metric,
                      decoration: const InputDecoration(labelText: 'Metrica'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Numero de sesiones',
                          child: Text('Numero de sesiones'),
                        ),
                        DropdownMenuItem(
                          value: 'Porcentaje de sesiones',
                          child: Text('Porcentaje de sesiones'),
                        ),
                        DropdownMenuItem(
                          value: 'Precio',
                          child: Text('Precio'),
                        ),
                        DropdownMenuItem(
                          value: 'Coste por sesion',
                          child: Text('Coste por sesion'),
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
                          'No hay material guardado en esta categoria.',
                        ),
                      )
                    else
                      ...List.generate(data.length, (index) {
                        final item = data[index];
                        final value = switch (metric) {
                          'Numero de sesiones' => item.sessions.toDouble(),
                          'Porcentaje de sesiones' =>
                            totalCount == 0
                                ? 0.0
                                : (item.sessions / totalCount) * 100,
                          'Precio' => item.price,
                          'Coste por sesion' =>
                            item.sessions == 0
                                ? 0.0
                                : item.price / item.sessions,
                          _ => 0.0,
                        };
                        final ratio = value / maxValue;
                        final valueLabel = switch (metric) {
                          'Numero de sesiones' => '${value.toInt()} sesiones',
                          'Porcentaje de sesiones' =>
                            '${value.toStringAsFixed(0)}%',
                          'Precio' => formatMetricCurrency(value),
                          'Coste por sesion' => formatMetricCurrency(value),
                          _ => '-',
                        };

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
                                width: 96,
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
                IconButton(
                  tooltip: 'Cerrar',
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(Icons.close),
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
  final double price;

  _UsageDatum({
    required this.label,
    required this.sessions,
    required this.price,
  });
}
