import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_message_view_model.dart';

String directChatMimeTypeForFile(String name, {required bool isVideo}) {
  final lower = name.toLowerCase();
  if (isVideo) {
    if (lower.endsWith('.mov')) {
      return 'video/quicktime';
    }
    if (lower.endsWith('.m4v')) {
      return 'video/x-m4v';
    }
    if (lower.endsWith('.webm')) {
      return 'video/webm';
    }
    return 'video/mp4';
  }
  if (lower.endsWith('.png')) {
    return 'image/png';
  }
  if (lower.endsWith('.webp')) {
    return 'image/webp';
  }
  if (lower.endsWith('.gif')) {
    return 'image/gif';
  }
  return 'image/jpeg';
}

String formatDirectChatHour(DateTime timestamp) {
  final h = timestamp.hour.toString().padLeft(2, '0');
  final m = timestamp.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String directChatParticipantInitials(String participant) {
  final parts = participant
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return 'U';
  }
  if (parts.length == 1) {
    return _firstGraphemeUpper(parts.first);
  }
  return '${_firstGraphemeUpper(parts.first)}${_firstGraphemeUpper(parts.last)}';
}

DirectChatMessageViewModel? resolveReplyingMessage(
  List<DirectChatMessageViewModel> messages,
  String? replyingMessageId,
) {
  if (replyingMessageId == null) {
    return null;
  }
  for (final message in messages) {
    if (message.id == replyingMessageId) {
      return message;
    }
  }
  return null;
}

DirectChatMessageViewModel applyReplyContext(
  DirectChatMessageViewModel message,
  DirectChatMessageViewModel? repliedMessage,
) {
  if (repliedMessage == null || message.replyToMessageId != null) {
    return message;
  }
  return message.copyWith(
    replyToMessageId: repliedMessage.id,
    replyToContent: repliedMessage.content,
    replyToType: repliedMessage.type,
    isReplyToMine: repliedMessage.isMine,
  );
}

String _firstGraphemeUpper(String value) {
  if (value.isEmpty) {
    return '';
  }
  return String.fromCharCode(value.runes.first).toUpperCase();
}
