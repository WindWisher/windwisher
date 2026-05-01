import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SpotChatAttachmentSelection {
  const SpotChatAttachmentSelection({
    required this.isVideo,
    required this.source,
  });

  final bool isVideo;
  final ImageSource source;
}

Future<ImageSource?> showSpotChatAttachmentSourceSheet(BuildContext context) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_a_photo_rounded),
              title: const Text('Tomar foto o video'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.perm_media_rounded),
              title: const Text('Adjuntar foto o video desde la galeria'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      );
    },
  );
}

Future<SpotChatAttachmentSelection?> showSpotChatCameraCaptureTypeSheet(
  BuildContext context,
) {
  return showModalBottomSheet<SpotChatAttachmentSelection>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_back_rounded),
              title: const Text('Foto'),
              onTap: () => Navigator.of(sheetContext).pop(
                const SpotChatAttachmentSelection(
                  isVideo: false,
                  source: ImageSource.camera,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.video_call_rounded),
              title: const Text('Video'),
              onTap: () => Navigator.of(sheetContext).pop(
                const SpotChatAttachmentSelection(
                  isVideo: true,
                  source: ImageSource.camera,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
