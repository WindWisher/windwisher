part of '../../spot_detail_page.dart';

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
    buckets.putIfAbsent(bucketStart, () => <_HistoricalWindPoint>[]).add(point);
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

int _maxBucketCountForHistorySelection(
  _HistoryRange range,
  Duration arrowDuration,
) {
  final totalMinutes = _durationForRange(range).inMinutes;
  final bucketMinutes = math.max(1, arrowDuration.inMinutes);
  return (totalMinutes / bucketMinutes).ceil();
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
