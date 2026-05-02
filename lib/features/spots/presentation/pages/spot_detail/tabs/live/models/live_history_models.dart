part of '../../../spot_detail_page.dart';

class _HistoricalWindPoint {
  const _HistoricalWindPoint({
    required this.time,
    required this.windKnots,
    this.gustKnots,
    this.windDirectionDeg,
    this.directionKind,
  });

  final DateTime time;
  final double windKnots;
  final double? gustKnots;
  final int? windDirectionDeg;
  final _HistoricalDirectionKind? directionKind;
}

class _HistoricalForecastAccuracySummary {
  const _HistoricalForecastAccuracySummary({
    required this.totalPercentage,
    required this.windPercentage,
    required this.windMatchedPoints,
    required this.windComparablePoints,
    required this.directionPercentage,
    required this.directionMatchedPoints,
    required this.directionComparablePoints,
    required this.combinedPercentage,
    required this.combinedMatchedPoints,
    required this.combinedComparablePoints,
    required this.meanAbsoluteErrorKnots,
  });

  final int? totalPercentage;
  final int? windPercentage;
  final int windMatchedPoints;
  final int windComparablePoints;
  final int? directionPercentage;
  final int directionMatchedPoints;
  final int directionComparablePoints;
  final int? combinedPercentage;
  final int combinedMatchedPoints;
  final int combinedComparablePoints;
  final double? meanAbsoluteErrorKnots;
}

enum _HistoryRange { h1, h3 }

enum _HistoricalBucketOption { min20, h1, h3, h6, h12 }

enum _HistoricalDirectionKind { exact, representative }

class _ChartArrowMarker {
  const _ChartArrowMarker({
    required this.xFraction,
    required this.windKnots,
    required this.directionDeg,
    required this.kind,
  });

  final double xFraction;
  final double windKnots;
  final int directionDeg;
  final _HistoricalDirectionKind kind;
}

class _ChartTimeGuide {
  const _ChartTimeGuide({
    required this.xFraction,
    required this.isMajor,
    this.label,
  });

  final double xFraction;
  final bool isMajor;
  final String? label;
}
