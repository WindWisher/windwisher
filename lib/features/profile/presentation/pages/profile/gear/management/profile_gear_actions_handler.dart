import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/state/profile_gear_controller.dart';

class ProfileGearActionsHandler {
  ProfileGearActionsHandler({
    required this.context,
    required this.mutateState,
    required this.gearController,
    required this.publishGearSetupsForSessions,
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
    required this.selectedBoardType,
    required this.setSelectedBoardType,
    required this.selectedKiteForSetupId,
    required this.selectedBarForSetupId,
    required this.selectedBoardForSetupId,
    required this.selectedHarnessForSetupId,
    required this.selectedWetsuitForSetupId,
    required this.selectedHelmetForSetupId,
    required this.selectedVestForSetupId,
  });

  final BuildContext context;
  final void Function(VoidCallback callback) mutateState;
  final ProfileGearController gearController;
  final VoidCallback publishGearSetupsForSessions;

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

  final String Function() selectedBoardType;
  final ValueChanged<String> setSelectedBoardType;
  final String? Function() selectedKiteForSetupId;
  final String? Function() selectedBarForSetupId;
  final String? Function() selectedBoardForSetupId;
  final String? Function() selectedHarnessForSetupId;
  final String? Function() selectedWetsuitForSetupId;
  final String? Function() selectedHelmetForSetupId;
  final String? Function() selectedVestForSetupId;
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
  );
  static const Uuid _uuid = Uuid();

  bool get canSaveGearSetup {
    return gearSetupNameController.text.trim().isNotEmpty &&
        selectedKiteForSetupId() != null &&
        selectedBoardForSetupId() != null;
  }

  void saveKite({String? editingId}) {
    if (!_canSaveKite) return;
    final kite = KiteItem(
      id: editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      brand: kiteBrandController.text.trim(),
      model: kiteModelController.text.trim(),
      sizeMeters: kiteSizeController.text.trim(),
      year: kiteYearController.text.trim(),
    );
    mutateState(() {
      gearController.saveKite(kite);
      kiteBrandController.clear();
      kiteModelController.clear();
      kiteSizeController.text = '12';
      kiteYearController.text = DateTime.now().year.toString();
    });
  }

  void saveBar({String? editingId}) {
    if (!_canSaveBar) return;
    final bar = BarItem(
      id: editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      brand: barBrandController.text.trim(),
      model: barModelController.text.trim(),
      lineLengthMeters: barLineLengthController.text.trim(),
      widthCm: barWidthController.text.trim(),
      year: barYearController.text.trim(),
    );
    mutateState(() {
      gearController.saveBar(bar);
      barBrandController.clear();
      barModelController.clear();
      barLineLengthController.text = '22';
      barWidthController.text = '50';
      barYearController.text = DateTime.now().year.toString();
    });
  }

  void saveBoard({String? editingId}) {
    if (!_canSaveBoard) return;
    final board = BoardItem(
      id: editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      brand: boardBrandController.text.trim(),
      model: boardModelController.text.trim(),
      type: selectedBoardType(),
      sizeCm: boardSizeController.text.trim(),
      year: boardYearController.text.trim(),
    );
    mutateState(() {
      gearController.saveBoard(board);
      boardBrandController.clear();
      boardModelController.clear();
      boardSizeController.clear();
      boardYearController.text = DateTime.now().year.toString();
      setSelectedBoardType('Twin tip');
    });
  }

  void saveHarness({String? editingId}) {
    if (!_canSaveHarness) return;
    final harness = HarnessItem(
      id: editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      brand: harnessBrandController.text.trim(),
      model: harnessModelController.text.trim(),
      size: harnessSizeController.text.trim(),
      year: harnessYearController.text.trim(),
    );
    mutateState(() {
      gearController.saveHarness(harness);
      harnessBrandController.clear();
      harnessModelController.clear();
      harnessSizeController.text = 'M';
      harnessYearController.text = DateTime.now().year.toString();
    });
  }

  void saveWetsuit({String? editingId}) {
    if (!_canSaveWetsuit) return;
    final wetsuit = WetsuitItem(
      id: editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      brand: wetsuitBrandController.text.trim(),
      model: wetsuitModelController.text.trim(),
      thickness: wetsuitThicknessController.text.trim(),
      size: wetsuitSizeController.text.trim(),
      year: wetsuitYearController.text.trim(),
    );
    mutateState(() {
      gearController.saveWetsuit(wetsuit);
      wetsuitBrandController.clear();
      wetsuitModelController.clear();
      wetsuitThicknessController.text = '4/3';
      wetsuitSizeController.text = 'M';
      wetsuitYearController.text = DateTime.now().year.toString();
    });
  }

  void saveHelmet({String? editingId}) {
    if (!_canSaveHelmet) return;
    final helmet = HelmetItem(
      id: editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      brand: helmetBrandController.text.trim(),
      model: helmetModelController.text.trim(),
      year: helmetYearController.text.trim(),
    );
    mutateState(() {
      gearController.saveHelmet(helmet);
      helmetBrandController.clear();
      helmetModelController.clear();
      helmetYearController.text = DateTime.now().year.toString();
    });
  }

  void saveVest({String? editingId}) {
    if (!_canSaveVest) return;
    final vest = VestItem(
      id: editingId ?? DateTime.now().microsecondsSinceEpoch.toString(),
      brand: vestBrandController.text.trim(),
      model: vestModelController.text.trim(),
      size: vestSizeController.text.trim(),
      year: vestYearController.text.trim(),
    );
    mutateState(() {
      gearController.saveVest(vest);
      vestBrandController.clear();
      vestModelController.clear();
      vestSizeController.text = 'M';
      vestYearController.text = DateTime.now().year.toString();
    });
  }

  void saveGearSetup({String? editingId}) {
    if (!canSaveGearSetup) return;
    final normalizedSetupId = _normalizedGearSetupId(editingId);
    final setup = GearSetup(
      id: normalizedSetupId,
      name: gearSetupNameController.text.trim(),
      kiteId: selectedKiteForSetupId()!,
      barId: selectedBarForSetupId(),
      boardId: selectedBoardForSetupId()!,
      harnessId: selectedHarnessForSetupId(),
      wetsuitId: selectedWetsuitForSetupId(),
      helmetId: selectedHelmetForSetupId(),
      vestId: selectedVestForSetupId(),
      createdAt: DateTime.now(),
    );
    mutateState(() {
      gearController.saveGearSetup(setup);
      if (editingId != null && editingId != normalizedSetupId) {
        gearController.deleteGearSetup(editingId);
      }
      gearSetupNameController.clear();
      publishGearSetupsForSessions();
    });

    if (Scaffold.maybeOf(context) != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Equipacion "${setup.name}" guardada')),
      );
    }
  }

  String _normalizedGearSetupId(String? currentId) {
    if (currentId != null && _uuidPattern.hasMatch(currentId)) {
      return currentId;
    }
    return _uuid.v4();
  }

  void deleteKite(String kiteId) {
    mutateState(() {
      gearController.deleteKite(kiteId);
      publishGearSetupsForSessions();
    });
  }

  void deleteBar(String barId) {
    mutateState(() {
      gearController.deleteBar(barId);
      publishGearSetupsForSessions();
    });
  }

  void deleteBoard(String boardId) {
    mutateState(() {
      gearController.deleteBoard(boardId);
      publishGearSetupsForSessions();
    });
  }

  void deleteHarness(String harnessId) {
    mutateState(() {
      gearController.deleteHarness(harnessId);
      publishGearSetupsForSessions();
    });
  }

  void deleteWetsuit(String wetsuitId) {
    mutateState(() {
      gearController.deleteWetsuit(wetsuitId);
      publishGearSetupsForSessions();
    });
  }

  void deleteHelmet(String helmetId) {
    mutateState(() {
      gearController.deleteHelmet(helmetId);
      publishGearSetupsForSessions();
    });
  }

  void deleteVest(String vestId) {
    mutateState(() {
      gearController.deleteVest(vestId);
      publishGearSetupsForSessions();
    });
  }

  void deleteGearSetup(String setupId) {
    mutateState(() {
      gearController.deleteGearSetup(setupId);
      publishGearSetupsForSessions();
    });
  }

  bool get _canSaveKite {
    return kiteBrandController.text.trim().isNotEmpty &&
        kiteModelController.text.trim().isNotEmpty &&
        kiteSizeController.text.trim().isNotEmpty &&
        kiteYearController.text.trim().isNotEmpty;
  }

  bool get _canSaveBar {
    return barBrandController.text.trim().isNotEmpty &&
        barModelController.text.trim().isNotEmpty &&
        barLineLengthController.text.trim().isNotEmpty &&
        barWidthController.text.trim().isNotEmpty &&
        barYearController.text.trim().isNotEmpty;
  }

  bool get _canSaveBoard {
    return boardBrandController.text.trim().isNotEmpty &&
        boardModelController.text.trim().isNotEmpty &&
        boardYearController.text.trim().isNotEmpty;
  }

  bool get _canSaveHarness {
    return harnessBrandController.text.trim().isNotEmpty &&
        harnessModelController.text.trim().isNotEmpty &&
        harnessSizeController.text.trim().isNotEmpty &&
        harnessYearController.text.trim().isNotEmpty;
  }

  bool get _canSaveWetsuit {
    return wetsuitBrandController.text.trim().isNotEmpty &&
        wetsuitModelController.text.trim().isNotEmpty &&
        wetsuitThicknessController.text.trim().isNotEmpty &&
        wetsuitSizeController.text.trim().isNotEmpty &&
        wetsuitYearController.text.trim().isNotEmpty;
  }

  bool get _canSaveHelmet {
    return helmetBrandController.text.trim().isNotEmpty &&
        helmetModelController.text.trim().isNotEmpty &&
        helmetYearController.text.trim().isNotEmpty;
  }

  bool get _canSaveVest {
    return vestBrandController.text.trim().isNotEmpty &&
        vestModelController.text.trim().isNotEmpty &&
        vestSizeController.text.trim().isNotEmpty &&
        vestYearController.text.trim().isNotEmpty;
  }
}
