import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/dialogs/profile_gear_usage_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/actions/profile_gear_usage_details_button.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/header/profile_gear_usage_stats_header.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/rows/profile_gear_usage_stat_row.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';

class ProfileGearUsageStatsCard extends StatelessWidget {
  const ProfileGearUsageStatsCard({
    super.key,
    required this.savedGearSetups,
    required this.savedKites,
    required this.savedBoards,
    required this.savedBars,
    required this.savedHarnesses,
    required this.savedWetsuits,
    required this.savedHelmets,
    required this.savedVests,
    required this.recordedSessions,
  });

  final List<GearSetup> savedGearSetups;
  final List<KiteItem> savedKites;
  final List<BoardItem> savedBoards;
  final List<BarItem> savedBars;
  final List<HarnessItem> savedHarnesses;
  final List<WetsuitItem> savedWetsuits;
  final List<HelmetItem> savedHelmets;
  final List<VestItem> savedVests;
  final List<RecordedSession> recordedSessions;

  @override
  Widget build(BuildContext context) {
    final totalSetups = savedGearSetups.length;
    final completeSetups = savedGearSetups
        .where(
          (setup) =>
              setup.barId != null &&
              setup.harnessId != null &&
              setup.wetsuitId != null &&
              setup.helmetId != null &&
              setup.vestId != null,
        )
        .length;
    final sessionsWithGear = _trackedSessions();
    final lastSessionLabel = sessionsWithGear.isEmpty
        ? '-'
        : _formatSimpleDate(
            sessionsWithGear
                .map((session) => session.endedAt)
                .reduce((a, b) => a.isAfter(b) ? a : b),
          );
    final totalDuration = sessionsWithGear.fold<Duration>(
      Duration.zero,
      (sum, session) => sum + session.duration,
    );
    final inventoryCostLabel = _formatCurrency(_inventoryCost());
    final averageCostPerSessionLabel = sessionsWithGear.isEmpty
        ? '-'
        : _formatCurrency(
            sessionsWithGear
                    .map((session) => _resolveSetup(session))
                    .whereType<GearSetup>()
                    .fold<double>(
                      0.0,
                      (sum, setup) => sum + _setupCost(setup),
                    ) /
                sessionsWithGear.length,
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileGearUsageStatsHeader(),
            const SizedBox(height: AppSpacing.sm),
            ProfileGearUsageStatRow(
              label: 'Equipaciones guardadas',
              value: '$totalSetups',
            ),
            ProfileGearUsageStatRow(
              label: 'Equipaciones completas',
              value: '$completeSetups',
            ),
            ProfileGearUsageStatRow(
              label: 'Sesiones con equipo asignado',
              value: '${sessionsWithGear.length}',
            ),
            ProfileGearUsageStatRow(
              label: 'Tiempo total con equipo',
              value: _formatDuration(totalDuration),
            ),
            ProfileGearUsageStatRow(
              label: 'Valor inventario',
              value: inventoryCostLabel,
            ),
            ProfileGearUsageStatRow(
              label: 'Coste medio por sesion',
              value: averageCostPerSessionLabel,
            ),
            ProfileGearUsageStatRow(
              label: 'Ultima sesion con equipo',
              value: lastSessionLabel,
            ),
            ProfileGearUsageStatRow(
              label: 'Equipacion mas usada',
              value: _mostUsedSetupLabel(),
            ),
            ProfileGearUsageStatRow(
              label: 'Cometa mas usada',
              value: _favoriteKiteLabel(),
            ),
            ProfileGearUsageStatRow(
              label: 'Tabla mas usada',
              value: _favoriteBoardLabel(),
            ),
            const SizedBox(height: AppSpacing.sm),
            ProfileGearUsageDetailsButton(
              onPressed: () => _openGearUsageDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGearUsageDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => ProfileGearUsageDialog(
        setups: savedGearSetups,
        kites: savedKites,
        boards: savedBoards,
        bars: savedBars,
        harnesses: savedHarnesses,
        wetsuits: savedWetsuits,
        helmets: savedHelmets,
        vests: savedVests,
        recordedSessions: recordedSessions,
      ),
    );
  }

  List<RecordedSession> _trackedSessions() {
    return recordedSessions
        .where((session) => _resolveSetup(session) != null)
        .toList(growable: false);
  }

  GearSetup? _resolveSetup(RecordedSession session) {
    if (savedGearSetups.isEmpty) return null;
    for (final setup in savedGearSetups) {
      if (session.gearSetupId != null && session.gearSetupId == setup.id) {
        return setup;
      }
    }
    final setupName = session.gearSetupName?.trim();
    if (setupName == null || setupName.isEmpty) return null;
    for (final setup in savedGearSetups) {
      if (setup.name.trim() == setupName) {
        return setup;
      }
    }
    return null;
  }

  String _mostUsedSetupLabel() {
    final usage = <String, int>{};
    for (final session in recordedSessions) {
      final setup = _resolveSetup(session);
      if (setup == null) continue;
      usage[setup.id] = (usage[setup.id] ?? 0) + 1;
    }
    final topId = _topUsageId(usage);
    if (topId == null) return '-';
    final setup = savedGearSetups.firstWhere(
      (item) => item.id == topId,
      orElse: () => savedGearSetups.first,
    );
    final count = usage[topId] ?? 0;
    return count > 1 ? '${setup.name} ($count)' : setup.name;
  }

  String _favoriteKiteLabel() {
    final usage = <String, int>{};
    for (final session in recordedSessions) {
      final setup = _resolveSetup(session);
      if (setup == null) continue;
      usage[setup.kiteId] = (usage[setup.kiteId] ?? 0) + 1;
    }
    final topId = _topUsageId(usage);
    if (topId == null) return '-';
    KiteItem? kite;
    for (final item in savedKites) {
      if (item.id == topId) {
        kite = item;
        break;
      }
    }
    if (kite == null) return '-';
    final count = usage[topId] ?? 0;
    final label = '${kite.brand} ${kite.model}';
    return count > 1 ? '$label ($count)' : label;
  }

  String _favoriteBoardLabel() {
    final usage = <String, int>{};
    for (final session in recordedSessions) {
      final setup = _resolveSetup(session);
      if (setup == null) continue;
      usage[setup.boardId] = (usage[setup.boardId] ?? 0) + 1;
    }
    final topId = _topUsageId(usage);
    if (topId == null) return '-';
    BoardItem? board;
    for (final item in savedBoards) {
      if (item.id == topId) {
        board = item;
        break;
      }
    }
    if (board == null) return '-';
    final count = usage[topId] ?? 0;
    final label = '${board.brand} ${board.model}';
    return count > 1 ? '$label ($count)' : label;
  }

  String? _topUsageId(Map<String, int> usage) {
    if (usage.isEmpty) return null;
    final entries = usage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }

  double _priceValue(String raw) {
    return double.tryParse(raw.replaceAll(',', '.').trim()) ?? 0.0;
  }

  double _setupCost(GearSetup setup) {
    KiteItem? kite;
    for (final item in savedKites) {
      if (item.id == setup.kiteId) {
        kite = item;
        break;
      }
    }
    BoardItem? board;
    for (final item in savedBoards) {
      if (item.id == setup.boardId) {
        board = item;
        break;
      }
    }
    BarItem? bar;
    if (setup.barId != null) {
      for (final item in savedBars) {
        if (item.id == setup.barId) {
          bar = item;
          break;
        }
      }
    }
    HarnessItem? harness;
    if (setup.harnessId != null) {
      for (final item in savedHarnesses) {
        if (item.id == setup.harnessId) {
          harness = item;
          break;
        }
      }
    }
    WetsuitItem? wetsuit;
    if (setup.wetsuitId != null) {
      for (final item in savedWetsuits) {
        if (item.id == setup.wetsuitId) {
          wetsuit = item;
          break;
        }
      }
    }
    HelmetItem? helmet;
    if (setup.helmetId != null) {
      for (final item in savedHelmets) {
        if (item.id == setup.helmetId) {
          helmet = item;
          break;
        }
      }
    }
    VestItem? vest;
    if (setup.vestId != null) {
      for (final item in savedVests) {
        if (item.id == setup.vestId) {
          vest = item;
          break;
        }
      }
    }

    return _priceValue(kite?.priceEur ?? '') +
        _priceValue(board?.priceEur ?? '') +
        _priceValue(bar?.priceEur ?? '') +
        _priceValue(harness?.priceEur ?? '') +
        _priceValue(wetsuit?.priceEur ?? '') +
        _priceValue(helmet?.priceEur ?? '') +
        _priceValue(vest?.priceEur ?? '');
  }

  double _inventoryCost() {
    double sumPrices<T>(Iterable<T> items, String Function(T item) priceOf) {
      return items.fold<double>(
        0.0,
        (sum, item) => sum + _priceValue(priceOf(item)),
      );
    }

    return sumPrices<KiteItem>(savedKites, (item) => item.priceEur) +
        sumPrices<BoardItem>(savedBoards, (item) => item.priceEur) +
        sumPrices<BarItem>(savedBars, (item) => item.priceEur) +
        sumPrices<HarnessItem>(savedHarnesses, (item) => item.priceEur) +
        sumPrices<WetsuitItem>(savedWetsuits, (item) => item.priceEur) +
        sumPrices<HelmetItem>(savedHelmets, (item) => item.priceEur) +
        sumPrices<VestItem>(savedVests, (item) => item.priceEur);
  }

  String _formatCurrency(double value) {
    return value <= 0 ? '-' : '${value.toStringAsFixed(0)} EUR';
  }

  String _formatSimpleDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes <= 0) return '0 min';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours == 0) return '${duration.inMinutes} min';
    if (minutes == 0) return '$hours h';
    return '$hours h $minutes min';
  }
}
