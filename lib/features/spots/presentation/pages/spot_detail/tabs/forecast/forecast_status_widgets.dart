part of '../../spot_detail_page.dart';

extension _SpotDetailForecastStatusWidgets on _SpotDetailPageState {
  String _compactTechnicalError(String value) {
    final normalized = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 140) {
      return normalized;
    }
    return '${normalized.substring(0, 140)}...';
  }

  bool get _isFullscreenActive =>
      _fullscreenMode != _ForecastFullscreenMode.none;

  Widget _buildForecastDataStatusBanner(_ForecastLoadResult result) {
    final colorScheme = Theme.of(context).colorScheme;
    final (icon, color, text) = switch (result.source) {
      _ForecastDataSource.live => (
        Icons.cloud_done_rounded,
        const Color(0xFF2E7D32),
        'Datos reales cargados desde $_forecastProvider.',
      ),
      _ForecastDataSource.mock => (
        Icons.developer_mode_rounded,
        colorScheme.primary,
        'Modo demo local para este proveedor.',
      ),
      _ForecastDataSource.fallback => (
        Icons.warning_amber_rounded,
        const Color(0xFFF9A825),
        result.message ?? 'Datos no disponibles.',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAemetBeachStatusBanner(_AemetBeachForecastLoadResult result) {
    final bannerResult = _ForecastLoadResult(
      rows: const <_ForecastRow>[],
      source: result.source,
      message: result.message,
      technicalError: result.technicalError,
    );
    return _buildForecastDataStatusBanner(bannerResult);
  }

  Widget _buildAemetCoastalStatusBanner(
    _AemetCoastalForecastLoadResult result,
  ) {
    final bannerResult = _ForecastLoadResult(
      rows: const <_ForecastRow>[],
      source: result.source,
      message: result.message,
      technicalError: result.technicalError,
    );
    return _buildForecastDataStatusBanner(bannerResult);
  }

  Widget _buildUnavailableForecastState({
    String? message,
    String? technicalError,
    VoidCallback? onRetry,
  }) {
    final diagnosticMessage = technicalError == null
        ? null
        : _compactTechnicalError(technicalError);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 28,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Sin datos disponibles',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            message ?? 'Prueba de nuevo mas tarde o cambia de proveedor.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (diagnosticMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              diagnosticMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildForecastLoadingState({bool includeBottomSpacing = false}) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: LinearProgressIndicator(),
        ),
        if (includeBottomSpacing) const SizedBox(height: AppSpacing.sm),
      ],
    );
  }
}
