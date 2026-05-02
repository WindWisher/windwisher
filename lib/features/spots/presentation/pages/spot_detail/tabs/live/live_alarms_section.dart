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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.9),
                    colorScheme.secondaryContainer.withValues(alpha: 0.75),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withValues(alpha: 0.72),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alarmas personalizadas',
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          spotEnabled
                              ? 'Spot activo para alertas'
                              : 'Spot desactivado para alertas',
                          style: textTheme.bodySmall?.copyWith(
                            color: spotEnabled
                                ? const Color(0xFF2E7D32)
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: spotEnabled,
                    onChanged: (value) async {
                      await catalog.setSpotEnabled(spotKey, value);
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
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.42,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.55),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Nueva alarma',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: _alarmStation,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Estacion meteorologica',
                      border: OutlineInputBorder(),
                    ),
                    items: alarmStations
                        .map(
                          (station) => DropdownMenuItem(
                            value: station,
                            child: SizedBox(
                              width: double.infinity,
                              child: Text(
                                _stationLabelForKey(station),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    selectedItemBuilder: (context) {
                      return alarmStations
                          .map(
                            (station) => Text(
                              _stationLabelForKey(station),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                          .toList();
                    },
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _alarmStation = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickAlarmTime(isStart: true),
                          icon: const Icon(Icons.schedule_rounded),
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Desde'),
                              Text(
                                _formatAlarmTime(
                                  _alarmStartHour,
                                  _alarmStartMinute,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _pickAlarmTime(isStart: false),
                          icon: const Icon(Icons.schedule_rounded),
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hasta'),
                              Text(
                                _formatAlarmTime(
                                  _alarmEndHour,
                                  _alarmEndMinute,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer.withValues(
                        alpha: 0.55,
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Rango de viento · ${_formatAlarmWindRange(_alarmWindRange)}',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  RangeSlider(
                    min: 4,
                    max: 40,
                    divisions: 36,
                    values: _alarmWindRange,
                    labels: RangeLabels(
                      _formatAlarmWindValue(_alarmWindRange.start),
                      _formatAlarmWindValue(_alarmWindRange.end),
                    ),
                    onChanged: (values) {
                      setState(() {
                        _alarmWindRange = values;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Direcciones activas',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      FilterChip(
                        label: const Text('Todas'),
                        selected:
                            _alarmDirections.length ==
                            _SpotDetailPageState._alarmDirectionOptions.length,
                        showCheckmark: false,
                        onSelected: (_) {
                          setState(() {
                            final allSelected =
                                _alarmDirections.length ==
                                _SpotDetailPageState
                                    ._alarmDirectionOptions
                                    .length;
                            _alarmDirections = allSelected
                                ? <String>{}
                                : _SpotDetailPageState._alarmDirectionOptions
                                      .toSet();
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final rows = <List<String>>[
                        _SpotDetailPageState._alarmDirectionOptions.sublist(
                          0,
                          4,
                        ),
                        _SpotDetailPageState._alarmDirectionOptions.sublist(
                          4,
                          8,
                        ),
                      ];
                      return Column(
                        children: rows
                            .map((row) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: row == rows.last ? 0 : AppSpacing.xs,
                                ),
                                child: Row(
                                  children: row
                                      .map((direction) {
                                        final selected = _alarmDirections
                                            .contains(direction);
                                        return Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              right: direction == row.last
                                                  ? 0
                                                  : AppSpacing.xs,
                                            ),
                                            child: FilterChip(
                                              showCheckmark: false,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              visualDensity:
                                                  VisualDensity.compact,
                                              labelPadding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 2,
                                                  ),
                                              label: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Transform.rotate(
                                                      angle:
                                                          _alarmDirectionRotation(
                                                            direction,
                                                          ),
                                                      child: Icon(
                                                        Icons
                                                            .navigation_rounded,
                                                        size: 14,
                                                        color: selected
                                                            ? colorScheme
                                                                  .onSecondaryContainer
                                                            : colorScheme
                                                                  .onSurfaceVariant,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      direction,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              selected: selected,
                                              onSelected: (value) {
                                                setState(() {
                                                  if (value) {
                                                    _alarmDirections = <String>{
                                                      ..._alarmDirections,
                                                      direction,
                                                    };
                                                  } else {
                                                    _alarmDirections =
                                                        _alarmDirections
                                                            .where(
                                                              (entry) =>
                                                                  entry !=
                                                                  direction,
                                                            )
                                                            .toSet();
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      })
                                      .toList(growable: false),
                                ),
                              );
                            })
                            .toList(growable: false),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<AlarmRepeatWindow>(
                    initialValue: _alarmRepeatWindow,
                    decoration: const InputDecoration(
                      labelText: 'Repetir cada',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min1,
                        child: Text('1 min'),
                      ),
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min5,
                        child: Text('5 min'),
                      ),
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min10,
                        child: Text('10 min'),
                      ),
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min15,
                        child: Text('15 min'),
                      ),
                      DropdownMenuItem(
                        value: AlarmRepeatWindow.min30,
                        child: Text('30 min'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _alarmRepeatWindow = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<int>(
                    initialValue: _alarmMaxRepeats,
                    decoration: const InputDecoration(
                      labelText: 'Maximo de avisos seguidos',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(6, (index) {
                      final value = index + 1;
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value aviso${value == 1 ? '' : 's'}'),
                      );
                    }),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _alarmMaxRepeats = value;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () async {
                        final wasEditing = _editingAlarmId != null;
                        if (_alarmDirections.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Selecciona al menos una direccion para la alarma.',
                              ),
                            ),
                          );
                          return;
                        }
                        final stationName = _stationDisplayName(_alarmStation);
                        final stationProvider =
                            _findStationByKey(_alarmStation)?.provider ?? '';
                        final alarm = SpotAlarmRecord(
                          id:
                              _editingAlarmId ??
                              DateTime.now().millisecondsSinceEpoch.toString(),
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
                        final duplicateExists = catalog.hasEquivalentAlarm(
                          alarm,
                          excludingId: _editingAlarmId,
                        );
                        if (duplicateExists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ya existe una alarma identica para esta estacion.',
                              ),
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
                          _syncAlarmMonitoring();
                        });
                        await _processLocalAlarmNotifications(
                          _savedAlarmsForCurrentSpot(),
                        );
                        if (!mounted) {
                          return;
                        }
                        if (!wasEditing) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nueva alarma creada.'),
                            ),
                          );
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
                      },
                      icon: const Icon(Icons.alarm_add_rounded),
                      label: Text(
                        _editingAlarmId == null
                            ? 'Guardar alarma'
                            : 'Guardar cambios',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.alarm_add_rounded,
                  size: 18,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Alarmas guardadas',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (savedAlarms.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Todavia no hay alarmas guardadas para este spot.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...List.generate(savedAlarms.length, (index) {
                final alarm = savedAlarms[index];
                final evaluation = _evaluateAlarm(alarm);
                final evaluationColor = _alarmEvaluationColor(
                  context,
                  evaluation,
                );
                final statusBackground = evaluationColor.withValues(
                  alpha: 0.12,
                );
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                    bottom: index == savedAlarms.length - 1 ? 0 : AppSpacing.sm,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alarm.stationName,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBackground,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        switch (evaluation.state) {
                                          _AlarmEvaluationState.active =>
                                            Icons.notifications_active_rounded,
                                          _AlarmEvaluationState.partial =>
                                            Icons.timelapse_rounded,
                                          _AlarmEvaluationState.idle =>
                                            Icons.notifications_paused_rounded,
                                          _AlarmEvaluationState.noData =>
                                            Icons.error_outline_rounded,
                                          _AlarmEvaluationState.disabled =>
                                            Icons.notifications_off_rounded,
                                        },
                                        size: 16,
                                        color: evaluationColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          evaluation.label,
                                          style: textTheme.bodySmall?.copyWith(
                                            color: evaluationColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Column(
                            children: [
                              IconButton(
                                tooltip: 'Editar',
                                onPressed: () {
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
                                },
                                icon: const Icon(Icons.edit_rounded),
                              ),
                              IconButton(
                                tooltip: 'Eliminar',
                                onPressed: () async {
                                  final confirmed = await _confirmDeleteAlarm(
                                    alarm,
                                  );
                                  if (!confirmed || !mounted) {
                                    return;
                                  }
                                  await LocalNotificationsService.instance
                                      .cancelAlarmCycle(
                                        alarmId: alarm.id,
                                        maxRepeats: alarm.maxRepeats,
                                      );
                                  final deleted = await catalog.deleteAlarm(
                                    alarm.id,
                                  );
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {
                                    if (_editingAlarmId == alarm.id) {
                                      _editingAlarmId = null;
                                    }
                                    _syncAlarmMonitoring();
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
                                },
                                icon: const Icon(Icons.delete_outline_rounded),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _alarmTriggerSummary(alarm),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _AlarmMetaChip(
                            icon: Icons.air_rounded,
                            label: _formatAlarmWindRange(alarm.windRange),
                          ),
                          _AlarmMetaChip(
                            icon: Icons.schedule_rounded,
                            label:
                                '${_formatAlarmTime(alarm.startHour, alarm.startMinute)}-${_formatAlarmTime(alarm.endHour, alarm.endMinute)}',
                          ),
                          _AlarmMetaChip(
                            icon: Icons.navigation_rounded,
                            label: alarm.directions.join('/'),
                          ),
                          _AlarmMetaChip(
                            icon: Icons.repeat_rounded,
                            label: _alarmRepeatWindowLabel(alarm.repeatWindow),
                          ),
                          _AlarmMetaChip(
                            icon: Icons.filter_3_rounded,
                            label: '${alarm.maxRepeats} avisos',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
