import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_gear_repository_port.dart';

class InMemoryProfileGearRepositoryAdapter
    implements ProfileGearRepositoryPort {
  @override
  Future<void> hydrate() async {}

  final List<KiteItem> _kites = [];
  final List<BarItem> _bars = [];
  final List<BoardItem> _boards = [];
  final List<HarnessItem> _harnesses = [];
  final List<WetsuitItem> _wetsuits = [];
  final List<HelmetItem> _helmets = [];
  final List<VestItem> _vests = [];
  final List<GearSetup> _gearSetups = [];

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
  void saveKite(KiteItem item) => _saveById(_kites, item, (value) => value.id);

  @override
  void saveBar(BarItem item) => _saveById(_bars, item, (value) => value.id);

  @override
  void saveBoard(BoardItem item) =>
      _saveById(_boards, item, (value) => value.id);

  @override
  void saveHarness(HarnessItem item) =>
      _saveById(_harnesses, item, (value) => value.id);

  @override
  void saveWetsuit(WetsuitItem item) =>
      _saveById(_wetsuits, item, (value) => value.id);

  @override
  void saveHelmet(HelmetItem item) =>
      _saveById(_helmets, item, (value) => value.id);

  @override
  void saveVest(VestItem item) => _saveById(_vests, item, (value) => value.id);

  @override
  void saveGearSetup(GearSetup setup) =>
      _saveById(_gearSetups, setup, (value) => value.id);

  @override
  void deleteKite(String id) => _kites.removeWhere((item) => item.id == id);

  @override
  void deleteBar(String id) => _bars.removeWhere((item) => item.id == id);

  @override
  void deleteBoard(String id) => _boards.removeWhere((item) => item.id == id);

  @override
  void deleteHarness(String id) =>
      _harnesses.removeWhere((item) => item.id == id);

  @override
  void deleteWetsuit(String id) =>
      _wetsuits.removeWhere((item) => item.id == id);

  @override
  void deleteHelmet(String id) => _helmets.removeWhere((item) => item.id == id);

  @override
  void deleteVest(String id) => _vests.removeWhere((item) => item.id == id);

  @override
  void deleteGearSetup(String id) =>
      _gearSetups.removeWhere((item) => item.id == id);

  @override
  void replaceGearSetups(List<GearSetup> setups) {
    _gearSetups
      ..clear()
      ..addAll(setups);
  }

  void clearAll() {
    _kites.clear();
    _bars.clear();
    _boards.clear();
    _harnesses.clear();
    _wetsuits.clear();
    _helmets.clear();
    _vests.clear();
    _gearSetups.clear();
  }

  void _saveById<T>(List<T> list, T item, String Function(T value) idOf) {
    final index = list.indexWhere((value) => idOf(value) == idOf(item));
    if (index >= 0) {
      list[index] = item;
    } else {
      list.insert(0, item);
    }
  }
}
