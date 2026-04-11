import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/management/profile_gear_management_controls.dart';

class ProfileGearManagementBuilder {
  ProfileGearManagementBuilder({
    required this.mutateState,
    required this.savedKites,
    required this.savedBars,
    required this.savedBoards,
    required this.savedHarnesses,
    required this.savedWetsuits,
    required this.savedHelmets,
    required this.savedVests,
    required this.selectedKiteManageId,
    required this.setSelectedKiteManageId,
    required this.selectedBarManageId,
    required this.setSelectedBarManageId,
    required this.selectedBoardManageId,
    required this.setSelectedBoardManageId,
    required this.selectedHarnessManageId,
    required this.setSelectedHarnessManageId,
    required this.selectedWetsuitManageId,
    required this.setSelectedWetsuitManageId,
    required this.selectedHelmetManageId,
    required this.setSelectedHelmetManageId,
    required this.selectedVestManageId,
    required this.setSelectedVestManageId,
    required this.findKite,
    required this.findBar,
    required this.findBoard,
    required this.findHarness,
    required this.findWetsuit,
    required this.findHelmet,
    required this.findVest,
    required this.openKiteDialog,
    required this.openBarDialog,
    required this.openBoardDialog,
    required this.openHarnessDialog,
    required this.openWetsuitDialog,
    required this.openHelmetDialog,
    required this.openVestDialog,
    required this.deleteKite,
    required this.deleteBar,
    required this.deleteBoard,
    required this.deleteHarness,
    required this.deleteWetsuit,
    required this.deleteHelmet,
    required this.deleteVest,
    required this.confirmDeleteItem,
  });

  final void Function(VoidCallback callback) mutateState;

  final List<KiteItem> Function() savedKites;
  final List<BarItem> Function() savedBars;
  final List<BoardItem> Function() savedBoards;
  final List<HarnessItem> Function() savedHarnesses;
  final List<WetsuitItem> Function() savedWetsuits;
  final List<HelmetItem> Function() savedHelmets;
  final List<VestItem> Function() savedVests;

  final String? Function() selectedKiteManageId;
  final ValueChanged<String?> setSelectedKiteManageId;
  final String? Function() selectedBarManageId;
  final ValueChanged<String?> setSelectedBarManageId;
  final String? Function() selectedBoardManageId;
  final ValueChanged<String?> setSelectedBoardManageId;
  final String? Function() selectedHarnessManageId;
  final ValueChanged<String?> setSelectedHarnessManageId;
  final String? Function() selectedWetsuitManageId;
  final ValueChanged<String?> setSelectedWetsuitManageId;
  final String? Function() selectedHelmetManageId;
  final ValueChanged<String?> setSelectedHelmetManageId;
  final String? Function() selectedVestManageId;
  final ValueChanged<String?> setSelectedVestManageId;

  final KiteItem? Function(String id) findKite;
  final BarItem? Function(String id) findBar;
  final BoardItem? Function(String id) findBoard;
  final HarnessItem? Function(String id) findHarness;
  final WetsuitItem? Function(String id) findWetsuit;
  final HelmetItem? Function(String id) findHelmet;
  final VestItem? Function(String id) findVest;

  final Future<void> Function({KiteItem? existing}) openKiteDialog;
  final Future<void> Function({BarItem? existing}) openBarDialog;
  final Future<void> Function({BoardItem? existing}) openBoardDialog;
  final Future<void> Function({HarnessItem? existing}) openHarnessDialog;
  final Future<void> Function({WetsuitItem? existing}) openWetsuitDialog;
  final Future<void> Function({HelmetItem? existing}) openHelmetDialog;
  final Future<void> Function({VestItem? existing}) openVestDialog;

  final void Function(String id) deleteKite;
  final void Function(String id) deleteBar;
  final void Function(String id) deleteBoard;
  final void Function(String id) deleteHarness;
  final void Function(String id) deleteWetsuit;
  final void Function(String id) deleteHelmet;
  final void Function(String id) deleteVest;

  final Future<bool> Function(String label) confirmDeleteItem;

