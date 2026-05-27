// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveHistorySeriesController on _SpotDetailPageState {
  List<_HistoricalWindPoint> _windowHistoricalPoints(
    List<_HistoricalWindPoint> points, {
    Duration? intradayBucket,
  }) {
    if (points.isEmpty) {
      return const <_HistoricalWindPoint>[];
    }
    if (intradayBucket != null) {
      final endExclusive = _alignBucketStart(
        points.last.time,
        intradayBucket,
      ).add(intradayBucket);
      final startInclusive = endExclusive.subtract(
        _durationForRange(_historyRange),
      );
      return points
          .where(
            (point) =>
                !point.time.isBefore(startInclusive) &&
                point.time.isBefore(endExclusive),
          )
          .toList(growable: false);
    }
    final lastPointTime = points.last.time;
    final cutoff = lastPointTime.subtract(_durationForRange(_historyRange));
    return points
        .where((point) => !point.time.isBefore(cutoff))
        .toList(growable: false);
  }

  void _scheduleHistoryChartFocus({
    required ScrollController controller,
    required bool fullscreen,
    required double chartWidth,
    required double viewportWidth,
    required List<double> xFractions,
    required String focusIdentity,
  }) {
    final lastFraction = xFractions.isEmpty ? 1.0 : xFractions.last;
    final focusKey =
        '${chartWidth.toStringAsFixed(1)}|${viewportWidth.toStringAsFixed(1)}|${lastFraction.toStringAsFixed(4)}|$fullscreen|$focusIdentity';
    final currentKey = fullscreen
        ? _historyChartFullscreenFocusKey
        : _historyChartFocusKey;
    if (currentKey == focusKey) {
      return;
    }
    if (fullscreen) {
      _historyChartFullscreenFocusKey = focusKey;
    } else {
      _historyChartFocusKey = focusKey;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!controller.hasClients) return;
      const rightPad = 12.0;
      final plotWidth = math.max(
        0.0,
        chartWidth - _liveChartLeftPad - rightPad,
      );
      final currentPointX = _liveChartLeftPad + (plotWidth * lastFraction);
      final visibleWidth = math.max(0.0, viewportWidth - _liveChartLeftPad);
      final targetX = math.max(
        _liveChartLeftPad + 24,
        _liveChartLeftPad + visibleWidth - 72,
      );
      final targetOffset = (currentPointX - targetX).clamp(
        0.0,
        controller.position.maxScrollExtent,
      );
      controller.jumpTo(targetOffset);
    });
  }

  ({DateTime startInclusive, DateTime endExclusive})
  _alignedIntradayWindowBounds(
    List<_HistoricalWindPoint> points,
    Duration bucket,
  ) {
    final endExclusive = _alignBucketStart(
      points.last.time,
      bucket,
    ).add(bucket);
    return (
      startInclusive: endExclusive.subtract(_durationForRange(_historyRange)),
      endExclusive: endExclusive,
    );
  }

  ({
    List<double> points,
    List<double?>? gust,
    List<String> labels,
    List<double> xFractions,
    List<int?> directions,
    List<_HistoricalDirectionKind?> directionKinds,
    List<_ChartArrowMarker> overlayMarkers,
    List<_ChartTimeGuide> timeGuides,
    List<int> dayStartIndexes,
    List<String> dayStartLabels,
    List<double?>? forecast,
    bool intraday,
    String intervalLabel,
    String? diagnosticLabel,
  })
  _historySeriesWindowed() {
    final prepared = _prepareHistorySeriesWindow();
    final intraday = prepared.intraday;
    final selectedBucketOption = prepared.selectedBucketOption;
    final usesRawCollectedHistory = prepared.usesRawCollectedHistory;
    final gridDuration = prepared.gridDuration;
    final arrowDuration = prepared.arrowDuration;
    final intradayBounds = prepared.intradayBounds;
    final boundedTrimmed = prepared.points;
    final points = boundedTrimmed
        .map((point) => point.windKnots)
        .toList(growable: false);
    final gust = boundedTrimmed
        .map((point) => point.gustKnots)
        .toList(growable: false);
    final labels = boundedTrimmed
        .map((point) => _formatHistoricalLabel(point, intraday: intraday))
        .toList(growable: false);
    final xFractions = intraday && intradayBounds != null
        ? _timeFractionsForPoints(
            boundedTrimmed,
            startInclusive: intradayBounds.startInclusive,
            endExclusive: intradayBounds.endExclusive,
          )
        : List<double>.generate(
            boundedTrimmed.length,
            (index) => boundedTrimmed.length <= 1
                ? 0
                : index / (boundedTrimmed.length - 1),
            growable: false,
          );
    final directions = boundedTrimmed
        .map((point) => point.windDirectionDeg)
        .toList(growable: false);
    final directionKinds = boundedTrimmed
        .map((point) => point.directionKind)
        .toList(growable: false);
    final overlayMarkers = const <_ChartArrowMarker>[];
    final timeGuides = intraday && intradayBounds != null
        ? _gridTimeGuides(
            startInclusive: intradayBounds.startInclusive,
            endExclusive: intradayBounds.endExclusive,
            gridStep: gridDuration,
          )
        : const <_ChartTimeGuide>[];
    final dayStartIndexes = <int>[];
    final dayStartLabels = <String>[];
    final diagnosticLabel = null;
    final forecast = _forecastSeriesForHistoricalPoints(
      boundedTrimmed,
      bucketDuration: arrowDuration,
    );
    DateTime? previous;
    for (var i = 0; i < boundedTrimmed.length; i++) {
      final current = boundedTrimmed[i].time;
      final isNewDay =
          previous == null ||
          previous.year != current.year ||
          previous.month != current.month ||
          previous.day != current.day;
      if (isNewDay) {
        dayStartIndexes.add(i);
        dayStartLabels.add(
          '${current.day.toString().padLeft(2, '0')}/${current.month.toString().padLeft(2, '0')}',
        );
      }
      previous = current;
    }
    return (
      points: points,
      gust: gust.any((value) => value != null) ? gust : null,
      labels: labels,
      xFractions: xFractions,
      directions: directions,
      directionKinds: directionKinds,
      overlayMarkers: overlayMarkers,
      timeGuides: timeGuides,
      dayStartIndexes: dayStartIndexes,
      dayStartLabels: dayStartLabels,
      forecast: forecast,
      intraday: intraday,
      intervalLabel: intraday
          ? usesRawCollectedHistory
                ? 'muestras reales'
                : _historicalBucketOptionLabel(selectedBucketOption!)
          : '1 d',
      diagnosticLabel: diagnosticLabel,
    );
  }

  ({
    List<_HistoricalWindPoint> realHistory,
    bool intraday,
    bool usesRawCollectedHistory,
    _HistoricalBucketOption? selectedBucketOption,
    Duration gridDuration,
    Duration arrowDuration,
    ({DateTime startInclusive, DateTime endExclusive})? intradayBounds,
    List<_HistoricalWindPoint> points,
  })
  _prepareHistorySeriesWindow() {
    final realHistory = _selectedHistoricalWindPoints();
    final intraday = _isIntradayHistoricalSeries(realHistory);
    final usesRawCollectedHistory =
        _usesRawCollectedHistoryForSelectedStation();
    final selectedBucketOption = intraday && !usesRawCollectedHistory
        ? _selectedBucketOption(_historyRange)
        : null;
    final gridDuration = intraday && !usesRawCollectedHistory
        ? _gridDurationForHistorySelection(_historyRange, selectedBucketOption!)
        : intraday
        ? const Duration(minutes: 10)
        : const Duration(days: 1);
    final arrowDuration = intraday && !usesRawCollectedHistory
        ? _arrowDurationForHistorySelection(
            _historyRange,
            selectedBucketOption!,
          )
        : intraday
        ? const Duration(minutes: 5)
        : const Duration(days: 1);
    final alignmentDuration =
        intraday && arrowDuration.inMinutes < gridDuration.inMinutes
        ? arrowDuration
        : gridDuration;
    final intradayBounds = intraday
        ? usesRawCollectedHistory
              ? (
                  startInclusive: realHistory.last.time.subtract(
                    _durationForRange(_historyRange),
                  ),
                  endExclusive: realHistory.last.time,
                )
              : _alignedIntradayWindowBounds(realHistory, alignmentDuration)
        : null;
    final windowed = usesRawCollectedHistory
        ? _windowHistoricalPoints(realHistory)
        : _windowHistoricalPoints(
            realHistory,
            intradayBucket: intraday ? alignmentDuration : null,
          );
    final displayPoints = intraday && !usesRawCollectedHistory
        ? _bucketHistoricalPoints(
            windowed,
            bucket: arrowDuration,
            representativeWhenMultiple: false,
          )
        : windowed;
    final boundedTrimmed = intraday && !usesRawCollectedHistory
        ? displayPoints.length >
                  _maxBucketCountForHistorySelection(
                    _historyRange,
                    arrowDuration,
                  )
              ? displayPoints.sublist(
                  displayPoints.length -
                      _maxBucketCountForHistorySelection(
                        _historyRange,
                        arrowDuration,
                      ),
                )
              : displayPoints
        : displayPoints;
    return (
      realHistory: realHistory,
      intraday: intraday,
      usesRawCollectedHistory: usesRawCollectedHistory,
      selectedBucketOption: selectedBucketOption,
      gridDuration: gridDuration,
      arrowDuration: arrowDuration,
      intradayBounds: intradayBounds,
      points: boundedTrimmed,
    );
  }
}
