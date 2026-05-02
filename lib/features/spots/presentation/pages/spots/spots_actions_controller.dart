// ignore_for_file: invalid_use_of_protected_member

part of 'spots_page.dart';

extension SpotsActionsController on SpotsPageState {
  bool _canRenderLocalImage(String? path) {
    return !kIsWeb && path != null && path.isNotEmpty;
  }

  Future<void> _showEditSpotSheet(_SpotItem spot) async {
    if (!_canEditOrDeleteSavedSpots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu plan actual no permite editar spots guardados'),
        ),
      );
      return;
    }

    final edited = await showModalBottomSheet<_SpotItem>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _EditSpotSheet(spot: spot),
    );

    if (!mounted || edited == null) {
      return;
    }

    final duplicated = _spots.any(
      (entry) =>
          entry != spot &&
          entry.name.trim().toLowerCase() == edited.name.trim().toLowerCase(),
    );
    if (duplicated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ese spot ya esta agregado')),
      );
      return;
    }

    setState(() {
      final index = _spots.indexOf(spot);
      if (index != -1) {
        _spots[index] = edited;
        _spotsModule.deleteSpotByName(spot.name);
        _spotsModule.saveSpot(edited);
      }
    });
  }

  void editSpotFromToolbar() {
    if (!_canEditOrDeleteSavedSpots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu plan actual no permite editar spots guardados'),
        ),
      );
      return;
    }
    if (_spots.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No hay spots para editar')));
      return;
    }

    setState(() {
      _pendingCardAction = _PendingCardAction.edit;
      _selectedSpotNames.clear();
    });
  }

  void deleteMultipleSpotsFromToolbar() {
    if (!_canEditOrDeleteSavedSpots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu plan actual no permite eliminar spots guardados'),
        ),
      );
      return;
    }
    if (_spots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay spots para eliminar')),
      );
      return;
    }

    setState(() {
      _pendingCardAction = _PendingCardAction.deleteMany;
      _selectedSpotNames.clear();
    });
  }

  bool get _isMultiMode => _pendingCardAction == _PendingCardAction.deleteMany;

  void _cancelPendingActionMode() {
    setState(() {
      _pendingCardAction = _PendingCardAction.none;
      _selectedSpotNames.clear();
    });
  }

  Future<void> _applyPendingBatchAction() async {
    if (_selectedSpotNames.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un spot')),
      );
      return;
    }

    if (_pendingCardAction == _PendingCardAction.deleteMany) {
      setState(() {
        for (final name in _selectedSpotNames) {
          _spotsModule.deleteSpotByName(name);
        }
        _spots.removeWhere((spot) => _selectedSpotNames.contains(spot.name));
        _pendingCardAction = _PendingCardAction.none;
        _selectedSpotNames.clear();
      });
      return;
    }

    return;
  }

  Future<void> _handleCardTap(_SpotItem spot) async {
    if (_pendingCardAction == _PendingCardAction.none) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SpotDetailPage(
            name: spot.name,
            area: spot.area,
            isCustom: spot.isCustom,
            latitude: spot.latitude,
            longitude: spot.longitude,
            aemetMunicipalityCode: spot.aemetMunicipalityCode,
            aemetBeachCode: spot.aemetBeachCode,
            aemetBeachCodes: spot.aemetBeachCodes,
            backgroundImagePath: spot.backgroundImagePath,
            spotsModule: _spotsModule,
          ),
        ),
      );
      return;
    }

    if (_pendingCardAction == _PendingCardAction.edit) {
      setState(() {
        _pendingCardAction = _PendingCardAction.none;
      });
      await _showEditSpotSheet(spot);
      return;
    }

    if (_pendingCardAction == _PendingCardAction.deleteMany) {
      setState(() {
        if (_selectedSpotNames.contains(spot.name)) {
          _selectedSpotNames.remove(spot.name);
        } else {
          _selectedSpotNames.add(spot.name);
        }
      });
      return;
    }

    return;
  }
}
