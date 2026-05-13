import 'package:windwisher/features/spots/domain/entities/spot_social_post.dart';

class SpotChatEntry {
  const SpotChatEntry._({
    required this.id,
    required this.postId,
    required this.authorUsername,
    required this.authorDisplayName,
    this.authorAvatarPath,
    required this.message,
    required this.createdAt,
    required this.isMine,
    required this.attachments,
    required this.replyCount,
    required this.isReply,
    this.parentAuthor,
    this.parentMessage,
  });

  factory SpotChatEntry.post({
    required String id,
    required String authorUsername,
    required String authorDisplayName,
    String? authorAvatarPath,
    required String message,
    required DateTime createdAt,
    required bool isMine,
    required List<SpotSocialAttachment> attachments,
    required int replyCount,
  }) {
    return SpotChatEntry._(
      id: id,
      postId: id,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      authorAvatarPath: authorAvatarPath,
      message: message,
      createdAt: createdAt,
      isMine: isMine,
      attachments: attachments,
      replyCount: replyCount,
      isReply: false,
    );
  }

  factory SpotChatEntry.reply({
    required String id,
    required String postId,
    required String authorUsername,
    required String authorDisplayName,
    String? authorAvatarPath,
    required String message,
    required DateTime createdAt,
    required bool isMine,
    required List<SpotSocialAttachment> attachments,
    required int replyCount,
    required String parentAuthor,
    required String parentMessage,
  }) {
    return SpotChatEntry._(
      id: id,
      postId: postId,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      authorAvatarPath: authorAvatarPath,
      message: message,
      createdAt: createdAt,
      isMine: isMine,
      attachments: attachments,
      replyCount: replyCount,
      isReply: true,
      parentAuthor: parentAuthor,
      parentMessage: parentMessage,
    );
  }

  final String id;
  final String postId;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarPath;
  final String message;
  final DateTime createdAt;
  final bool isMine;
  final List<SpotSocialAttachment> attachments;
  final int replyCount;
  final bool isReply;
  final String? parentAuthor;
  final String? parentMessage;
}

List<SpotChatEntry> buildSpotChatEntries(List<SpotSocialPost> feed) {
  final entries = <SpotChatEntry>[];
  for (final post in feed) {
    entries.add(
      SpotChatEntry.post(
        id: post.id,
        authorUsername: post.authorUsername,
        authorDisplayName: post.authorDisplayName,
        authorAvatarPath: post.authorAvatarPath,
        message: post.message,
        createdAt: post.createdAt,
        isMine: post.isMine,
        attachments: post.attachments,
        replyCount: _countRepliesCascade(post.replies),
      ),
    );
    _appendReplyEntries(
      target: entries,
      postId: post.id,
      replies: post.replies,
      parentAuthor: post.authorDisplayName,
      parentMessage: post.message,
    );
  }
  entries.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return entries;
}

int _countRepliesCascade(List<SpotSocialReply> replies) {
  var count = 0;
  for (final reply in replies) {
    count += 1;
    count += _countRepliesCascade(reply.replies);
  }
  return count;
}

void _appendReplyEntries({
  required List<SpotChatEntry> target,
  required String postId,
  required List<SpotSocialReply> replies,
  required String parentAuthor,
  required String parentMessage,
}) {
  for (final reply in replies) {
    target.add(
      SpotChatEntry.reply(
        id: reply.id,
        postId: postId,
        authorUsername: reply.authorUsername,
        authorDisplayName: reply.authorDisplayName,
        authorAvatarPath: reply.authorAvatarPath,
        message: reply.message,
        createdAt: reply.createdAt,
        isMine: reply.isMine,
        attachments: reply.attachments,
        replyCount: _countRepliesCascade(reply.replies),
        parentAuthor: parentAuthor,
        parentMessage: parentMessage,
      ),
    );
    _appendReplyEntries(
      target: target,
      postId: postId,
      replies: reply.replies,
      parentAuthor: reply.authorDisplayName,
      parentMessage: reply.message,
    );
  }
}
