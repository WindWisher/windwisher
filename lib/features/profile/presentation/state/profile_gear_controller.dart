import 'package:windwisher/features/profile/application/use_cases/profile_gear_use_cases.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';

class ProfileGearController {
  ProfileGearController({required ProfileGearUseCases useCases})
    : _useCases = useCases {
    _refresh();
  }

  final ProfileGearUseCases _useCases;

  List<KiteItem> _savedKites = const [];
  List<BarItem> _savedBars = const [];
  List<BoardItem> _savedBoards = const [];
  List<HarnessItem> _savedHarnesses = const [];
  List<WetsuitItem> _savedWetsuits = const [];
  List<HelmetItem> _savedHelmets = const [];
  List<VestItem> _savedVests = const [];
  List<GearSetup> _savedGearSetups = const [];

  String selectedBoardType = 'Twin tip';
  int selectedGearConfigTabIndex = 0;
  String? selectedKiteManageId;
  String? selectedBarManageId;
  String? selectedBoardManageId;
  String? selectedHarnessManageId;
  String? selectedWetsuitManageId;
  String? selectedHelmetManageId;
  String? selectedVestManageId;
  String? selectedKiteForSetupId;
  String? selectedBarForSetupId;
  String? selectedBoardForSetupId;
  String? selectedHarnessForSetupId;
  String? selectedWetsuitForSetupId;
  String? selectedHelmetForSetupId;
  String? selectedVestForSetupId;

  List<KiteItem> get savedKites => _savedKites;
  List<BarItem> get savedBars => _savedBars;
  List<BoardItem> get savedBoards => _savedBoards;
  List<HarnessItem> get savedHarnesses => _savedHarnesses;
  List<WetsuitItem> get savedWetsuits => _savedWetsuits;
  List<HelmetItem> get savedHelmets => _savedHelmets;
  List<VestItem> get savedVests => _savedVests;
  List<GearSetup> get savedGearSetups => _savedGearSetups;

  Future<void> hydrate() async {
    await _useCases.hydrate();
    _refresh();
  }

  void saveKite(KiteItem kite) {
    _useCases.saveKite(kite);
    selectedKiteManageId = kite.id;
    selectedKiteForSetupId ??= kite.id;
    _refresh();
  }

  void saveBar(BarItem bar) {
    _useCases.saveBar(bar);
    selectedBarManageId = bar.id;
    selectedBarForSetupId ??= bar.id;
    _refresh();
  }

  void saveBoard(BoardItem board) {
    _useCases.saveBoard(board);
    selectedBoardManageId = board.id;
    selectedBoardForSetupId ??= board.id;
    _refresh();
  }

  void saveHarness(HarnessItem harness) {
    _useCases.saveHarness(harness);
    selectedHarnessManageId = harness.id;
    selectedHarnessForSetupId ??= harness.id;
    _refresh();
  }

  void saveWetsuit(WetsuitItem wetsuit) {
    _useCases.saveWetsuit(wetsuit);
    selectedWetsuitManageId = wetsuit.id;
    selectedWetsuitForSetupId ??= wetsuit.id;
    _refresh();
  }

  void saveHelmet(HelmetItem helmet) {
    _useCases.saveHelmet(helmet);
    selectedHelmetManageId = helmet.id;
    selectedHelmetForSetupId ??= helmet.id;
    _refresh();
  }

  void saveVest(VestItem vest) {
    _useCases.saveVest(vest);
    selectedVestManageId = vest.id;
    selectedVestForSetupId ??= vest.id;
    _refresh();
  }

  void saveGearSetup(GearSetup setup) {
    _useCases.saveGearSetup(setup);
    _refresh();
  }

  void deleteKite(String kiteId) {
    _useCases.deleteKite(kiteId);
    _refresh();
    if (selectedKiteManageId == kiteId) {
      selectedKiteManageId = _savedKites.isEmpty ? null : _savedKites.first.id;
    }
    if (selectedKiteForSetupId == kiteId) {
      selectedKiteForSetupId = _savedKites.isEmpty
          ? null
          : _savedKites.first.id;
    }
    _useCases.replaceGearSetups(
      _savedGearSetups.where((setup) => setup.kiteId != kiteId).toList(),
    );
    _refresh();
  }

  void deleteBar(String barId) {
    _useCases.deleteBar(barId);
    _refresh();
    if (selectedBarManageId == barId) {
      selectedBarManageId = _savedBars.isEmpty ? null : _savedBars.first.id;
    }
    if (selectedBarForSetupId == barId) {
      selectedBarForSetupId = _savedBars.isEmpty ? null : _savedBars.first.id;
    }
    _useCases.replaceGearSetups(
      _savedGearSetups
          .map(
            (setup) =>
                setup.barId == barId ? setup.copyWith(barId: null) : setup,
          )
          .toList(),
    );
    _refresh();
  }

