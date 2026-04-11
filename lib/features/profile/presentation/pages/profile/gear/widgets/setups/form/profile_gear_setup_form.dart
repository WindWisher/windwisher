import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/setups/form/fields/profile_gear_setup_name_field.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/setups/form/fields/profile_gear_setup_selector_field.dart';

class ProfileGearSetupForm extends StatelessWidget {
  const ProfileGearSetupForm({
    super.key,
    required this.nameController,
    required this.onNameChanged,
    required this.selectedKiteId,
    required this.savedKites,
    required this.onKiteChanged,
    required this.selectedBoardId,
    required this.savedBoards,
    required this.onBoardChanged,
    required this.selectedBarId,
    required this.savedBars,
    required this.onBarChanged,
    required this.selectedHarnessId,
    required this.savedHarnesses,
    required this.onHarnessChanged,
    required this.selectedWetsuitId,
    required this.savedWetsuits,
    required this.onWetsuitChanged,
    required this.selectedHelmetId,
    required this.savedHelmets,
    required this.onHelmetChanged,
    required this.selectedVestId,
    required this.savedVests,
    required this.onVestChanged,
  });

  final TextEditingController nameController;
  final ValueChanged<String> onNameChanged;
  final String? selectedKiteId;
  final List<KiteItem> savedKites;
  final ValueChanged<String?> onKiteChanged;
  final String? selectedBoardId;
  final List<BoardItem> savedBoards;
  final ValueChanged<String?> onBoardChanged;
  final String? selectedBarId;
  final List<BarItem> savedBars;
  final ValueChanged<String?> onBarChanged;
  final String? selectedHarnessId;
  final List<HarnessItem> savedHarnesses;
  final ValueChanged<String?> onHarnessChanged;
  final String? selectedWetsuitId;
  final List<WetsuitItem> savedWetsuits;
  final ValueChanged<String?> onWetsuitChanged;
  final String? selectedHelmetId;
  final List<HelmetItem> savedHelmets;
  final ValueChanged<String?> onHelmetChanged;
  final String? selectedVestId;
  final List<VestItem> savedVests;
  final ValueChanged<String?> onVestChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileGearSetupNameField(
            controller: nameController,
            onChanged: onNameChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearSetupSelectorField(
            fieldKey: ValueKey(
              'setup-kite-${selectedKiteId ?? 'none'}-${savedKites.length}',
            ),
            value: selectedKiteId,
            label: 'Cometa',
            items: savedKites
                .map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.id,
                    child: Text(
                      '${item.brand} ${item.model} ${item.sizeMeters}m (${item.year})',
                    ),
                  ),
                )
                .toList(),
            onChanged: onKiteChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearSetupSelectorField(
            fieldKey: ValueKey(
              'setup-board-${selectedBoardId ?? 'none'}-${savedBoards.length}',
            ),
            value: selectedBoardId,
            label: 'Tabla',
            items: savedBoards
                .map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.id,
                    child: Text('${item.brand} ${item.model} (${item.year})'),
                  ),
                )
                .toList(),
            onChanged: onBoardChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearSetupSelectorField(
            fieldKey: ValueKey(
              'setup-bar-${selectedBarId ?? 'none'}-${savedBars.length}',
            ),
            value: selectedBarId,
            label: 'Barra',
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Sin barra'),
              ),
              ...savedBars.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text('${item.brand} ${item.model} (${item.year})'),
                ),
              ),
            ],
            onChanged: onBarChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearSetupSelectorField(
            fieldKey: ValueKey(
              'setup-harness-${selectedHarnessId ?? 'none'}-${savedHarnesses.length}',
            ),
            value: selectedHarnessId,
            label: 'Arnes',
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Sin arnes'),
              ),
              ...savedHarnesses.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text('${item.brand} ${item.model} (${item.year})'),
                ),
              ),
            ],
            onChanged: onHarnessChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearSetupSelectorField(
            fieldKey: ValueKey(
              'setup-wetsuit-${selectedWetsuitId ?? 'none'}-${savedWetsuits.length}',
            ),
            value: selectedWetsuitId,
            label: 'Traje',
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Sin traje'),
              ),
              ...savedWetsuits.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text('${item.brand} ${item.model} (${item.year})'),
                ),
              ),
            ],
            onChanged: onWetsuitChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearSetupSelectorField(
            fieldKey: ValueKey(
              'setup-helmet-${selectedHelmetId ?? 'none'}-${savedHelmets.length}',
            ),
            value: selectedHelmetId,
            label: 'Casco',
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Sin casco'),
              ),
              ...savedHelmets.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text('${item.brand} ${item.model} (${item.year})'),
                ),
              ),
            ],
            onChanged: onHelmetChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearSetupSelectorField(
            fieldKey: ValueKey(
              'setup-vest-${selectedVestId ?? 'none'}-${savedVests.length}',
            ),
            value: selectedVestId,
            label: 'Chaleco',
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Sin chaleco'),
              ),
              ...savedVests.map(
                (item) => DropdownMenuItem<String?>(
                  value: item.id,
                  child: Text(
                    '${item.brand} ${item.model} ${item.size} (${item.year})',
                  ),
                ),
              ),
            ],
            onChanged: onVestChanged,
          ),
        ],
      ),
    );
  }
}
