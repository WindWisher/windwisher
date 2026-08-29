import 'dart:typed_data';

import 'package:windwisher/features/spots/domain/entities/spot_social_post.dart';

class SpotSocialAttachmentDraft {
  const SpotSocialAttachmentDraft({
    required this.type,
    required this.fileName,
    required this.bytes,
    this.mimeType,
    this.thumbnailBytes,
    this.thumbnailMimeType,
  });

  final SpotSocialAttachmentType type;
  final String fileName;
  final Uint8List bytes;
  final String? mimeType;
  final Uint8List? thumbnailBytes;
  final String? thumbnailMimeType;
}

abstract interface class SpotSocialService {
  bool get requiresAuthenticatedWrites;
  bool get canWrite;

  Stream<void> watchSpotFeed({
    required String spotName,
    required String spotArea,
  });

  Stream<int> watchSpotPresence({
    required String spotName,
    required String spotArea,
  });

  Stream<Set<String>> watchSpotTyping({
    required String spotName,
    required String spotArea,
  });

  Future<void> sendTypingState({
    required String spotName,
    required String spotArea,
    required String displayName,
    required bool isTyping,
  });

  Future<List<SpotSocialPost>> loadPosts({
    required String spotName,
    required String spotArea,
  });

  Future<SpotSocialPost> addPost({
    required String spotName,
    required String spotArea,
    required String authorUsername,
    required String authorDisplayName,
    required String message,
    List<SpotSocialAttachmentDraft> attachments = const [],
  });

  Future<SpotSocialReply> addReply({
    required String postId,
    required String authorUsername,
    required String authorDisplayName,
    required String message,
    String? parentReplyId,
    List<SpotSocialAttachmentDraft> attachments = const [],
  });

  Future<SpotSocialPost> updatePost({
    required String postId,
    required String message,
  });

  Future<SpotSocialReply> updateReply({
    required String replyId,
    required String message,
  });

  Future<void> deletePost({required String postId});
  Future<void> deleteReply({required String replyId});
}

String buildSpotSocialKey({
  required String spotName,
  required String spotArea,
}) {
  return '${spotName.trim().toLowerCase()}::${spotArea.trim().toLowerCase()}';
}
