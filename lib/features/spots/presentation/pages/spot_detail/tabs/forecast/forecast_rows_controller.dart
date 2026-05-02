part of '../../spot_detail_page.dart';

extension _SpotDetailForecastRowsController on _SpotDetailPageState {
  List<_ForecastRow> _mapForecastEntriesToRows(
    List<_SpotForecastEntry> entries,
  ) {
    return entries
        .map(
          (entry) => _ForecastRow(
            slotTime: entry.time,
            hour: _formatForecastSlot(entry.time),
            windKnots: entry.windKnots,
            gustKnots: entry.gustKnots,
            windDeg: entry.windDeg,
            tempC: entry.airTempC,
            waterTempC: entry.waterTempC,
            pressureHpa: entry.pressureHpa,
            cloudCoverPct: entry.cloudCoverPct,
            waveM: entry.waveM == null
                ? null
                : double.parse(entry.waveM!.toStringAsFixed(1)),
            wavePeriodSeconds: entry.wavePeriodSeconds == null
                ? null
                : double.parse(entry.wavePeriodSeconds!.toStringAsFixed(1)),
            waveDirDeg: entry.waveDirDeg,
            currentMps: entry.currentMps == null
                ? null
                : double.parse(entry.currentMps!.toStringAsFixed(2)),
            currentDirDeg: entry.currentDirDeg,
            salinityPsu: entry.salinityPsu == null
                ? null
                : double.parse(entry.salinityPsu!.toStringAsFixed(1)),
            rainMm: entry.rainMm == null
                ? null
                : double.parse(entry.rainMm!.toStringAsFixed(1)),
          ),
        )
        .toList(growable: false);
  }

  List<_ForecastRow> _rowsForProvider(String provider) {
    switch (provider) {
      case 'AEMET':
        return _generateForecastRows(
          days: 3,
          baseWindKnots: 14,
          baseWindDeg: 74,
          baseAirTempC: 22,
          baseWaterTempC: 18,
          basePressureHpa: 1016,
          baseWaveM: 0.9,
          providerBias: 0,
        );
      case 'Meteoblue':
        return _generateForecastRows(
          days: 7,
          baseWindKnots: 15,
          baseWindDeg: 82,
          baseAirTempC: 21,
          baseWaterTempC: 18,
          basePressureHpa: 1015,
          baseWaveM: 0.9,
          providerBias: 1,
        );
      case 'Meteosource':
        return _generateForecastRows(
          days: 1,
          baseWindKnots: 14,
          baseWindDeg: 88,
          baseAirTempC: 21,
          baseWaterTempC: 18,
          basePressureHpa: 1014,
          baseWaveM: 0.8,
          providerBias: 1,
        );
      case 'Meteostat':
        return _generateForecastRows(
          days: 7,
          baseWindKnots: 13,
          baseWindDeg: 86,
          baseAirTempC: 20,
          baseWaterTempC: 18,
          basePressureHpa: 1015,
          baseWaveM: 0.8,
          providerBias: 0,
        );
      default:
        return _generateForecastRows(
          days: 15,
          baseWindKnots: 13,
          baseWindDeg: 78,
          baseAirTempC: 21,
          baseWaterTempC: 18,
          basePressureHpa: 1017,
          baseWaveM: 0.8,
          providerBias: -1,
        );
    }
  }

