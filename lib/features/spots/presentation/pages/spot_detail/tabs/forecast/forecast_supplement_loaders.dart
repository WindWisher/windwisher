// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailForecastSupplementLoaders on _SpotDetailPageState {
  Future<T> _runForecastRequest<T>(Future<T> Function() action) {
    return action().timeout(_SpotDetailPageState._forecastRequestTimeout);
  }

  Future<_MeteoblueCurrentDayLoadResult> _loadMeteoblueCurrentDay() async {
    try {
      final snapshot = await _runForecastRequest(
        () => _meteoblueCurrentDayClient.fetchSnapshot(spot: widget.spot),
      );
      return _MeteoblueCurrentDayLoadResult(
        snapshot: snapshot,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _MeteoblueCurrentDayLoadResult(
        snapshot: const MeteoblueCurrentDaySnapshot(
          current: null,
          sea: <MeteoblueSeaData>[],
          days: <MeteoblueDayData>[],
        ),
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.meteoblueAccessConfigured
            ? 'Meteoblue sin API key cargada.'
            : 'Current/Day de Meteoblue no disponible.',
        technicalError: '$error',
      );
    }
  }

  Future<_MeteoblueCurrentDayLoadResult> _ensureMeteoblueCurrentDayFuture() {
    return _meteoblueCurrentDayFuture ??= _loadMeteoblueCurrentDay();
  }

  Future<_MeteosourceCurrentDayLoadResult> _loadMeteosourceCurrentDay() async {
    try {
      final snapshot = await _runForecastRequest(
        () => _meteosourceCurrentDayClient.fetchSnapshot(spot: widget.spot),
      );
      return _MeteosourceCurrentDayLoadResult(
        snapshot: snapshot,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _MeteosourceCurrentDayLoadResult(
        snapshot: const MeteosourceCurrentDaySnapshot(
          current: null,
          days: <MeteosourceDayData>[],
        ),
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.meteosourceAccessConfigured
            ? 'Meteosource sin API key cargada.'
            : 'Current/Day de Meteosource no disponible.',
        technicalError: '$error',
      );
    }
  }

  Future<_MeteosourceCurrentDayLoadResult>
  _ensureMeteosourceCurrentDayFuture() {
    return _meteosourceCurrentDayFuture ??= _loadMeteosourceCurrentDay();
  }

  Future<_MeteostatDayLoadResult> _loadMeteostatDay() async {
    try {
      final snapshot = await _runForecastRequest(
        () => _meteostatDayClient.fetchSnapshot(spot: widget.spot),
      );
      return _MeteostatDayLoadResult(
        snapshot: snapshot,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _MeteostatDayLoadResult(
        snapshot: const MeteostatDaySnapshot(days: <MeteostatDayData>[]),
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.meteostatAccessConfigured
            ? 'Meteostat sin RapidAPI key cargada.'
            : 'Day de Meteostat no disponible.',
        technicalError: '$error',
      );
    }
  }

  Future<_MeteostatDayLoadResult> _ensureMeteostatDayFuture() {
    return _meteostatDayFuture ??= _loadMeteostatDay();
  }

  Future<_AemetBeachForecastLoadResult> _loadAemetBeachForecast() async {
    try {
      final selectedBeachCode = extractAemetBeachCodeFromModel(
        model: _forecastModel,
        spot: widget.spot,
      );
      final data = await _runForecastRequest(
        () => _aemetBeachForecastClient.fetchForecasts(
          spot: widget.spot,
          beachCodes: selectedBeachCode == null ? null : [selectedBeachCode],
        ),
      );
      return _AemetBeachForecastLoadResult(
        data: data,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _AemetBeachForecastLoadResult(
        data: const <AemetBeachForecastData>[],
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.aemetAccessConfigured
            ? 'AEMET playa sin API key cargada.'
            : 'AEMET playa no disponible.',
        technicalError: '$error',
      );
    }
  }

  void _refreshAemetBeachForecast() {
    setState(() {
      _aemetBeachForecastFuture = _loadAemetBeachForecast();
    });
  }

  Future<_AemetBeachForecastLoadResult> _ensureAemetBeachForecastFuture() {
    return _aemetBeachForecastFuture ??= _loadAemetBeachForecast();
  }

  Future<_AemetCoastalForecastLoadResult> _loadAemetCoastalForecast() async {
    try {
      final data = await _runForecastRequest(
        () => _aemetCoastalForecastClient.fetchForecast(spot: widget.spot),
      );
      return _AemetCoastalForecastLoadResult(
        data: data,
        source: _ForecastDataSource.live,
      );
    } catch (error) {
      return _AemetCoastalForecastLoadResult(
        data: null,
        source: _ForecastDataSource.fallback,
        message: !EnvConfig.aemetAccessConfigured
            ? 'AEMET maritima sin API key cargada.'
            : 'AEMET maritima costera no disponible.',
        technicalError: '$error',
      );
    }
  }

  void _refreshAemetCoastalForecast() {
    setState(() {
      _aemetCoastalForecastFuture = _loadAemetCoastalForecast();
    });
  }

  Future<_AemetCoastalForecastLoadResult> _ensureAemetCoastalForecastFuture() {
    return _aemetCoastalForecastFuture ??= _loadAemetCoastalForecast();
  }
}
