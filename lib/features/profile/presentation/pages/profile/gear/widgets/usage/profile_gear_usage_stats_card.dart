import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/dialogs/profile_gear_usage_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/actions/profile_gear_usage_details_button.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/header/profile_gear_usage_stats_header.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/usage/rows/profile_gear_usage_stat_row.dart';

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
  });

  final List<GearSetup> savedGearSetups;
  final List<KiteItem> savedKites;
  final List<BoardItem> savedBoards;
  final List<BarItem> savedBars;
  final List<HarnessItem> savedHarnesses;
  final List<WetsuitItem> savedWetsuits;
  final List<HelmetItem> savedHelmets;
  final List<VestItem> savedVests;

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
    final lastSavedLabel = savedGearSetups.isEmpty
        ? '-'
        : _formatSimpleDate(savedGearSetups.first.createdAt);
    final mostUsedSetupLabel = _mostUsedSetupLabel();
    final favoriteKiteLabel = _favoriteKiteLabel();
    final favoriteBoardLabel = _favoriteBoardLabel();

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
              label: 'Ultima configuracion',
              value: lastSavedLabel,
            ),
            ProfileGearUsageStatRow(
              label: 'Equipacion mas usada',
              value: mostUsedSetupLabel,
            ),
            ProfileGearUsageStatRow(
              label: 'Cometa mas usada',
              value: favoriteKiteLabel,
            ),
            ProfileGearUsageStatRow(
              label: 'Tabla mas usada',
              value: favoriteBoardLabel,
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
      ),
    );
  }

  String _mostUsedSetupLabel() {
    if (savedGearSetups.isEmpty) return '-';
    final usage = <String, int>{};
    for (final setup in savedGearSetups) {
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
    for (final setup in savedGearSetups) {
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
    for (final setup in savedGearSetups) {
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

  String _formatSimpleDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
