// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveStationActions on _SpotDetailPageState {
  Future<void> _checkAemetOlivaStation(_NearbyStation station) async {
    if (!_isOlivaAemetOfficialStation(station)) {
      return;
    }
    setState(() {
      _isLiveRefreshing = true;
    });
    try {
      final refreshed = await _fetchLiveDataForStation(station);
      if (!mounted) {
        return;
      }
      if (refreshed == null) {
        _showLiveRefreshFeedback(
          'AEMET Oliva no ha devuelto datos live ahora mismo.',
        );
        return;
      }
      setState(() {
        final current = _liveStationsLoadResult;
        if (current == null) {
          return;
        }
        final updatedLiveData = Map<String, _StationLiveData>.from(
          current.liveDataByStation,
        );
        updatedLiveData[_stationKey(station)] = refreshed;
        _liveStationsLoadResult = _LiveStationsLoadResult(
          stations: current.stations,
          liveDataByStation: updatedLiveData,
          historicalSeriesByStation: current.historicalSeriesByStation,
          source: current.source,
          message: current.message,
          technicalError: current.technicalError,
        );
      });
      _showLiveRefreshFeedback(_formatAemetOlivaCheckMessage(refreshed));
    } catch (error) {
      if (!mounted) {
        return;
      }
      _showLiveRefreshFeedback('No se pudo chequear AEMET Oliva: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLiveRefreshing = false;
        });
      }
    }
  }

  String _formatAemetOlivaCheckMessage(_StationLiveData liveData) {
    final observedAt = liveData.observedAt == null
        ? 'sin hora'
        : _formatObservedAt(liveData.observedAt!);
    final wind = _formatWind(liveData.windKnots);
    final direction = liveData.windDeg == null
        ? ''
        : ' · dir ${liveData.windDeg}';
    final gust = liveData.gustKnots == null
        ? ''
        : ' · racha ${_formatWind(liveData.gustKnots)}';
    return 'AEMET Oliva OK · $observedAt · $wind$direction$gust';
  }

  Future<void> _showLiveStationMapDialog(_NearbyStation station) async {
    final latLng = LatLng(station.latitude, station.longitude);
    final screenSize = MediaQuery.sizeOf(context);
    final dialogWidth = math.min(screenSize.width * 0.94, 720.0);
    final mapHeight = math.min(screenSize.height * 0.55, 460.0);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: SizedBox(
            width: dialogWidth,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estacion · ${station.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: mapHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: latLng,
                            initialZoom: 12,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.windwisher.app',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: latLng,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.red,
                                    size: 36,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${station.latitude.toStringAsFixed(4)}, ${station.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
