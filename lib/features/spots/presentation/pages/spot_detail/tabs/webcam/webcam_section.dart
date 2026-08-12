part of '../../spot_detail_page.dart';

extension _SpotDetailWebcamSection on _SpotDetailPageState {
  Widget _buildWebcamSection(TextTheme textTheme) {
    final webcams = _webcamsForSpot();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              webcams.length == 1 ? 'Webcam principal' : 'Webcams disponibles',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('${widget.name} · ${widget.area}', style: textTheme.bodySmall),
            const SizedBox(height: AppSpacing.sm),
            if (webcams.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'No hay webcams disponibles para este spot por ahora.',
                  style: textTheme.bodyMedium,
                ),
              )
            else
              ...webcams.map(
                (webcam) => Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: ListTile(
                    title: Text(webcam.name),
                    subtitle: Text(_webcamSubtitle(webcam)),
                    trailing: FilledButton.icon(
                      onPressed: () => _openWebcam(webcam),
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Abrir'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _webcamSubtitle(_SpotWebcam webcam) {
    final distanceKm = widget.latitude != null && widget.longitude != null
        ? _webcamDistanceKm(webcam, widget.latitude!, widget.longitude!)
        : null;
    final parts = <String>[
      if (webcam.locationLabel != null && webcam.locationLabel!.isNotEmpty)
        webcam.locationLabel!,
      if (distanceKm != null)
        AppUnitsController.instance.formatDistance(distanceKm),
      webcam.source,
    ];
    if (parts.isNotEmpty) {
      return parts.join(' · ');
    }
    return webcam.summary ??
        '${webcam.source} · ${webcam.resolution} · ${webcam.status}';
  }

  List<_SpotWebcam> _webcamsForSpot() {
    final webcams = _spotsModule.getSpotWebcams(
      spotName: widget.name,
      isCustom: widget.isCustom,
    );
    final spotLat = widget.latitude;
    final spotLon = widget.longitude;
    if (spotLat == null || spotLon == null) {
      return webcams;
    }
    final sorted = List<_SpotWebcam>.from(webcams);
    sorted.sort((a, b) {
      final aDistance = _webcamDistanceKm(a, spotLat, spotLon);
      final bDistance = _webcamDistanceKm(b, spotLat, spotLon);
      if (aDistance == null && bDistance == null) {
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (aDistance == null) return 1;
      if (bDistance == null) return -1;
      final distanceCompare = aDistance.compareTo(bDistance);
      if (distanceCompare != 0) {
        return distanceCompare;
      }
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });
    return sorted;
  }

  double? _webcamDistanceKm(
    _SpotWebcam webcam,
    double spotLat,
    double spotLon,
  ) {
    final webcamLat = webcam.latitude;
    final webcamLon = webcam.longitude;
    if (webcamLat == null || webcamLon == null) {
      return null;
    }
    return _distanceKm(
      latitudeA: spotLat,
      longitudeA: spotLon,
      latitudeB: webcamLat,
      longitudeB: webcamLon,
    );
  }

  void _openWebcam(_SpotWebcam webcam) {
    final relatedPages = _spotsModule.getWebcamReferencePages(webcam.name);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WebcamPlayerPage(
          webcamName: webcam.name,
          source: webcam.source,
          status: webcam.status,
          resolution: webcam.resolution,
          primaryPageUrl: webcam.primaryPageUrl,
          summary: webcam.summary,
          streamManifestUrl: webcam.streamManifestUrl,
          previewImageUrl: webcam.previewImageUrl,
          embedAsIframe: webcam.embedAsIframe,
          focusIframeUrlContains: webcam.focusIframeUrlContains,
          relatedPages: relatedPages,
        ),
      ),
    );
  }
}