  Widget buildKiteManagement() {
    if (savedKites().isEmpty) return const SizedBox.shrink();
    return _buildManagementControls(
      value: selectedKiteManageId(),
      fieldLabel: 'Cometa guardada',
      items: savedKites()
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id,
              child: Text('${item.brand} ${item.model} ${item.sizeMeters}m'),
            ),
          )
          .toList(),
      onChanged: (value) {
        mutateState(() => setSelectedKiteManageId(value));
      },
      onEdit: selectedKiteManageId() == null
          ? null
          : () {
              final item = findKite(selectedKiteManageId()!);
              if (item != null) {
                openKiteDialog(existing: item);
              }
            },
      onDelete: selectedKiteManageId() == null
          ? null
          : () => deleteKite(selectedKiteManageId()!),
      deleteTargetLabel: 'la cometa seleccionada',
    );
  }

  Widget buildBarManagement() {
    if (savedBars().isEmpty) return const SizedBox.shrink();
    return _buildManagementControls(
      value: selectedBarManageId(),
      fieldLabel: 'Barra guardada',
      items: savedBars()
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id,
              child: Text('${item.brand} ${item.model}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        mutateState(() => setSelectedBarManageId(value));
      },
      onEdit: selectedBarManageId() == null
          ? null
          : () {
              final item = findBar(selectedBarManageId()!);
              if (item != null) {
                openBarDialog(existing: item);
              }
            },
      onDelete: selectedBarManageId() == null
          ? null
          : () => deleteBar(selectedBarManageId()!),
      deleteTargetLabel: 'la barra seleccionada',
    );
  }

  Widget buildBoardManagement() {
    if (savedBoards().isEmpty) return const SizedBox.shrink();
    return _buildManagementControls(
      value: selectedBoardManageId(),
      fieldLabel: 'Tabla guardada',
      items: savedBoards()
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id,
              child: Text('${item.brand} ${item.model}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        mutateState(() => setSelectedBoardManageId(value));
      },
      onEdit: selectedBoardManageId() == null
          ? null
          : () {
              final item = findBoard(selectedBoardManageId()!);
              if (item != null) {
                openBoardDialog(existing: item);
              }
            },
      onDelete: selectedBoardManageId() == null
          ? null
          : () => deleteBoard(selectedBoardManageId()!),
      deleteTargetLabel: 'la tabla seleccionada',
    );
  }

  Widget buildHarnessManagement() {
    if (savedHarnesses().isEmpty) return const SizedBox.shrink();
    return _buildManagementControls(
      value: selectedHarnessManageId(),
      fieldLabel: 'Arnes guardado',
      items: savedHarnesses()
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id,
              child: Text('${item.brand} ${item.model}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        mutateState(() => setSelectedHarnessManageId(value));
      },
      onEdit: selectedHarnessManageId() == null
          ? null
          : () {
              final item = findHarness(selectedHarnessManageId()!);
              if (item != null) {
                openHarnessDialog(existing: item);
              }
            },
      onDelete: selectedHarnessManageId() == null
          ? null
          : () => deleteHarness(selectedHarnessManageId()!),
      deleteTargetLabel: 'el arnes seleccionado',
    );
  }

  Widget buildWetsuitManagement() {
    if (savedWetsuits().isEmpty) return const SizedBox.shrink();
    return _buildManagementControls(
      value: selectedWetsuitManageId(),
      fieldLabel: 'Traje guardado',
      items: savedWetsuits()
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id,
              child: Text('${item.brand} ${item.model}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        mutateState(() => setSelectedWetsuitManageId(value));
      },
      onEdit: selectedWetsuitManageId() == null
          ? null
          : () {
              final item = findWetsuit(selectedWetsuitManageId()!);
              if (item != null) {
                openWetsuitDialog(existing: item);
              }
            },
      onDelete: selectedWetsuitManageId() == null
          ? null
          : () => deleteWetsuit(selectedWetsuitManageId()!),
      deleteTargetLabel: 'el traje seleccionado',
    );
  }

  Widget buildHelmetManagement() {
    if (savedHelmets().isEmpty) return const SizedBox.shrink();
    return _buildManagementControls(
      value: selectedHelmetManageId(),
      fieldLabel: 'Casco guardado',
      items: savedHelmets()
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id,
              child: Text('${item.brand} ${item.model}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        mutateState(() => setSelectedHelmetManageId(value));
      },
      onEdit: selectedHelmetManageId() == null
          ? null
          : () {
              final item = findHelmet(selectedHelmetManageId()!);
              if (item != null) {
                openHelmetDialog(existing: item);
              }
            },
      onDelete: selectedHelmetManageId() == null
          ? null
          : () => deleteHelmet(selectedHelmetManageId()!),
      deleteTargetLabel: 'el casco seleccionado',
    );
  }

  Widget buildVestManagement() {
    if (savedVests().isEmpty) return const SizedBox.shrink();
    return _buildManagementControls(
      value: selectedVestManageId(),
      fieldLabel: 'Chaleco guardado',
      items: savedVests()
          .map(
            (item) => DropdownMenuItem<String>(
              value: item.id,
              child: Text('${item.brand} ${item.model} · ${item.size}'),
            ),
          )
          .toList(),
      onChanged: (value) {
        mutateState(() => setSelectedVestManageId(value));
      },
      onEdit: selectedVestManageId() == null
          ? null
          : () {
              final item = findVest(selectedVestManageId()!);
              if (item != null) {
                openVestDialog(existing: item);
              }
            },
      onDelete: selectedVestManageId() == null
          ? null
          : () => deleteVest(selectedVestManageId()!),
      deleteTargetLabel: 'el chaleco seleccionado',
    );
  }

  Widget _buildManagementControls({
    required String? value,
    required String fieldLabel,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    required VoidCallback? onEdit,
    required VoidCallback? onDelete,
    required String deleteTargetLabel,
  }) {
    return ProfileGearManagementControls(
      value: value,
      fieldLabel: fieldLabel,
      items: items,
      onChanged: onChanged,
      onEdit: onEdit,
      onDelete: onDelete,
      onConfirmDelete: () => confirmDeleteItem(deleteTargetLabel),
    );
  }
}
