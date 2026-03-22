import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_gear_repository_port.dart';

class ProfileGearUseCases {
  const ProfileGearUseCases(this._repository);

  final ProfileGearRepositoryPort _repository;

  Future<void> hydrate() => _repository.hydrate();

  List<KiteItem> getKites() => _repository.getKites();

  List<BarItem> getBars() => _repository.getBars();

  List<BoardItem> getBoards() => _repository.getBoards();

  List<HarnessItem> getHarnesses() => _repository.getHarnesses();

  List<WetsuitItem> getWetsuits() => _repository.getWetsuits();

  List<HelmetItem> getHelmets() => _repository.getHelmets();

  List<VestItem> getVests() => _repository.getVests();

  List<GearSetup> getGearSetups() => _repository.getGearSetups();

  void saveKite(KiteItem item) => _repository.saveKite(item);

  void saveBar(BarItem item) => _repository.saveBar(item);

  void saveBoard(BoardItem item) => _repository.saveBoard(item);

  void saveHarness(HarnessItem item) => _repository.saveHarness(item);

  void saveWetsuit(WetsuitItem item) => _repository.saveWetsuit(item);

  void saveHelmet(HelmetItem item) => _repository.saveHelmet(item);

  void saveVest(VestItem item) => _repository.saveVest(item);

  void saveGearSetup(GearSetup setup) => _repository.saveGearSetup(setup);

  void deleteKite(String id) => _repository.deleteKite(id);

  void deleteBar(String id) => _repository.deleteBar(id);

  void deleteBoard(String id) => _repository.deleteBoard(id);

  void deleteHarness(String id) => _repository.deleteHarness(id);

  void deleteWetsuit(String id) => _repository.deleteWetsuit(id);

  void deleteHelmet(String id) => _repository.deleteHelmet(id);

  void deleteVest(String id) => _repository.deleteVest(id);

  void deleteGearSetup(String id) => _repository.deleteGearSetup(id);

  void replaceGearSetups(List<GearSetup> setups) {
    _repository.replaceGearSetups(setups);
  }
}
