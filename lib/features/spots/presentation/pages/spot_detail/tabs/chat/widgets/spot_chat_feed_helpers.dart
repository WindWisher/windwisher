import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/spots/domain/entities/spot_social_post.dart';
import 'package:windwisher/features/spots/application/services/spot_social_service.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/chat/widgets/spot_chat_attachment_helpers.dart';

String normalizedSpotChatUsername(UserProfileData profile) {
  final handle = profile.handle.trim().replaceFirst('@', '');
  if (handle.isNotEmpty) {
    return handle;
  }
  final displayName = profile.displayName.trim();
  if (displayName.isNotEmpty) {
    return displayName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
  }
  return 'rider';
}

String spotChatDisplayName(UserProfileData profile) {
  final displayName = profile.displayName.trim();
  if (displayName.isNotEmpty) {
    return displayName;
  }
  final username = normalizedSpotChatUsername(profile);
  if (username.isEmpty) {
    return 'Rider';
  }
  return username
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

SpotSocialPost optimisticSpotChatPost({
  required String tempId,
  required String spotName,
  required String spotArea,
  required UserProfileData profile,
  required String message,
  required List<SpotSocialAttachmentDraft> attachments,
}) {
  final now = DateTime.now();
  return SpotSocialPost(
    id: tempId,
    spotName: spotName,
    spotArea: spotArea,
    authorUsername: normalizedSpotChatUsername(profile),
    authorDisplayName: spotChatDisplayName(profile),
    message: message,
    createdAt: now,
    updatedAt: now,
    isMine: true,
    attachments: optimisticSpotChatAttachments(attachments),
    replies: const <SpotSocialReply>[],
  );
}

SpotSocialReply optimisticSpotChatReply({
  required String tempId,
  required String postId,
  required String? parentReplyId,
  required UserProfileData profile,
  required String message,
  required List<SpotSocialAttachmentDraft> attachments,
}) {
  return SpotSocialReply(
    id: tempId,
    postId: postId,
    parentReplyId: parentReplyId,
    authorUsername: normalizedSpotChatUsername(profile),
    authorDisplayName: spotChatDisplayName(profile),
    message: message,
    createdAt: DateTime.now(),
    isMine: true,
    attachments: optimisticSpotChatAttachments(attachments),
    replies: const <SpotSocialReply>[],
  );
}

List<SpotSocialPost> appendOptimisticSpotChatReply({
  required List<SpotSocialPost> feed,
  required String postId,
  required String? parentReplyId,
  required SpotSocialReply reply,
}) {
  return feed
      .map((post) {
        if (post.id != postId) {
          return post;
        }
        final nextReplies = List<SpotSocialReply>.from(post.replies);
        if (parentReplyId == null || parentReplyId.isEmpty) {
          nextReplies.add(reply);
        } else {
          appendOptimisticNestedSpotChatReply(
            replies: nextReplies,
            parentReplyId: parentReplyId,
            reply: reply,
          );
        }
        return post.copyWith(replies: nextReplies);
      })
      .toList(growable: false);
}

bool appendOptimisticNestedSpotChatReply({
  required List<SpotSocialReply> replies,
  required String parentReplyId,
  required SpotSocialReply reply,
}) {
  for (var index = 0; index < replies.length; index += 1) {
    final current = replies[index];
    if (current.id == parentReplyId) {
      final children = List<SpotSocialReply>.from(current.replies)..add(reply);
      replies[index] = current.copyWith(replies: children);
      return true;
    }
    final children = List<SpotSocialReply>.from(current.replies);
    if (appendOptimisticNestedSpotChatReply(
      replies: children,
      parentReplyId: parentReplyId,
      reply: reply,
    )) {
      replies[index] = current.copyWith(replies: children);
      return true;
    }
  }
  return false;
}

SpotSocialPost? findSpotChatPostById(List<SpotSocialPost> feed, String postId) {
  for (final post in feed) {
    if (post.id == postId) {
      return post;
    }
  }
  return null;
}

SpotSocialReply? findSpotChatReplyById(
  List<SpotSocialPost> feed,
  String replyId,
) {
  SpotSocialReply? search(List<SpotSocialReply> replies) {
    for (final reply in replies) {
      if (reply.id == replyId) {
        return reply;
      }
      final nested = search(reply.replies);
      if (nested != null) {
        return nested;
      }
    }
    return null;
  }

  for (final post in feed) {
    final found = search(post.replies);
    if (found != null) {
      return found;
    }
  }
  return null;
}
