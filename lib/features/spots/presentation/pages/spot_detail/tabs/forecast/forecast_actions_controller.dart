// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailForecastActionsController on _SpotDetailPageState {
  void _openForecastTableFullscreen() {
    setState(() {
      _fullscreenMode = _ForecastFullscreenMode.forecastTable;
    });
  }

  void _updateForecastRange(_ForecastRange range) {
    setState(() {
      _forecastRange = range;
      _syncForecastResolutionWithRange();
    });
  }

  void _updateForecastResolution(_ForecastResolution resolution) {
    setState(() {
      _forecastResolution = _effectiveForecastResolution(
        _forecastRange,
        resolution,
      );
    });
  }

  WebViewController? _createWindguruController() {
    if (WebViewPlatform.instance == null) {
      return null;
    }
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..loadHtmlString(
        _windguruWidgetHtmlForSpot(widget.name),
        baseUrl: 'https://www.windguru.cz',
      );
  }

  Future<void> _openWindMap() async {
    final result = await _forecastRowsFuture;
    if (!mounted) {
      return;
    }
    if (!_canBuildWindMapFromForecastResult(result)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este forecast no tiene datos reutilizables para el mapa de viento.',
          ),
        ),
      );
      return;
    }
    final center = LatLng(
      widget.latitude ?? _avametOlivaStationLat,
      widget.longitude ?? _avametOlivaStationLon,
    );
    final baseRows = _clipForecastRows(
      result.rows,
      provider: _forecastProvider,
      range: _forecastRange,
    );
    final mapResolution = switch (_forecastRange) {
      _ForecastRange.d15 => _ForecastResolution.h6,
      _ => _ForecastResolution.h3,
    };
    final forecastRows = _resampleForecastRows(baseRows, mapResolution);
    final samples = forecastRows
        .map(
          (row) => WindMapSample(
            time: row.slotTime,
            windKnots: row.windKnots,
            windDeg: row.windDeg,
            gustKnots: row.gustKnots,
            waveM: row.waveM,
          ),
        )
        .toList(growable: false);
    var gridSnapshots = const <OpenMeteoWindMapGridSnapshot>[];
    if (_forecastProvider == 'Open-Meteo') {
      try {
        gridSnapshots = await _openMeteoWindMapGridClient.fetchGrid(
          centerLat: center.latitude,
          centerLon: center.longitude,
          model: _forecastModel,
        );
      } catch (_) {
        gridSnapshots = const <OpenMeteoWindMapGridSnapshot>[];
      }
    }

    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WindMapPage(
          spotName: widget.name,
          center: center,
          samples: samples,
          providerLabel: _forecastProvider,
          modelLabel: _forecastModel,
          gridSnapshots: gridSnapshots,
        ),
      ),
    );
  }

  bool _supportsWindMapForCurrentForecastSelection() {
    if (_usesWindguruProvider()) {
      return false;
    }
    if (_usesAemetBeachForecastModel()) {
      return false;
    }
    if (_usesAemetCoastalForecastModel()) {
      return false;
    }
    return true;
  }

  bool _canBuildWindMapFromForecastResult(_ForecastLoadResult result) {
    if (!_supportsWindMapForCurrentForecastSelection()) {
      return false;
    }
    if (result.rows.isEmpty) {
      return false;
    }
    return result.rows.any((row) => row.windKnots > 0);
  }

  Future<void> _showForecastModelInfoDialog() {
    final info = getSpotForecastModelInfo(
      provider: _forecastProvider,
      model: _forecastModel,
    );
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(info.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(info.description),
              const SizedBox(height: AppSpacing.sm),
              Text('Tipo: ${info.scope}'),
              const SizedBox(height: 4),
              Text('Resolucion: ${info.resolution}'),
              const SizedBox(height: 4),
              Text('Horizonte: ${info.horizon}'),
              if (getSpotForecastModelRecommendation(
                    spotName: widget.name,
                    provider: _forecastProvider,
                    model: _forecastModel,
                  )
                  case final recommendation?) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Para ${widget.name}: ${recommendation.badgeLabel}. ${recommendation.message}',
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
