import 'dart:async';
import 'dart:convert';

import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_gear_repository_port.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/in_memory/in_memory_profile_gear_repository_adapter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileGearRepositoryAdapter implements ProfileGearRepositoryPort {
  SupabaseProfileGearRepositoryAdapter({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  static const _kitesTable = 'user_kites';
  static const _barsTable = 'user_bars';
  static const _boardsTable = 'user_boards';
  static const _harnessesTable = 'user_harnesses';
  static const _wetsuitsTable = 'user_wetsuits';
  static const _helmetsTable = 'user_helmets';
  static const _vestsTable = 'user_vests';
  static const _setupsTable = 'user_gear_setups';

  final SupabaseClient _client;
  final InMemoryProfileGearRepositoryAdapter _memory =
      InMemoryProfileGearRepositoryAdapter();

  @override
  Future<void> hydrate() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }

    _memory.clearAll();

    final kiteRows = await _selectUserRows(
      _kitesTable,
      user.id,
      'id, brand, model, size_meters, year',
    );
    for (final row in kiteRows) {
      final item = _hydrateKiteRow(row);
      if (item != null) {
        _memory.saveKite(item);
      }
    }

    final barRows = await _selectUserRows(
      _barsTable,
      user.id,
      'id, brand, model, line_length_meters, width_cm, year',
    );
    for (final row in barRows) {
      final item = _hydrateBarRow(row);
      if (item != null) {
        _memory.saveBar(item);
      }
    }

    final boardRows = await _selectUserRows(
      _boardsTable,
      user.id,
      'id, brand, model, type, size_cm, year',
    );
    for (final row in boardRows) {
      final item = _hydrateBoardRow(row);
      if (item != null) {
        _memory.saveBoard(item);
      }
    }

    final harnessRows = await _selectUserRows(
      _harnessesTable,
      user.id,
      'id, brand, model, size, year',
    );
    for (final row in harnessRows) {
      final item = _hydrateHarnessRow(row);
      if (item != null) {
        _memory.saveHarness(item);
      }
    }

    final wetsuitRows = await _selectUserRows(
      _wetsuitsTable,
      user.id,
      'id, brand, model, thickness, size, year',
    );
    for (final row in wetsuitRows) {
      final item = _hydrateWetsuitRow(row);
      if (item != null) {
        _memory.saveWetsuit(item);
      }
    }

    final helmetRows = await _selectUserRows(
      _helmetsTable,
      user.id,
      'id, brand, model, year',
    );
    for (final row in helmetRows) {
      final item = _hydrateHelmetRow(row);
      if (item != null) {
        _memory.saveHelmet(item);
      }
    }

    final vestRows = await _selectUserRows(
      _vestsTable,
      user.id,
      'id, brand, model, size, year',
    );
    for (final row in vestRows) {
      final item = _hydrateVestRow(row);
      if (item != null) {
        _memory.saveVest(item);
      }
    }

    final setupRows = await _selectUserRows(
      _setupsTable,
      user.id,
      'id, name, board, kite, bar, wetsuit, notes, created_at',
    );

    final setups = <GearSetup>[];
    for (final row in setupRows) {
      final hydrated = _hydrateSetupRow(row);
      if (hydrated == null) {
        continue;
      }
      final snapshot = hydrated.snapshot;
      if (snapshot.kite != null &&
          !_memory.getKites().any((item) => item.id == snapshot.kite!.id)) {
        _memory.saveKite(snapshot.kite!);
      }
      if (snapshot.bar != null &&
          !_memory.getBars().any((item) => item.id == snapshot.bar!.id)) {
        _memory.saveBar(snapshot.bar!);
      }
      if (snapshot.board != null &&
          !_memory.getBoards().any((item) => item.id == snapshot.board!.id)) {
        _memory.saveBoard(snapshot.board!);
      }
      if (snapshot.harness != null &&
          !_memory.getHarnesses().any(
            (item) => item.id == snapshot.harness!.id,
          )) {
        _memory.saveHarness(snapshot.harness!);
      }
      if (snapshot.wetsuit != null &&
          !_memory.getWetsuits().any(
            (item) => item.id == snapshot.wetsuit!.id,
          )) {
        _memory.saveWetsuit(snapshot.wetsuit!);
      }
      if (snapshot.helmet != null &&
          !_memory.getHelmets().any(
            (item) => item.id == snapshot.helmet!.id,
          )) {
        _memory.saveHelmet(snapshot.helmet!);
      }
      if (snapshot.vest != null &&
          !_memory.getVests().any((item) => item.id == snapshot.vest!.id)) {
        _memory.saveVest(snapshot.vest!);
      }
      setups.add(hydrated.setup);
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
  void saveKite(KiteItem item) {
    _memory.saveKite(item);
    unawaited(_upsertRemoteKite(item));
  }

  @override
  void saveBar(BarItem item) {
    _memory.saveBar(item);
    unawaited(_upsertRemoteBar(item));
  }

  @override
  void saveBoard(BoardItem item) {
    _memory.saveBoard(item);
    unawaited(_upsertRemoteBoard(item));
  }

  @override
  void saveHarness(HarnessItem item) {
    _memory.saveHarness(item);
    unawaited(_upsertRemoteHarness(item));
  }

  @override
  void saveWetsuit(WetsuitItem item) {
    _memory.saveWetsuit(item);
    unawaited(_upsertRemoteWetsuit(item));
  }

  @override
  void saveHelmet(HelmetItem item) {
    _memory.saveHelmet(item);
    unawaited(_upsertRemoteHelmet(item));
  }

  @override
  void saveVest(VestItem item) {
    _memory.saveVest(item);
    unawaited(_upsertRemoteVest(item));
  }

  @override
  void saveGearSetup(GearSetup setup) {
    _memory.saveGearSetup(setup);
    unawaited(_upsertRemoteSetup(setup));
  }

  @override
  void deleteKite(String id) {
    _memory.deleteKite(id);
    unawaited(_deleteRemoteRow(_kitesTable, id));
  }

  @override
  void deleteBar(String id) {
    _memory.deleteBar(id);
    unawaited(_deleteRemoteRow(_barsTable, id));
  }

  @override
  void deleteBoard(String id) {
    _memory.deleteBoard(id);
    unawaited(_deleteRemoteRow(_boardsTable, id));
  }

  @override
  void deleteHarness(String id) {
    _memory.deleteHarness(id);
    unawaited(_deleteRemoteRow(_harnessesTable, id));
  }

  @override
  void deleteWetsuit(String id) {
    _memory.deleteWetsuit(id);
    unawaited(_deleteRemoteRow(_wetsuitsTable, id));
  }

  @override
  void deleteHelmet(String id) {
    _memory.deleteHelmet(id);
    unawaited(_deleteRemoteRow(_helmetsTable, id));
  }

  @override
  void deleteVest(String id) {
    _memory.deleteVest(id);
    unawaited(_deleteRemoteRow(_vestsTable, id));
  }

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
    await _client.from(_setupsTable).upsert(<String, dynamic>{
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
    await _deleteRemoteRow(_setupsTable, id);
  }

  Future<void> _replaceRemoteSetups(List<GearSetup> setups) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from(_setupsTable).delete().eq('user_id', user.id);
    for (final setup in setups) {
      await _upsertRemoteSetup(setup);
    }
  }

  Future<List<Map<String, dynamic>>> _selectUserRows(
    String table,
    String userId,
    String columns,
  ) async {
    final rows = await _client
        .from(table)
        .select(columns)
        .eq('user_id', userId);
    return (rows as List<dynamic>).whereType<Map<String, dynamic>>().toList(
      growable: false,
    );
  }

  Future<void> _deleteRemoteRow(String table, String id) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from(table).delete().eq('user_id', user.id).eq('id', id);
  }

  Future<void> _upsertRemoteKite(KiteItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from(_kitesTable).upsert(<String, dynamic>{
      'id': item.id,
      'user_id': user.id,
      'brand': item.brand,
      'model': item.model,
      'size_meters': item.sizeMeters,
      'year': item.year,
    });
  }

  Future<void> _upsertRemoteBar(BarItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from(_barsTable).upsert(<String, dynamic>{
      'id': item.id,
      'user_id': user.id,
      'brand': item.brand,
      'model': item.model,
      'line_length_meters': item.lineLengthMeters,
      'width_cm': item.widthCm,
      'year': item.year,
    });
  }

  Future<void> _upsertRemoteBoard(BoardItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from(_boardsTable).upsert(<String, dynamic>{
      'id': item.id,
      'user_id': user.id,
      'brand': item.brand,
      'model': item.model,
      'type': item.type,
      'size_cm': item.sizeCm,
      'year': item.year,
    });
  }

  Future<void> _upsertRemoteHarness(HarnessItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from(_harnessesTable).upsert(<String, dynamic>{
      'id': item.id,
      'user_id': user.id,
      'brand': item.brand,
      'model': item.model,
      'size': item.size,
      'year': item.year,
    });
  }

  Future<void> _upsertRemoteWetsuit(WetsuitItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from(_wetsuitsTable).upsert(<String, dynamic>{
      'id': item.id,
      'user_id': user.id,
      'brand': item.brand,
      'model': item.model,
      'thickness': item.thickness,
      'size': item.size,
      'year': item.year,
    });
  }

  Future<void> _upsertRemoteHelmet(HelmetItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from(_helmetsTable).upsert(<String, dynamic>{
      'id': item.id,
      'user_id': user.id,
      'brand': item.brand,
      'model': item.model,
      'year': item.year,
    });
  }

  Future<void> _upsertRemoteVest(VestItem item) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return;
    }
    await _client.from(_vestsTable).upsert(<String, dynamic>{
      'id': item.id,
      'user_id': user.id,
      'brand': item.brand,
      'model': item.model,
      'size': item.size,
      'year': item.year,
    });
  }

  KiteItem? _hydrateKiteRow(Map<String, dynamic> row) {
    final id = row['id'] as String?;
    if (id == null || id.isEmpty) {
      return null;
    }
    return KiteItem(
      id: id,
      brand: row['brand'] as String? ?? '',
      model: row['model'] as String? ?? '',
      sizeMeters: row['size_meters'] as String? ?? '',
      year: row['year'] as String? ?? '',
    );
  }

  BarItem? _hydrateBarRow(Map<String, dynamic> row) {
    final id = row['id'] as String?;
    if (id == null || id.isEmpty) {
      return null;
    }
    return BarItem(
      id: id,
      brand: row['brand'] as String? ?? '',
      model: row['model'] as String? ?? '',
      lineLengthMeters: row['line_length_meters'] as String? ?? '',
      widthCm: row['width_cm'] as String? ?? '',
      year: row['year'] as String? ?? '',
    );
  }

  BoardItem? _hydrateBoardRow(Map<String, dynamic> row) {
    final id = row['id'] as String?;
    if (id == null || id.isEmpty) {
      return null;
    }
    return BoardItem(
      id: id,
      brand: row['brand'] as String? ?? '',
      model: row['model'] as String? ?? '',
      type: row['type'] as String? ?? '',
      sizeCm: row['size_cm'] as String? ?? '',
      year: row['year'] as String? ?? '',
    );
  }

  HarnessItem? _hydrateHarnessRow(Map<String, dynamic> row) {
    final id = row['id'] as String?;
    if (id == null || id.isEmpty) {
      return null;
    }
    return HarnessItem(
      id: id,
      brand: row['brand'] as String? ?? '',
      model: row['model'] as String? ?? '',
      size: row['size'] as String? ?? '',
      year: row['year'] as String? ?? '',
    );
  }

  WetsuitItem? _hydrateWetsuitRow(Map<String, dynamic> row) {
    final id = row['id'] as String?;
    if (id == null || id.isEmpty) {
      return null;
    }
    return WetsuitItem(
      id: id,
      brand: row['brand'] as String? ?? '',
      model: row['model'] as String? ?? '',
      thickness: row['thickness'] as String? ?? '',
      size: row['size'] as String? ?? '',
      year: row['year'] as String? ?? '',
    );
  }

  HelmetItem? _hydrateHelmetRow(Map<String, dynamic> row) {
    final id = row['id'] as String?;
    if (id == null || id.isEmpty) {
      return null;
    }
    return HelmetItem(
      id: id,
      brand: row['brand'] as String? ?? '',
      model: row['model'] as String? ?? '',
      year: row['year'] as String? ?? '',
    );
  }

  VestItem? _hydrateVestRow(Map<String, dynamic> row) {
    final id = row['id'] as String?;
    if (id == null || id.isEmpty) {
      return null;
    }
    return VestItem(
      id: id,
      brand: row['brand'] as String? ?? '',
      model: row['model'] as String? ?? '',
      size: row['size'] as String? ?? '',
      year: row['year'] as String? ?? '',
    );
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
