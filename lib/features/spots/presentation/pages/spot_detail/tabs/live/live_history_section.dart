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
      final canLoadHistory = _supportsHistoricalDataForSelectedStation();
      return _LiveHistoryLoadCard(
        sourceLabel: _historicalSeriesDisplayLabel(),
        stationName: _selectedStationName(),
        isLoading: _isHistoricalLoading,
        canLoad: canLoadHistory,
        description: _selectedHistoricalUnavailableDescription(),
        onLoad: _loadSelectedStationHistoricalData,
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
    final usesRawCollectedHistory =
        _usesRawCollectedHistoryForSelectedStation();
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
            _LiveHistoryHeader(
              intraday: intraday,
              providerLabel: historyProviderLabel,
              stationName: _selectedStationName(),
              diagnosticLabel: diagnosticLabel,
            ),
            const SizedBox(height: AppSpacing.xs),
            _LiveHistoryRangeControls(
              usesFixedWindow: usesFixedAemetOlivaWindow,
              coverageLabel: historicalCoverageLabel,
              availableRanges: availableRanges,
              selectedRange: _historyRange,
              showBucketSelector:
                  intraday &&
                  !usesFixedAemetOlivaWindow &&
                  !usesRawCollectedHistory,
              bucketOptions: _availableBucketOptions(_historyRange),
              selectedBucketOption: _selectedBucketOption(_historyRange),
              onRangeChanged: _handleHistoryRangeChanged,
              onBucketChanged: _handleHistoricalBucketOptionChanged,
            ),
            const SizedBox(height: AppSpacing.sm),
            _LiveHistoryComparisonControls(
              providers: _historyForecastProviders(),
              selectedProvider: selectedHistoryForecastProvider,
              models: historyForecastModels,
              selectedModel: selectedHistoryForecastModel,
              canLoad: canLoadHistoricalForecast,
              isLoading: _historyForecastLoadRequested,
              onProviderChanged: _handleHistoryForecastProviderChanged,
              onModelChanged: _handleHistoryForecastModelChanged,
              onLoad: _ensureHistoryForecastRowsLoaded,
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
            _LiveHistoryChartShell(
              isRefreshing: _isHistoricalRefreshing,
              onRefresh: _refreshHistoricalChartData,
              onOpenFullscreen: _openHistoricalChartFullscreen,
              chart: _buildInteractiveHistoryChart(
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
          ],
        ),
      ),
    );
  }
}
