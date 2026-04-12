import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/setups/dialog/profile_gear_setup_dialog.dart';

class ProfileSummaryGearSetups extends StatelessWidget {
  const ProfileSummaryGearSetups({
    super.key,
    required this.savedGearSetups,
    required this.findKite,
    required this.findBar,
    required this.findBoard,
    required this.findHarness,
    required this.findWetsuit,
    required this.findHelmet,
    required this.findVest,
  });

  final List<GearSetup> savedGearSetups;
  final KiteItem? Function(String id) findKite;
  final BarItem? Function(String id) findBar;
  final BoardItem? Function(String id) findBoard;
  final HarnessItem? Function(String id) findHarness;
  final WetsuitItem? Function(String id) findWetsuit;
  final HelmetItem? Function(String id) findHelmet;
  final VestItem? Function(String id) findVest;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (savedGearSetups.isEmpty) {
      return const SizedBox.shrink();
    }

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        shape: const Border(),
        collapsedShape: const Border(),
        iconColor: colorScheme.primary,
        collapsedIconColor: colorScheme.onSurfaceVariant,
        title: Text(
          'Equipaciones guardadas',
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${savedGearSetups.length} disponibles',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        children: [
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final setup in savedGearSetups)
                  _ProfileSummaryGearSetupChip(
                    setup: setup,
                    detailLines: _buildDetailLines(setup),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildDetailLines(GearSetup setup) {
    final kite = findKite(setup.kiteId);
    final board = findBoard(setup.boardId);
    final bar = setup.barId == null ? null : findBar(setup.barId!);
    final harness = setup.harnessId == null
        ? null
        : findHarness(setup.harnessId!);
    final wetsuit = setup.wetsuitId == null
        ? null
        : findWetsuit(setup.wetsuitId!);
    final helmet = setup.helmetId == null ? null : findHelmet(setup.helmetId!);
    final vest = setup.vestId == null ? null : findVest(setup.vestId!);

    return <String>[
      if (kite != null) 'Cometa: ${kite.brand} ${kite.model}',
      if (board != null) 'Tabla: ${board.brand} ${board.model}',
      if (bar != null) 'Barra: ${bar.brand} ${bar.model}',
      if (harness != null) 'Arnes: ${harness.brand} ${harness.model}',
      if (wetsuit != null) 'Traje: ${wetsuit.brand} ${wetsuit.model}',
      if (helmet != null) 'Casco: ${helmet.brand} ${helmet.model}',
      if (vest != null) 'Chaleco: ${vest.brand} ${vest.model}',
    ];
  }
}

class _ProfileSummaryGearSetupChip extends StatelessWidget {
  const _ProfileSummaryGearSetupChip({
    required this.setup,
    required this.detailLines,
  });

  final GearSetup setup;
  final List<String> detailLines;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () {
          ProfileGearSetupDialog.show(
            context,
            setupName: setup.name,
            detailLines: detailLines,
          );
        },
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.checkroom_rounded,
                size: 16,
                color: colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: AppSpacing.xs),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  setup.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
