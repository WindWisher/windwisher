import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';

abstract class SpotsRemoteMediaPort {
  List<SpotWebcam> getWebcamsForSpot({
    required String spotName,
    required bool isCustom,
  });

  List<WebcamReferencePage> getRelatedPagesForWebcam(String webcamName);
}
