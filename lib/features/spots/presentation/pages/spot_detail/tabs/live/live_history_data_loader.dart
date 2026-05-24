part of '../../spot_detail_page.dart';

extension _SpotDetailLiveHistoryDataLoader on _SpotDetailPageState {
  Future<List<_HistoricalWindPoint>?> _fetchHistoricalDataForStation(
    _NearbyStation station,
  ) async {
    if (station.provider == 'AVAMET') {
      final stationId = station.stationId;
      if (stationId == null) {
        return null;
      }
      final intradayHistory = await _avametIntradayHistoryClient
          .fetchIntradayWindHistory(stationId: stationId);
      final refreshedHistory = intradayHistory
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);

      if (refreshedHistory.isNotEmpty) {
        return refreshedHistory;
      }

      final dailyHistory = await _avametDailyHistoryClient
          .fetchDailyWindHistory(stationId: stationId);
      return dailyHistory
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
            ),
          )
          .toList(growable: false);
    }

    if (station.provider == 'INFORATGE') {
      final feed = await _inforatgeOlivaNovaClient.fetchFeed(
        stationCode: _inforatgeStationCodeFor(station.stationId),
        liveUrl: _inforatgeLiveUrlFor(station.stationId),
        historyUrl: _inforatgeHistoryUrlFor(station.stationId),
      );
      return feed.points
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    }

    if (station.provider == 'AIGUABLANCA') {
      final feed = await _aiguaBlancaMeteoClient.fetchFeed();
      return feed.points
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              gustKnots: point.gustKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    }

    if (station.provider == 'PUERTOS') {
      final stationId = int.tryParse(station.stationId ?? '');
      if (stationId == null) {
        return null;
      }
      final history = await _portusRealtimeWindClient.fetchWindHistory(
        stationId: stationId,
      );
      return history
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              gustKnots: point.gustKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    }

    if (station.provider == 'METEOPILES') {
      return _fetchBackendCollectedLiveHistory(station);
    }

    if (station.provider == 'METEOCLIMATIC') {
      return _fetchBackendCollectedLiveHistory(station);
    }

    if (station.provider == 'WINDGURU_STATION') {
      return _fetchBackendCollectedLiveHistory(station);
    }

    if (station.provider == 'WEATHERCLOUD') {
      return _fetchBackendCollectedLiveHistory(station);
    }

    if (station.provider == 'WUNDERGROUND') {
      final stationId = station.stationId;
      if (stationId == null) {
        return null;
      }
      final history = await _wundergroundPwsClient.fetchOneDayHistory(
        stationId: stationId,
      );
      return history
          .map(
            (point) => _HistoricalWindPoint(
              time: point.time,
              windKnots: point.windKnots,
              gustKnots: point.gustKnots,
              windDirectionDeg: point.windDirectionDeg,
              directionKind: point.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    }

    if (station.provider == 'MADIS_MARITIME' ||
        station.provider == 'COPERNICUS_MARINE') {
      return _fetchMaritimeObservationHistory(station);
    }

    if (station.provider == 'AEMET' && station.stationId != null) {
      final observationSeries = await _aemetObservationClient
          .fetchStationObservations(
            stationId: station.stationId!,
            referenceLatitude: station.latitude,
            referenceLongitude: station.longitude,
          );
      return observationSeries
          .where((snapshot) => snapshot.observedAt != null)
          .map(
            (snapshot) => _HistoricalWindPoint(
              time: snapshot.observedAt!,
              windKnots: snapshot.windKnots ?? 0,
              gustKnots: snapshot.gustKnots,
              windDirectionDeg: snapshot.windDirectionDeg,
              directionKind: snapshot.windDirectionDeg == null
                  ? null
                  : _HistoricalDirectionKind.exact,
            ),
          )
          .toList(growable: false);
    }

    return null;
  }

  Future<List<_HistoricalWindPoint>> _fetchBackendCollectedLiveHistory(
    _NearbyStation station,
  ) async {
    final client = _spotLiveObservationHistoryClient;
    if (client == null) {
      return const <_HistoricalWindPoint>[];
    }
    final history = await client.fetchStationHistory(
      stationKey: station.stationKey,
      range: const Duration(hours: 72),
    );
    final mappedHistory = history
        .where((point) => point.windKnots != null)
        .map(
          (point) => _HistoricalWindPoint(
            time: point.observedAt,
            windKnots: point.windKnots!,
            gustKnots: point.gustKnots,
            windDirectionDeg: point.windDirectionDeg,
            directionKind: point.windDirectionDeg == null
                ? null
                : _HistoricalDirectionKind.exact,
          ),
        )
        .toList(growable: false);
    debugPrint(
      'LiveStationTiming phase=backend-history stationKey=${station.stationKey} '
      'provider=${station.provider} rawPoints=${history.length} '
      'windPoints=${mappedHistory.length}',
    );
    return mappedHistory;
  }

  Future<List<_HistoricalWindPoint>> _fetchMaritimeObservationHistory(
    _NearbyStation station,
  ) async {
    final client = _spotMaritimeObservationsClient;
    if (client == null) {
      return const <_HistoricalWindPoint>[];
    }
    final history = await client.fetchHistory(
      spotName: widget.name,
      stationKey: station.stationKey,
      range: const Duration(hours: 72),
    );
    return history
        .where((point) => point.windKnots != null)
        .map(
          (point) => _HistoricalWindPoint(
            time: point.observedAt,
            windKnots: point.windKnots!,
            gustKnots: point.gustKnots,
            windDirectionDeg: point.windDirectionDeg,
            directionKind: point.windDirectionDeg == null
                ? null
                : _HistoricalDirectionKind.exact,
          ),
        )
        .toList(growable: false);
  }
}
