part of '../../spot_detail_page.dart';

extension _SpotDetailLiveHistorySection on _SpotDetailPageState {
  Widget _buildInteractiveHistoryChart({
    required List<double> points,
    required List<double?>? gustPoints,
    required List<String> labels,
    required List<double> xFractions,
    required List<int?> directionDegs,
    required List<_HistoricalDirectionKind?> directionKinds,
    required List<_ChartArrowMarker> overlayMarkers,
    required List<_ChartTimeGuide> timeGuides,
    required List<int> dayStartIndexes,
    required List<String> dayStartLabels,
    required List<double?>? forecastPoints,
    required ScrollController scrollController,
    required bool fullscreen,
    double? fixedHeight,
  }) {
    const yAxisWidth = _liveChartLeftPad;
    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = math.max(
          constraints.maxWidth,
          (math.max(points.length, timeGuides.length) * 20.0) + 90,
        );
        final chartHeight = fixedHeight ?? constraints.maxHeight;

        final realLineColor = const Color(0xFF1F1F8F);
        final gustLineColor = const Color(0xFFC2185B);
        final forecastLineColor = const Color(0xFFD84315);
        final gridMajorColor = Theme.of(
          context,
        ).colorScheme.outline.withValues(alpha: 0.35);
        final gridMinorColor = Theme.of(
          context,
        ).colorScheme.outline.withValues(alpha: 0.16);
        final textColor = Theme.of(context).colorScheme.onSurface;
        final surfaceColor = Theme.of(context).colorScheme.surface;

        _scheduleHistoryChartFocus(
          controller: scrollController,
          fullscreen: fullscreen,
          chartWidth: chartWidth,
          viewportWidth: constraints.maxWidth,
          xFractions: xFractions,
        );

        return Stack(
          children: [
            ClipRect(
              child: SingleChildScrollView(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: chartWidth,
                  height: chartHeight,
                  child: CustomPaint(
                    painter: _LiveWindChartPainter(
                      points: points,
                      gustPoints: gustPoints,
                      timeLabels: labels,
                      pointXFractions: xFractions,
                      markerDirectionsDeg: directionDegs,
                      markerDirectionKinds: directionKinds,
                      overlayMarkers: overlayMarkers,
                      timeGuides: timeGuides,
                      dayStartIndexes: dayStartIndexes,
                      dayStartLabels: dayStartLabels,
                      forecastPoints: forecastPoints,
                      realLineColor: realLineColor,
                      gustLineColor: gustLineColor,
                      forecastLineColor: forecastLineColor,
                      gridMajorColor: gridMajorColor,
                      gridMinorColor: gridMinorColor,
                      textColor: textColor,
                      windSpeedUnit: _windSpeedUnit,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: yAxisWidth,
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LiveWindYAxisPainter(
                    points: points,
                    gustPoints: gustPoints,
                    forecastPoints: forecastPoints,
                    gridMajorColor: gridMajorColor,
                    gridMinorColor: gridMinorColor,
                    textColor: textColor,
                    backgroundColor: surfaceColor,
                    windSpeedUnit: _windSpeedUnit,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openHistoricalChartFullscreen() async {
    final series = _historySeriesWindowed();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('Historico · ${_selectedStationName()}')),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HistoricalChartLegend(
                  showGust: series.gust != null,
                  showForecast: series.forecast != null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Expanded(
                  child: _buildInteractiveHistoryChart(
                    points: series.points,
                    gustPoints: series.gust,
                    labels: series.labels,
                    xFractions: series.xFractions,
                    directionDegs: series.directions,
                    directionKinds: series.directionKinds,
                    overlayMarkers: series.overlayMarkers,
                    timeGuides: series.timeGuides,
                    dayStartIndexes: series.dayStartIndexes,
                    dayStartLabels: series.dayStartLabels,
                    forecastPoints: series.forecast,
                    scrollController: _historyChartFullscreenScrollController,
                    fullscreen: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoricalChart() {
    if (!_hasRealHistoricalSeries()) {
      final sourceLabel = _historicalSeriesDisplayLabel();
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Historico $sourceLabel · ${_selectedStationName()}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Carga el historico real solo cuando quieras consultar la grafica.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: _isHistoricalLoading
                      ? null
                      : _loadSelectedStationHistoricalData,
                  icon: _isHistoricalLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.show_chart_rounded),
                  label: Text(
                    _isHistoricalLoading
                        ? 'Cargando historico'
                        : 'Cargar historico',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final series = _historySeriesWindowed();
    final preparedHistory = _prepareHistorySeriesWindow();
    final intraday = series.intraday;
    final diagnosticLabel = series.diagnosticLabel;
    final historyProviderLabel = _historicalSeriesDisplayLabel();
    final usesFixedAemetOlivaWindow = _usesFixedAemetOlivaHistoryWindow();
    final selectedHistoryForecastProvider = _historyForecastProvider;
    final selectedHistoryForecastModel = _historyForecastModel;
    final historyForecastModels = selectedHistoryForecastProvider == null
        ? const <String>[]
        : _historyForecastModelsForProvider(selectedHistoryForecastProvider);
    final canLoadHistoricalForecast =
        selectedHistoryForecastProvider != null &&
        selectedHistoryForecastModel != null &&
        _supportsHistoricalForecastOverlay(
          provider: selectedHistoryForecastProvider,
          model: selectedHistoryForecastModel,
        );
    final historicalCoverageLabel = _historicalCoverageLabel(
      _selectedHistoricalWindPoints(),
    );
    final forecastAccuracy = _historicalForecastAccuracySummary(
      points: preparedHistory.points,
      bucketDuration: preparedHistory.arrowDuration,
    );
    final availableRanges = _supportsThreeDayHistoryForSelectedStation()
        ? const <_HistoryRange>[_HistoryRange.h1, _HistoryRange.h3]
        : const <_HistoryRange>[_HistoryRange.h1];
    if (!availableRanges.contains(_historyRange)) {
      _historyRange = _HistoryRange.h1;
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${intraday ? 'Historico intradia $historyProviderLabel' : 'Historico diario $historyProviderLabel'} · ${_selectedStationName()}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (diagnosticLabel != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                diagnosticLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            if (usesFixedAemetOlivaWindow)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  historicalCoverageLabel,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<_HistoryRange>(
                  segments: availableRanges
                      .map(
                        (range) => ButtonSegment<_HistoryRange>(
                          value: range,
                          label: Text(_historyRangeLabel(range)),
                        ),
                      )
                      .toList(growable: false),
                  selected: {_historyRange},
                  onSelectionChanged: (value) =>
                      _handleHistoryRangeChanged(value.first),
                ),
              ),
            if (intraday && !usesFixedAemetOlivaWindow) ...[
              const SizedBox(height: AppSpacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SegmentedButton<_HistoricalBucketOption>(
                  segments: _availableBucketOptions(_historyRange)
                      .map(
                        (option) => ButtonSegment<_HistoricalBucketOption>(
                          value: option,
                          label: Text(_historicalBucketOptionLabel(option)),
                        ),
                      )
                      .toList(growable: false),
                  selected: {_selectedBucketOption(_historyRange)},
                  onSelectionChanged: (value) =>
                      _handleHistoricalBucketOptionChanged(value.first),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedHistoryForecastProvider,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Proveedor forecast',
                      hintText: 'Seleccionar',
                      isDense: true,
                    ),
                    items: _historyForecastProviders()
                        .map(
                          (provider) => DropdownMenuItem<String>(
                            value: provider,
                            child: Text(provider),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null || value == _historyForecastProvider) {
                        return;
                      }
                      _handleHistoryForecastProviderChanged(value);
                    },
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    initialValue: selectedHistoryForecastModel,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Modelo forecast',
                      hintText: 'Seleccionar',
                      isDense: true,
                    ),
                    items: historyForecastModels
                        .map((model) {
                          return DropdownMenuItem<String>(
                            value: model,
                            child: Text(model),
                          );
                        })
                        .toList(growable: false),
                    onChanged: historyForecastModels.isEmpty
                        ? null
                        : (value) {
                            if (value == null ||
                                value == _historyForecastModel) {
                              return;
                            }
                            _handleHistoryForecastModelChanged(value);
                          },
                  ),
                ),
                OutlinedButton.icon(
                  onPressed:
                      _historyForecastLoadRequested ||
                          !canLoadHistoricalForecast
                      ? null
                      : _ensureHistoryForecastRowsLoaded,
                  icon: _historyForecastLoadRequested
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.compare_arrows_rounded),
                  label: Text(
                    _historyForecastLoadRequested
                        ? 'Cargando comparativa'
                        : 'Cargar comparativa',
                  ),
                ),
              ],
            ),
            if (forecastAccuracy != null) ...[
              const SizedBox(height: AppSpacing.sm),
              ForecastAccuracyCard(
                totalPercentage: forecastAccuracy.totalPercentage,
                windPercentage: forecastAccuracy.windPercentage,
                directionPercentage: forecastAccuracy.directionPercentage,
                meanAbsoluteErrorKnots: forecastAccuracy.meanAbsoluteErrorKnots,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            _HistoricalChartLegend(
              showGust: series.gust != null,
              showForecast: series.forecast != null,
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 420,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildInteractiveHistoryChart(
                      points: series.points,
                      gustPoints: series.gust,
                      labels: series.labels,
                      xFractions: series.xFractions,
                      directionDegs: series.directions,
                      directionKinds: series.directionKinds,
                      overlayMarkers: series.overlayMarkers,
                      timeGuides: series.timeGuides,
                      dayStartIndexes: series.dayStartIndexes,
                      dayStartLabels: series.dayStartLabels,
                      forecastPoints: series.forecast,
                      scrollController: _historyChartScrollController,
                      fullscreen: false,
                      fixedHeight: 420,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Refrescar grafica',
                        onPressed: _isHistoricalRefreshing
                            ? null
                            : _refreshHistoricalChartData,
                        icon: _isHistoricalRefreshing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Material(
                      color: Theme.of(context).colorScheme.surface,
                      elevation: 2,
                      shape: const CircleBorder(),
                      child: IconButton(
                        tooltip: 'Pantalla completa',
                        onPressed: _openHistoricalChartFullscreen,
                        icon: const Icon(Icons.fullscreen_rounded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
