class SpotWebcam {
  const SpotWebcam({
    required this.name,
    required this.source,
    required this.status,
    required this.resolution,
    this.primaryPageUrl,
    this.summary,
    this.streamManifestUrl,
    this.previewImageUrl,
    this.locationLabel,
    this.latitude,
    this.longitude,
  });

  final String name;
  final String source;
  final String status;
  final String resolution;
  final String? primaryPageUrl;
  final String? summary;
  final String? streamManifestUrl;
  final String? previewImageUrl;
  final String? locationLabel;
  final double? latitude;
  final double? longitude;
}

class WebcamReferencePage {
  const WebcamReferencePage({required this.title, required this.url});

  final String title;
  final String url;
}
