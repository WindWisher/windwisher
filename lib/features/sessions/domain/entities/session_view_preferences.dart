class SessionViewPreferences {
  const SessionViewPreferences({
    required this.selectedTabKey,
    required this.filterDeviceName,
    required this.sortOrder,
    required this.lastUsedGearSetupId,
    required this.lastUsedUploadSpot,
  });

  final String selectedTabKey;
  final String filterDeviceName;
  final String sortOrder;
  final String? lastUsedGearSetupId;
  final String lastUsedUploadSpot;

  factory SessionViewPreferences.initial() {
    return const SessionViewPreferences(
      selectedTabKey: 'start',
      filterDeviceName: 'Todos',
      sortOrder: 'Mas recientes',
      lastUsedGearSetupId: null,
      lastUsedUploadSpot: 'Oliva Norte',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'selectedTabKey': selectedTabKey,
      'filterDeviceName': filterDeviceName,
      'sortOrder': sortOrder,
      'lastUsedGearSetupId': lastUsedGearSetupId,
      'lastUsedUploadSpot': lastUsedUploadSpot,
    };
  }

  static SessionViewPreferences fromJson(Map<String, dynamic> json) {
    return SessionViewPreferences(
      selectedTabKey: json['selectedTabKey'] as String? ?? 'start',
      filterDeviceName: json['filterDeviceName'] as String? ?? 'Todos',
      sortOrder: json['sortOrder'] as String? ?? 'Mas recientes',
      lastUsedGearSetupId: json['lastUsedGearSetupId'] as String?,
      lastUsedUploadSpot:
          json['lastUsedUploadSpot'] as String? ?? 'Oliva Norte',
    );
  }
}
