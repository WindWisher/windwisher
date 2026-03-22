import 'dart:async';
import 'dart:convert';

import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_gear_repository_port.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/in_memory/in_memory_profile_gear_repository_adapter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileGearRepositoryAdapter implements ProfileGearRepositoryPort {
  SupabaseProfileGearRepositoryAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;
  final InMemoryProfileGearRepositoryAdapter _memory =
      InMemoryProfileGearRepositoryAdapter();

  @override
  Future<void> hydrate() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    final rows = await _client
        .from('user_gear_setups')
        .select('id, name, board, kite, bar, wetsuit, notes, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    final kites = <String, KiteItem>{};
    final bars = <String, BarItem>{};
    final boards = <String, BoardItem>{};
    final harnesses = <String, HarnessItem>{};
    final wetsuits = <String, WetsuitItem>{};
    final helmets = <String, HelmetItem>{};
    final vests = <String, VestItem>{};
    final setups = <GearSetup>[];

    for (final row in (rows as List<dynamic>).whereType<Map<String, dynamic>>()) {
      final hydrated = _hydrateSetupRow(row);
      if (hydrated == null) {
        continue;
      }
      final snapshot = hydrated.snapshot;
      if (snapshot.kite != null) {
        kites[snapshot.kite!.id] = snapshot.kite!;
      }
      if (snapshot.bar != null) {
        bars[snapshot.bar!.id] = snapshot.bar!;
      }
      if (snapshot.board != null) {
        boards[snapshot.board!.id] = snapshot.board!;
      }
      if (snapshot.harness != null) {
        harnesses[snapshot.harness!.id] = snapshot.harness!;
      }
      if (snapshot.wetsuit != null) {
        wetsuits[snapshot.wetsuit!.id] = snapshot.wetsuit!;
      }
      if (snapshot.helmet != null) {
        helmets[snapshot.helmet!.id] = snapshot.helmet!;
      }
      if (snapshot.vest != null) {
        vests[snapshot.vest!.id] = snapshot.vest!;
      }
      setups.add(hydrated.setup);
    }

    for (final item in kites.values) {
      _memory.saveKite(item);
    }
    for (final item in bars.values) {
      _memory.saveBar(item);
    }
    for (final item in boards.values) {
      _memory.saveBoard(item);
    }
    for (final item in harnesses.values) {
      _memory.saveHarness(item);
    }
    for (final item in wetsuits.values) {
      _memory.saveWetsuit(item);
    }
    for (final item in helmets.values) {
      _memory.saveHelmet(item);
    }
    for (final item in vests.values) {
      _memory.saveVest(item);
    }
    _memory.replaceGearSetups(setups);
  }

  @override
  List<KiteItem> getKites() => _memory.getKites();

  @override
  List<BarItem> getBars() => _memory.getBars();

  @override
  List<BoardItem> getBoards() => _memory.getBoards();

  @override
  List<HarnessItem> getHarnesses() => _memory.getHarnesses();

  @override
  List<WetsuitItem> getWetsuits() => _memory.getWetsuits();

  @override
  List<HelmetItem> getHelmets() => _memory.getHelmets();

  @override
  List<VestItem> getVests() => _memory.getVests();

  @override
  List<GearSetup> getGearSetups() => _memory.getGearSetups();

  @override
  void saveKite(KiteItem item) => _memory.saveKite(item);

  @override
  void saveBar(BarItem item) => _memory.saveBar(item);

  @override
  void saveBoard(BoardItem item) => _memory.saveBoard(item);

  @override
  void saveHarness(HarnessItem item) => _memory.saveHarness(item);

  @override
  void saveWetsuit(WetsuitItem item) => _memory.saveWetsuit(item);

  @override
  void saveHelmet(HelmetItem item) => _memory.saveHelmet(item);

  @override
  void saveVest(VestItem item) => _memory.saveVest(item);

  @override
  void saveGearSetup(GearSetup setup) {
    _memory.saveGearSetup(setup);
    unawaited(_upsertRemoteSetup(setup));
  }

  @override
  void deleteKite(String id) => _memory.deleteKite(id);

  @override
  void deleteBar(String id) => _memory.deleteBar(id);

  @override
  void deleteBoard(String id) => _memory.deleteBoard(id);

  @override
  void deleteHarness(String id) => _memory.deleteHarness(id);

  @override
  void deleteWetsuit(String id) => _memory.deleteWetsuit(id);

  @override
  void deleteHelmet(String id) => _memory.deleteHelmet(id);

  @override
  void deleteVest(String id) => _memory.deleteVest(id);

  @override
  void deleteGearSetup(String id) {
    _memory.deleteGearSetup(id);
    unawaited(_deleteRemoteSetup(id));
  }

  @override
  void replaceGearSetups(List<GearSetup> setups) {
    _memory.replaceGearSetups(setups);
    unawaited(_replaceRemoteSetups(setups));
  }

  Future<void> _upsertRemoteSetup(GearSetup setup) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    final snapshot = _buildSnapshot(setup);
    await _client.from('user_gear_setups').upsert(<String, dynamic>{
      'id': setup.id,
      'user_id': user.id,
      'name': setup.name,
      'board': _boardLabel(snapshot.board),
      'kite': _kiteLabel(snapshot.kite),
      'bar': _barLabel(snapshot.bar),
      'wetsuit': _wetsuitLabel(snapshot.wetsuit),
      'notes': jsonEncode(_serializeSnapshot(setup: setup, snapshot: snapshot)),
      'created_at': setup.createdAt.toUtc().toIso8601String(),
    });
  }

  Future<void> _deleteRemoteSetup(String id) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client
        .from('user_gear_setups')
        .delete()
        .eq('user_id', user.id)
        .eq('id', id);
  }

  Future<void> _replaceRemoteSetups(List<GearSetup> setups) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from('user_gear_setups').delete().eq('user_id', user.id);
    for (final setup in setups) {
      await _upsertRemoteSetup(setup);
    }
  }

  _HydratedSetup? _hydrateSetupRow(Map<String, dynamic> row) {
    final notes = row['notes'] as String?;
    if (notes != null && notes.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(notes);
        if (decoded is Map<String, dynamic>) {
          final setup = _deserializeSetup(decoded['setup']);
          final snapshot = _deserializeSnapshot(decoded['items']);
          if (setup != null && snapshot != null) {
            return _HydratedSetup(setup: setup, snapshot: snapshot);
          }
        }
      } catch (_) {}
    }

    final rowId = row['id'] as String? ?? '';
    final createdAt =
        DateTime.tryParse((row['created_at'] as String?) ?? '') ??
        DateTime.now();
    final kite = (row['kite'] as String?)?.trim();
    final board = (row['board'] as String?)?.trim();
    if (rowId.isEmpty || kite == null || kite.isEmpty || board == null || board.isEmpty) {
      return null;
    }

    final kiteItem = KiteItem(
      id: 'remote-kite-$rowId',
      brand: kite,
      model: '',
      sizeMeters: '',
      year: '',
    );
    final boardItem = BoardItem(
      id: 'remote-board-$rowId',
      brand: board,
      model: '',
      type: '',
      sizeCm: '',
      year: '',
    );
    final bar = (row['bar'] as String?)?.trim();
    final wetsuit = (row['wetsuit'] as String?)?.trim();
    final barItem = bar == null || bar.isEmpty
        ? null
        : BarItem(
            id: 'remote-bar-$rowId',
            brand: bar,
            model: '',
            lineLengthMeters: '',
            widthCm: '',
            year: '',
          );
    final wetsuitItem = wetsuit == null || wetsuit.isEmpty
        ? null
        : WetsuitItem(
            id: 'remote-wetsuit-$rowId',
            brand: wetsuit,
            model: '',
            thickness: '',
            size: '',
            year: '',
          );
    return _HydratedSetup(
      setup: GearSetup(
        id: rowId,
        name: (row['name'] as String?) ?? 'Setup',
        kiteId: kiteItem.id,
        barId: barItem?.id,
        boardId: boardItem.id,
        wetsuitId: wetsuitItem?.id,
        createdAt: createdAt,
      ),
      snapshot: _GearSnapshot(
        kite: kiteItem,
        bar: barItem,
        board: boardItem,
        wetsuit: wetsuitItem,
      ),
    );
  }

  _GearSnapshot _buildSnapshot(GearSetup setup) {
    return _GearSnapshot(
      kite: _memory.getKites().where((item) => item.id == setup.kiteId).firstOrNull,
      bar: setup.barId == null
          ? null
          : _memory.getBars().where((item) => item.id == setup.barId).firstOrNull,
      board: _memory.getBoards().where((item) => item.id == setup.boardId).firstOrNull,
      harness: setup.harnessId == null
          ? null
          : _memory.getHarnesses().where((item) => item.id == setup.harnessId).firstOrNull,
      wetsuit: setup.wetsuitId == null
          ? null
          : _memory.getWetsuits().where((item) => item.id == setup.wetsuitId).firstOrNull,
      helmet: setup.helmetId == null
          ? null
          : _memory.getHelmets().where((item) => item.id == setup.helmetId).firstOrNull,
      vest: setup.vestId == null
          ? null
          : _memory.getVests().where((item) => item.id == setup.vestId).firstOrNull,
    );
  }

  Map<String, dynamic> _serializeSnapshot({
    required GearSetup setup,
    required _GearSnapshot snapshot,
  }) {
    return <String, dynamic>{
      'version': 1,
      'setup': <String, dynamic>{
        'id': setup.id,
        'name': setup.name,
        'kiteId': setup.kiteId,
        'barId': setup.barId,
        'boardId': setup.boardId,
        'harnessId': setup.harnessId,
        'wetsuitId': setup.wetsuitId,
        'helmetId': setup.helmetId,
        'vestId': setup.vestId,
        'createdAt': setup.createdAt.toUtc().toIso8601String(),
      },
      'items': <String, dynamic>{
        'kite': _serializeKite(snapshot.kite),
        'bar': _serializeBar(snapshot.bar),
        'board': _serializeBoard(snapshot.board),
        'harness': _serializeHarness(snapshot.harness),
        'wetsuit': _serializeWetsuit(snapshot.wetsuit),
        'helmet': _serializeHelmet(snapshot.helmet),
        'vest': _serializeVest(snapshot.vest),
      },
    };
  }

  GearSetup? _deserializeSetup(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    final id = source['id'] as String?;
    final name = source['name'] as String?;
    final kiteId = source['kiteId'] as String?;
    final boardId = source['boardId'] as String?;
    if (id == null || name == null || kiteId == null || boardId == null) {
      return null;
    }
    return GearSetup(
      id: id,
      name: name,
      kiteId: kiteId,
      barId: source['barId'] as String?,
      boardId: boardId,
      harnessId: source['harnessId'] as String?,
      wetsuitId: source['wetsuitId'] as String?,
      helmetId: source['helmetId'] as String?,
      vestId: source['vestId'] as String?,
      createdAt:
          DateTime.tryParse((source['createdAt'] as String?) ?? '') ??
          DateTime.now(),
    );
  }

  _GearSnapshot? _deserializeSnapshot(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    return _GearSnapshot(
      kite: _deserializeKite(source['kite']),
      bar: _deserializeBar(source['bar']),
      board: _deserializeBoard(source['board']),
      harness: _deserializeHarness(source['harness']),
      wetsuit: _deserializeWetsuit(source['wetsuit']),
      helmet: _deserializeHelmet(source['helmet']),
      vest: _deserializeVest(source['vest']),
    );
  }

  Map<String, dynamic>? _serializeKite(KiteItem? item) => item == null
      ? null
      : <String, dynamic>{
          'id': item.id,
          'brand': item.brand,
          'model': item.model,
          'sizeMeters': item.sizeMeters,
          'year': item.year,
        };

  KiteItem? _deserializeKite(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    return KiteItem(
      id: source['id'] as String? ?? '',
      brand: source['brand'] as String? ?? '',
      model: source['model'] as String? ?? '',
      sizeMeters: source['sizeMeters'] as String? ?? '',
      year: source['year'] as String? ?? '',
    );
  }

  Map<String, dynamic>? _serializeBar(BarItem? item) => item == null
      ? null
      : <String, dynamic>{
          'id': item.id,
          'brand': item.brand,
          'model': item.model,
          'lineLengthMeters': item.lineLengthMeters,
          'widthCm': item.widthCm,
          'year': item.year,
        };

  BarItem? _deserializeBar(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    return BarItem(
      id: source['id'] as String? ?? '',
      brand: source['brand'] as String? ?? '',
      model: source['model'] as String? ?? '',
      lineLengthMeters: source['lineLengthMeters'] as String? ?? '',
      widthCm: source['widthCm'] as String? ?? '',
      year: source['year'] as String? ?? '',
    );
  }

  Map<String, dynamic>? _serializeBoard(BoardItem? item) => item == null
      ? null
      : <String, dynamic>{
          'id': item.id,
          'brand': item.brand,
          'model': item.model,
          'type': item.type,
          'sizeCm': item.sizeCm,
          'year': item.year,
        };

  BoardItem? _deserializeBoard(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    return BoardItem(
      id: source['id'] as String? ?? '',
      brand: source['brand'] as String? ?? '',
      model: source['model'] as String? ?? '',
      type: source['type'] as String? ?? '',
      sizeCm: source['sizeCm'] as String? ?? '',
      year: source['year'] as String? ?? '',
    );
  }

  Map<String, dynamic>? _serializeHarness(HarnessItem? item) => item == null
      ? null
      : <String, dynamic>{
          'id': item.id,
          'brand': item.brand,
          'model': item.model,
          'size': item.size,
          'year': item.year,
        };

  HarnessItem? _deserializeHarness(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    return HarnessItem(
      id: source['id'] as String? ?? '',
      brand: source['brand'] as String? ?? '',
      model: source['model'] as String? ?? '',
      size: source['size'] as String? ?? '',
      year: source['year'] as String? ?? '',
    );
  }

  Map<String, dynamic>? _serializeWetsuit(WetsuitItem? item) => item == null
      ? null
      : <String, dynamic>{
          'id': item.id,
          'brand': item.brand,
          'model': item.model,
          'thickness': item.thickness,
          'size': item.size,
          'year': item.year,
        };

  WetsuitItem? _deserializeWetsuit(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    return WetsuitItem(
      id: source['id'] as String? ?? '',
      brand: source['brand'] as String? ?? '',
      model: source['model'] as String? ?? '',
      thickness: source['thickness'] as String? ?? '',
      size: source['size'] as String? ?? '',
      year: source['year'] as String? ?? '',
    );
  }

  Map<String, dynamic>? _serializeHelmet(HelmetItem? item) => item == null
      ? null
      : <String, dynamic>{
          'id': item.id,
          'brand': item.brand,
          'model': item.model,
          'year': item.year,
        };

  HelmetItem? _deserializeHelmet(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    return HelmetItem(
      id: source['id'] as String? ?? '',
      brand: source['brand'] as String? ?? '',
      model: source['model'] as String? ?? '',
      year: source['year'] as String? ?? '',
    );
  }

  Map<String, dynamic>? _serializeVest(VestItem? item) => item == null
      ? null
      : <String, dynamic>{
          'id': item.id,
          'brand': item.brand,
          'model': item.model,
          'size': item.size,
          'year': item.year,
        };

  VestItem? _deserializeVest(dynamic source) {
    if (source is! Map<String, dynamic>) {
      return null;
    }
    return VestItem(
      id: source['id'] as String? ?? '',
      brand: source['brand'] as String? ?? '',
      model: source['model'] as String? ?? '',
      size: source['size'] as String? ?? '',
      year: source['year'] as String? ?? '',
    );
  }

  String? _kiteLabel(KiteItem? item) {
    if (item == null) {
      return null;
    }
    final parts = <String>[item.brand, item.model, item.sizeMeters];
    return parts.where((part) => part.trim().isNotEmpty).join(' ').trim();
  }

  String? _boardLabel(BoardItem? item) {
    if (item == null) {
      return null;
    }
    final parts = <String>[item.brand, item.model, item.sizeCm];
    return parts.where((part) => part.trim().isNotEmpty).join(' ').trim();
  }

  String? _barLabel(BarItem? item) {
    if (item == null) {
      return null;
    }
    final parts = <String>[item.brand, item.model];
    return parts.where((part) => part.trim().isNotEmpty).join(' ').trim();
  }

  String? _wetsuitLabel(WetsuitItem? item) {
    if (item == null) {
      return null;
    }
    final parts = <String>[item.brand, item.model, item.thickness];
    return parts.where((part) => part.trim().isNotEmpty).join(' ').trim();
  }
}

class _HydratedSetup {
  const _HydratedSetup({required this.setup, required this.snapshot});

  final GearSetup setup;
  final _GearSnapshot snapshot;
}

class _GearSnapshot {
  const _GearSnapshot({
    this.kite,
    this.bar,
    this.board,
    this.harness,
    this.wetsuit,
    this.helmet,
    this.vest,
  });

  final KiteItem? kite;
  final BarItem? bar;
  final BoardItem? board;
  final HarnessItem? harness;
  final WetsuitItem? wetsuit;
  final HelmetItem? helmet;
  final VestItem? vest;
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
