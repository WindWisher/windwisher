import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_gear_usage_page.dart';

class ProfileGearSection extends StatelessWidget {
  const ProfileGearSection({
    required this.savedKites,
    required this.savedBars,
    required this.savedBoards,
    required this.savedHarnesses,
    required this.savedWetsuits,
    required this.savedHelmets,
    required this.savedVests,
    required this.savedGearSetups,
    required this.selectedGearConfigTabIndex,
    required this.onSelectGearConfigTab,
    required this.onOpenGearSetupDialog,
    required this.onOpenGearSetupDetailsDialog,
    required this.onConfirmDeleteItem,
    required this.onDeleteGearSetup,
    required this.findKite,
    required this.findBar,
    required this.findBoard,
    required this.findHarness,
    required this.findWetsuit,
    required this.findHelmet,
    required this.findVest,
    required this.kiteManagement,
    required this.boardManagement,
    required this.barManagement,
    required this.harnessManagement,
    required this.wetsuitManagement,
    required this.helmetManagement,
    required this.vestManagement,
    required this.onOpenKiteDialog,
    required this.onOpenBoardDialog,
    required this.onOpenBarDialog,
    required this.onOpenHarnessDialog,
    required this.onOpenWetsuitDialog,
    required this.onOpenHelmetDialog,
    required this.onOpenVestDialog,
    super.key,
  });

