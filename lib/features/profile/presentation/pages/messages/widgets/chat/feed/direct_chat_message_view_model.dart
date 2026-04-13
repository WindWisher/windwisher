import 'package:windwisher/features/profile/domain/entities/direct_chat_message.dart';

class DirectChatMessageViewModel {
  const DirectChatMessageViewModel({
    required this.id,
    required this.content,
    required this.sentAt,
    required this.isMine,
    this.isEdited = false,
    this.type = DirectChatMessageTypeView.text,
    this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.replyToMessageId,
    this.replyToContent,
    this.replyToType,
    this.isReplyToMine,
  });

  factory DirectChatMessageViewModel.fromEntity(DirectChatMessage message) {
    return DirectChatMessageViewModel(
      id: message.id,
      content: message.content,
      sentAt: message.sentAt,
      isMine: message.isMine,
      isEdited: message.isEdited,
      type: switch (message.type) {
        DirectChatMessageType.image => DirectChatMessageTypeView.image,
        DirectChatMessageType.video => DirectChatMessageTypeView.video,
        DirectChatMessageType.text => DirectChatMessageTypeView.text,
      },
      mediaUrl: message.mediaUrl,
      thumbnailUrl: message.thumbnailUrl,
      fileName: message.fileName,
      replyToMessageId: message.replyToMessageId,
      replyToContent: message.replyToContent,
      replyToType: switch (message.replyToType) {
        DirectChatMessageType.image => DirectChatMessageTypeView.image,
        DirectChatMessageType.video => DirectChatMessageTypeView.video,
        DirectChatMessageType.text => DirectChatMessageTypeView.text,
        null => null,
      },
      isReplyToMine: message.isReplyToMine,
    );
  }

  final String id;
  final String content;
  final DateTime sentAt;
  final bool isMine;
  final bool isEdited;
  final DirectChatMessageTypeView type;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final String? replyToMessageId;
  final String? replyToContent;
  final DirectChatMessageTypeView? replyToType;
  final bool? isReplyToMine;

  DirectChatMessageViewModel copyWith({
    String? replyToMessageId,
    String? replyToContent,
    DirectChatMessageTypeView? replyToType,
    bool? isReplyToMine,
  }) {
    return DirectChatMessageViewModel(
      id: id,
      content: content,
      sentAt: sentAt,
      isMine: isMine,
      isEdited: isEdited,
      type: type,
      mediaUrl: mediaUrl,
      thumbnailUrl: thumbnailUrl,
      fileName: fileName,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      replyToContent: replyToContent ?? this.replyToContent,
      replyToType: replyToType ?? this.replyToType,
      isReplyToMine: isReplyToMine ?? this.isReplyToMine,
    );
  }
}

enum DirectChatMessageTypeView { text, image, video }