  List<_ForecastRow> _generateForecastRows({
    required int days,
    required int baseWindKnots,
    required int baseWindDeg,
    required int baseAirTempC,
    required int baseWaterTempC,
    required int basePressureHpa,
    required double baseWaveM,
    required int providerBias,
  }) {
    final rows = <_ForecastRow>[];
    final now = DateTime.now();
    final startHour = ((now.hour ~/ 3) * 3) + 3;
    final start = DateTime(now.year, now.month, now.day, startHour);
    final totalSlots = (days * 8) + 1;

    for (var i = 0; i < totalSlots; i++) {
      final slot = start.add(Duration(hours: i * 3));
      final dayPhase = math.sin(((slot.hour - 8) / 24) * math.pi * 2);
      final synopticPhase = math.sin(i / 3.2);
      final windKnots = math.max(
        6,
        baseWindKnots +
            providerBias +
            (dayPhase * 4).round() +
            (synopticPhase * 2).round(),
      );
      final gustKnots = windKnots + 5 + (math.cos(i / 2.4) * 2).round();
      final windDeg = _normalizeDegrees(
        baseWindDeg + (math.sin(i / 4) * 18).roundToDouble(),
      ).round();
      final tempC = baseAirTempC + (dayPhase * 3).round() + (i ~/ 16);
      final waterTempC = baseWaterTempC + (i ~/ 24);
      final pressureHpa =
          basePressureHpa + (math.cos(i / 5) * 3).round() - (i ~/ 20);
      final cloudCoverPct = (28 + (math.sin(i / 2.1) * 24) + (i % 5) * 6)
          .round()
          .clamp(4, 100);
      final waveM = (baseWaveM + (windKnots / 25) + (math.cos(i / 3.4) * 0.18))
          .clamp(0.4, 2.8);
      final rainMm = cloudCoverPct > 72 && i % 4 == 1
          ? ((cloudCoverPct - 68) / 20).clamp(0.1, 2.2)
          : 0.0;

      rows.add(
        _ForecastRow(
          slotTime: slot,
          hour: _formatForecastSlot(slot),
          windKnots: windKnots,
          gustKnots: gustKnots,
          windDeg: windDeg,
          tempC: tempC,
          waterTempC: waterTempC,
          pressureHpa: pressureHpa,
          cloudCoverPct: cloudCoverPct,
          waveM: double.parse(waveM.toStringAsFixed(1)),
          rainMm: double.parse(rainMm.toStringAsFixed(1)),
        ),
      );
    }

    return rows;
  }

  String _formatForecastSlot(DateTime value, {int stepMinutes = 180}) {
    const weekdays = ['Lun', 'Mar', 'Mie', 'Jue', 'Vie', 'Sab', 'Dom'];
    final weekday = weekdays[value.weekday - 1];
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final timeLabel = stepMinutes >= 60 ? '$hour h' : '$hour:$minute';
    return '$weekday\n$timeLabel';
  }

  List<_ForecastResolution> _allowedForecastResolutions(_ForecastRange range) {
    if (_forecastProvider == 'Meteoblue') {
      switch (range) {
        case _ForecastRange.d15:
          return const [_ForecastResolution.h1];
        case _ForecastRange.d7:
          return const [_ForecastResolution.h1];
        case _ForecastRange.d3:
          return const [_ForecastResolution.h1, _ForecastResolution.m15];
        case _ForecastRange.d1:
          return const [_ForecastResolution.h1, _ForecastResolution.m15];
      }
    }

    if (_forecastProvider == 'Meteosource') {
      return const [_ForecastResolution.h1];
    }

    if (_forecastProvider == 'Meteostat') {
      return const [_ForecastResolution.h1];
    }

    if (_usesAemetPortusForecastModel()) {
      return const [_ForecastResolution.h1, _ForecastResolution.h3];
    }

    switch (range) {
      case _ForecastRange.d15:
        return const [_ForecastResolution.h6];
      case _ForecastRange.d7:
        return const [_ForecastResolution.h6, _ForecastResolution.h3];
      case _ForecastRange.d3:
        return const [_ForecastResolution.h3, _ForecastResolution.h1];
      case _ForecastRange.d1:
        return const [
          _ForecastResolution.h3,
          _ForecastResolution.h1,
          _ForecastResolution.m20,
        ];
    }
  }

  _ForecastResolution _preferredForecastResolution(_ForecastRange range) {
    if (_forecastProvider == 'Meteoblue') {
      switch (range) {
        case _ForecastRange.d15:
        case _ForecastRange.d7:
          return _ForecastResolution.h1;
        case _ForecastRange.d3:
        case _ForecastRange.d1:
          return _ForecastResolution.m15;
      }
    }

    if (_forecastProvider == 'Meteosource') {
      return _ForecastResolution.h1;
    }

    if (_forecastProvider == 'Meteostat') {
      return _ForecastResolution.h1;
    }

    if (_usesAemetPortusForecastModel()) {
      return _ForecastResolution.h1;
    }

    switch (range) {
      case _ForecastRange.d15:
        return _ForecastResolution.h6;
      case _ForecastRange.d7:
        return _ForecastResolution.h3;
      case _ForecastRange.d3:
        return _ForecastResolution.h3;
      case _ForecastRange.d1:
        return _ForecastResolution.h3;
    }
  }

  double _lerpAngle(double startDeg, double endDeg, double t) {
    final diff = (((endDeg - startDeg) + 540) % 360) - 180;
    return _normalizeDegrees(startDeg + diff * t);
  }

