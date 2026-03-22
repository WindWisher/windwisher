class SpotItem {
  const SpotItem({
    required this.name,
    required this.area,
    required this.isCustom,
    required this.createdAt,
    this.latitude,
    this.longitude,
    this.aemetMunicipalityCode,
    this.aemetBeachCode,
    this.aemetBeachCodes = const <String>[],
    this.backgroundImagePath,
  });

  final String name;
  final String area;
  final bool isCustom;
  final DateTime createdAt;
  final double? latitude;
  final double? longitude;
  final String? aemetMunicipalityCode;
  final String? aemetBeachCode;
  final List<String> aemetBeachCodes;
  final String? backgroundImagePath;

  List<String> get resolvedAemetBeachCodes {
    final values = <String>[];
    if (aemetBeachCode != null && aemetBeachCode!.isNotEmpty) {
      values.add(aemetBeachCode!);
    }
    for (final code in aemetBeachCodes) {
      if (code.isNotEmpty && !values.contains(code)) {
        values.add(code);
      }
    }
    return List<String>.unmodifiable(values);
  }
}
