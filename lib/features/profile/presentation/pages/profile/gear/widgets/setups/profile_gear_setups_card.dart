import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/setups/empty/profile_gear_setups_empty_state.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/setups/items/profile_gear_setup_action_chip.dart';

class ProfileGearSetupsCard extends StatelessWidget {
  const ProfileGearSetupsCard({
    super.key,
    required this.savedGearSetups,
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

  final List<GearSetup> savedGearSetups;
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
    final textTheme = Theme.of(context).textTheme;

    return Card(
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
            const SizedBox(height: AppSpacing.sm),
            if (savedGearSetups.isEmpty)
              const ProfileGearSetupsEmptyState()
            else
              Column(
                children: [
                  for (var i = 0; i < savedGearSetups.length; i++) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ProfileGearSetupActionChip(
                        setup: savedGearSetups[i],
                        findKite: findKite,
                        findBar: findBar,
                        findBoard: findBoard,
                        findHarness: findHarness,
                        findWetsuit: findWetsuit,
                        findHelmet: findHelmet,
                        findVest: findVest,
                        onOpenGearSetupDialog: onOpenGearSetupDialog,
                        onConfirmDeleteItem: onConfirmDeleteItem,
                        onDeleteGearSetup: onDeleteGearSetup,
                      ),
                    ),
                    if (i < savedGearSetups.length - 1)
                      const SizedBox(height: AppSpacing.xs),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
