import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';

abstract class ProfileGearRepositoryPort {
  Future<void> hydrate();

  List<KiteItem> getKites();

  List<BarItem> getBars();

  List<BoardItem> getBoards();

  List<HarnessItem> getHarnesses();

  List<WetsuitItem> getWetsuits();

  List<HelmetItem> getHelmets();

  List<VestItem> getVests();

  List<GearSetup> getGearSetups();

  void saveKite(KiteItem item);

  void saveBar(BarItem item);

  void saveBoard(BoardItem item);

  void saveHarness(HarnessItem item);

  void saveWetsuit(WetsuitItem item);

  void saveHelmet(HelmetItem item);

  void saveVest(VestItem item);

  void saveGearSetup(GearSetup setup);

  void deleteKite(String id);

  void deleteBar(String id);

  void deleteBoard(String id);

  void deleteHarness(String id);

  void deleteWetsuit(String id);

  void deleteHelmet(String id);

  void deleteVest(String id);

  void deleteGearSetup(String id);

  void replaceGearSetups(List<GearSetup> setups);
}
