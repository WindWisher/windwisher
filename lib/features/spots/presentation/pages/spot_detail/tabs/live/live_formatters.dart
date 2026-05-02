part of '../../spot_detail_page.dart';

extension _SpotDetailLiveFormatters on _SpotDetailPageState {
  String _formatObservedAt(DateTime value) {
    String two(int input) => input.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)} ${two(value.hour)}:${two(value.minute)}';
  }

  String _formatWind(double? knots) {
    if (knots == null) {
      return '-';
    }
    switch (_windSpeedUnit) {
      case _WindSpeedUnit.knots:
        return '${knots.round()} kt';
      case _WindSpeedUnit.kmh:
        return '${(knots * 1.852).toStringAsFixed(1)} km/h';
      case _WindSpeedUnit.mph:
        return '${(knots * 1.15078).toStringAsFixed(1)} mph';
      case _WindSpeedUnit.beaufort:
        return 'FUERZA ${_beaufortFromKnots(knots.round())}';
    }
  }

  String _formatWindRoseValue(double? knots) {
    return _formatWind(knots);
  }

  String _formatWindUnitValue(double knots) {
    switch (_windSpeedUnit) {
      case _WindSpeedUnit.knots:
        return knots.round().toString();
      case _WindSpeedUnit.kmh:
        return (knots * 1.852).round().toString();
      case _WindSpeedUnit.mph:
        return (knots * 1.15078).round().toString();
      case _WindSpeedUnit.beaufort:
        return _beaufortFromKnots(knots.round()).toString();
    }
  }

  String _windUnitSuffix() {
    switch (_windSpeedUnit) {
      case _WindSpeedUnit.knots:
        return 'kt';
      case _WindSpeedUnit.kmh:
        return 'km/h';
      case _WindSpeedUnit.mph:
        return 'mph';
      case _WindSpeedUnit.beaufort:
        return '';
    }
  }

  String _formatWindRangeLabel({
    int? lowerInclusiveKnots,
    int? upperInclusiveKnots,
    int? upperExclusiveKnots,
    int? lowerExclusiveKnots,
  }) {
    if (_windSpeedUnit == _WindSpeedUnit.beaufort) {
      if (upperExclusiveKnots != null) {
        return '< FUERZA ${_beaufortFromKnots(upperExclusiveKnots)}';
      }
      if (lowerExclusiveKnots != null) {
        return '> FUERZA ${_beaufortFromKnots(lowerExclusiveKnots)}';
      }
      if (lowerInclusiveKnots != null && upperInclusiveKnots != null) {
        return 'FUERZA ${_beaufortFromKnots(lowerInclusiveKnots)}-${_beaufortFromKnots(upperInclusiveKnots)}';
      }
    }
    final suffix = _windUnitSuffix();
    if (upperExclusiveKnots != null) {
      return '< ${_formatWindUnitValue(upperExclusiveKnots.toDouble())} $suffix';
    }
    if (lowerExclusiveKnots != null) {
      return '> ${_formatWindUnitValue(lowerExclusiveKnots.toDouble())} $suffix';
    }
    if (lowerInclusiveKnots != null && upperInclusiveKnots != null) {
      return '${_formatWindUnitValue(lowerInclusiveKnots.toDouble())}-${_formatWindUnitValue(upperInclusiveKnots.toDouble())} $suffix';
    }
    return '-';
  }

  String _formatOptionalInt(int? value, String suffix) {
    if (value == null) {
      return '-';
    }
    return '$value$suffix';
  }

  String _formatOptionalDouble(double? value, String suffix) {
    if (value == null) {
      return '-';
    }
    return '${value.toStringAsFixed(1)}$suffix';
  }

  Widget _liveMetric(String label, String value) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  Color _windColor(int knots) {
    if (knots < 10) {
      return Colors.transparent;
    }
    return _windSemaforoColor(knots.toDouble());
  }

  Color _rainColor(double mm) {
    if (mm <= 0) {
      return const Color(0xFFE0E0E0);
    }
    if (mm < 0.5) {
      return const Color(0xFFB3E5FC);
    }
    if (mm < 1.5) {
      return const Color(0xFF81D4FA);
    }
    return const Color(0xFF4FC3F7);
  }

  Color _airTempColor(int tempC) {
    if (tempC <= 16) {
      return const Color(0xFFB3E5FC);
    }
    if (tempC <= 20) {
      return const Color(0xFF81D4FA);
    }
    if (tempC <= 24) {
      return const Color(0xFFFFF59D);
    }
    if (tempC <= 28) {
      return const Color(0xFFFFCC80);
    }
    return const Color(0xFFFFAB91);
  }

  Color _waterTempColor(int tempC) {
    if (tempC <= 16) {
      return const Color(0xFF90CAF9);
    }
    if (tempC <= 18) {
      return const Color(0xFF81D4FA);
    }
    if (tempC <= 20) {
      return const Color(0xFF80DEEA);
    }
    if (tempC <= 22) {
      return const Color(0xFFA5D6A7);
    }
    return const Color(0xFFC5E1A5);
  }
}
