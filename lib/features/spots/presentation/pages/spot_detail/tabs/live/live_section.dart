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
          : 'Ultimo dato: ${_formatObservedAtWithAge(observedAt, label: liveData.observedAtLabel)}',
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
        final compassCard = Stack(
          children: [
            _buildWindRoseWithCompassOverlay(liveData),
            Positioned(
              top: AppSpacing.xs,
              left: AppSpacing.xs,
              child: IconButton.filledTonal(
                tooltip: _compassOverlayMode == _CompassOverlayMode.realtime
                    ? 'Desactivar brujula'
                    : 'Activar brujula',
                onPressed: hasWindData ? _toggleRealtimeCompass : null,
                icon: Icon(
                  _compassOverlayMode == _CompassOverlayMode.realtime
                      ? Icons.explore_off_rounded
                      : Icons.explore_rounded,
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.xs,
              right: AppSpacing.xs,
              child: IconButton.filledTonal(
                tooltip: 'Refrescar estacion',
                onPressed: _isLiveRefreshing
                    ? null
                    : _refreshSelectedStationLiveData,
                icon: _isLiveRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ),
          ],
        );
        return compassCard;
      },
    );
  }

  Widget _buildLiveMetricsGrid() {
    final liveData = _selectedLiveData();
    final station = _findStationByKey(_selectedStation);
    return _LiveMetricsGrid(
      metrics: [
        _LiveMetricData(
          label: 'Viento',
          value: _formatWind(liveData.windKnots),
        ),
        _LiveMetricData(
          label: station?.provider == 'INFORATGE' ? 'Racha max.' : 'Racha',
          value: _formatWind(liveData.gustKnots),
        ),
        _LiveMetricData(
          label: 'Temperatura',
          value: _formatOptionalDouble(liveData.tempC, ' C'),
        ),
        _LiveMetricData(
          label: 'Presion',
          value: _formatOptionalInt(liveData.pressureHpa, ' hPa'),
        ),
        _LiveMetricData(
          label: 'Humedad',
          value: _formatOptionalInt(liveData.humidityPct, '%'),
        ),
        _LiveMetricData(
          label: 'Lluvia',
          value: _formatOptionalDouble(liveData.rainMm, ' mm'),
        ),
      ],
    );
  }

  Widget _buildLiveActionsRow(_NearbyStation station) {
    return _LiveStationActionsRow(
      station: station,
      onShowMap: _showLiveStationMapDialog,
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
