// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveSection on _SpotDetailPageState {
  Widget _buildLiveStationDropdown() {
    final stations = _resolvedNearbyStations();
    final stationKeys = stations.map(_stationKey).toList(growable: false);
    final effectiveKey = stationKeys.contains(_selectedStation)
        ? _selectedStation
        : (stationKeys.isNotEmpty ? stationKeys.first : _selectedStation);
    return _LiveStationDropdown(
      stations: stations,
      selectedStationKey: effectiveKey,
      stationKeyOf: _stationKey,
      stationLabelOf: _stationLabel,
      onChanged: _handleLiveStationChanged,
    );
  }

  Widget _buildLiveProviderLabel() {
    final liveData = _selectedLiveData();
    final observedAt = liveData.observedAt;
    return _LiveProviderLabel(
      text: observedAt == null
          ? null
          : 'Ultimo dato: ${_formatObservedAtWithAge(observedAt)}',
    );
  }

  Widget _buildLiveWindUnitSelector() {
    return _LiveWindUnitSelector(
      selectedUnit: _windSpeedUnit,
      onChanged: _handleWindSpeedUnitChanged,
    );
  }

  Widget _buildLiveCompassSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final hasSelectedPayload = _resolvedLiveDataByStation().containsKey(
          _selectedStation,
        );
        if (_isLiveRefreshing && !hasSelectedPayload) {
          return _buildLiveWindLoadingCard();
        }
        final liveData = _selectedLiveData();
        final hasWindData =
            liveData.windKnots != null && liveData.windDeg != null;
        return _LiveCompassShell(
          compassEnabled: _compassOverlayMode == _CompassOverlayMode.realtime,
          canToggleCompass: hasWindData,
          isRefreshing: _isLiveRefreshing,
          onToggleCompass: _toggleRealtimeCompass,
          onRefresh: _refreshSelectedStationLiveData,
          child: _buildWindRoseWithCompassOverlay(liveData),
        );
      },
    );
  }

  Widget _buildLiveMetricsGrid() {
    final liveData = _selectedLiveData();
    final station = _findStationByKey(_selectedStation);
    final metrics = <_LiveMetricData>[
      if (liveData.windKnots != null)
        _LiveMetricData(
          label: 'Viento',
          value: _formatWind(liveData.windKnots),
        ),
      if (liveData.gustKnots != null)
        _LiveMetricData(
          label: station?.provider == 'INFORATGE' ? 'Racha max.' : 'Racha',
          value: _formatWind(liveData.gustKnots),
        ),
      if (liveData.windMinKnots != null)
        _LiveMetricData(
          label: 'Viento min.',
          value: _formatWind(liveData.windMinKnots),
        ),
      if (liveData.tempC != null)
        _LiveMetricData(
          label: 'Temperatura',
          value: AppUnitsController.instance.formatTemperature(liveData.tempC!),
        ),
      if (liveData.pressureHpa != null)
        _LiveMetricData(
          label: 'Presion',
          value: _formatOptionalInt(liveData.pressureHpa, ' hPa'),
        ),
      if (liveData.humidityPct != null)
        _LiveMetricData(
          label: 'Humedad',
          value: _formatOptionalInt(liveData.humidityPct, '%'),
        ),
      if (liveData.rainMm != null)
        _LiveMetricData(
          label: 'Lluvia',
          value: _formatOptionalDouble(liveData.rainMm, ' mm'),
        ),
      if (liveData.seaSurfaceTempC != null)
        _LiveMetricData(
          label: 'Temp. agua',
          value: AppUnitsController.instance.formatTemperature(
            liveData.seaSurfaceTempC!,
          ),
        ),
      if (liveData.waveHeightM != null)
        _LiveMetricData(
          label: 'Oleaje',
          value: AppUnitsController.instance.formatHeight(liveData.waveHeightM!),
        ),
      if (liveData.wavePeriodS != null)
        _LiveMetricData(
          label: 'Periodo',
          value: _formatOptionalDouble(liveData.wavePeriodS, ' s'),
        ),
    ];
    return _LiveMetricsGrid(metrics: metrics);
  }

  Widget _buildLiveActionsRow(_NearbyStation station) {
    return _LiveStationActionsRow(
      station: station,
      onShowMap: _showLiveStationMapDialog,
    );
  }

  Widget _buildMaritimeObservationsButton() {
    if (!_canLoadMaritimeObservations()) {
      return const SizedBox.shrink();
    }
    final loadedLabel = _maritimeObservationsLoaded
        ? 'Actualizar observaciones maritimas'
        : 'Cargar observaciones maritimas';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _isMaritimeObservationsLoading
              ? null
              : _loadMaritimeObservations,
          icon: _isMaritimeObservationsLoading
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sailing_outlined),
          label: Text(
            _isMaritimeObservationsLoading
                ? 'Buscando observaciones...'
                : loadedLabel,
          ),
        ),
        if (_maritimeObservationsLoaded) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Radio ${_maritimeObservationsRadiusKm.toStringAsFixed(0)} km · '
            '$_maritimeObservationsLoadedCount con viento de '
            '$_maritimeObservationsTotal observaciones detectadas',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (_maritimeObservationsHasMore) ...[
            const SizedBox(height: AppSpacing.xs),
            TextButton.icon(
              onPressed: _isMaritimeObservationsLoading
                  ? null
                  : _loadMoreMaritimeObservations,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Cargar 10 observaciones mas'),
            ),
          ],
        ],
        if (_maritimeObservationsError != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            _maritimeObservationsError!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLiveSection() {
    final loadResult = _liveStationsLoadResult;
    if (loadResult == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: _buildForecastLoadingState(includeBottomSpacing: true),
        ),
      );
    }
    if (loadResult.source == _LiveStationsDataSource.unavailable ||
        loadResult.stations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: _buildUnavailableForecastState(
            message:
                loadResult.message ??
                'No hay observaciones reales disponibles para este spot.',
            technicalError: loadResult.technicalError,
            onRetry: _isLiveRefreshing ? null : _loadLiveStations,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLiveStationDropdown(),
            _buildLiveActionsRow(
              _findStationByKey(_selectedStation) ??
                  _resolvedNearbyStations().first,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildMaritimeObservationsButton(),
            const SizedBox(height: AppSpacing.sm),
            _buildLiveProviderLabel(),
            const SizedBox(height: AppSpacing.sm),
            _buildLiveWindUnitSelector(),
            const SizedBox(height: AppSpacing.sm),
            _buildLiveCompassSection(),
            const SizedBox(height: AppSpacing.sm),
            _buildLiveMetricsGrid(),
            const SizedBox(height: AppSpacing.sm),
            _buildHistoricalChart(),
            const SizedBox(height: AppSpacing.sm),
            _buildCustomAlarmsSection(),
          ],
        ),
      ),
    );
  }
}
