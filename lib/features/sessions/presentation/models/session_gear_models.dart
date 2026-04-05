import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';

class SessionProfileGearSnapshot {
  const SessionProfileGearSnapshot({
    required this.setups,
    required this.kitesById,
    required this.boardsById,
    required this.barsById,
    required this.harnessesById,
    required this.wetsuitsById,
    required this.helmetsById,
    required this.vestsById,
  });

  final List<GearSetup> setups;
  final Map<String, KiteItem> kitesById;
  final Map<String, BoardItem> boardsById;
  final Map<String, BarItem> barsById;
  final Map<String, HarnessItem> harnessesById;
  final Map<String, WetsuitItem> wetsuitsById;
  final Map<String, HelmetItem> helmetsById;
  final Map<String, VestItem> vestsById;
}
