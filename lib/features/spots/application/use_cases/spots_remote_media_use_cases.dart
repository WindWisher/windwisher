import 'package:windwisher/features/spots/domain/entities/spot_webcam.dart';
import 'package:windwisher/features/spots/domain/ports/out/spots_remote_media_port.dart';

class GetSpotWebcamsUseCase {
  const GetSpotWebcamsUseCase(this._port);

  final SpotsRemoteMediaPort _port;

  List<SpotWebcam> call({required String spotName, required bool isCustom}) {
    return _port.getWebcamsForSpot(spotName: spotName, isCustom: isCustom);
  }
}

class GetWebcamReferencePagesUseCase {
  const GetWebcamReferencePagesUseCase(this._port);

  final SpotsRemoteMediaPort _port;

  List<WebcamReferencePage> call(String webcamName) {
    return _port.getRelatedPagesForWebcam(webcamName);
  }
}
