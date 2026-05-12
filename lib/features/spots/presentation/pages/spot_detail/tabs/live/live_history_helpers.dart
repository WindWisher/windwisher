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
