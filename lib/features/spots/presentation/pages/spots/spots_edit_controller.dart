// ignore_for_file: invalid_use_of_protected_member

part of 'spots_page.dart';

extension _SpotsEditController on SpotsPageState {
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
        _syncManualOrderFromSpots();
        _spotsModule.deleteSpotByName(spot.name);
        _spotsModule.saveSpot(edited);
      }
    });
  }
}
