import 'package:windwisher/features/spots/application/services/spot_social_service.dart';

class SpotChatPostSubmission {
  const SpotChatPostSubmission({
    required this.text,
    required this.attachments,
    required this.tempId,
    this.editingPostId,
  });

  final String text;
  final List<SpotSocialAttachmentDraft> attachments;
  final String tempId;
  final String? editingPostId;

  bool get isEditing => editingPostId != null;
}

class SpotChatReplySubmission {
  const SpotChatReplySubmission({
    required this.text,
    required this.attachments,
    required this.tempId,
    required this.postId,
    this.parentReplyId,
    this.editingReplyId,
  });

  final String text;
  final List<SpotSocialAttachmentDraft> attachments;
  final String tempId;
  final String postId;
  final String? parentReplyId;
  final String? editingReplyId;

  bool get isEditing => editingReplyId != null;
}

SpotChatPostSubmission? buildSpotChatPostSubmission({
  required String text,
  required List<SpotSocialAttachmentDraft> attachments,
  required bool isSubmitting,
  required String? editingPostId,
}) {
  final trimmedText = text.trim();
  if ((trimmedText.isEmpty && attachments.isEmpty) || isSubmitting) {
    return null;
  }
  return SpotChatPostSubmission(
    text: trimmedText,
    attachments: List<SpotSocialAttachmentDraft>.from(attachments),
    tempId: _spotChatTempId('post'),
    editingPostId: editingPostId,
  );
}

SpotChatReplySubmission? buildSpotChatReplySubmission({
  required String text,
  required List<SpotSocialAttachmentDraft> attachments,
  required bool isSubmitting,
  required String? replyingPostId,
  required String? replyingReplyId,
  required String? editingReplyId,
  required String? editingReplyPostId,
}) {
  final trimmedText = text.trim();
  final postId = editingReplyId != null ? editingReplyPostId : replyingPostId;
  if ((trimmedText.isEmpty && attachments.isEmpty) ||
      postId == null ||
      isSubmitting) {
    return null;
  }
  return SpotChatReplySubmission(
    text: trimmedText,
    attachments: List<SpotSocialAttachmentDraft>.from(attachments),
    tempId: _spotChatTempId('reply'),
    postId: postId,
    parentReplyId: replyingReplyId,
    editingReplyId: editingReplyId,
  );
}

String _spotChatTempId(String type) {
  return 'local-$type-${DateTime.now().microsecondsSinceEpoch}';
}
