class MySessionCardData {
  const MySessionCardData({
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.deviceName,
    required this.deviceKind,
    this.gearSetupName,
    required this.localPhotoPath,
    required this.durationLabel,
    required this.jumpLabel,
    required this.hangtimeLabel,
    required this.maxSpeedLabel,
  });

  final String title;
  final String subtitle;
  final String summary;
  final String deviceName;
  final String deviceKind;
  final String? gearSetupName;
  final String? localPhotoPath;
  final String durationLabel;
  final String? jumpLabel;
  final String? hangtimeLabel;
  final String? maxSpeedLabel;
}

class MySessionsEmptyStateData {
  const MySessionsEmptyStateData({
    required this.message,
    required this.showClearSearchAction,
  });

  final String message;
  final bool showClearSearchAction;
}

class MySessionsSearchFieldData {
  const MySessionsSearchFieldData({
    required this.hintText,
    required this.showClearAction,
  });

  final String hintText;
  final bool showClearAction;
}

class MySessionsPageData {
  const MySessionsPageData({
    required this.searchFieldData,
    required this.emptyStateData,
    required this.hasSessions,
  });

  final MySessionsSearchFieldData searchFieldData;
  final MySessionsEmptyStateData emptyStateData;
  final bool hasSessions;
}
