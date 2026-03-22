import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_gear_dialogs_helpers.dart';

class ProfileGearDialogsCoordinator {
  ProfileGearDialogsCoordinator({
    required this.context,
    required this.mutateState,
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
    required this.savedKites,
    required this.savedBars,
    required this.savedBoards,
    required this.savedHarnesses,
    required this.savedWetsuits,
    required this.savedHelmets,
    required this.savedVests,
    required this.findKite,
    required this.findBar,
    required this.findBoard,
    required this.findHarness,
    required this.findWetsuit,
    required this.findHelmet,
    required this.findVest,
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

  final BuildContext context;
  final void Function(VoidCallback callback) mutateState;

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

  final List<KiteItem> Function() savedKites;
  final List<BarItem> Function() savedBars;
  final List<BoardItem> Function() savedBoards;
  final List<HarnessItem> Function() savedHarnesses;
  final List<WetsuitItem> Function() savedWetsuits;
  final List<HelmetItem> Function() savedHelmets;
  final List<VestItem> Function() savedVests;

  final KiteItem? Function(String id) findKite;
  final BarItem? Function(String id) findBar;
  final BoardItem? Function(String id) findBoard;
  final HarnessItem? Function(String id) findHarness;
  final WetsuitItem? Function(String id) findWetsuit;
  final HelmetItem? Function(String id) findHelmet;
  final VestItem? Function(String id) findVest;

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

  final bool Function() canSaveGearSetup;
  final void Function({String? editingId}) saveGearSetup;
  final void Function({String? editingId}) saveKite;
  final void Function({String? editingId}) saveBar;
  final void Function({String? editingId}) saveBoard;
  final void Function({String? editingId}) saveHarness;
  final void Function({String? editingId}) saveWetsuit;
  final void Function({String? editingId}) saveHelmet;
  final void Function({String? editingId}) saveVest;

  Future<bool> confirmDeleteItem(String itemLabel) {
    return showConfirmDeleteItemDialog(context: context, itemLabel: itemLabel);
  }

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
            return AlertDialog(
              title: const Text('Configurar equipacion'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: gearSetupNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de equipacion',
                        hintText: 'Ej: Big Air 25-35kt',
                      ),
                      onChanged: (_) {
                        setDialogState(() {});
                        mutateState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      key: ValueKey(
                        'setup-kite-${selectedKiteForSetupId() ?? 'none'}-${savedKites().length}',
                      ),
                      initialValue: selectedKiteForSetupId(),
                      decoration: const InputDecoration(labelText: 'Cometa'),
                      items: savedKites()
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.id,
                              child: Text(
                                '${item.brand} ${item.model} ${item.sizeMeters}m (${item.year})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        mutateState(() => setSelectedKiteForSetupId(value));
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'setup-board-${selectedBoardForSetupId() ?? 'none'}-${savedBoards().length}',
                      ),
                      initialValue: selectedBoardForSetupId(),
                      decoration: const InputDecoration(labelText: 'Tabla'),
                      items: savedBoards()
                          .map(
                            (item) => DropdownMenuItem<String?>(
                              value: item.id,
                              child: Text(
                                '${item.brand} ${item.model} (${item.year})',
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        mutateState(() => setSelectedBoardForSetupId(value));
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'setup-bar-${selectedBarForSetupId() ?? 'none'}-${savedBars().length}',
                      ),
                      initialValue: selectedBarForSetupId(),
                      decoration: const InputDecoration(labelText: 'Barra'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sin barra'),
                        ),
                        ...savedBars().map(
                          (item) => DropdownMenuItem<String?>(
                            value: item.id,
                            child: Text(
                              '${item.brand} ${item.model} (${item.year})',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        mutateState(() => setSelectedBarForSetupId(value));
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'setup-harness-${selectedHarnessForSetupId() ?? 'none'}-${savedHarnesses().length}',
                      ),
                      initialValue: selectedHarnessForSetupId(),
                      decoration: const InputDecoration(labelText: 'Arnes'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sin arnes'),
                        ),
                        ...savedHarnesses().map(
                          (item) => DropdownMenuItem<String?>(
                            value: item.id,
                            child: Text(
                              '${item.brand} ${item.model} (${item.year})',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        mutateState(() => setSelectedHarnessForSetupId(value));
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'setup-wetsuit-${selectedWetsuitForSetupId() ?? 'none'}-${savedWetsuits().length}',
                      ),
                      initialValue: selectedWetsuitForSetupId(),
                      decoration: const InputDecoration(labelText: 'Traje'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sin traje'),
                        ),
                        ...savedWetsuits().map(
                          (item) => DropdownMenuItem<String?>(
                            value: item.id,
                            child: Text(
                              '${item.brand} ${item.model} (${item.year})',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        mutateState(() => setSelectedWetsuitForSetupId(value));
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'setup-helmet-${selectedHelmetForSetupId() ?? 'none'}-${savedHelmets().length}',
                      ),
                      initialValue: selectedHelmetForSetupId(),
                      decoration: const InputDecoration(labelText: 'Casco'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sin casco'),
                        ),
                        ...savedHelmets().map(
                          (item) => DropdownMenuItem<String?>(
                            value: item.id,
                            child: Text(
                              '${item.brand} ${item.model} (${item.year})',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        mutateState(() => setSelectedHelmetForSetupId(value));
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'setup-vest-${selectedVestForSetupId() ?? 'none'}-${savedVests().length}',
                      ),
                      initialValue: selectedVestForSetupId(),
                      decoration: const InputDecoration(labelText: 'Chaleco'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Sin chaleco'),
                        ),
                        ...savedVests().map(
                          (item) => DropdownMenuItem<String?>(
                            value: item.id,
                            child: Text(
                              '${item.brand} ${item.model} ${item.size} (${item.year})',
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        mutateState(() => setSelectedVestForSetupId(value));
                        setDialogState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: canSaveGearSetup()
                      ? () {
                          saveGearSetup(editingId: existing?.id);
                          Navigator.of(dialogContext).pop();
                        }
                      : null,
                  child: const Text('Guardar equipacion'),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
        return AlertDialog(
          title: const Text('Configurar cometa'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kiteBrandController,
                  decoration: const InputDecoration(labelText: 'Marca cometa'),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: kiteModelController,
                  decoration: const InputDecoration(labelText: 'Modelo cometa'),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: kiteSizeController,
                  decoration: const InputDecoration(
                    labelText: 'Tamano cometa (m)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: kiteYearController,
                  decoration: const InputDecoration(labelText: 'Ano cometa'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                saveKite(editingId: existing?.id);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Guardar cometa'),
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
        return AlertDialog(
          title: const Text('Configurar barra'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: barBrandController,
                  decoration: const InputDecoration(labelText: 'Marca barra'),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: barModelController,
                  decoration: const InputDecoration(labelText: 'Modelo barra'),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: barLineLengthController,
                  decoration: const InputDecoration(
                    labelText: 'Longitud lineas (m)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: barWidthController,
                  decoration: const InputDecoration(
                    labelText: 'Ancho barra (cm)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: barYearController,
                  decoration: const InputDecoration(labelText: 'Ano barra'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                saveBar(editingId: existing?.id);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Guardar barra'),
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
            return AlertDialog(
              title: const Text('Configurar tabla'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: boardBrandController,
                      decoration: const InputDecoration(
                        labelText: 'Marca tabla',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: boardModelController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo tabla',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    DropdownButtonFormField<String>(
                      initialValue: boardType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo tabla',
                      ),
                      items: const ['Twin tip', 'Surf', 'Foil']
                          .map(
                            (value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setDialogState(() => boardType = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: boardSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Tamano tabla (cm)',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: boardYearController,
                      decoration: const InputDecoration(labelText: 'Ano tabla'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    mutateState(() => setSelectedBoardType(boardType));
                    saveBoard(editingId: existing?.id);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Guardar tabla'),
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Configurar arnes'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: harnessBrandController,
                      decoration: const InputDecoration(
                        labelText: 'Marca arnes',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: harnessModelController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo arnes',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: harnessSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Talla arnes',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: harnessYearController,
                      decoration: const InputDecoration(labelText: 'Ano arnes'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    saveHarness(editingId: existing?.id);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Guardar arnes'),
                ),
              ],
            );
          },
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Configurar traje'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: wetsuitBrandController,
                      decoration: const InputDecoration(
                        labelText: 'Marca traje',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: wetsuitModelController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo traje',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: wetsuitThicknessController,
                      decoration: const InputDecoration(
                        labelText: 'Grosor traje (mm)',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: wetsuitSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Talla traje',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: wetsuitYearController,
                      decoration: const InputDecoration(labelText: 'Ano traje'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    saveWetsuit(editingId: existing?.id);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Guardar traje'),
                ),
              ],
            );
          },
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
        return AlertDialog(
          title: const Text('Configurar casco'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: helmetBrandController,
                  decoration: const InputDecoration(labelText: 'Marca casco'),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: helmetModelController,
                  decoration: const InputDecoration(labelText: 'Modelo casco'),
                ),
                const SizedBox(height: AppSpacing.xs),
                TextField(
                  controller: helmetYearController,
                  decoration: const InputDecoration(labelText: 'Ano casco'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                saveHelmet(editingId: existing?.id);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Guardar casco'),
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Configurar chaleco'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: vestBrandController,
                      decoration: const InputDecoration(
                        labelText: 'Marca chaleco',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: vestModelController,
                      decoration: const InputDecoration(
                        labelText: 'Modelo chaleco',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: vestSizeController,
                      decoration: const InputDecoration(
                        labelText: 'Talla chaleco',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: vestYearController,
                      decoration: const InputDecoration(
                        labelText: 'Ano chaleco',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    saveVest(editingId: existing?.id);
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Guardar chaleco'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
