import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/presentation/models/session_gear_models.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class SessionGearMapper {
  const SessionGearMapper._();

  static SessionProfileGearSnapshot buildSnapshot({
    required List<GearSetup> gearSetups,
    required List<KiteItem> kites,
    required List<BoardItem> boards,
    required List<BarItem> bars,
    required List<HarnessItem> harnesses,
    required List<WetsuitItem> wetsuits,
    required List<HelmetItem> helmets,
    required List<VestItem> vests,
  }) {
    final deduplicated = <String, GearSetup>{
      for (final setup in gearSetups) setup.id: setup,
    };
    return SessionProfileGearSnapshot(
      setups: deduplicated.values.toList(growable: false),
      kitesById: {for (final kite in kites) kite.id: kite},
      boardsById: {for (final board in boards) board.id: board},
      barsById: {for (final bar in bars) bar.id: bar},
      harnessesById: {for (final harness in harnesses) harness.id: harness},
      wetsuitsById: {for (final wetsuit in wetsuits) wetsuit.id: wetsuit},
      helmetsById: {for (final helmet in helmets) helmet.id: helmet},
      vestsById: {for (final vest in vests) vest.id: vest},
    );
  }

  static List<SessionGearSetupOptionData> buildGearSetupOptions(
    SessionProfileGearSnapshot snapshot,
  ) {
    return snapshot.setups.map((setup) {
      final detailLines = buildGearSetupDetailLines(
        kite: snapshot.kitesById[setup.kiteId],
        board: snapshot.boardsById[setup.boardId],
        bar: setup.barId == null ? null : snapshot.barsById[setup.barId!],
        harness: setup.harnessId == null
            ? null
            : snapshot.harnessesById[setup.harnessId!],
        wetsuit: setup.wetsuitId == null
            ? null
            : snapshot.wetsuitsById[setup.wetsuitId!],
        helmet: setup.helmetId == null
            ? null
            : snapshot.helmetsById[setup.helmetId!],
        vest: setup.vestId == null ? null : snapshot.vestsById[setup.vestId!],
      );
      return SessionGearSetupOptionData(
        id: setup.id,
        name: setup.name,
        detailLines: detailLines,
      );
    }).toList(growable: false);
  }

  static List<String> buildGearSetupDetailLines({
    KiteItem? kite,
    BoardItem? board,
    BarItem? bar,
    HarnessItem? harness,
    WetsuitItem? wetsuit,
    HelmetItem? helmet,
    VestItem? vest,
  }) {
    return [
      if (kite != null)
        'Cometa: ${kite.brand} ${kite.model} ${kite.sizeMeters}m',
      if (board != null)
        board.sizeCm.trim().isEmpty
            ? 'Tabla: ${board.brand} ${board.model}'
            : 'Tabla: ${board.brand} ${board.model} ${board.sizeCm}cm',
      if (bar != null)
        'Barra: ${bar.brand} ${bar.model} · ${bar.lineLengthMeters}m/${bar.widthCm}cm',
      if (harness != null)
        'Arnes: ${harness.brand} ${harness.model} · ${harness.size}',
      if (wetsuit != null)
        'Traje: ${wetsuit.brand} ${wetsuit.model} · ${wetsuit.thickness} · ${wetsuit.size}',
      if (helmet != null)
        'Casco: ${helmet.brand} ${helmet.model} (${helmet.year})',
      if (vest != null)
        'Chaleco: ${vest.brand} ${vest.model} · ${vest.size} (${vest.year})',
    ];
  }

  static GearSetup? findGearSetup(
    SessionProfileGearSnapshot snapshot,
    RecordedSession session,
  ) {
    if (session.gearSetupId != null) {
      for (final setup in snapshot.setups) {
        if (setup.id == session.gearSetupId) {
          return setup;
        }
      }
    }
    if (session.gearSetupName != null) {
      for (final setup in snapshot.setups) {
        if (setup.name == session.gearSetupName) {
          return setup;
        }
      }
    }
    return null;
  }
}
