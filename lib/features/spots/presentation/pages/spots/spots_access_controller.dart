part of 'spots_page.dart';

extension _SpotsAccessController on SpotsPageState {
  bool get _hasAdvancedSpotAccess {
    return _myRoles.any(_advancedRoleNames.contains);
  }

  bool get _canCreateCustomSpots => _hasAdvancedSpotAccess;

  bool get _canEditOrDeleteSavedSpots => _hasAdvancedSpotAccess;

  int get _officialSpotCount => _spots.where((spot) => !spot.isCustom).length;
}

const _advancedRoleNames = <String>{
  'pro',
  'vip',
  'moderator',
  'admin',
  'super_admin',
};
