import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/profile/application/use_cases/profile_gear_use_cases.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_gear_repository_port.dart';
import 'package:windwisher/features/profile/presentation/state/profile_gear_controller.dart';

void main() {
  test('hydrate refreshes controller state from repository', () async {
    final repository = _HydratingProfileGearRepository();
    final controller = ProfileGearController(
      useCases: ProfileGearUseCases(repository),
    );

    expect(controller.savedKites, isEmpty);
    expect(controller.savedBoards, isEmpty);
    expect(controller.savedGearSetups, isEmpty);

    await controller.hydrate();

    expect(repository.hydrateCallCount, 1);
    expect(controller.savedKites, hasLength(1));
    expect(controller.savedBars, hasLength(1));
    expect(controller.savedBoards, hasLength(1));
    expect(controller.savedHarnesses, hasLength(1));
    expect(controller.savedWetsuits, hasLength(1));
    expect(controller.savedHelmets, hasLength(1));
    expect(controller.savedVests, hasLength(1));
    expect(controller.savedGearSetups, hasLength(1));
    expect(controller.savedGearSetups.single.name, 'Levante 20-25');
    expect(controller.findKite('kite_1')?.model, 'Orbit');
    expect(controller.findBoard('board_1')?.model, 'Atmos');
  });
}

class _HydratingProfileGearRepository implements ProfileGearRepositoryPort {
  int hydrateCallCount = 0;

  final List<KiteItem> _kites = [];
  final List<BarItem> _bars = [];
  final List<BoardItem> _boards = [];
  final List<HarnessItem> _harnesses = [];
  final List<WetsuitItem> _wetsuits = [];
  final List<HelmetItem> _helmets = [];
  final List<VestItem> _vests = [];
  final List<GearSetup> _gearSetups = [];

  @override
  Future<void> hydrate() async {
    hydrateCallCount += 1;
    _kites
      ..clear()
      ..add(
        KiteItem(
          id: 'kite_1',
          brand: 'North',
          model: 'Orbit',
          sizeMeters: '10',
          year: '2025',
        ),
      );
    _bars
      ..clear()
      ..add(
        BarItem(
          id: 'bar_1',
          brand: 'North',
          model: 'Navigator',
          lineLengthMeters: '22',
          widthCm: '50',
          year: '2025',
        ),
      );
    _boards
      ..clear()
      ..add(
        BoardItem(
          id: 'board_1',
          brand: 'North',
          model: 'Atmos',
          type: 'Twin tip',
          sizeCm: '136',
          year: '2025',
        ),
      );
    _harnesses
      ..clear()
      ..add(
        HarnessItem(
          id: 'harness_1',
          brand: 'Mystic',
          model: 'Stealth',
          size: 'M',
          year: '2025',
        ),
      );
    _wetsuits
      ..clear()
      ..add(
        WetsuitItem(
          id: 'wetsuit_1',
          brand: 'Manera',
          model: 'Meteor',
          thickness: '4/3',
          size: 'M',
          year: '2025',
        ),
      );
    _helmets
      ..clear()
      ..add(
        HelmetItem(
          id: 'helmet_1',
          brand: 'Gath',
          model: 'Neo',
          year: '2025',
        ),
      );
    _vests
      ..clear()
      ..add(
        VestItem(
          id: 'vest_1',
          brand: 'ION',
          model: 'Vector',
          size: 'M',
          year: '2025',
        ),
      );
    _gearSetups
      ..clear()
      ..add(
        GearSetup(
          id: 'setup_1',
          name: 'Levante 20-25',
          kiteId: 'kite_1',
          barId: 'bar_1',
          boardId: 'board_1',
          harnessId: 'harness_1',
          wetsuitId: 'wetsuit_1',
          helmetId: 'helmet_1',
          vestId: 'vest_1',
          createdAt: DateTime(2026, 3, 15, 21, 20),
        ),
      );
  }

  @override
  List<KiteItem> getKites() => List<KiteItem>.unmodifiable(_kites);

  @override
  List<BarItem> getBars() => List<BarItem>.unmodifiable(_bars);

  @override
  List<BoardItem> getBoards() => List<BoardItem>.unmodifiable(_boards);

  @override
  List<HarnessItem> getHarnesses() =>
      List<HarnessItem>.unmodifiable(_harnesses);

  @override
  List<WetsuitItem> getWetsuits() => List<WetsuitItem>.unmodifiable(_wetsuits);

  @override
  List<HelmetItem> getHelmets() => List<HelmetItem>.unmodifiable(_helmets);

  @override
  List<VestItem> getVests() => List<VestItem>.unmodifiable(_vests);

  @override
  List<GearSetup> getGearSetups() => List<GearSetup>.unmodifiable(_gearSetups);

  @override
  void saveKite(KiteItem item) {}

  @override
  void saveBar(BarItem item) {}

  @override
  void saveBoard(BoardItem item) {}

  @override
  void saveHarness(HarnessItem item) {}

  @override
  void saveWetsuit(WetsuitItem item) {}

  @override
  void saveHelmet(HelmetItem item) {}

  @override
  void saveVest(VestItem item) {}

  @override
  void saveGearSetup(GearSetup setup) {}

  @override
  void deleteKite(String id) {}

  @override
  void deleteBar(String id) {}

  @override
  void deleteBoard(String id) {}

  @override
  void deleteHarness(String id) {}

  @override
  void deleteWetsuit(String id) {}

  @override
  void deleteHelmet(String id) {}

  @override
  void deleteVest(String id) {}

  @override
  void deleteGearSetup(String id) {}

  @override
  void replaceGearSetups(List<GearSetup> setups) {}
}
