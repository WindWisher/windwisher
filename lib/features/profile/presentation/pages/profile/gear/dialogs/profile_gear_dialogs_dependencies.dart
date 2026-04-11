import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';

class ProfileGearDialogControllers {
  const ProfileGearDialogControllers({
    required this.gearSetupNameController,
    required this.kiteBrandController,
    required this.kiteModelController,
    required this.kiteSizeController,
    required this.kiteYearController,
    required this.barBrandController,
    required this.barModelController,
    required this.barLineLengthController,
    required this.barWidthController,
    required this.barYearController,
    required this.boardBrandController,
    required this.boardModelController,
    required this.boardSizeController,
    required this.boardYearController,
    required this.harnessBrandController,
    required this.harnessModelController,
    required this.harnessSizeController,
    required this.harnessYearController,
    required this.wetsuitBrandController,
    required this.wetsuitModelController,
    required this.wetsuitThicknessController,
    required this.wetsuitSizeController,
    required this.wetsuitYearController,
    required this.helmetBrandController,
    required this.helmetModelController,
    required this.helmetYearController,
    required this.vestBrandController,
    required this.vestModelController,
    required this.vestSizeController,
    required this.vestYearController,
  });

  final TextEditingController gearSetupNameController;
  final TextEditingController kiteBrandController;
  final TextEditingController kiteModelController;
  final TextEditingController kiteSizeController;
  final TextEditingController kiteYearController;
  final TextEditingController barBrandController;
  final TextEditingController barModelController;
  final TextEditingController barLineLengthController;
  final TextEditingController barWidthController;
  final TextEditingController barYearController;
  final TextEditingController boardBrandController;
  final TextEditingController boardModelController;
  final TextEditingController boardSizeController;
  final TextEditingController boardYearController;
  final TextEditingController harnessBrandController;
  final TextEditingController harnessModelController;
  final TextEditingController harnessSizeController;
  final TextEditingController harnessYearController;
  final TextEditingController wetsuitBrandController;
  final TextEditingController wetsuitModelController;
  final TextEditingController wetsuitThicknessController;
  final TextEditingController wetsuitSizeController;
  final TextEditingController wetsuitYearController;
  final TextEditingController helmetBrandController;
  final TextEditingController helmetModelController;
  final TextEditingController helmetYearController;
  final TextEditingController vestBrandController;
  final TextEditingController vestModelController;
  final TextEditingController vestSizeController;
  final TextEditingController vestYearController;
}

class ProfileGearDialogInventory {
  const ProfileGearDialogInventory({
    required this.savedKites,
    required this.savedBars,
    required this.savedBoards,
    required this.savedHarnesses,
    required this.savedWetsuits,
    required this.savedHelmets,
    required this.savedVests,
  });

  final List<KiteItem> Function() savedKites;
  final List<BarItem> Function() savedBars;
  final List<BoardItem> Function() savedBoards;
  final List<HarnessItem> Function() savedHarnesses;
  final List<WetsuitItem> Function() savedWetsuits;
  final List<HelmetItem> Function() savedHelmets;
  final List<VestItem> Function() savedVests;
}

class ProfileGearDialogResolvers {
  const ProfileGearDialogResolvers({
    required this.findKite,
    required this.findBar,
    required this.findBoard,
    required this.findHarness,
    required this.findWetsuit,
    required this.findHelmet,
    required this.findVest,
  });

  final KiteItem? Function(String id) findKite;
  final BarItem? Function(String id) findBar;
  final BoardItem? Function(String id) findBoard;
  final HarnessItem? Function(String id) findHarness;
  final WetsuitItem? Function(String id) findWetsuit;
  final HelmetItem? Function(String id) findHelmet;
  final VestItem? Function(String id) findVest;
}

class ProfileGearDialogSelection {
  const ProfileGearDialogSelection({
    required this.selectedBoardType,
    required this.setSelectedBoardType,
    required this.selectedKiteForSetupId,
    required this.setSelectedKiteForSetupId,
    required this.selectedBarForSetupId,
    required this.setSelectedBarForSetupId,
    required this.selectedBoardForSetupId,
    required this.setSelectedBoardForSetupId,
    required this.selectedHarnessForSetupId,
    required this.setSelectedHarnessForSetupId,
    required this.selectedWetsuitForSetupId,
    required this.setSelectedWetsuitForSetupId,
    required this.selectedHelmetForSetupId,
    required this.setSelectedHelmetForSetupId,
    required this.selectedVestForSetupId,
    required this.setSelectedVestForSetupId,
  });

  final String Function() selectedBoardType;
  final ValueChanged<String> setSelectedBoardType;
  final String? Function() selectedKiteForSetupId;
  final ValueChanged<String?> setSelectedKiteForSetupId;
  final String? Function() selectedBarForSetupId;
  final ValueChanged<String?> setSelectedBarForSetupId;
  final String? Function() selectedBoardForSetupId;
  final ValueChanged<String?> setSelectedBoardForSetupId;
  final String? Function() selectedHarnessForSetupId;
  final ValueChanged<String?> setSelectedHarnessForSetupId;
  final String? Function() selectedWetsuitForSetupId;
  final ValueChanged<String?> setSelectedWetsuitForSetupId;
  final String? Function() selectedHelmetForSetupId;
  final ValueChanged<String?> setSelectedHelmetForSetupId;
  final String? Function() selectedVestForSetupId;
  final ValueChanged<String?> setSelectedVestForSetupId;
}

class ProfileGearDialogSaveActions {
  const ProfileGearDialogSaveActions({
    required this.canSaveGearSetup,
    required this.saveGearSetup,
    required this.saveKite,
    required this.saveBar,
    required this.saveBoard,
    required this.saveHarness,
    required this.saveWetsuit,
    required this.saveHelmet,
    required this.saveVest,
  });

  final bool Function() canSaveGearSetup;
  final void Function({String? editingId}) saveGearSetup;
  final void Function({String? editingId}) saveKite;
  final void Function({String? editingId}) saveBar;
  final void Function({String? editingId}) saveBoard;
  final void Function({String? editingId}) saveHarness;
  final void Function({String? editingId}) saveWetsuit;
  final void Function({String? editingId}) saveHelmet;
  final void Function({String? editingId}) saveVest;
}
