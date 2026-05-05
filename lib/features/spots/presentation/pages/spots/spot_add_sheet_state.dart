part of 'spots_page.dart';

class _SpotAddSheetStateSnapshot {
  const _SpotAddSheetStateSnapshot({
    required this.name,
    required this.selectedOfficialSpot,
    required this.customPoint,
    required this.customMode,
  });

  final String name;
  final _AvailableSpot? selectedOfficialSpot;
  final _CustomSpotPoint? customPoint;
  final bool customMode;

  bool get hasSelectedOfficialSpot {
    return name.isNotEmpty && selectedOfficialSpot != null;
  }

  bool get requiresCoordinates {
    return name.isNotEmpty && !hasSelectedOfficialSpot;
  }

  bool get canSave {
    return name.isNotEmpty && (!requiresCoordinates || customPoint != null);
  }

  bool get allowTextFields {
    return !customMode || customPoint != null;
  }
}