  final List<KiteItem> savedKites;
  final List<BarItem> savedBars;
  final List<BoardItem> savedBoards;
  final List<HarnessItem> savedHarnesses;
  final List<WetsuitItem> savedWetsuits;
  final List<HelmetItem> savedHelmets;
  final List<VestItem> savedVests;
  final List<GearSetup> savedGearSetups;
  final int selectedGearConfigTabIndex;
  final ValueChanged<int> onSelectGearConfigTab;
  final Future<void> Function({GearSetup? existing}) onOpenGearSetupDialog;
  final void Function(GearSetup setup) onOpenGearSetupDetailsDialog;
  final Future<bool> Function(String label) onConfirmDeleteItem;
  final void Function(String setupId) onDeleteGearSetup;
  final KiteItem? Function(String id) findKite;
  final BarItem? Function(String id) findBar;
  final BoardItem? Function(String id) findBoard;
  final HarnessItem? Function(String id) findHarness;
  final WetsuitItem? Function(String id) findWetsuit;
  final HelmetItem? Function(String id) findHelmet;
  final VestItem? Function(String id) findVest;
  final Widget kiteManagement;
  final Widget boardManagement;
  final Widget barManagement;
  final Widget harnessManagement;
  final Widget wetsuitManagement;
  final Widget helmetManagement;
  final Widget vestManagement;
  final VoidCallback onOpenKiteDialog;
  final VoidCallback onOpenBoardDialog;
  final VoidCallback onOpenBarDialog;
  final VoidCallback onOpenHarnessDialog;
  final VoidCallback onOpenWetsuitDialog;
  final VoidCallback onOpenHelmetDialog;
  final VoidCallback onOpenVestDialog;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      key: const ValueKey('equipo'),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu material', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Primero configura las piezas de tu quiver. Luego podras crear equipaciones con ese material.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Gestionar piezas del quiver',
                  style: textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Cometas, tablas, barras y resto de material disponible para tus equipaciones.',
                ),
                const SizedBox(height: AppSpacing.sm),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.35),
                      ),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary,
                    ),
                    segments: const [
                      ButtonSegment<int>(value: 0, label: Text('Cometa')),
                      ButtonSegment<int>(value: 1, label: Text('Tabla')),
                      ButtonSegment<int>(value: 2, label: Text('Barra')),
                      ButtonSegment<int>(value: 3, label: Text('Arnes')),
                      ButtonSegment<int>(value: 4, label: Text('Traje')),
                      ButtonSegment<int>(value: 5, label: Text('Casco')),
                      ButtonSegment<int>(value: 6, label: Text('Chaleco')),
                    ],
                    selected: {selectedGearConfigTabIndex},
                    onSelectionChanged: (selection) {
                      onSelectGearConfigTab(selection.first);
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildSelectedGearConfigSection(textTheme),
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
                Text('Mis equipaciones', style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Crea combinaciones listas para usar con el material que ya tengas guardado.',
                  style: textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => onOpenGearSetupDialog(),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Nueva equipacion'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Equipaciones guardadas (${savedGearSetups.length})',
                  style: textTheme.titleMedium,
                ),
                if (savedGearSetups.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Aun no has guardado ninguna equipacion.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...savedGearSetups.map((setup) {
                    final kite = findKite(setup.kiteId);
                    final board = findBoard(setup.boardId);
                    final bar = setup.barId == null
                        ? null
                        : findBar(setup.barId!);
                    final harness = setup.harnessId == null
                        ? null
                        : findHarness(setup.harnessId!);
                    final wetsuit = setup.wetsuitId == null
                        ? null
                        : findWetsuit(setup.wetsuitId!);
                    final helmet = setup.helmetId == null
                        ? null
                        : findHelmet(setup.helmetId!);
                    final vest = setup.vestId == null
                        ? null
                        : findVest(setup.vestId!);

                    final summaryParts = <String>[
                      if (kite != null) 'Cometa: ${kite.brand} ${kite.model}',
                      if (board != null) 'Tabla: ${board.brand} ${board.model}',
                      if (bar != null) 'Barra: ${bar.brand} ${bar.model}',
                      if (harness != null)
                        'Arnes: ${harness.brand} ${harness.model}',
                      if (wetsuit != null)
                        'Traje: ${wetsuit.brand} ${wetsuit.model}',
                      if (helmet != null)
                        'Casco: ${helmet.brand} ${helmet.model}',
                      if (vest != null) 'Chaleco: ${vest.brand} ${vest.model}',
                    ];

                    return Card(
                      margin: const EdgeInsets.only(top: AppSpacing.sm),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onOpenGearSetupDetailsDialog(setup),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          title: Text(setup.name),
                          subtitle: Text(summaryParts.join(' · ')),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz),
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
                            itemBuilder: (context) => const [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Editar'),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _buildGearUsageStatsCard(context, textTheme),
          ),
        ),
      ],
    );
  }

  Widget _buildGearUsageStatsCard(BuildContext context, TextTheme textTheme) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Estadisticas de uso de equipacion',
            style: textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildGearStatRow('Equipaciones guardadas', '$totalSetups'),
        _buildGearStatRow('Equipaciones completas', '$completeSetups'),
        _buildGearStatRow('Ultima configuracion', lastSavedLabel),
        const SizedBox(height: AppSpacing.sm),
        Center(
          child: OutlinedButton.icon(
            onPressed: () => _openGearUsageDetailsPage(context),
            icon: const Icon(Icons.insights_outlined),
            label: const Text('Detalles'),
          ),
        ),
      ],
    );
  }

  void _openGearUsageDetailsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GearUsageDetailsPage(
          setups: savedGearSetups,
          kites: savedKites,
          boards: savedBoards,
          bars: savedBars,
          harnesses: savedHarnesses,
          wetsuits: savedWetsuits,
          helmets: savedHelmets,
          vests: savedVests,
        ),
      ),
    );
  }

  Widget _buildSelectedGearConfigSection(TextTheme textTheme) {
    switch (selectedGearConfigTabIndex) {
      case 0:
        return _buildGearConfigSection(
          textTheme: textTheme,
          title: 'Cometa',
          buttonLabel: 'Configurar cometa',
          icon: Icons.air,
          savedLabel: 'Cometas guardadas (${savedKites.length})',
          onPressed: onOpenKiteDialog,
          managementWidget: kiteManagement,
        );
      case 1:
        return _buildGearConfigSection(
          textTheme: textTheme,
          title: 'Tabla',
          buttonLabel: 'Configurar tabla',
          icon: Icons.surfing,
          savedLabel: 'Tablas guardadas (${savedBoards.length})',
          onPressed: onOpenBoardDialog,
          managementWidget: boardManagement,
        );
      case 2:
        return _buildGearConfigSection(
          textTheme: textTheme,
          title: 'Barra',
          buttonLabel: 'Configurar barra',
          icon: Icons.tune,
          savedLabel: 'Barras guardadas (${savedBars.length})',
          onPressed: onOpenBarDialog,
          managementWidget: barManagement,
        );
      case 3:
        return _buildGearConfigSection(
          textTheme: textTheme,
          title: 'Arnes',
          buttonLabel: 'Configurar arnes',
          icon: Icons.sports_martial_arts,
          savedLabel: 'Arneses guardados (${savedHarnesses.length})',
          onPressed: onOpenHarnessDialog,
          managementWidget: harnessManagement,
        );
      case 4:
        return _buildGearConfigSection(
          textTheme: textTheme,
          title: 'Traje',
          buttonLabel: 'Configurar traje',
          icon: Icons.checkroom,
          savedLabel: 'Trajes guardados (${savedWetsuits.length})',
          onPressed: onOpenWetsuitDialog,
          managementWidget: wetsuitManagement,
        );
      case 5:
        return _buildGearConfigSection(
          textTheme: textTheme,
          title: 'Casco',
          buttonLabel: 'Configurar casco',
          icon: Icons.health_and_safety,
          savedLabel: 'Cascos guardados (${savedHelmets.length})',
          onPressed: onOpenHelmetDialog,
          managementWidget: helmetManagement,
        );
      case 6:
        return _buildGearConfigSection(
          textTheme: textTheme,
          title: 'Chaleco',
          buttonLabel: 'Configurar chaleco',
          icon: Icons.shield_outlined,
          savedLabel: 'Chalecos guardados (${savedVests.length})',
          onPressed: onOpenVestDialog,
          managementWidget: vestManagement,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGearConfigSection({
    required TextTheme textTheme,
    required String title,
    required String buttonLabel,
    required IconData icon,
    required String savedLabel,
    required VoidCallback onPressed,
    required Widget managementWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.xs),
        FilledButton.tonalIcon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(buttonLabel),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(savedLabel),
        managementWidget,
        Text(
          'Disponible en el desplegable de equipacion personalizada.',
          style: textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildGearStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatSimpleDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}
