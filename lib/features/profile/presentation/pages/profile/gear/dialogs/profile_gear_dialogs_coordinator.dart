import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/dialogs/profile_gear_dialogs_dependencies.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/dialogs/profile_gear_dialogs_helpers.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/actions/profile_gear_dialog_actions.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/dialog/profile_gear_form_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/profile_bar_form.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/profile_board_form.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/profile_harness_form.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/profile_helmet_form.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/profile_kite_form.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/profile_vest_form.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/profile_wetsuit_form.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/setups/form/actions/profile_gear_setup_dialog_actions.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/setups/form/profile_gear_setup_form.dart';

part 'profile_gear_item_dialogs.dart';
part 'profile_gear_setup_dialogs.dart';

class ProfileGearDialogsCoordinator {
  ProfileGearDialogsCoordinator({
    required this.context,
    required this.mutateState,
    required this.controllers,
    required this.inventory,
    required this.resolvers,
    required this.selection,
    required this.actions,
  });

  final BuildContext context;
  final void Function(VoidCallback callback) mutateState;

  final ProfileGearDialogControllers controllers;
  final ProfileGearDialogInventory inventory;
  final ProfileGearDialogResolvers resolvers;
  final ProfileGearDialogSelection selection;
  final ProfileGearDialogSaveActions actions;

  TextEditingController get gearSetupNameController =>
      controllers.gearSetupNameController;
  TextEditingController get kiteBrandController =>
      controllers.kiteBrandController;
  TextEditingController get kiteModelController =>
      controllers.kiteModelController;
  TextEditingController get kiteSizeController =>
      controllers.kiteSizeController;
  TextEditingController get kiteYearController =>
      controllers.kiteYearController;
  TextEditingController get kitePriceController =>
      controllers.kitePriceController;
  TextEditingController get barBrandController =>
      controllers.barBrandController;
  TextEditingController get barModelController =>
      controllers.barModelController;
  TextEditingController get barLineLengthController =>
      controllers.barLineLengthController;
  TextEditingController get barWidthController =>
      controllers.barWidthController;
  TextEditingController get barYearController => controllers.barYearController;
  TextEditingController get barPriceController =>
      controllers.barPriceController;
  TextEditingController get boardBrandController =>
      controllers.boardBrandController;
  TextEditingController get boardModelController =>
      controllers.boardModelController;
  TextEditingController get boardSizeController =>
      controllers.boardSizeController;
  TextEditingController get boardYearController =>
      controllers.boardYearController;
  TextEditingController get boardPriceController =>
      controllers.boardPriceController;
  TextEditingController get harnessBrandController =>
      controllers.harnessBrandController;
  TextEditingController get harnessModelController =>
      controllers.harnessModelController;
  TextEditingController get harnessSizeController =>
      controllers.harnessSizeController;
  TextEditingController get harnessYearController =>
      controllers.harnessYearController;
  TextEditingController get harnessPriceController =>
      controllers.harnessPriceController;
  TextEditingController get wetsuitBrandController =>
      controllers.wetsuitBrandController;
  TextEditingController get wetsuitModelController =>
      controllers.wetsuitModelController;
  TextEditingController get wetsuitThicknessController =>
      controllers.wetsuitThicknessController;
  TextEditingController get wetsuitSizeController =>
      controllers.wetsuitSizeController;
  TextEditingController get wetsuitYearController =>
      controllers.wetsuitYearController;
  TextEditingController get wetsuitPriceController =>
      controllers.wetsuitPriceController;
  TextEditingController get helmetBrandController =>
      controllers.helmetBrandController;
  TextEditingController get helmetModelController =>
      controllers.helmetModelController;
  TextEditingController get helmetYearController =>
      controllers.helmetYearController;
  TextEditingController get helmetPriceController =>
      controllers.helmetPriceController;
  TextEditingController get vestBrandController =>
      controllers.vestBrandController;
  TextEditingController get vestModelController =>
      controllers.vestModelController;
  TextEditingController get vestSizeController =>
      controllers.vestSizeController;
  TextEditingController get vestYearController =>
      controllers.vestYearController;
  TextEditingController get vestPriceController =>
      controllers.vestPriceController;

