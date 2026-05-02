part of '../../../spot_detail_page.dart';

const double _liveChartLeftPad = 38.0;

Color _windSemaforoColor(double knots) => windSemaforoColor(knots);

int _beaufortFromKnots(int knots) {
  if (knots < 1) return 0;
  if (knots < 4) return 1;
  if (knots < 7) return 2;
  if (knots < 11) return 3;
  if (knots < 17) return 4;
  if (knots < 22) return 5;
  if (knots < 28) return 6;
  if (knots < 34) return 7;
  if (knots < 41) return 8;
  if (knots < 48) return 9;
  if (knots < 56) return 10;
  if (knots < 64) return 11;
  return 12;
}

double _displayWindValue(double knots, _WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
      return knots;
    case _WindSpeedUnit.kmh:
      return knots * 1.852;
    case _WindSpeedUnit.mph:
      return knots * 1.15078;
    case _WindSpeedUnit.beaufort:
      return _beaufortFromKnots(knots.round()).toDouble();
  }
}

double _historicalMinorStep(_WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
      return 2;
    case _WindSpeedUnit.kmh:
      return 4;
    case _WindSpeedUnit.mph:
      return 2;
    case _WindSpeedUnit.beaufort:
      return 1;
  }
}

double _historicalMajorStep(_WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
      return 2;
    case _WindSpeedUnit.kmh:
      return 4;
    case _WindSpeedUnit.mph:
      return 2;
    case _WindSpeedUnit.beaufort:
      return 1;
  }
}

double _historicalMinChartMax(_WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
      return 12;
    case _WindSpeedUnit.kmh:
      return 24;
    case _WindSpeedUnit.mph:
      return 14;
    case _WindSpeedUnit.beaufort:
      return 6;
  }
}

String _formatHistoricalAxisValue(double value, _WindSpeedUnit unit) {
  switch (unit) {
    case _WindSpeedUnit.knots:
    case _WindSpeedUnit.beaufort:
      return value.toStringAsFixed(0);
    case _WindSpeedUnit.kmh:
    case _WindSpeedUnit.mph:
      return value.toStringAsFixed(0);
  }
}

enum _WindSpeedUnit { knots, kmh, mph, beaufort }
