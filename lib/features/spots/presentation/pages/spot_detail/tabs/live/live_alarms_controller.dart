// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveAlarmsController on _SpotDetailPageState {
  String _currentSpotAlarmKey() => '${widget.name}::${widget.area}';

  List<SpotAlarmRecord> _savedAlarmsForCurrentSpot() {
    return SpotAlarmCatalog.instance.alarmsForSpot(_currentSpotAlarmKey());
  }

  Future<void> _hydrateAlarmCatalog() async {
    await SpotAlarmCatalog.instance.hydrateFromRemote();
    if (!mounted) {
      return;
    }
    setState(() {
      _syncAlarmMonitoring();
    });
  }

  void _syncAlarmMonitoring() {
    final savedAlarms = _savedAlarmsForCurrentSpot();
    final hasSavedAlarms = savedAlarms.isNotEmpty;
    final catalog = SpotAlarmCatalog.instance;
    final shouldMonitor =
        _isAppResumed &&
        hasSavedAlarms &&
        catalog.globalEnabled &&
        catalog.isSpotEnabled(_currentSpotAlarmKey());
    if (!shouldMonitor) {
      _alarmAutoRefreshTimer?.cancel();
      _alarmAutoRefreshTimer = null;
      return;
    }
    final monitoringInterval = _alarmMonitoringInterval(savedAlarms);
    _alarmAutoRefreshTimer?.cancel();
    _alarmAutoRefreshTimer = Timer.periodic(monitoringInterval, (_) {
      if (!mounted || !_isAppResumed) {
        return;
      }
      unawaited(_loadLiveStations());
    });
  }

  Duration _alarmMonitoringInterval(List<SpotAlarmRecord> alarms) {
    if (alarms.any((alarm) => alarm.repeatWindow == AlarmRepeatWindow.min1)) {
      return const Duration(minutes: 1);
    }
    return const Duration(minutes: 5);
  }

  Future<void> _refreshAlarmStationsLiveData(
    List<SpotAlarmRecord> alarms,
  ) async {
    final stationKeys = alarms.map((alarm) => alarm.stationKey).toSet();
    if (stationKeys.isEmpty) {
      return;
    }
    final current = _liveStationsLoadResult;
    if (current == null) {
      return;
    }
    final updatedLiveData = Map<String, _StationLiveData>.from(
      current.liveDataByStation,
    );
    var changed = false;
    for (final stationKey in stationKeys) {
      if (stationKey == _selectedStation) {
        continue;
      }
      final station = _findStationByKey(stationKey);
      if (station == null) {
        continue;
      }
      try {
        final refreshed = await _fetchLiveDataForStation(station);
        if (refreshed == null) {
          continue;
        }
        updatedLiveData[stationKey] = refreshed;
        changed = true;
      } catch (_) {
        continue;
      }
    }
    if (!mounted || !changed) {
      return;
    }
    setState(() {
      final currentResult = _liveStationsLoadResult;
      if (currentResult == null) {
        return;
      }
      _liveStationsLoadResult = _LiveStationsLoadResult(
        stations: currentResult.stations,
        liveDataByStation: updatedLiveData,
        historicalSeriesByStation: currentResult.historicalSeriesByStation,
        source: currentResult.source,
        message: currentResult.message,
        technicalError: currentResult.technicalError,
      );
    });
  }

  Future<void> _processLocalAlarmNotifications(
    List<SpotAlarmRecord> alarms,
  ) async {
    if (alarms.isEmpty) {
      return;
    }
    final catalog = SpotAlarmCatalog.instance;
    for (final alarm in alarms) {
      final evaluation = _evaluateAlarm(alarm);
      if (evaluation.state == _AlarmEvaluationState.active) {
        if (alarm.triggerCount >= alarm.maxRepeats) {
          continue;
        }
        await LocalNotificationsService.instance.showSpotAlarm(
          alarmId: alarm.id,
          title: 'Alarma activa en ${alarm.spotName}',
          body: _localAlarmNotificationBody(alarm),
          repeatWindow: alarm.repeatWindow,
          maxRepeats: alarm.maxRepeats,
        );
        catalog.updateTriggerState(
          alarmId: alarm.id,
          triggerCount: alarm.maxRepeats,
          lastTriggeredAt: DateTime.now(),
        );
        continue;
      }

      final shouldReset =
          evaluation.state == _AlarmEvaluationState.idle ||
          evaluation.state == _AlarmEvaluationState.partial ||
          evaluation.state == _AlarmEvaluationState.disabled;
      if (!shouldReset ||
          (alarm.triggerCount == 0 && alarm.lastTriggeredAt == null)) {
        continue;
      }
      await LocalNotificationsService.instance.cancelAlarmCycle(
        alarmId: alarm.id,
        maxRepeats: alarm.maxRepeats,
      );
      catalog.updateTriggerState(
        alarmId: alarm.id,
        triggerCount: 0,
        clearLastTriggeredAt: true,
      );
    }
  }

  String _localAlarmNotificationBody(SpotAlarmRecord alarm) {
    final liveData = _resolvedLiveDataByStation()[alarm.stationKey];
    final wind = _formatWind(liveData?.windKnots);
    final direction = _directionBucketLabel(liveData?.windDeg) ?? 'sin dir.';
    return '${alarm.stationName}: $wind $direction · objetivo ${_formatAlarmWindRange(alarm.windRange)}';
  }

  String _formatAlarmWindValue(num knots) {
    switch (_windSpeedUnit) {
      case _WindSpeedUnit.knots:
        return '${knots.round()} kt';
      case _WindSpeedUnit.kmh:
        return '${(knots * 1.852).round()} km/h';
      case _WindSpeedUnit.mph:
        return '${(knots * 1.15078).round()} mph';
      case _WindSpeedUnit.beaufort:
        return 'FUERZA ${_beaufortFromKnots(knots.round())}';
    }
  }

  String _formatAlarmWindRange(RangeValues range) {
    if (_windSpeedUnit == _WindSpeedUnit.beaufort) {
      return 'FUERZA ${_beaufortFromKnots(range.start.round())}-${_beaufortFromKnots(range.end.round())}';
    }
    final start = _formatAlarmWindValue(range.start);
    final end = _formatAlarmWindValue(range.end);
    final suffix = _windUnitSuffix();
    final startValue = start.replaceAll(' $suffix', '');
    final endValue = end.replaceAll(' $suffix', '');
    return '$startValue-$endValue $suffix';
  }

  String _alarmRepeatWindowLabel(AlarmRepeatWindow window) {
    switch (window) {
      case AlarmRepeatWindow.min1:
        return '1 min';
      case AlarmRepeatWindow.min5:
        return '5 min';
      case AlarmRepeatWindow.min10:
        return '10 min';
      case AlarmRepeatWindow.min15:
        return '15 min';
      case AlarmRepeatWindow.min30:
        return '30 min';
    }
  }

  String _formatAlarmTime(int hour, int minute) {
    final safeHour = _sanitizeAlarmHour(hour);
    final safeMinute = _sanitizeAlarmMinute(minute);
    return '${safeHour.toString().padLeft(2, '0')}:${safeMinute.toString().padLeft(2, '0')}';
  }

  Future<void> _pickAlarmTime({required bool isStart}) async {
    final initialTime = TimeOfDay(
      hour: _sanitizeAlarmHour(isStart ? _alarmStartHour : _alarmEndHour),
      minute: _sanitizeAlarmMinute(
        isStart ? _alarmStartMinute : _alarmEndMinute,
      ),
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (!mounted || picked == null) {
      return;
    }
    setState(() {
      if (isStart) {
        _alarmStartHour = picked.hour;
        _alarmStartMinute = picked.minute;
      } else {
        _alarmEndHour = picked.hour;
        _alarmEndMinute = picked.minute;
      }
    });
  }

  int _sanitizeAlarmHour(int hour) => hour.clamp(0, 23);

  int _sanitizeAlarmMinute(int minute) => minute.clamp(0, 59);

  bool _isTimeInAlarmRange({
    required int totalMinutes,
    required int startHour,
    required int endHour,
    required int startMinute,
    required int endMinute,
  }) {
    final startTotal = (startHour * 60) + startMinute;
    final endTotal = (endHour * 60) + endMinute;
    if (startTotal == endTotal) {
      return true;
    }
    if (startTotal < endTotal) {
      return totalMinutes >= startTotal && totalMinutes < endTotal;
    }
    return totalMinutes >= startTotal || totalMinutes < endTotal;
  }

  String? _directionBucketLabel(int? directionDeg) {
    if (directionDeg == null) {
      return null;
    }
    final normalized = ((directionDeg % 360) + 360) % 360;
    if (normalized < 23 || normalized >= 338) return 'N';
    if (normalized < 68) return 'NE';
    if (normalized < 113) return 'E';
    if (normalized < 158) return 'SE';
    if (normalized < 203) return 'S';
    if (normalized < 248) return 'SW';
    if (normalized < 293) return 'W';
    return 'NW';
  }

  double _alarmDirectionRotation(String direction) {
    switch (direction) {
      case 'N':
        return 0;
      case 'NE':
        return math.pi / 4;
      case 'E':
        return math.pi / 2;
      case 'SE':
        return (3 * math.pi) / 4;
      case 'S':
        return math.pi;
      case 'SW':
        return (5 * math.pi) / 4;
      case 'W':
        return (3 * math.pi) / 2;
      case 'NW':
        return (7 * math.pi) / 4;
    }
    return 0;
  }

  _AlarmEvaluation _evaluateAlarm(SpotAlarmRecord alarm) {
    final catalog = SpotAlarmCatalog.instance;
    if (!alarm.enabled) {
      return const _AlarmEvaluation(
        state: _AlarmEvaluationState.disabled,
        label: 'Alarma desactivada',
      );
    }
    if (!catalog.globalEnabled) {
      return const _AlarmEvaluation(
        state: _AlarmEvaluationState.disabled,
        label: 'Alarmas globales desactivadas',
      );
    }
    if (!catalog.isSpotEnabled(alarm.spotKey)) {
      return const _AlarmEvaluation(
        state: _AlarmEvaluationState.disabled,
        label: 'Alarmas de este spot desactivadas',
      );
    }

    final liveData = _resolvedLiveDataByStation()[alarm.stationKey];
    final currentWind = liveData?.windKnots?.toDouble();
    final currentDirection = _directionBucketLabel(liveData?.windDeg);
    final observedAt = liveData?.observedAt;

    if (liveData == null || observedAt == null || currentWind == null) {
      return const _AlarmEvaluation(
        state: _AlarmEvaluationState.noData,
        label: 'Sin datos live suficientes',
      );
    }

    final timeMatches = _isTimeInAlarmRange(
      totalMinutes: (observedAt.hour * 60) + observedAt.minute,
      startHour: alarm.startHour,
      endHour: alarm.endHour,
      startMinute: alarm.startMinute,
      endMinute: alarm.endMinute,
    );
    final windMatches =
        currentWind >= alarm.windRange.start &&
        currentWind <= alarm.windRange.end;
    final directionMatches =
        currentDirection != null && alarm.directions.contains(currentDirection);

    if (timeMatches && windMatches && directionMatches) {
      return _AlarmEvaluation(
        state: _AlarmEvaluationState.active,
        label:
            'Lista para disparar · repetir ${_alarmRepeatWindowLabel(alarm.repeatWindow)} · ${alarm.triggerCount}/${alarm.maxRepeats}',
      );
    }

    if (windMatches && (timeMatches || directionMatches)) {
      return _AlarmEvaluation(
        state: _AlarmEvaluationState.partial,
        label:
            'Coincidencia parcial · hora ${timeMatches ? "ok" : "no"} · direccion ${directionMatches ? "ok" : "no"}',
      );
    }

    return _AlarmEvaluation(
      state: _AlarmEvaluationState.idle,
      label:
          'No activa ahora · ${_formatAlarmWindValue(currentWind)} · ${currentDirection ?? "sin direccion"}',
    );
  }

  Color _alarmEvaluationColor(
    BuildContext context,
    _AlarmEvaluation evaluation,
  ) {
    switch (evaluation.state) {
      case _AlarmEvaluationState.active:
        return const Color(0xFF2E7D32);
      case _AlarmEvaluationState.partial:
        return const Color(0xFFEF6C00);
      case _AlarmEvaluationState.idle:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case _AlarmEvaluationState.noData:
        return Theme.of(context).colorScheme.error;
      case _AlarmEvaluationState.disabled:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Future<bool> _confirmDeleteAlarm(SpotAlarmRecord alarm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar alarma'),
          content: Text(
            'Se eliminara la alarma de ${alarm.stationName} para ${widget.name}. Esta accion no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    return confirmed == true;
  }

  String _relativeTimeLabel(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'ahora';
    }
    if (difference.inHours < 1) {
      return 'hace ${difference.inMinutes} min';
    }
    if (difference.inDays < 1) {
      return 'hace ${difference.inHours} h';
    }
    return 'hace ${difference.inDays} d';
  }

  String _alarmTriggerSummary(SpotAlarmRecord alarm) {
    final lastTriggeredAt = alarm.lastTriggeredAt;
    if (lastTriggeredAt == null) {
      return 'Aun no ha disparado';
    }
    return 'Ultimo aviso ${_relativeTimeLabel(lastTriggeredAt)} · ${alarm.triggerCount}/${alarm.maxRepeats}';
  }
}
