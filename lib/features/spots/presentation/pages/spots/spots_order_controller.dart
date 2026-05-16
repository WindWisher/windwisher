// ignore_for_file: invalid_use_of_protected_member

part of 'spots_page.dart';

extension _SpotsOrderController on SpotsPageState {
  File get _spotOrderFile => File(
    AppStoragePaths.resolve('spots_manual_order_${_spotOrderOwnerKey()}.json'),
  );

  String _spotOrderOwnerKey() {
    final userId = EnvConfig.supabaseConfigured
        ? Supabase.instance.client.auth.currentUser?.id
        : null;
    final rawKey = (userId == null || userId.isEmpty) ? 'local' : userId;
    return rawKey.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  String _spotOrderKey(_SpotItem spot) {
    return spot.name.trim().toLowerCase();
  }

  List<String> _loadSpotOrderKeys() {
    try {
      final file = _spotOrderFile;
      if (!file.existsSync()) {
        return const <String>[];
      }
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! List) {
        return const <String>[];
      }
      return decoded.whereType<String>().toList(growable: false);
    } catch (_) {
      return const <String>[];
    }
  }

  void _persistSpotOrderKeys() {
    try {
      _spotOrderFile.writeAsStringSync(jsonEncode(_spotOrderKeys));
    } catch (_) {
      // The order is a convenience preference; failing to persist it must not
      // block the spots list itself.
    }
  }

  void _applyStoredSpotOrder() {
    if (_spotOrderKeys.isEmpty || _spots.length < 2) {
      return;
    }
    final orderIndex = <String, int>{
      for (var index = 0; index < _spotOrderKeys.length; index++)
        _spotOrderKeys[index]: index,
    };
    _spots.sort((a, b) {
      final aIndex = orderIndex[_spotOrderKey(a)];
      final bIndex = orderIndex[_spotOrderKey(b)];
      if (aIndex != null && bIndex != null) {
        return aIndex.compareTo(bIndex);
      }
      if (aIndex != null) {
        return -1;
      }
      if (bIndex != null) {
        return 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  void _syncManualOrderFromSpots() {
    _spotOrderKeys = _spots.map(_spotOrderKey).toList(growable: false);
    _persistSpotOrderKeys();
  }

  void _handleSpotReorder(int oldIndex, int newIndex) {
    if (_sort != _SpotSort.manual || _isMultiMode) {
      return;
    }
    final visibleSpots = _filteredSpots;
    if (oldIndex < 0 ||
        oldIndex >= visibleSpots.length ||
        newIndex < 0 ||
        newIndex > visibleSpots.length) {
      return;
    }

    setState(() {
      final reorderedVisible = visibleSpots.toList(growable: true);
      final targetIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
      final movedSpot = reorderedVisible.removeAt(oldIndex);
      reorderedVisible.insert(targetIndex, movedSpot);

      final visibleKeys = visibleSpots.map(_spotOrderKey).toSet();
      final visibleQueue = reorderedVisible.toList(growable: true);
      for (var index = 0; index < _spots.length; index++) {
        if (!visibleKeys.contains(_spotOrderKey(_spots[index]))) {
          continue;
        }
        _spots[index] = visibleQueue.removeAt(0);
      }
      _syncManualOrderFromSpots();
    });
  }
}
