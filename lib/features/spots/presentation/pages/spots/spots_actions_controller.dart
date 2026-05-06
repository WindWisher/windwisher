// ignore_for_file: invalid_use_of_protected_member

part of 'spots_page.dart';

extension SpotsActionsController on SpotsPageState {
  bool _canRenderLocalImage(String? path) {
    return !kIsWeb && path != null && path.isNotEmpty;
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
            capabilities: spot.capabilities,
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
      _toggleSpotSelection(spot);
      return;
    }

    return;
  }
}
