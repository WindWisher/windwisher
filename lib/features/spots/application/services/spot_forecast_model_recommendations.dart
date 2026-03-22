class SpotForecastModelRecommendation {
  const SpotForecastModelRecommendation({
    required this.badgeLabel,
    required this.message,
  });

  final String badgeLabel;
  final String message;
}

SpotForecastModelRecommendation? getSpotForecastModelRecommendation({
  required String spotName,
  required String provider,
  required String model,
}) {
  final normalizedSpot = spotName.trim().toLowerCase();

  if (provider == 'Open-Meteo' && normalizedSpot == 'oliva puerto') {
    return switch (model) {
      'AROME Seamless' => const SpotForecastModelRecommendation(
        badgeLabel: 'Top',
        message:
            'Muy buena apuesta por su detalle y continuidad en corto plazo.',
      ),
      'ARPEGE Europe' => const SpotForecastModelRecommendation(
        badgeLabel: 'Top',
        message:
            'Muy recomendable por su equilibrio entre cobertura regional y detalle.',
      ),
      'ECMWF' => const SpotForecastModelRecommendation(
        badgeLabel: 'Recomendado',
        message: 'Referencia muy solida si quieres un baseline estable.',
      ),
      'AROME France' => const SpotForecastModelRecommendation(
        badgeLabel: 'Recomendado',
        message: 'Interesante si la cobertura fina entra bien en la zona.',
      ),
      _ => null,
    };
  }

  return null;
}
