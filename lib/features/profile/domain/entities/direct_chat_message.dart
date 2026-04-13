enum DirectChatMessageType { text, image, video }

class DirectChatMessage {
  const DirectChatMessage({
    required this.id,
    required this.threadId,
    required this.content,
    required this.sentAt,
    required this.isMine,
    this.type = DirectChatMessageType.text,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.mimeType,
    this.isEdited = false,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToType,
    this.isReplyToMine,
  });

  final String id;
  final String threadId;
  final String content;
  final DateTime sentAt;
  final bool isMine;
  final DirectChatMessageType type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final String? mimeType;
  final bool isEdited;
  final String? replyToMessageId;
  final String? replyToContent;
  final DirectChatMessageType? replyToType;
  final bool? isReplyToMine;
}
