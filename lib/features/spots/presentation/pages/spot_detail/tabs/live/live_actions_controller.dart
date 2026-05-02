// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailLiveActionsController on _SpotDetailPageState {
  void _handleHistoryRangeChanged(_HistoryRange value) {
    setState(() {
      _historyRange = value;
    });
  }

  void _handleHistoricalBucketOptionChanged(_HistoricalBucketOption value) {
    setState(() {
      _setSelectedBucketOption(value);
    });
  }

  void _handleWindSpeedUnitChanged(_WindSpeedUnit value) {
    setState(() {
      _windSpeedUnit = value;
    });
  }

  Future<void> _toggleRealtimeCompass() async {
    if (_compassOverlayMode == _CompassOverlayMode.realtime) {
      if (!mounted) return;
      setState(() {
        _compassOverlayMode = _CompassOverlayMode.off;
      });
      return;
    }
    if (kIsWeb) {
      final granted = await ensureWebCompassPermission();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Brujula no disponible. Revisa permisos/sensor.'),
          ),
        );
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _compassOverlayMode = _CompassOverlayMode.realtime;
    });
  }
}
