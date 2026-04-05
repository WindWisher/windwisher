import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class StartSessionMediaLogic {
  const StartSessionMediaLogic._();

  static String labelForSelection(SessionMediaSelection selection) {
    return switch (selection) {
      SessionMediaSelection.none => 'Pantallazo del mapa del spot',
      SessionMediaSelection.camera => 'Foto tomada con cámara',
      SessionMediaSelection.gallery => 'Foto elegida de galería',
    };
  }

  static SessionMediaSelection selectionForStoredSession({
    required String sessionMediaLabel,
    required String? sessionPhotoLocalPath,
  }) {
    if (sessionPhotoLocalPath == null) {
      return SessionMediaSelection.none;
    }
    return sessionMediaLabel.toLowerCase().contains('camara')
        ? SessionMediaSelection.camera
        : SessionMediaSelection.gallery;
  }

  static Future<String?> pickAndStoreSessionMedia(
    SessionMediaSelection selection, {
    required ImagePicker imagePicker,
  }) async {
    if (selection == SessionMediaSelection.none) {
      return null;
    }

    final picked = await imagePicker.pickImage(
      source: selection == SessionMediaSelection.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 88,
    );

    if (picked == null) {
      return null;
    }

    return storeSessionMedia(picked);
  }

  static Future<String> storeSessionMedia(XFile file) async {
    final appDir = await getApplicationDocumentsDirectory();
    final mediaDir = Directory(
      '${appDir.path}${Platform.pathSeparator}session_media',
    );
    if (!await mediaDir.exists()) {
      await mediaDir.create(recursive: true);
    }

    final dot = file.path.lastIndexOf('.');
    final extension = (dot < 0 || dot == file.path.length - 1)
        ? ''
        : file.path.substring(dot);
    final output = File(
      '${mediaDir.path}${Platform.pathSeparator}session_${DateTime.now().millisecondsSinceEpoch}$extension',
    );
    await output.writeAsBytes(await file.readAsBytes(), flush: true);
    return output.path;
  }

  static bool isMissingPluginError(Object error) {
    return error is MissingPluginException;
  }
}