  List<_ForecastRow> _resampleForecastRows(
    List<_ForecastRow> baseRows,
    _ForecastResolution resolution,
  ) {
    if (_forecastProvider == 'Meteoblue') {
      return _selectNativeMeteoblueRows(baseRows, resolution);
    }

    if (resolution == _ForecastResolution.h6) {
      final rows = <_ForecastRow>[];
      for (var i = 0; i < baseRows.length; i += 2) {
        final row = baseRows[i];
        rows.add(_copyForecastRowWithSlotLabel(row, stepMinutes: 360));
      }
      return rows;
    }

    if (resolution == _ForecastResolution.h3) {
      return _selectRowsAtNativeResolution(baseRows, resolution);
    }

    if (baseRows.length < 2) {
      return baseRows;
    }

    final rows = <_ForecastRow>[];
    final stepMinutes = resolution.minutes;

    for (var i = 0; i < baseRows.length - 1; i++) {
      final current = baseRows[i];
      final next = baseRows[i + 1];
      final totalMinutes = next.slotTime.difference(current.slotTime).inMinutes;
      final steps = totalMinutes ~/ stepMinutes;

      for (var step = 0; step < steps; step++) {
        final t = step / steps;
        final slotTime = current.slotTime.add(
          Duration(minutes: step * stepMinutes),
        );
        rows.add(
          _ForecastRow(
            slotTime: slotTime,
            hour: _formatForecastSlot(slotTime, stepMinutes: stepMinutes),
            windKnots:
                (current.windKnots + (next.windKnots - current.windKnots) * t)
                    .round(),
            gustKnots: _lerpNullableInt(current.gustKnots, next.gustKnots, t),
            windDeg: _lerpAngle(
              current.windDeg.toDouble(),
              next.windDeg.toDouble(),
              t,
            ).round(),
            tempC: _lerpNullableInt(current.tempC, next.tempC, t),
            waterTempC: _lerpNullableInt(
              current.waterTempC,
              next.waterTempC,
              t,
            ),
            pressureHpa: _lerpNullableInt(
              current.pressureHpa,
              next.pressureHpa,
              t,
            ),
            cloudCoverPct: _lerpNullableInt(
              current.cloudCoverPct,
              next.cloudCoverPct,
              t,
            ),
            waveM: _lerpNullableDouble(current.waveM, next.waveM, t),
            wavePeriodSeconds: _lerpNullableDouble(
              current.wavePeriodSeconds,
              next.wavePeriodSeconds,
              t,
            ),
            waveDirDeg: _lerpNullableAngle(
              current.waveDirDeg,
              next.waveDirDeg,
              t,
            ),
            currentMps: _lerpNullableDouble(
              current.currentMps,
              next.currentMps,
              t,
            ),
            currentDirDeg: _lerpNullableAngle(
              current.currentDirDeg,
              next.currentDirDeg,
              t,
            ),
            salinityPsu: _lerpNullableDouble(
              current.salinityPsu,
              next.salinityPsu,
              t,
            ),
            rainMm: _lerpNullableDouble(current.rainMm, next.rainMm, t),
          ),
        );
      }
    }

    final last = baseRows.last;
    rows.add(_copyForecastRowWithSlotLabel(last, stepMinutes: stepMinutes));

    return rows;
  }

  List<_ForecastRow> _selectNativeMeteoblueRows(
    List<_ForecastRow> baseRows,
    _ForecastResolution resolution,
  ) {
    final nativeRows = baseRows
        .map(
          (row) => _copyForecastRowWithSlotLabel(
            row,
            stepMinutes: resolution.minutes,
          ),
        )
        .toList(growable: false);

    if (resolution == _ForecastResolution.m15) {
      return nativeRows;
    }
    if (resolution == _ForecastResolution.h1) {
      return nativeRows.where((row) => row.slotTime.minute == 0).toList();
    }
    return nativeRows;
  }

  List<_ForecastRow> _selectRowsAtNativeResolution(
    List<_ForecastRow> baseRows,
    _ForecastResolution resolution,
  ) {
    if (baseRows.isEmpty) {
      return const <_ForecastRow>[];
    }
    final start = baseRows.first.slotTime;
    return baseRows
        .where((row) {
          final diffMinutes = row.slotTime.difference(start).inMinutes;
          return diffMinutes % resolution.minutes == 0;
        })
        .map(
          (row) => _copyForecastRowWithSlotLabel(
            row,
            stepMinutes: resolution.minutes,
          ),
        )
        .toList(growable: false);
  }

