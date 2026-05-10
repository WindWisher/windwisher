// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveHistoryController on _SpotDetailPageState {
  Future<bool> _refreshSelectedStationHistoricalData() async {
    final station = _findStationByKey(_selectedStation);
    final current = _liveStationsLoadResult;
    if (station == null || current == null) {
      return false;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final refreshedHistory = await _fetchHistoricalDataForStation(station);
      debugPrint(
        'LiveStationTiming phase=history elapsedMs=${stopwatch.elapsedMilliseconds} '
        'provider=${station.provider} stationKey=${station.stationKey} '
        'station="${station.name}" success=${refreshedHistory != null} '
        'points=${refreshedHistory?.length ?? 0}',
      );
      if (!mounted || refreshedHistory == null) {
        return false;
      }

      setState(() {
        final latest = _liveStationsLoadResult;
        if (latest == null) {
          return;
        }
        final updatedHistory = Map<String, List<_HistoricalWindPoint>>.from(
          latest.historicalSeriesByStation,
        );
        updatedHistory[station.stationKey] = refreshedHistory;
        _liveStationsLoadResult = _LiveStationsLoadResult(
          stations: latest.stations,
          liveDataByStation: latest.liveDataByStation,
          historicalSeriesByStation: updatedHistory,
          source: latest.source,
          message: latest.message,
          technicalError: latest.technicalError,
        );
      });
      return true;
    } catch (error) {
      debugPrint(
        'LiveStationTiming phase=history elapsedMs=${stopwatch.elapsedMilliseconds} '
        'provider=${station.provider} stationKey=${station.stationKey} '
        'station="${station.name}" error=$error',
      );
      return false;
    }
  }

  Future<void> _loadSelectedStationHistoricalData() async {
    if (_isHistoricalLoading) {
      return;
    }
    setState(() {
      _isHistoricalLoading = true;
    });
    try {
      final historyUpdated = await _refreshSelectedStationHistoricalData();
      if (!historyUpdated && mounted) {
        _showLiveRefreshFeedback(
          'No se pudo cargar el historico de ${_stationDisplayName(_selectedStation)}.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isHistoricalLoading = false;
        });
      }
    }
  }

  Future<List<_HistoricalWindPoint>?> _fetchHistoricalDataForStation(
    _NearbyStation station,
  ) async {
    if (station.provider == 'AVAMET') {
      final stationId = station.stationId;
      if (stationId == null) {
        return null;
      }
      final intradayHistory = await _avametIntradayHistoryClient
          .fetchIntradayWindHistory(stationId: stationId);
      final refreshedHistory = intradayHistory
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);

      if (refreshedHistory.isNotEmpty) {
        return refreshedHistory;
      }

      final dailyHistory = await _avametDailyHistoryClient
          .fetchDailyWindHistory(stationId: stationId);
      return dailyHistory
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
            ),
          )
          .toList(growable: false);
    }

    if (station.provider == 'INFORATGE') {
      final feed = await _inforatgeOlivaNovaClient.fetchFeed(
        stationCode: station.stationId == _inforatgePoliesportiuStationId
            ? '01'
            : '02',
        liveUrl: station.stationId == _inforatgePoliesportiuStationId
            ? InforatgeOlivaNovaClient.livePoliesportiuUrl
            : InforatgeOlivaNovaClient.liveOlivaNovaUrl,
      );
      return feed.points
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    }

    if (station.provider == 'AIGUABLANCA') {
      final feed = await _aiguaBlancaMeteoClient.fetchFeed();
      return feed.points
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              gustKnots: point.gustKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    }

    if (station.provider == 'PUERTOS') {
      final stationId = int.tryParse(station.stationId ?? '');
      if (stationId == null) {
        return null;
      }
      final history = await _portusRealtimeWindClient.fetchWindHistory(
        stationId: stationId,
      );
      return history
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              gustKnots: point.gustKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    }

    if (station.provider == 'AEMET' && station.stationId != null) {
      final observationSeries = await _aemetObservationClient
          .fetchStationObservations(
            stationId: station.stationId!,
            referenceLatitude: station.latitude,
            referenceLongitude: station.longitude,
          );
      return observationSeries
          .where((snapshot) => snapshot.observedAt != null)
          .map(
            (snapshot) => _HistoricalWindPoint(
              time: snapshot.observedAt!,
              windKnots: snapshot.windKnots ?? 0,
              gustKnots: snapshot.gustKnots,
              windDirectionDeg: snapshot.windDirectionDeg,
              directionKind: snapshot.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    }

    return null;
  }

  Future<void> _refreshHistoricalChartData() async {
    if (_isHistoricalRefreshing) {
      return;
    }
    setState(() {
      _isHistoricalRefreshing = true;
    });
    try {
      await _refreshSelectedStationLiveData();
      final historyUpdated = await _refreshSelectedStationHistoricalData();
      _refreshHistoryForecastRows();
      if (!historyUpdated && mounted) {
        _showLiveRefreshFeedback(
          'No se pudo actualizar el historico de ${_stationDisplayName(_selectedStation)}.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isHistoricalRefreshing = false;
        });
      }
    }
  }

  List<_HistoricalWindPoint> _selectedHistoricalWindPoints() {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return const <_HistoricalWindPoint>[];
    }
    return _historicalWindPointsForStation(station);
  }

  List<_HistoricalWindPoint> _historicalWindPointsForStation(
    _NearbyStation station,
  ) {
    return _liveStationsLoadResult?.historicalSeriesByStation[station
            .stationKey] ??
        const <_HistoricalWindPoint>[];
  }

  bool _hasRealHistoricalSeries() => _selectedHistoricalWindPoints().isNotEmpty;

  bool _supportsThreeDayHistoryForSelectedStation() {
    final station = _findStationByKey(_selectedStation);
    if (station == null) {
      return false;
    }
    if (station.provider == 'INFORATGE') {
      return false;
    }
    if (station.provider == 'AIGUABLANCA') {
      return false;
    }
    if (station.provider == 'AEMET' && station.stationId == '8058X') {
      return false;
    }
    return true;
  }

  bool _usesFixedAemetOlivaHistoryWindow() {
    final station = _findStationByKey(_selectedStation);
    return _isOlivaAemetOfficialStation(station);
  }

  String _historicalSeriesDisplayLabel() {
    final station = _findStationByKey(_selectedStation);
    switch (station?.provider) {
      case 'AEMET':
        return 'AEMET';
      case 'AVAMET':
        return 'AVAMET';
      case 'INFORATGE':
        return 'Inforatge';
      default:
        return 'Historico';
    }
  }

  String _historicalCoverageLabel(List<_HistoricalWindPoint> points) {
    if (points.isEmpty) {
      return 'Sin historico disponible';
    }
    if (points.length == 1) {
      return 'Ultima hora disponible';
    }
    Duration smallestStep = points.last.time.difference(points.first.time);
    for (var i = 1; i < points.length; i++) {
      final delta = points[i].time.difference(points[i - 1].time);
      if (delta.inMinutes <= 0) {
        continue;
      }
      if (delta < smallestStep) {
        smallestStep = delta;
      }
    }
    final coveredDuration =
        points.last.time.difference(points.first.time) + smallestStep;
    if (coveredDuration.inHours >= 24) {
      return 'Ultimas 24 h disponibles';
    }
    if (coveredDuration.inHours >= 1) {
      return 'Ultimas ${coveredDuration.inHours} h disponibles';
    }
    return 'Ultimos ${coveredDuration.inMinutes} min disponibles';
  }

  String _historyRangeLabel(_HistoryRange range) {
    switch (range) {
      case _HistoryRange.h1:
        return '1d';
      case _HistoryRange.h3:
        return '3d';
    }
  }

  Duration _durationForRange(_HistoryRange range) {
    switch (range) {
      case _HistoryRange.h1:
        return const Duration(days: 1);
      case _HistoryRange.h3:
        return const Duration(days: 3);
    }
  }

  bool _isIntradayHistoricalSeries(List<_HistoricalWindPoint> points) {
    if (points.length < 2) {
      return false;
    }
    for (var i = 1; i < points.length; i++) {
      final delta = points[i].time.difference(points[i - 1].time);
      if (delta.inHours < 12) {
        return true;
      }
    }
    return false;
  }

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

  String _formatHistoricalLabel(
    _HistoricalWindPoint point, {
    required bool intraday,
  }) {
    String two(int input) => input.toString().padLeft(2, '0');
    if (!intraday) {
      return '${two(point.time.day)}/${two(point.time.month)}';
    }
    return '${two(point.time.hour)}:${two(point.time.minute)}';
  }

  List<_HistoricalBucketOption> _availableBucketOptions(_HistoryRange range) {
    switch (range) {
      case _HistoryRange.h1:
        if (_usesFixedAemetOlivaHistoryWindow()) {
          return const <_HistoricalBucketOption>[
            _HistoricalBucketOption.h1,
            _HistoricalBucketOption.h3,
          ];
        }
        return const <_HistoricalBucketOption>[
          _HistoricalBucketOption.min20,
          _HistoricalBucketOption.h1,
          _HistoricalBucketOption.h3,
        ];
      case _HistoryRange.h3:
        return const <_HistoricalBucketOption>[
          _HistoricalBucketOption.h3,
          _HistoricalBucketOption.h6,
          _HistoricalBucketOption.h12,
        ];
    }
  }

  _HistoricalBucketOption _selectedBucketOption(_HistoryRange range) {
    if (_usesFixedAemetOlivaHistoryWindow()) {
      return _HistoricalBucketOption.h1;
    }
    switch (range) {
      case _HistoryRange.h1:
        return _historyBucket1d;
      case _HistoryRange.h3:
        return _historyBucket3d;
    }
  }

  void _setSelectedBucketOption(_HistoricalBucketOption option) {
    if (_usesFixedAemetOlivaHistoryWindow()) {
      _historyBucket1d = _HistoricalBucketOption.h1;
      return;
    }
    switch (_historyRange) {
      case _HistoryRange.h1:
        _historyBucket1d = option;
      case _HistoryRange.h3:
        _historyBucket3d = option;
    }
  }

  Duration _bucketDurationForOption(_HistoricalBucketOption option) {
    switch (option) {
      case _HistoricalBucketOption.min20:
        return const Duration(minutes: 20);
      case _HistoricalBucketOption.h1:
        return const Duration(hours: 1);
      case _HistoricalBucketOption.h3:
        return const Duration(hours: 3);
      case _HistoricalBucketOption.h6:
        return const Duration(hours: 6);
      case _HistoricalBucketOption.h12:
        return const Duration(hours: 12);
    }
  }

  DateTime _alignBucketStart(DateTime time, Duration bucket) {
    final minutes = bucket.inMinutes;
    final dayStart = DateTime(time.year, time.month, time.day);
    final elapsedMinutes = time.difference(dayStart).inMinutes;
    final bucketIndex = elapsedMinutes ~/ minutes;
    return dayStart.add(Duration(minutes: bucketIndex * minutes));
  }

  List<_HistoricalWindPoint> _bucketHistoricalPoints(
    List<_HistoricalWindPoint> points, {
    required Duration bucket,
    bool representativeWhenMultiple = true,
  }) {
    if (points.isEmpty) {
      return const <_HistoricalWindPoint>[];
    }

    final buckets = <DateTime, List<_HistoricalWindPoint>>{};
    for (final point in points) {
      final bucketStart = _alignBucketStart(point.time, bucket);
      buckets
          .putIfAbsent(bucketStart, () => <_HistoricalWindPoint>[])
          .add(point);
    }

    final entries = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final result = <_HistoricalWindPoint>[];
    for (final entry in entries) {
      final bucketPoints = entry.value;
      final avgWind =
          bucketPoints.fold<double>(0, (acc, point) => acc + point.windKnots) /
          bucketPoints.length;
      final gustValues = bucketPoints
          .map((point) => point.gustKnots)
          .whereType<double>()
          .toList(growable: false);
      _HistoricalWindPoint? directionPoint;
      for (final point in bucketPoints.reversed) {
        if (point.windDirectionDeg != null) {
          directionPoint = point;
          break;
        }
      }
      final lastDirection = directionPoint?.windDirectionDeg;
      final directionKind = lastDirection == null
          ? null
          : (!representativeWhenMultiple || bucketPoints.length == 1)
          ? directionPoint?.directionKind ?? _HistoricalDirectionKind.exact
          : _HistoricalDirectionKind.representative;
      result.add(
        _HistoricalWindPoint(
          time: entry.key,
          windKnots: avgWind,
          gustKnots: gustValues.isEmpty
              ? null
              : gustValues.reduce((a, b) => a > b ? a : b),
          windDirectionDeg: lastDirection,
          directionKind: directionKind,
        ),
      );
    }
    return result;
  }

  String _formatBucketLabel(Duration bucket) {
    if (bucket.inMinutes == 20) {
      return '20 min';
    }
    if (bucket.inHours == 1) {
      return '1 h';
    }
    return '${bucket.inHours} h';
  }

  String _historicalBucketOptionLabel(_HistoricalBucketOption option) {
    return _formatBucketLabel(_bucketDurationForOption(option));
  }

  void _scheduleHistoryChartFocus({
    required ScrollController controller,
    required bool fullscreen,
    required double chartWidth,
    required double viewportWidth,
    required List<double> xFractions,
  }) {
    final lastFraction = xFractions.isEmpty ? 1.0 : xFractions.last;
    final focusKey =
        '${chartWidth.toStringAsFixed(1)}|${viewportWidth.toStringAsFixed(1)}|${lastFraction.toStringAsFixed(4)}|$fullscreen';
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

  Duration _gridDurationForHistorySelection(
    _HistoryRange range,
    _HistoricalBucketOption option,
  ) {
    switch (range) {
      case _HistoryRange.h3:
        switch (option) {
          case _HistoricalBucketOption.h12:
            return const Duration(hours: 12);
          case _HistoricalBucketOption.h6:
            return const Duration(hours: 6);
          case _HistoricalBucketOption.h3:
            return const Duration(hours: 3);
          case _HistoricalBucketOption.min20:
          case _HistoricalBucketOption.h1:
            return const Duration(hours: 3);
        }
      case _HistoryRange.h1:
        switch (option) {
          case _HistoricalBucketOption.h3:
            return const Duration(hours: 3);
          case _HistoricalBucketOption.h1:
            return const Duration(hours: 1);
          case _HistoricalBucketOption.min20:
            return const Duration(minutes: 20);
          case _HistoricalBucketOption.h6:
          case _HistoricalBucketOption.h12:
            return const Duration(hours: 1);
        }
    }
  }

  Duration _arrowDurationForHistorySelection(
    _HistoryRange range,
    _HistoricalBucketOption option,
  ) {
    switch (range) {
      case _HistoryRange.h3:
        switch (option) {
          case _HistoricalBucketOption.h12:
            return const Duration(hours: 6);
          case _HistoricalBucketOption.h6:
            return const Duration(hours: 3);
          case _HistoricalBucketOption.h3:
            return const Duration(hours: 3);
          case _HistoricalBucketOption.min20:
          case _HistoricalBucketOption.h1:
            return const Duration(hours: 1);
        }
      case _HistoryRange.h1:
        switch (option) {
          case _HistoricalBucketOption.h3:
            return const Duration(hours: 1);
          case _HistoricalBucketOption.h1:
            return const Duration(minutes: 30);
          case _HistoricalBucketOption.min20:
            return const Duration(minutes: 5);
          case _HistoricalBucketOption.h6:
          case _HistoricalBucketOption.h12:
            return const Duration(hours: 1);
        }
    }
  }

  int _maxBucketCountForHistorySelection(
    _HistoryRange range,
    Duration arrowDuration,
  ) {
    final totalMinutes = _durationForRange(range).inMinutes;
    final bucketMinutes = math.max(1, arrowDuration.inMinutes);
    return (totalMinutes / bucketMinutes).ceil();
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

  double _timeFraction(
    DateTime time, {
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) {
    final totalMs = endExclusive.difference(startInclusive).inMilliseconds;
    if (totalMs <= 0) {
      return 0;
    }
    final elapsedMs = time.difference(startInclusive).inMilliseconds;
    return (elapsedMs / totalMs).clamp(0.0, 1.0);
  }

  List<double> _timeFractionsForPoints(
    List<_HistoricalWindPoint> points, {
    required DateTime startInclusive,
    required DateTime endExclusive,
  }) {
    return points
        .map(
          (point) => _timeFraction(
            point.time,
            startInclusive: startInclusive,
            endExclusive: endExclusive,
          ),
        )
        .toList(growable: false);
  }

  List<_ChartTimeGuide> _gridTimeGuides({
    required DateTime startInclusive,
    required DateTime endExclusive,
    required Duration gridStep,
  }) {
    final guides = <_ChartTimeGuide>[];
    var cursor = _alignBucketStart(startInclusive, gridStep);
    if (cursor.isBefore(startInclusive)) {
      cursor = cursor.add(gridStep);
    }
    for (; !cursor.isAfter(endExclusive); cursor = cursor.add(gridStep)) {
      final isHour = cursor.minute == 0;
      final isMajor = gridStep.inMinutes >= 60 ? true : isHour;
      final showsEveryTwentyMinutes = gridStep.inMinutes == 20;
      guides.add(
        _ChartTimeGuide(
          xFraction: _timeFraction(
            cursor,
            startInclusive: startInclusive,
            endExclusive: endExclusive,
          ),
          isMajor: isMajor,
          label: showsEveryTwentyMinutes
              ? '${cursor.hour.toString().padLeft(2, '0')}:${cursor.minute.toString().padLeft(2, '0')}'
              : isMajor
              ? '${cursor.hour.toString().padLeft(2, '0')}h'
              : null,
        ),
      );
    }
    return guides;
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
          ? _historicalBucketOptionLabel(selectedBucketOption!)
          : '1 d',
      diagnosticLabel: diagnosticLabel,
    );
  }

  ({
    List<_HistoricalWindPoint> realHistory,
    bool intraday,
    _HistoricalBucketOption? selectedBucketOption,
    Duration gridDuration,
    Duration arrowDuration,
    ({DateTime startInclusive, DateTime endExclusive})? intradayBounds,
    List<_HistoricalWindPoint> points,
  })
  _prepareHistorySeriesWindow() {
    final realHistory = _selectedHistoricalWindPoints();
    final intraday = _isIntradayHistoricalSeries(realHistory);
    final selectedBucketOption = intraday
        ? _selectedBucketOption(_historyRange)
        : null;
    final gridDuration = intraday
        ? _gridDurationForHistorySelection(_historyRange, selectedBucketOption!)
        : const Duration(days: 1);
    final arrowDuration = intraday
        ? _arrowDurationForHistorySelection(
            _historyRange,
            selectedBucketOption!,
          )
        : const Duration(days: 1);
    final alignmentDuration =
        intraday && arrowDuration.inMinutes < gridDuration.inMinutes
        ? arrowDuration
        : gridDuration;
    final intradayBounds = intraday
        ? _alignedIntradayWindowBounds(realHistory, alignmentDuration)
        : null;
    final windowed = _windowHistoricalPoints(
      realHistory,
      intradayBucket: intraday ? alignmentDuration : null,
    );
    final trimmed = intraday
        ? _bucketHistoricalPoints(
            windowed,
            bucket: arrowDuration,
            representativeWhenMultiple: false,
          )
        : windowed;
    final boundedTrimmed = intraday
        ? trimmed.length >
                  _maxBucketCountForHistorySelection(
                    _historyRange,
                    arrowDuration,
                  )
              ? trimmed.sublist(
                  trimmed.length -
                      _maxBucketCountForHistorySelection(
                        _historyRange,
                        arrowDuration,
                      ),
                )
              : trimmed
        : trimmed;
    return (
      realHistory: realHistory,
      intraday: intraday,
      selectedBucketOption: selectedBucketOption,
      gridDuration: gridDuration,
      arrowDuration: arrowDuration,
      intradayBounds: intradayBounds,
      points: boundedTrimmed,
    );
  }

  bool _supportsHistoricalForecastOverlay({
    required String provider,
    required String model,
  }) {
    return _historyForecastModelsForProvider(provider).contains(model);
  }

  List<_ForecastRow> _historicalForecastOverlayRows() {
    final latestResult = _historyForecastRowsResult;
    final selectedProvider = _historyForecastProvider;
    final selectedModel = _historyForecastModel;
    if (latestResult == null ||
        latestResult.source != _ForecastDataSource.live ||
        latestResult.rows.isEmpty ||
        selectedProvider == null ||
        selectedModel == null ||
        !_supportsHistoricalForecastOverlay(
          provider: selectedProvider,
          model: selectedModel,
        )) {
      return const <_ForecastRow>[];
    }
    final rows = List<_ForecastRow>.from(latestResult.rows)
      ..sort((a, b) => a.slotTime.compareTo(b.slotTime));
    return rows;
  }

  List<double?>? _forecastSeriesForHistoricalPoints(
    List<_HistoricalWindPoint> points, {
    required Duration bucketDuration,
  }) {
    if (points.isEmpty) {
      return null;
    }
    if (_usesFixedAemetOlivaHistoryWindow()) {
      return null;
    }
    final rows = _historicalForecastOverlayRows();
    if (rows.isEmpty) {
      return null;
    }
    final values = points
        .map(
          (point) => _forecastWindForTime(
            point.time,
            rows,
            bucketDuration: bucketDuration,
          ),
        )
        .toList(growable: false);
    if (!values.any((value) => value != null)) {
      return null;
    }
    return values;
  }

  _HistoricalForecastAccuracySummary? _historicalForecastAccuracySummary({
    required List<_HistoricalWindPoint> points,
    required Duration bucketDuration,
  }) {
    if (points.isEmpty || _usesFixedAemetOlivaHistoryWindow()) {
      return null;
    }
    final rows = _historicalForecastOverlayRows();
    if (rows.isEmpty) {
      return null;
    }

    var speedMatched = 0;
    var speedComparable = 0;
    var directionMatched = 0;
    var directionComparable = 0;
    var combinedMatched = 0;
    var combinedComparable = 0;
    var absoluteErrorSum = 0.0;

    for (final point in points) {
      final forecastWind = _forecastWindForTime(
        point.time,
        rows,
        bucketDuration: bucketDuration,
      );
      final forecastDirection = _forecastDirectionForTime(
        point.time,
        rows,
        bucketDuration: bucketDuration,
      );

      final hasSpeed = forecastWind != null;
      final hasDirection =
          forecastDirection != null && point.windDirectionDeg != null;

      var speedHit = false;
      var directionHit = false;

      if (hasSpeed) {
        final error = (forecastWind - point.windKnots).abs();
        absoluteErrorSum += error;
        speedComparable += 1;
        speedHit = error <= 2.0;
        if (speedHit) {
          speedMatched += 1;
        }
      }

      if (hasDirection) {
        final error = _angularDifferenceDegrees(
          forecastDirection,
          point.windDirectionDeg!,
        );
        directionComparable += 1;
        directionHit = error <= 30;
        if (directionHit) {
          directionMatched += 1;
        }
      }

      if (hasSpeed && hasDirection) {
        combinedComparable += 1;
        if (speedHit && directionHit) {
          combinedMatched += 1;
        }
      }
    }

    if (speedComparable == 0 && directionComparable == 0) {
      return null;
    }

    return _HistoricalForecastAccuracySummary(
      totalPercentage: (speedComparable + directionComparable) == 0
          ? null
          : (((speedMatched + directionMatched) /
                        (speedComparable + directionComparable)) *
                    100)
                .round(),
      windPercentage: speedComparable == 0
          ? null
          : ((speedMatched / speedComparable) * 100).round(),
      windMatchedPoints: speedMatched,
      windComparablePoints: speedComparable,
      directionPercentage: directionComparable == 0
          ? null
          : ((directionMatched / directionComparable) * 100).round(),
      directionMatchedPoints: directionMatched,
      directionComparablePoints: directionComparable,
      combinedPercentage: combinedComparable == 0
          ? null
          : ((combinedMatched / combinedComparable) * 100).round(),
      combinedMatchedPoints: combinedMatched,
      combinedComparablePoints: combinedComparable,
      meanAbsoluteErrorKnots: speedComparable == 0
          ? null
          : absoluteErrorSum / speedComparable,
    );
  }

  double? _forecastWindForTime(
    DateTime target,
    List<_ForecastRow> rows, {
    required Duration bucketDuration,
  }) {
    if (rows.isEmpty) {
      return null;
    }
    final edgeTolerance = Duration(
      minutes: math.max(bucketDuration.inMinutes, 60),
    );
    if (rows.length == 1) {
      final diff = rows.first.slotTime.difference(target).abs();
      return diff <= edgeTolerance ? rows.first.windKnots.toDouble() : null;
    }

    if (target.isBefore(rows.first.slotTime)) {
      final diff = rows.first.slotTime.difference(target);
      return diff <= edgeTolerance ? rows.first.windKnots.toDouble() : null;
    }

    for (var i = 1; i < rows.length; i++) {
      final previous = rows[i - 1];
      final current = rows[i];
      if (target.isAtSameMomentAs(previous.slotTime)) {
        return previous.windKnots.toDouble();
      }
      if (target.isAtSameMomentAs(current.slotTime)) {
        return current.windKnots.toDouble();
      }
      if (target.isBefore(current.slotTime)) {
        final totalMillis = current.slotTime
            .difference(previous.slotTime)
            .inMilliseconds;
        if (totalMillis <= 0) {
          return current.windKnots.toDouble();
        }
        final elapsedMillis = target
            .difference(previous.slotTime)
            .inMilliseconds;
        final ratio = (elapsedMillis / totalMillis).clamp(0.0, 1.0);
        return previous.windKnots +
            ((current.windKnots - previous.windKnots) * ratio);
      }
    }

    final trailingDiff = target.difference(rows.last.slotTime);
    return trailingDiff <= edgeTolerance
        ? rows.last.windKnots.toDouble()
        : null;
  }

  int? _forecastDirectionForTime(
    DateTime target,
    List<_ForecastRow> rows, {
    required Duration bucketDuration,
  }) {
    if (rows.isEmpty) {
      return null;
    }
    final edgeTolerance = Duration(
      minutes: math.max(bucketDuration.inMinutes, 60),
    );
    _ForecastRow? nearest;
    var nearestDiff = Duration(days: 365);
    for (final row in rows) {
      final diff = row.slotTime.difference(target).abs();
      if (diff < nearestDiff) {
        nearest = row;
        nearestDiff = diff;
      }
    }
    if (nearest == null || nearestDiff > edgeTolerance) {
      return null;
    }
    return nearest.windDeg;
  }

  int _angularDifferenceDegrees(int a, int b) {
    final diff = (a - b).abs() % 360;
    return diff > 180 ? 360 - diff : diff;
  }
}
