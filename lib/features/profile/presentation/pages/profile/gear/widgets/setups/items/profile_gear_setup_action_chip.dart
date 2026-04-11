import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/setups/dialog/profile_gear_setup_dialog.dart';

class ProfileGearSetupActionChip extends StatelessWidget {
  const ProfileGearSetupActionChip({
    super.key,
    required this.setup,
    required this.findKite,
    required this.findBar,
    required this.findBoard,
    required this.findHarness,
    required this.findWetsuit,
    required this.findHelmet,
    required this.findVest,
    required this.onOpenGearSetupDialog,
    required this.onConfirmDeleteItem,
    required this.onDeleteGearSetup,
  });

  final GearSetup setup;
  final KiteItem? Function(String id) findKite;
  final BarItem? Function(String id) findBar;
  final BoardItem? Function(String id) findBoard;
  final HarnessItem? Function(String id) findHarness;
  final WetsuitItem? Function(String id) findWetsuit;
  final HelmetItem? Function(String id) findHelmet;
  final VestItem? Function(String id) findVest;
  final Future<void> Function({GearSetup? existing}) onOpenGearSetupDialog;
  final Future<bool> Function(String label) onConfirmDeleteItem;
  final void Function(String setupId) onDeleteGearSetup;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final detailLines = _buildDetailLines();
    final secondaryLabel = _buildSecondaryLabel();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            ProfileGearSetupDialog.show(
              context,
              setupName: setup.name,
              detailLines: detailLines,
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.checkroom_rounded,
                    size: 18,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        setup.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        secondaryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Container(
                  width: 1,
                  height: 24,
                  color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 2),
                PopupMenuButton<String>(
                  tooltip: 'Opciones',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 20,
                  icon: Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onSelected: (action) async {
                    if (action == 'edit') {
                      await onOpenGearSetupDialog(existing: setup);
                      return;
                    }

                    if (action == 'delete') {
                      final confirmed = await onConfirmDeleteItem(
                        'la equipacion seleccionada',
                      );
                      if (confirmed) {
                        onDeleteGearSetup(setup.id);
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Editar'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(
                        'Eliminar',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _buildSecondaryLabel() {
    final kite = findKite(setup.kiteId);
    final board = findBoard(setup.boardId);
    final parts = <String>[
      if (kite != null) '${kite.brand} ${kite.model}',
      if (board != null) '${board.brand} ${board.model}',
    ];

    if (parts.isNotEmpty) {
      return parts.join(' · ');
    }

    final detailLines = _buildDetailLines();
    if (detailLines.isNotEmpty) {
      return detailLines.first;
    }

    return 'Sin detalle adicional';
  }

  List<String> _buildDetailLines() {
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
