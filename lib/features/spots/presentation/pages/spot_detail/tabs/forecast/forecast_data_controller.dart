// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailForecastDataController on _SpotDetailPageState {
  List<String> _modelsForProvider(String provider) {
    return getSpotForecastModels(
      spotName: widget.name,
      spotArea: widget.area,
      spotBeachCode: widget.aemetBeachCode,
      spotBeachCodes: widget.aemetBeachCodes,
      provider: provider,
    );
  }

  List<String> _historyForecastProviders() {
    return const <String>[
      'Open-Meteo',
      'Meteoblue',
      'Meteosource',
      'Meteostat',
    ];
  }

  List<String> _historyForecastModelsForProvider(String provider) {
    final models = _modelsForProvider(provider);
    switch (provider) {
      case 'Open-Meteo':
        return models;
      case 'Meteoblue':
        return models
            .where((model) => model == 'Basic' || model == 'Sea')
            .toList(growable: false);
      case 'Meteosource':
        return models
            .where((model) => model == 'Hourly')
            .toList(growable: false);
      case 'Meteostat':
        return models
            .where((model) => model == 'Hourly')
            .toList(growable: false);
      default:
        return const <String>[];
    }
  }

  void _ensureHistoryForecastRowsLoaded() {
    if (_historyForecastLoadRequested) {
      return;
    }
    _historyForecastLoadRequested = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _loadHistoryForecastRows();
    });
  }

  bool _providerUsesModelForFetch(String provider, [String? model]) {
    if (provider == 'AEMET') {
      return isAemetPortusAtmosphereForecastModel(model ?? _forecastModel);
    }
    return provider != 'Windguru';
  }

  bool _usesAemetBeachForecastModel([String? model]) {
    return _forecastProvider == 'AEMET' &&
        isAemetBeachForecastModelLabel(model ?? _forecastModel);
  }

  bool _usesAemetCoastalForecastModel([String? model]) {
    return _forecastProvider == 'AEMET' &&
        (model ?? _forecastModel) == kAemetCoastalForecastModel;
  }

  bool _usesAemetPortusForecastModel([String? model]) {
    return _forecastProvider == 'AEMET' &&
        isAemetPortusAtmosphereForecastModel(model ?? _forecastModel);
  }

  bool _usesMeteoblueProvider() {
    return _forecastProvider == 'Meteoblue';
  }

  bool _usesMeteoblueCurrentModel() {
    return _usesMeteoblueProvider() && _forecastModel == 'Current';
  }

  bool _usesMeteoblueDayModel() {
    return _usesMeteoblueProvider() && _forecastModel == 'Day';
  }

  bool _usesMeteoblueSeaModel() {
    return _usesMeteoblueProvider() && _forecastModel == 'Sea';
  }

  bool _usesMeteosourceProvider() {
    return _forecastProvider == 'Meteosource';
  }

  bool _usesMeteosourceCurrentModel() {
    return _usesMeteosourceProvider() && _forecastModel == 'Current';
  }

  bool _usesMeteosourceDayModel() {
    return _usesMeteosourceProvider() && _forecastModel == 'Day';
  }

  bool _usesMeteostatProvider() {
    return _forecastProvider == 'Meteostat';
  }

  bool _usesMeteostatDayModel() {
    return _usesMeteostatProvider() && _forecastModel == 'Day';
  }

  bool _usesWindguruProvider() {
    return _forecastProvider == 'Windguru';
  }

  Future<_ForecastLoadResult> _loadForecastRows() async {
    final requestedProvider = _forecastProvider;
    final requestedModel = _forecastModel;
    try {
      final entries = await _runForecastRequest(
        () => _spotsModule.getSpotForecast(
          spot: widget.spot,
          provider: requestedProvider,
          model: requestedModel,
        ),
      );
      if (entries.isEmpty) {
        final fallbackMessage =
            requestedProvider == 'AEMET' &&
                !isAemetPortusAtmosphereForecastModel(requestedModel) &&
                !EnvConfig.aemetAccessConfigured
            ? 'AEMET sin API key cargada.'
            : requestedProvider == 'Meteoblue' &&
                  !EnvConfig.meteoblueAccessConfigured
            ? 'Meteoblue sin API key cargada.'
            : requestedProvider == 'Meteosource' &&
                  !EnvConfig.meteosourceAccessConfigured
            ? 'Meteosource sin API key cargada.'
            : requestedProvider == 'Meteostat' &&
                  !EnvConfig.meteostatAccessConfigured
            ? 'Meteostat sin RapidAPI key cargada.'
            : '$requestedProvider no devolvio datos reales.';
        return _ForecastLoadResult(
          rows: const <_ForecastRow>[],
          source: _ForecastDataSource.fallback,
          message: fallbackMessage,
        );
      }
      final rows = _mapForecastEntriesToRows(entries);
      return _ForecastLoadResult(rows: rows, source: _ForecastDataSource.live);
    } catch (error) {
      final rawError = '$error';
      final fallbackMessage =
          requestedProvider == 'AEMET' && rawError.contains('429')
          ? 'AEMET ha limitado temporalmente las peticiones.'
          : 'Error cargando $requestedProvider.';
      return _ForecastLoadResult(
        rows: const <_ForecastRow>[],
        source: _ForecastDataSource.fallback,
        message: fallbackMessage,
        technicalError: rawError,
      );
    }
  }

  Future<_ForecastLoadResult> _loadHistoryForecastRows() async {
    final requestedProvider = _historyForecastProvider;
    final requestedModel = _historyForecastModel;
    try {
      final entries = await _runForecastRequest(
        () => _spotsModule.getSpotForecast(
          spot: widget.spot,
          provider: requestedProvider,
          model: requestedModel,
        ),
      );
      final result = entries.isEmpty
          ? _ForecastLoadResult(
              rows: const <_ForecastRow>[],
              source: _ForecastDataSource.fallback,
              message: '$requestedProvider no devolvio datos reales.',
            )
          : _ForecastLoadResult(
              rows: _mapForecastEntriesToRows(entries),
              source: _ForecastDataSource.live,
            );
      if (mounted &&
          _historyForecastProvider == requestedProvider &&
          _historyForecastModel == requestedModel) {
        setState(() {
          _historyForecastRowsResult = result;
        });
      }
      return result;
    } catch (error) {
      final result = _ForecastLoadResult(
        rows: const <_ForecastRow>[],
        source: _ForecastDataSource.fallback,
        message: 'Error cargando $requestedProvider.',
        technicalError: '$error',
      );
      if (mounted &&
          _historyForecastProvider == requestedProvider &&
          _historyForecastModel == requestedModel) {
        setState(() {
          _historyForecastRowsResult = result;
        });
      }
      return result;
    }
  }

  void _refreshForecastRows() {
    setState(() {
      _forecastRowsFuture = _loadForecastRows();
      if (_usesMeteoblueProvider()) {
        _meteoblueCurrentDayFuture = _loadMeteoblueCurrentDay();
      }
      if (_usesMeteosourceProvider()) {
        _meteosourceCurrentDayFuture = _loadMeteosourceCurrentDay();
      }
      if (_usesMeteostatDayModel()) {
        _meteostatDayFuture = _loadMeteostatDay();
      }
    });
  }

  void _refreshHistoryForecastRows() {
    setState(() {
      _historyForecastRowsResult = null;
      _historyForecastLoadRequested = true;
    });
    _loadHistoryForecastRows();
  }

  void _handleForecastProviderChanged(String value) {
    setState(() {
      _forecastProvider = value;
      final models = _modelsForProvider(value);
      if (!models.contains(_forecastModel) && models.isNotEmpty) {
        _forecastModel =
            getSpotDefaultForecastModel(
              spotName: widget.name,
              spotArea: widget.area,
              spotBeachCode: widget.aemetBeachCode,
              spotBeachCodes: widget.aemetBeachCodes,
              provider: value,
            ) ??
            models.first;
      }
      _syncForecastRangeWithProvider();
    });
    if (_usesWindguruProvider()) {
      return;
    }
    if (_usesAemetBeachForecastModel()) {
      _refreshAemetBeachForecast();
    } else if (_usesAemetCoastalForecastModel()) {
      _refreshAemetCoastalForecast();
    } else {
      _refreshForecastRows();
    }
  }

  void _handleForecastModelChanged(String value) {
    final shouldRefresh = _providerUsesModelForFetch(_forecastProvider, value);
    setState(() {
      _forecastModel = value;
      _syncForecastRangeWithProvider();
    });
    if (_usesAemetBeachForecastModel(value)) {
      _refreshAemetBeachForecast();
    } else if (_usesAemetCoastalForecastModel(value)) {
      _refreshAemetCoastalForecast();
    } else if (shouldRefresh) {
      _refreshForecastRows();
    }
  }

  void _handleHistoryForecastProviderChanged(String value) {
    final models = _historyForecastModelsForProvider(value);
    setState(() {
      _historyForecastProvider = value;
      _historyForecastModel = models.isNotEmpty ? models.first : '';
      _historyForecastRowsResult = null;
      _historyForecastLoadRequested = true;
    });
    _loadHistoryForecastRows();
  }

  void _handleHistoryForecastModelChanged(String value) {
    setState(() {
      _historyForecastModel = value;
      _historyForecastRowsResult = null;
      _historyForecastLoadRequested = true;
    });
    _loadHistoryForecastRows();
  }
}