  void deleteBoard(String boardId) {
    _useCases.deleteBoard(boardId);
    _refresh();
    if (selectedBoardManageId == boardId) {
      selectedBoardManageId = _savedBoards.isEmpty
          ? null
          : _savedBoards.first.id;
    }
    if (selectedBoardForSetupId == boardId) {
      selectedBoardForSetupId = _savedBoards.isEmpty
          ? null
          : _savedBoards.first.id;
    }
    _useCases.replaceGearSetups(
      _savedGearSetups.where((setup) => setup.boardId != boardId).toList(),
    );
    _refresh();
  }

  void deleteHarness(String harnessId) {
    _useCases.deleteHarness(harnessId);
    _refresh();
    if (selectedHarnessManageId == harnessId) {
      selectedHarnessManageId = _savedHarnesses.isEmpty
          ? null
          : _savedHarnesses.first.id;
    }
    if (selectedHarnessForSetupId == harnessId) {
      selectedHarnessForSetupId = _savedHarnesses.isEmpty
          ? null
          : _savedHarnesses.first.id;
    }
    _useCases.replaceGearSetups(
      _savedGearSetups
          .map(
            (setup) => setup.harnessId == harnessId
                ? setup.copyWith(harnessId: null)
                : setup,
          )
          .toList(),
    );
    _refresh();
  }

  void deleteWetsuit(String wetsuitId) {
    _useCases.deleteWetsuit(wetsuitId);
    _refresh();
    if (selectedWetsuitManageId == wetsuitId) {
      selectedWetsuitManageId = _savedWetsuits.isEmpty
          ? null
          : _savedWetsuits.first.id;
    }
    if (selectedWetsuitForSetupId == wetsuitId) {
      selectedWetsuitForSetupId = _savedWetsuits.isEmpty
          ? null
          : _savedWetsuits.first.id;
    }
    _useCases.replaceGearSetups(
      _savedGearSetups
          .map(
            (setup) => setup.wetsuitId == wetsuitId
                ? setup.copyWith(wetsuitId: null)
                : setup,
          )
          .toList(),
    );
    _refresh();
  }

  void deleteHelmet(String helmetId) {
    _useCases.deleteHelmet(helmetId);
    _refresh();
    if (selectedHelmetManageId == helmetId) {
      selectedHelmetManageId = _savedHelmets.isEmpty
          ? null
          : _savedHelmets.first.id;
    }
    if (selectedHelmetForSetupId == helmetId) {
      selectedHelmetForSetupId = _savedHelmets.isEmpty
          ? null
          : _savedHelmets.first.id;
    }
    _useCases.replaceGearSetups(
      _savedGearSetups
          .map(
            (setup) => setup.helmetId == helmetId
                ? setup.copyWith(helmetId: null)
                : setup,
          )
          .toList(),
    );
    _refresh();
  }

  void deleteVest(String vestId) {
    _useCases.deleteVest(vestId);
    _refresh();
    if (selectedVestManageId == vestId) {
      selectedVestManageId = _savedVests.isEmpty ? null : _savedVests.first.id;
    }
    if (selectedVestForSetupId == vestId) {
      selectedVestForSetupId = _savedVests.isEmpty
          ? null
          : _savedVests.first.id;
    }
    _useCases.replaceGearSetups(
      _savedGearSetups
          .map(
            (setup) =>
                setup.vestId == vestId ? setup.copyWith(vestId: null) : setup,
          )
          .toList(),
    );
    _refresh();
  }

  void deleteGearSetup(String setupId) {
    _useCases.deleteGearSetup(setupId);
    _refresh();
  }

  KiteItem? findKite(String id) =>
      _savedKites.where((item) => item.id == id).firstOrNull;

  BarItem? findBar(String id) =>
      _savedBars.where((item) => item.id == id).firstOrNull;

  BoardItem? findBoard(String id) =>
      _savedBoards.where((item) => item.id == id).firstOrNull;

  HarnessItem? findHarness(String id) =>
      _savedHarnesses.where((item) => item.id == id).firstOrNull;

  WetsuitItem? findWetsuit(String id) =>
      _savedWetsuits.where((item) => item.id == id).firstOrNull;

  HelmetItem? findHelmet(String id) =>
      _savedHelmets.where((item) => item.id == id).firstOrNull;

  VestItem? findVest(String id) =>
      _savedVests.where((item) => item.id == id).firstOrNull;

  void _refresh() {
    _savedKites = _useCases.getKites();
    _savedBars = _useCases.getBars();
    _savedBoards = _useCases.getBoards();
    _savedHarnesses = _useCases.getHarnesses();
    _savedWetsuits = _useCases.getWetsuits();
    _savedHelmets = _useCases.getHelmets();
    _savedVests = _useCases.getVests();
    _savedGearSetups = _useCases.getGearSetups();
  }
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
