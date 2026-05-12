part of '../../spot_detail_page.dart';

extension _SpotDetailLiveHistoryForecastOverlay on _SpotDetailPageState {
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
