import 'package:image_picker/image_picker.dart';
import 'package:windwisher/features/spots/domain/entities/spot_social_post.dart';
import 'package:windwisher/features/spots/infrastructure/services/spot_social_client.dart';

String spotChatAttachmentFileName(XFile file) {
  final name = file.name.trim();
  if (name.isNotEmpty) {
    return name;
  }
  final path = file.path;
  if (path.isEmpty) {
    return 'adjunto';
  }
  return path.split(RegExp(r'[\\/]')).last;
}

String spotChatAttachmentMimeType({
  required bool isVideo,
  required String fileName,
}) {
  final lower = fileName.toLowerCase();
  if (isVideo) {
    if (lower.endsWith('.mov')) return 'video/quicktime';
    if (lower.endsWith('.webm')) return 'video/webm';
    return 'video/mp4';
  }
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  return 'image/jpeg';
}

bool isSpotChatVideoFileName(String fileName) {
  final lower = fileName.toLowerCase();
  return lower.endsWith('.mp4') ||
      lower.endsWith('.mov') ||
      lower.endsWith('.webm') ||
      lower.endsWith('.m4v') ||
      lower.endsWith('.avi') ||
      lower.endsWith('.mkv');
}

Future<SpotSocialAttachmentDraft> spotChatAttachmentDraftFromPickedFile(
  XFile file, {
  required bool isVideo,
}) async {
  final fileName = spotChatAttachmentFileName(file);
  return SpotSocialAttachmentDraft(
    type: isVideo
        ? SpotSocialAttachmentType.video
        : SpotSocialAttachmentType.image,
    fileName: fileName,
    bytes: await file.readAsBytes(),
    mimeType: spotChatAttachmentMimeType(isVideo: isVideo, fileName: fileName),
  );
}

Future<SpotSocialAttachmentDraft> spotChatAttachmentDraftFromPickedMedia(
  XFile file,
) {
  final fileName = spotChatAttachmentFileName(file);
  return spotChatAttachmentDraftFromPickedFile(
    file,
    isVideo: isSpotChatVideoFileName(fileName),
  );
}

List<SpotSocialAttachmentDraft> appendPendingSpotChatAttachment(
  List<SpotSocialAttachmentDraft> attachments,
  SpotSocialAttachmentDraft draft,
) {
  return [...attachments, draft];
}

List<SpotSocialAttachmentDraft> removePendingSpotChatAttachmentAt(
  List<SpotSocialAttachmentDraft> attachments,
  int index,
) {
  if (index < 0 || index >= attachments.length) {
    return attachments;
  }
  final next = List<SpotSocialAttachmentDraft>.from(attachments)
    ..removeAt(index);
  return next;
}

List<SpotSocialAttachment> optimisticSpotChatAttachments(
  List<SpotSocialAttachmentDraft> drafts,
) {
  final createdAt = DateTime.now().microsecondsSinceEpoch;
  return [
    for (var index = 0; index < drafts.length; index += 1)
      SpotSocialAttachment(
        id: 'local-$createdAt-$index-${drafts[index].fileName}',
        type: drafts[index].type,
        url: '',
        storagePath: drafts[index].fileName,
        fileName: drafts[index].fileName,
        mimeType: drafts[index].mimeType,
        sizeBytes: drafts[index].bytes.length,
      ),
  ];
}
