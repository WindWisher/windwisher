part of 'spots_page.dart';

String? _validateSpotForAdd({
  required String name,
  required bool allowCustomMode,
  required Set<String> existingSpotNames,
  required _AvailableSpot? selectedOfficialSpot,
  required _CustomSpotPoint? customPoint,
}) {
  final normalized = (selectedOfficialSpot?.name ?? name).toLowerCase();

  if (name.isEmpty) {
    return 'El nombre del spot es obligatorio';
  }

  if (existingSpotNames.contains(normalized)) {
    return 'Ese spot ya esta agregado';
  }

  if (selectedOfficialSpot == null && customPoint == null) {
    return allowCustomMode
        ? 'Para un spot personalizado debes seleccionar coordenadas.'
        : 'Debes seleccionar uno de los spots oficiales sugeridos.';
  }

  if (!allowCustomMode &&
      (selectedOfficialSpot == null || customPoint != null)) {
    return 'Con el plan user solo puedes guardar spots oficiales.';
  }

  return null;
}

_SpotItem _buildAddedSpotItem({
  required String name,
  required String area,
  required _AvailableSpot? selectedOfficialSpot,
  required _CustomSpotPoint? customPoint,
  required String? backgroundImagePath,
}) {
  return _SpotItem(
    name: selectedOfficialSpot?.name ?? name,
    area: area.isEmpty ? 'Sin zona definida' : area,
    isCustom: customPoint != null || selectedOfficialSpot == null,
    createdAt: DateTime.now(),
    latitude: customPoint?.latitude ?? selectedOfficialSpot?.latitude,
    longitude: customPoint?.longitude ?? selectedOfficialSpot?.longitude,
    aemetMunicipalityCode: selectedOfficialSpot?.aemetMunicipalityCode,
    aemetBeachCode: selectedOfficialSpot?.aemetBeachCode,
    aemetBeachCodes: selectedOfficialSpot?.aemetBeachCodes ?? const <String>[],
    backgroundImagePath: backgroundImagePath,
  );
}