  _ForecastRow _copyForecastRowWithSlotLabel(
    _ForecastRow row, {
    required int stepMinutes,
  }) {
    return _ForecastRow(
      slotTime: row.slotTime,
      hour: _formatForecastSlot(row.slotTime, stepMinutes: stepMinutes),
      windKnots: row.windKnots,
      gustKnots: row.gustKnots,
      windDeg: row.windDeg,
      tempC: row.tempC,
      waterTempC: row.waterTempC,
      pressureHpa: row.pressureHpa,
      cloudCoverPct: row.cloudCoverPct,
      waveM: row.waveM,
      wavePeriodSeconds: row.wavePeriodSeconds,
      waveDirDeg: row.waveDirDeg,
      currentMps: row.currentMps,
      currentDirDeg: row.currentDirDeg,
      salinityPsu: row.salinityPsu,
      rainMm: row.rainMm,
    );
  }

  int? _lerpNullableInt(int? current, int? next, double t) {
    if (current == null || next == null) {
      return null;
    }
    return (current + (next - current) * t).round();
  }

  double? _lerpNullableDouble(double? current, double? next, double t) {
    if (current == null || next == null) {
      return null;
    }
    return double.parse((current + (next - current) * t).toStringAsFixed(1));
  }

  int? _lerpNullableAngle(int? current, int? next, double t) {
    if (current == null || next == null) {
      return null;
    }
    return _lerpAngle(current.toDouble(), next.toDouble(), t).round();
  }

  String _nullableMetricText(String? value) {
    return value == null || value.isEmpty ? '-' : value;
  }

  List<_ForecastRow> _rowsForSelectedForecastRange(String provider) {
    return _rowsForForecastRange(provider, _forecastRange);
  }

  List<_ForecastRow> _rowsForForecastRange(
    String provider,
    _ForecastRange range,
  ) {
    final rows = _rowsForProvider(provider);
    return _clipForecastRows(rows, provider: provider, range: range);
  }

  List<_ForecastRow> _clipForecastRows(
    List<_ForecastRow> rows, {
    required String provider,
    required _ForecastRange range,
  }) {
    if (rows.isEmpty) {
      return const <_ForecastRow>[];
    }

    final end = rows.first.slotTime.add(Duration(days: range.days));
    return rows.where((row) => row.slotTime.isBefore(end)).toList();
  }

  List<_ForecastRange> _availableForecastRanges(String provider) {
    if (provider == 'AEMET' && _usesAemetPortusForecastModel()) {
      final rows = _rowsForProvider(provider);
      if (rows.isEmpty) {
        return const [_ForecastRange.d1];
      }
      final totalHours =
          rows.last.slotTime.difference(rows.first.slotTime).inHours + 1;
      return const [
        _ForecastRange.d1,
        _ForecastRange.d3,
      ].where((range) => totalHours >= range.days * 24).toList();
    }

    if (provider == 'Meteoblue' || provider == 'Meteostat') {
      final rows = _rowsForProvider(provider);
      if (rows.isEmpty) {
        return const [_ForecastRange.d1];
      }
      final totalHours =
          rows.last.slotTime.difference(rows.first.slotTime).inHours + 1;
      return _ForecastRange.values
          .where((range) => totalHours >= range.days * 24)
          .toList();
    }
    if (provider == 'Meteosource') {
      return const [_ForecastRange.d1];
    }
    if (provider == 'Windguru') {
      return const [_ForecastRange.d1];
    }
    final availableDays = (_rowsForProvider(provider).length / 8).floor();
    return _ForecastRange.values
        .where((range) => range.days <= availableDays)
        .toList();
  }

  void _syncForecastRangeWithProvider() {
    final ranges = _availableForecastRanges(_forecastProvider);
    if (!ranges.contains(_forecastRange) && ranges.isNotEmpty) {
      _forecastRange = ranges.last;
    }
    _syncForecastResolutionWithRange();
  }

  void _syncForecastResolutionWithRange() {
    final allowed = _allowedForecastResolutions(_forecastRange);
    if (!allowed.contains(_forecastResolution)) {
      _forecastResolution = _preferredForecastResolution(_forecastRange);
    }
  }

  _ForecastResolution _effectiveForecastResolution(
    _ForecastRange range,
    _ForecastResolution requested,
  ) {
    final allowed = _allowedForecastResolutions(range);
    if (allowed.contains(requested)) {
      return requested;
    }
    return _preferredForecastResolution(range);
  }

  double _forecastColumnWidth(_ForecastResolution? resolution) {
    switch (resolution) {
      case _ForecastResolution.h6:
        return 86;
      case _ForecastResolution.h1:
        return 72;
      case _ForecastResolution.m15:
        return 74;
      case _ForecastResolution.m20:
        return 64;
      case _ForecastResolution.h3:
      case null:
        return 76;
    }
  }
}