  List<KiteItem> Function() get savedKites => inventory.savedKites;
  List<BarItem> Function() get savedBars => inventory.savedBars;
  List<BoardItem> Function() get savedBoards => inventory.savedBoards;
  List<HarnessItem> Function() get savedHarnesses => inventory.savedHarnesses;
  List<WetsuitItem> Function() get savedWetsuits => inventory.savedWetsuits;
  List<HelmetItem> Function() get savedHelmets => inventory.savedHelmets;
  List<VestItem> Function() get savedVests => inventory.savedVests;

  KiteItem? Function(String id) get findKite => resolvers.findKite;
  BarItem? Function(String id) get findBar => resolvers.findBar;
  BoardItem? Function(String id) get findBoard => resolvers.findBoard;
  HarnessItem? Function(String id) get findHarness => resolvers.findHarness;
  WetsuitItem? Function(String id) get findWetsuit => resolvers.findWetsuit;
  HelmetItem? Function(String id) get findHelmet => resolvers.findHelmet;
  VestItem? Function(String id) get findVest => resolvers.findVest;

  String Function() get selectedBoardType => selection.selectedBoardType;
  ValueChanged<String> get setSelectedBoardType =>
      selection.setSelectedBoardType;
  String? Function() get selectedKiteForSetupId =>
      selection.selectedKiteForSetupId;
  ValueChanged<String?> get setSelectedKiteForSetupId =>
      selection.setSelectedKiteForSetupId;
  String? Function() get selectedBarForSetupId =>
      selection.selectedBarForSetupId;
  ValueChanged<String?> get setSelectedBarForSetupId =>
      selection.setSelectedBarForSetupId;
  String? Function() get selectedBoardForSetupId =>
      selection.selectedBoardForSetupId;
  ValueChanged<String?> get setSelectedBoardForSetupId =>
      selection.setSelectedBoardForSetupId;
  String? Function() get selectedHarnessForSetupId =>
      selection.selectedHarnessForSetupId;
  ValueChanged<String?> get setSelectedHarnessForSetupId =>
      selection.setSelectedHarnessForSetupId;
  String? Function() get selectedWetsuitForSetupId =>
      selection.selectedWetsuitForSetupId;
  ValueChanged<String?> get setSelectedWetsuitForSetupId =>
      selection.setSelectedWetsuitForSetupId;
  String? Function() get selectedHelmetForSetupId =>
      selection.selectedHelmetForSetupId;
  ValueChanged<String?> get setSelectedHelmetForSetupId =>
      selection.setSelectedHelmetForSetupId;
  String? Function() get selectedVestForSetupId =>
      selection.selectedVestForSetupId;
  ValueChanged<String?> get setSelectedVestForSetupId =>
      selection.setSelectedVestForSetupId;

  bool Function() get canSaveGearSetup => actions.canSaveGearSetup;
  void Function({String? editingId}) get saveGearSetup => actions.saveGearSetup;
  void Function({String? editingId}) get saveKite => actions.saveKite;
  void Function({String? editingId}) get saveBar => actions.saveBar;
  void Function({String? editingId}) get saveBoard => actions.saveBoard;
  void Function({String? editingId}) get saveHarness => actions.saveHarness;
  void Function({String? editingId}) get saveWetsuit => actions.saveWetsuit;
  void Function({String? editingId}) get saveHelmet => actions.saveHelmet;
  void Function({String? editingId}) get saveVest => actions.saveVest;

  Future<bool> confirmDeleteItem(String itemLabel) {
    return showConfirmDeleteItemDialog(context: context, itemLabel: itemLabel);
  }
}
