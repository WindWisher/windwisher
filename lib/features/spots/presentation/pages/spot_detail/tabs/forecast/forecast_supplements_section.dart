// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailForecastSupplementsSection on _SpotDetailPageState {
  MeteoblueCurrentDaySnapshot get _emptyMeteoblueSnapshot =>
      const MeteoblueCurrentDaySnapshot(
        current: null,
        sea: <MeteoblueSeaData>[],
        days: <MeteoblueDayData>[],
      );

  Widget _buildSelectedMeteoblueSupplement(
    _MeteoblueCurrentDayLoadResult result,
  ) {
    return MeteoblueForecastSupplementCard(
      snapshot: result.snapshot,
      message: result.message,
      showCurrent: _usesMeteoblueCurrentModel(),
      showSea: _usesMeteoblueSeaModel(),
      showDay: _usesMeteoblueDayModel(),
      seaVisibleHours: _meteoblueSeaVisibleHours,
      onSeaVisibleHoursChanged: (hours) {
        setState(() {
          _meteoblueSeaVisibleHours = hours;
        });
      },
      showFullscreenButton: _usesMeteoblueSeaModel(),
      onOpenFullscreen: _usesMeteoblueSeaModel()
          ? () {
              setState(() {
                _fullscreenMode = _ForecastFullscreenMode.meteoblueSea;
              });
            }
          : null,
    );
  }

  Widget _buildSelectedMeteosourceSupplement(
    _MeteosourceCurrentDayLoadResult result,
  ) {
    return MeteosourceForecastSupplementCard(
      snapshot: result.snapshot,
      message: result.message,
      showCurrent: _usesMeteosourceCurrentModel(),
      showDay: _usesMeteosourceDayModel(),
    );
  }

  Widget _buildSelectedMeteostatDaySupplement(_MeteostatDayLoadResult result) {
    return MeteostatDaySupplementCard(
      snapshot: result.snapshot,
      message: result.message,
    );
  }

  Widget _buildExpandedMeteoblueSeaOverlay(
    _MeteoblueCurrentDayLoadResult result,
  ) {
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;

    return Positioned.fill(
      child: Stack(
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final seaCard = MeteoblueForecastSupplementCard(
                  snapshot: result.snapshot,
                  message: result.message,
                  showCurrent: false,
                  showSea: true,
                  showDay: false,
                  seaVisibleHours: _meteoblueSeaVisibleHours,
                  showSeaHeader: false,
                  showSeaControls: false,
                  showFullscreenButton: false,
                  expandToFill: true,
                );
                final content = isLandscape
                    ? SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: seaCard,
                      )
                    : SizedBox(
                        width: constraints.maxHeight,
                        height: constraints.maxWidth,
                        child: RotatedBox(quarterTurns: 1, child: seaCard),
                      );

                return ClipRect(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: content,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
            child: SafeArea(
              child: SizedBox(
                width: 34,
                height: 34,
                child: FloatingActionButton(
                  mini: true,
                  heroTag: 'meteoblueSeaFullscreenClose',
                  tooltip: 'Salir de fullscreen',
                  elevation: 0,
                  highlightElevation: 0,
                  backgroundColor: Colors.black.withValues(alpha: 0.22),
                  foregroundColor: Colors.white.withValues(alpha: 0.9),
                  shape: const CircleBorder(),
                  onPressed: () {
                    setState(() {
                      _fullscreenMode = _ForecastFullscreenMode.none;
                    });
                  },
                  child: const Icon(Icons.close_rounded, size: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForecastTableContent(_ForecastLoadResult result) {
    if (result.source == _ForecastDataSource.fallback) {
      return _buildUnavailableForecastState(
        message:
            result.message ??
            'Prueba de nuevo mas tarde o cambia de proveedor.',
        technicalError: result.technicalError,
        onRetry: _refreshForecastRows,
      );
    }

    final effectiveResolution = _effectiveForecastResolution(
      _forecastRange,
      _forecastResolution,
    );
    return Column(
      children: [
        Row(children: [Expanded(child: _buildForecastTableTitle())]),
        const SizedBox(height: AppSpacing.xs),
        _buildForecastDataStatusBanner(result),
        const SizedBox(height: AppSpacing.sm),
        _buildWindguruStyleTable(
          rowsOverride: _resampleForecastRows(
            _clipForecastRows(
              result.rows,
              provider: _forecastProvider,
              range: _forecastRange,
            ),
            effectiveResolution,
          ),
          onOpenFullscreen: _openForecastTableFullscreen,
          selectedRange: _forecastRange,
          fullscreenResolution: effectiveResolution,
          showResolutionSelector: true,
          onRangeChanged: _updateForecastRange,
          onResolutionChanged: _updateForecastResolution,
        ),
      ],
    );
  }

  void _openWindguruFullscreen() {
    setState(() {
      if (!_SpotDetailPageState._isFlutterTest && !kIsWeb) {
        _windguruFullscreenController ??= _createWindguruController();
      }
      _fullscreenMode = _ForecastFullscreenMode.windguru;
    });
  }

  Widget _buildWindguruForecastSection() {
    final controller = _SpotDetailPageState._isFlutterTest || kIsWeb
        ? _windguruController
        : (_windguruController ??= _createWindguruController());
    if (_SpotDetailPageState._isFlutterTest ||
        (!kIsWeb && controller == null)) {
      final message = _SpotDetailPageState._isFlutterTest
          ? 'Windguru no disponible en esta plataforma de prueba.'
          : 'No se ha podido iniciar el widget de Windguru.';
      return _buildUnavailableForecastState(message: message);
    }
    const windguruStatus = _ForecastLoadResult(
      rows: <_ForecastRow>[],
      source: _ForecastDataSource.live,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildForecastDataStatusBanner(windguruStatus),
        const SizedBox(height: AppSpacing.sm),
        WindguruForecastCard(
          title: _buildForecastTableTitle(),
          subtitle: _windguruWidgetSubtitleForSpot(widget.name),
          height: _windguruWidgetHeightForSpot(widget.name),
          controller: controller,
          webEmbedHtml: kIsWeb ? _windguruWidgetHtmlForSpot(widget.name) : null,
          isFullscreenActive:
              _fullscreenMode == _ForecastFullscreenMode.windguru,
          onOpenFullscreen: _openWindguruFullscreen,
        ),
      ],
    );
  }

  Widget _buildMeteoblueSupplement() {
    return FutureBuilder<_MeteoblueCurrentDayLoadResult>(
      future: _ensureMeteoblueCurrentDayFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState();
        }
        final currentDay =
            snapshot.data ??
            _MeteoblueCurrentDayLoadResult(
              snapshot: _emptyMeteoblueSnapshot,
              source: _ForecastDataSource.fallback,
              message: 'Meteoblue no disponible.',
            );

        return _buildSelectedMeteoblueSupplement(currentDay);
      },
    );
  }

  Widget _buildMeteosourceSupplement() {
    return FutureBuilder<_MeteosourceCurrentDayLoadResult>(
      future: _ensureMeteosourceCurrentDayFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState();
        }
        final currentDay =
            snapshot.data ??
            const _MeteosourceCurrentDayLoadResult(
              snapshot: MeteosourceCurrentDaySnapshot(
                current: null,
                days: <MeteosourceDayData>[],
              ),
              source: _ForecastDataSource.fallback,
              message: 'Meteosource no disponible.',
            );

        return _buildSelectedMeteosourceSupplement(currentDay);
      },
    );
  }

  Widget _buildMeteostatDaySupplement() {
    return FutureBuilder<_MeteostatDayLoadResult>(
      future: _ensureMeteostatDayFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState();
        }
        final dayResult =
            snapshot.data ??
            const _MeteostatDayLoadResult(
              snapshot: MeteostatDaySnapshot(days: <MeteostatDayData>[]),
              source: _ForecastDataSource.fallback,
              message: 'Meteostat Day no disponible.',
            );

        return _buildSelectedMeteostatDaySupplement(dayResult);
      },
    );
  }

  Widget _buildForecastSupplementOrTable(_ForecastLoadResult result) {
    if (_usesMeteoblueCurrentModel() ||
        _usesMeteoblueDayModel() ||
        _usesMeteoblueSeaModel()) {
      return _buildMeteoblueSupplement();
    }
    if (_usesMeteosourceCurrentModel() || _usesMeteosourceDayModel()) {
      return _buildMeteosourceSupplement();
    }
    if (_usesMeteostatDayModel()) {
      return _buildMeteostatDaySupplement();
    }
    return _buildForecastTableContent(result);
  }

  Widget _buildAemetBeachForecastSection() {
    return FutureBuilder<_AemetBeachForecastLoadResult>(
      future: _ensureAemetBeachForecastFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState(includeBottomSpacing: true);
        }

        final result =
            snapshot.data ??
            _AemetBeachForecastLoadResult(
              data: const <AemetBeachForecastData>[],
              source: _ForecastDataSource.fallback,
              message: 'AEMET playa no disponible.',
            );
        if (result.source == _ForecastDataSource.fallback ||
            result.data.isEmpty) {
          return _buildUnavailableForecastState(
            message:
                result.message ??
                'Prueba de nuevo mas tarde o cambia de proveedor.',
            technicalError: result.technicalError,
            onRetry: _refreshAemetBeachForecast,
          );
        }
        return Column(
          children: [
            Row(children: [Expanded(child: _buildForecastTableTitle())]),
            const SizedBox(height: AppSpacing.xs),
            _buildAemetBeachStatusBanner(result),
            const SizedBox(height: AppSpacing.sm),
            ...result.data.map(
              (beachData) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AemetBeachForecastTable(data: beachData),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAemetCoastalForecastSection() {
    return FutureBuilder<_AemetCoastalForecastLoadResult>(
      future: _ensureAemetCoastalForecastFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildForecastLoadingState(includeBottomSpacing: true);
        }

        final result =
            snapshot.data ??
            _AemetCoastalForecastLoadResult(
              data: null,
              source: _ForecastDataSource.fallback,
              message: 'AEMET maritima costera no disponible.',
            );
        if (result.source == _ForecastDataSource.fallback ||
            result.data == null) {
          return _buildUnavailableForecastState(
            message:
                result.message ??
                'Prueba de nuevo mas tarde o cambia de proveedor.',
            technicalError: result.technicalError,
            onRetry: _refreshAemetCoastalForecast,
          );
        }
        return Column(
          children: [
            Row(children: [Expanded(child: _buildForecastTableTitle())]),
            const SizedBox(height: AppSpacing.xs),
            _buildAemetCoastalStatusBanner(result),
            const SizedBox(height: AppSpacing.sm),
            AemetCoastalForecastTable(data: result.data!),
          ],
        );
      },
    );
  }
}
