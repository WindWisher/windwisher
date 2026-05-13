// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveAlarmsSection on _SpotDetailPageState {
  Widget _buildCustomAlarmsSection() {
    final catalog = SpotAlarmCatalog.instance;
    final spotKey = _currentSpotAlarmKey();
    final alarmStations = _resolvedNearbyStations().map(_stationKey).toList();
    if (!alarmStations.contains(_alarmStation) && alarmStations.isNotEmpty) {
      _alarmStation = alarmStations.first;
    }
    final savedAlarms = _savedAlarmsForCurrentSpot();
    final spotEnabled = catalog.isSpotEnabled(spotKey);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LiveAlarmsHeader(
              enabled: spotEnabled,
              onChanged: (value) => _setSpotAlarmsEnabled(
                catalog: catalog,
                spotKey: spotKey,
                enabled: value,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildAlarmForm(
              catalog: catalog,
              spotKey: spotKey,
              alarmStations: alarmStations,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildSavedAlarmsList(catalog: catalog, savedAlarms: savedAlarms),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmForm({
    required SpotAlarmCatalog catalog,
    required String spotKey,
    required List<String> alarmStations,
  }) {
    return _LiveNewAlarmCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LiveAlarmStationDropdown(
            stationKeys: alarmStations,
            selectedStationKey: _alarmStation,
            stationLabelForKey: _stationLabelForKey,
            onChanged: _setAlarmStation,
          ),
          const SizedBox(height: AppSpacing.sm),
          _LiveAlarmTimeRangeButtons(
            startLabel: _formatAlarmTime(_alarmStartHour, _alarmStartMinute),
            endLabel: _formatAlarmTime(_alarmEndHour, _alarmEndMinute),
            onPickStart: () => _pickAlarmTime(isStart: true),
            onPickEnd: () => _pickAlarmTime(isStart: false),
          ),
          const SizedBox(height: AppSpacing.sm),
          _LiveAlarmWindRangeSelector(
            windRange: _alarmWindRange,
            rangeLabel: _formatAlarmWindRange(_alarmWindRange),
            startLabel: _formatAlarmWindValue(_alarmWindRange.start),
            endLabel: _formatAlarmWindValue(_alarmWindRange.end),
            onChanged: _setAlarmWindRange,
          ),
          const SizedBox(height: AppSpacing.sm),
          _LiveAlarmDirectionSelector(
            options: _SpotDetailPageState._alarmDirectionOptions,
            selectedDirections: _alarmDirections,
            rotationForDirection: _alarmDirectionRotation,
            onSelectAllToggled: _toggleAllAlarmDirections,
            onDirectionToggled: _setAlarmDirection,
          ),
          const SizedBox(height: AppSpacing.sm),
          _LiveAlarmRepeatControls(
            repeatWindow: _alarmRepeatWindow,
            maxRepeats: _alarmMaxRepeats,
            onRepeatWindowChanged: _setAlarmRepeatWindow,
            onMaxRepeatsChanged: _setAlarmMaxRepeats,
          ),
          const SizedBox(height: AppSpacing.sm),
          _LiveAlarmSaveButton(
            isEditing: _editingAlarmId != null,
            onPressed: () =>
                _saveCurrentAlarm(catalog: catalog, spotKey: spotKey),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedAlarmsList({
    required SpotAlarmCatalog catalog,
    required List<SpotAlarmRecord> savedAlarms,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _LiveSavedAlarmsHeader(),
        const SizedBox(height: AppSpacing.sm),
        if (savedAlarms.isEmpty)
          const _LiveSavedAlarmsEmptyState()
        else
          ...List.generate(savedAlarms.length, (index) {
            final alarm = savedAlarms[index];
            return _buildSavedAlarmCard(
              catalog: catalog,
              alarm: alarm,
              isLast: index == savedAlarms.length - 1,
            );
          }),
      ],
    );
  }

  Widget _buildSavedAlarmCard({
    required SpotAlarmCatalog catalog,
    required SpotAlarmRecord alarm,
    required bool isLast,
  }) {
    final evaluation = _evaluateAlarm(alarm);
    final evaluationColor = _alarmEvaluationColor(context, evaluation);
    return _LiveSavedAlarmCard(
      alarm: alarm,
      evaluation: evaluation,
      evaluationColor: evaluationColor,
      triggerSummary: _alarmTriggerSummary(alarm),
      windRangeLabel: _formatAlarmWindRange(alarm.windRange),
      timeRangeLabel:
          '${_formatAlarmTime(alarm.startHour, alarm.startMinute)}-${_formatAlarmTime(alarm.endHour, alarm.endMinute)}',
      repeatWindowLabel: _alarmRepeatWindowLabel(alarm.repeatWindow),
      isLast: isLast,
      onEdit: () {
        _startEditingAlarm(alarm);
      },
      onDelete: () => _deleteSavedAlarm(catalog: catalog, alarm: alarm),
    );
  }

  Future<void> _setSpotAlarmsEnabled({
    required SpotAlarmCatalog catalog,
    required String spotKey,
    required bool enabled,
  }) async {
    await catalog.setSpotEnabled(spotKey, enabled);
    if (!mounted) {
      return;
    }
    setState(() {});
    if (catalog.lastSyncError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo sincronizar el estado de alarmas: ${catalog.lastSyncError}',
          ),
        ),
      );
    }
  }

  void _setAlarmStation(String stationKey) {
    setState(() {
      _alarmStation = stationKey;
    });
  }

  void _setAlarmWindRange(RangeValues values) {
    setState(() {
      _alarmWindRange = values;
    });
  }

  void _toggleAllAlarmDirections() {
    setState(() {
      final allSelected =
          _alarmDirections.length ==
          _SpotDetailPageState._alarmDirectionOptions.length;
      _alarmDirections = allSelected
          ? <String>{}
          : _SpotDetailPageState._alarmDirectionOptions.toSet();
    });
  }

  void _setAlarmDirection(String direction, bool selected) {
    setState(() {
      if (selected) {
        _alarmDirections = <String>{..._alarmDirections, direction};
      } else {
        _alarmDirections = _alarmDirections
            .where((entry) => entry != direction)
            .toSet();
      }
    });
  }

  void _setAlarmRepeatWindow(AlarmRepeatWindow value) {
    setState(() {
      _alarmRepeatWindow = value;
    });
  }

  void _setAlarmMaxRepeats(int value) {
    setState(() {
      _alarmMaxRepeats = value;
    });
  }

  Future<void> _saveCurrentAlarm({
    required SpotAlarmCatalog catalog,
    required String spotKey,
  }) async {
    final wasEditing = _editingAlarmId != null;
    if (_alarmDirections.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona al menos una direccion para la alarma.'),
        ),
      );
      return;
    }

    final alarm = _buildAlarmRecord(spotKey);
    final duplicateExists = catalog.hasEquivalentAlarm(
      alarm,
      excludingId: _editingAlarmId,
    );
    if (duplicateExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya existe una alarma identica para esta estacion.'),
        ),
      );
      return;
    }

    final saved = await catalog.saveAlarm(alarm);
    if (!mounted) {
      return;
    }
    setState(() {
      _editingAlarmId = null;
    });
    if (!wasEditing) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Nueva alarma creada.')));
    }
    if (!saved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'La alarma se guardo localmente, pero no se pudo sincronizar: ${catalog.lastSyncError ?? 'error desconocido'}',
          ),
        ),
      );
    }
  }

  SpotAlarmRecord _buildAlarmRecord(String spotKey) {
    final stationName = _stationDisplayName(_alarmStation);
    final stationProvider = _findStationByKey(_alarmStation)?.provider ?? '';
    return SpotAlarmRecord(
      id: _editingAlarmId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      spotKey: spotKey,
      spotName: widget.name,
      spotArea: widget.area,
      stationProvider: stationProvider,
      stationKey: _alarmStation,
      stationName: stationName,
      windRange: _alarmWindRange,
      startHour: _alarmStartHour,
      endHour: _alarmEndHour,
      startMinute: _alarmStartMinute,
      endMinute: _alarmEndMinute,
      directions: _alarmDirections,
      repeatWindow: _alarmRepeatWindow,
      maxRepeats: _alarmMaxRepeats,
    );
  }

  void _startEditingAlarm(SpotAlarmRecord alarm) {
    setState(() {
      _editingAlarmId = alarm.id;
      _alarmStation = alarm.stationKey;
      _alarmWindRange = alarm.windRange;
      _alarmRepeatWindow = alarm.repeatWindow;
      _alarmMaxRepeats = alarm.maxRepeats;
      _alarmStartHour = alarm.startHour;
      _alarmEndHour = alarm.endHour;
      _alarmStartMinute = alarm.startMinute;
      _alarmEndMinute = alarm.endMinute;
      _alarmDirections = alarm.directions;
    });
  }

  Future<void> _deleteSavedAlarm({
    required SpotAlarmCatalog catalog,
    required SpotAlarmRecord alarm,
  }) async {
    final confirmed = await _confirmDeleteAlarm(alarm);
    if (!confirmed || !mounted) {
      return;
    }
    await LocalNotificationsService.instance.cancelAlarmCycle(
      alarmId: alarm.id,
      maxRepeats: alarm.maxRepeats,
    );
    final deleted = await catalog.deleteAlarm(alarm.id);
    if (!mounted) {
      return;
    }
    setState(() {
      if (_editingAlarmId == alarm.id) {
        _editingAlarmId = null;
      }
    });
    if (!deleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'La alarma se elimino localmente, pero no se pudo sincronizar: ${catalog.lastSyncError ?? 'error desconocido'}',
          ),
        ),
      );
    }
  }
}
