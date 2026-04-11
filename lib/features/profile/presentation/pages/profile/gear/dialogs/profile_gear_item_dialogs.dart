part of 'profile_gear_dialogs_coordinator.dart';

extension ProfileGearItemDialogs on ProfileGearDialogsCoordinator {
  Future<void> openKiteDialog({KiteItem? existing}) async {
    if (existing != null) {
      kiteBrandController.text = existing.brand;
      kiteModelController.text = existing.model;
      kiteSizeController.text = existing.sizeMeters;
      kiteYearController.text = existing.year;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ProfileGearFormDialog(
          title: 'Configurar cometa',
          content: ProfileKiteForm(
            brandController: kiteBrandController,
            modelController: kiteModelController,
            sizeController: kiteSizeController,
            yearController: kiteYearController,
          ),
          actions: [
            ProfileGearDialogActions(
              saveLabel: 'Guardar cometa',
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSave: () {
                saveKite(editingId: existing?.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> openBarDialog({BarItem? existing}) async {
    if (existing != null) {
      barBrandController.text = existing.brand;
      barModelController.text = existing.model;
      barLineLengthController.text = existing.lineLengthMeters;
      barWidthController.text = existing.widthCm;
      barYearController.text = existing.year;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ProfileGearFormDialog(
          title: 'Configurar barra',
          content: ProfileBarForm(
            brandController: barBrandController,
            modelController: barModelController,
            lineLengthController: barLineLengthController,
            widthController: barWidthController,
            yearController: barYearController,
          ),
          actions: [
            ProfileGearDialogActions(
              saveLabel: 'Guardar barra',
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSave: () {
                saveBar(editingId: existing?.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> openBoardDialog({BoardItem? existing}) async {
    var boardType = existing?.type ?? selectedBoardType();
    if (existing != null) {
      boardBrandController.text = existing.brand;
      boardModelController.text = existing.model;
      boardSizeController.text = existing.sizeCm;
      boardYearController.text = existing.year;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ProfileGearFormDialog(
              title: 'Configurar tabla',
              content: ProfileBoardForm(
                brandController: boardBrandController,
                modelController: boardModelController,
                boardType: boardType,
                onBoardTypeChanged: (value) {
                  if (value == null) return;
                  setDialogState(() => boardType = value);
                },
                sizeController: boardSizeController,
                yearController: boardYearController,
              ),
              actions: [
                ProfileGearDialogActions(
                  saveLabel: 'Guardar tabla',
                  onCancel: () => Navigator.of(dialogContext).pop(),
                  onSave: () {
                    mutateState(() => setSelectedBoardType(boardType));
                    saveBoard(editingId: existing?.id);
                    Navigator.of(dialogContext).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> openHarnessDialog({HarnessItem? existing}) async {
    if (existing != null) {
      harnessBrandController.text = existing.brand;
      harnessModelController.text = existing.model;
      harnessSizeController.text = existing.size;
      harnessYearController.text = existing.year;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ProfileGearFormDialog(
          title: 'Configurar arnes',
          content: ProfileHarnessForm(
            brandController: harnessBrandController,
            modelController: harnessModelController,
            sizeController: harnessSizeController,
            yearController: harnessYearController,
          ),
          actions: [
            ProfileGearDialogActions(
              saveLabel: 'Guardar arnes',
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSave: () {
                saveHarness(editingId: existing?.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> openWetsuitDialog({WetsuitItem? existing}) async {
    if (existing != null) {
      wetsuitBrandController.text = existing.brand;
      wetsuitModelController.text = existing.model;
      wetsuitThicknessController.text = existing.thickness;
      wetsuitSizeController.text = existing.size;
      wetsuitYearController.text = existing.year;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ProfileGearFormDialog(
          title: 'Configurar traje',
          content: ProfileWetsuitForm(
            brandController: wetsuitBrandController,
            modelController: wetsuitModelController,
            thicknessController: wetsuitThicknessController,
            sizeController: wetsuitSizeController,
            yearController: wetsuitYearController,
          ),
          actions: [
            ProfileGearDialogActions(
              saveLabel: 'Guardar traje',
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSave: () {
                saveWetsuit(editingId: existing?.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> openHelmetDialog({HelmetItem? existing}) async {
    if (existing != null) {
      helmetBrandController.text = existing.brand;
      helmetModelController.text = existing.model;
      helmetYearController.text = existing.year;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ProfileGearFormDialog(
          title: 'Configurar casco',
          content: ProfileHelmetForm(
            brandController: helmetBrandController,
            modelController: helmetModelController,
            yearController: helmetYearController,
          ),
          actions: [
            ProfileGearDialogActions(
              saveLabel: 'Guardar casco',
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSave: () {
                saveHelmet(editingId: existing?.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> openVestDialog({VestItem? existing}) async {
    if (existing != null) {
      vestBrandController.text = existing.brand;
      vestModelController.text = existing.model;
      vestSizeController.text = existing.size;
      vestYearController.text = existing.year;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return ProfileGearFormDialog(
          title: 'Configurar chaleco',
          content: ProfileVestForm(
            brandController: vestBrandController,
            modelController: vestModelController,
            sizeController: vestSizeController,
            yearController: vestYearController,
          ),
          actions: [
            ProfileGearDialogActions(
              saveLabel: 'Guardar chaleco',
              onCancel: () => Navigator.of(dialogContext).pop(),
              onSave: () {
                saveVest(editingId: existing?.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
