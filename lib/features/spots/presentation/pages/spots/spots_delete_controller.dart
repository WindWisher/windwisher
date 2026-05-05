// ignore_for_file: invalid_use_of_protected_member

part of 'spots_page.dart';

extension SpotsDeleteController on SpotsPageState {
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

    if (_pendingCardAction != _PendingCardAction.deleteMany) {
      return;
    }

    setState(() {
      for (final name in _selectedSpotNames) {
        _spotsModule.deleteSpotByName(name);
      }
      _spots.removeWhere((spot) => _selectedSpotNames.contains(spot.name));
      _pendingCardAction = _PendingCardAction.none;
      _selectedSpotNames.clear();
    });
  }

  void _toggleSpotSelection(_SpotItem spot) {
    setState(() {
      if (_selectedSpotNames.contains(spot.name)) {
        _selectedSpotNames.remove(spot.name);
      } else {
        _selectedSpotNames.add(spot.name);
      }
    });
  }
}
