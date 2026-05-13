// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailForecastFullscreenSection on _SpotDetailPageState {
  Widget _buildForecastTableTitle() {
    final modelLabel = _usesWindguruProvider() ? 'Windguru' : _forecastModel;
    return Text(
      'Tabla Forecast ($modelLabel)',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }

  Widget _buildExpandedForecastOverlay(_ForecastLoadResult result) {
    final orientation = MediaQuery.orientationOf(context);
    final isLandscape = orientation == Orientation.landscape;
    final baseRows = _clipForecastRows(
      result.rows,
      provider: _forecastProvider,
      range: _forecastRange,
    );
    final forecastRows = _resampleForecastRows(baseRows, _forecastResolution);

    return Positioned.fill(
      child: Stack(
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final usableMainAxis = isLandscape
                    ? constraints.maxHeight
                    : constraints.maxWidth;
                final fullscreenRowHeight = math.max(24.0, usableMainAxis / 10);
                final forecastTable = _buildWindguruStyleTable(
                  rowsOverride: forecastRows,
                  selectedRange: _forecastRange,
                  showRangeSelector: false,
                  showResolutionSelector: false,
                  showFullscreenButton: false,
                  expandToFill: true,
                  fullscreenRowHeight: fullscreenRowHeight,
                  fullscreenResolution: _forecastResolution,
                );
                final content = isLandscape
                    ? SizedBox(
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                        child: forecastTable,
                      )
                    : SizedBox(
                        width: constraints.maxHeight,
                        height: constraints.maxWidth,
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: forecastTable,
                        ),
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
                  heroTag: 'forecastFullscreenClose',
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

  Widget _buildExpandedWindguruOverlay() {
    final isSupported = !_SpotDetailPageState._isFlutterTest;
    return WindguruFullscreenOverlay(
      controller: _windguruFullscreenController,
      webEmbedHtml: kIsWeb ? _windguruWidgetHtmlForSpot(widget.name) : null,
      isSupported: isSupported,
      unsupportedMessage: 'Windguru no disponible en este dispositivo.',
      onClose: () {
        setState(() {
          _fullscreenMode = _ForecastFullscreenMode.none;
        });
      },
    );
  }
}
