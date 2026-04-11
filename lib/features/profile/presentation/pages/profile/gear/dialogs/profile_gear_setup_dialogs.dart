part of 'profile_gear_dialogs_coordinator.dart';

extension ProfileGearSetupDialogs on ProfileGearDialogsCoordinator {
  Future<void> openGearSetupDetailsDialog(GearSetup setup) {
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

    return showGearSetupDetailsDialog(
      context: context,
      setup: setup,
      kite: kite,
      board: board,
      bar: bar,
      harness: harness,
      wetsuit: wetsuit,
      helmet: helmet,
      vest: vest,
    );
  }

  Future<void> openGearSetupDialog({GearSetup? existing}) async {
    if (existing != null) {
      gearSetupNameController.text = existing.name;
      setSelectedKiteForSetupId(existing.kiteId);
      setSelectedBarForSetupId(existing.barId);
      setSelectedBoardForSetupId(existing.boardId);
      setSelectedHarnessForSetupId(existing.harnessId);
      setSelectedWetsuitForSetupId(existing.wetsuitId);
      setSelectedHelmetForSetupId(existing.helmetId);
      setSelectedVestForSetupId(existing.vestId);
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return ProfileGearFormDialog(
              title: 'Configurar equipacion',
              content: ProfileGearSetupForm(
                nameController: gearSetupNameController,
                onNameChanged: (_) {
                  setDialogState(() {});
                  mutateState(() {});
                },
                selectedKiteId: selectedKiteForSetupId(),
                savedKites: savedKites(),
                onKiteChanged: (value) {
                  mutateState(() => setSelectedKiteForSetupId(value));
                  setDialogState(() {});
                },
                selectedBoardId: selectedBoardForSetupId(),
                savedBoards: savedBoards(),
                onBoardChanged: (value) {
                  mutateState(() => setSelectedBoardForSetupId(value));
                  setDialogState(() {});
                },
                selectedBarId: selectedBarForSetupId(),
                savedBars: savedBars(),
                onBarChanged: (value) {
                  mutateState(() => setSelectedBarForSetupId(value));
                  setDialogState(() {});
                },
                selectedHarnessId: selectedHarnessForSetupId(),
                savedHarnesses: savedHarnesses(),
                onHarnessChanged: (value) {
                  mutateState(() => setSelectedHarnessForSetupId(value));
                  setDialogState(() {});
                },
                selectedWetsuitId: selectedWetsuitForSetupId(),
                savedWetsuits: savedWetsuits(),
                onWetsuitChanged: (value) {
                  mutateState(() => setSelectedWetsuitForSetupId(value));
                  setDialogState(() {});
                },
                selectedHelmetId: selectedHelmetForSetupId(),
                savedHelmets: savedHelmets(),
                onHelmetChanged: (value) {
                  mutateState(() => setSelectedHelmetForSetupId(value));
                  setDialogState(() {});
                },
                selectedVestId: selectedVestForSetupId(),
                savedVests: savedVests(),
                onVestChanged: (value) {
                  mutateState(() => setSelectedVestForSetupId(value));
                  setDialogState(() {});
                },
              ),
              actions: [
                ProfileGearSetupDialogActions(
                  canSave: canSaveGearSetup(),
                  onCancel: () => Navigator.of(dialogContext).pop(),
                  onSave: () {
                    saveGearSetup(editingId: existing?.id);
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
}
