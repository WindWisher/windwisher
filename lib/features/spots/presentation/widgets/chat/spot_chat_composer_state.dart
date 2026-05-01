import 'package:windwisher/features/spots/presentation/widgets/chat/spot_chat_entry.dart';

class SpotChatComposerState {
  const SpotChatComposerState({
    required this.usesReplyComposer,
    required this.isEditingReply,
    required this.isEditingPost,
    required this.canAttach,
    required this.sendLabel,
    required this.hintText,
    this.title,
    this.replyAuthor,
    this.replyMessage,
  });

  final bool usesReplyComposer;
  final bool isEditingReply;
  final bool isEditingPost;
  final bool canAttach;
  final String sendLabel;
  final String hintText;
  final String? title;
  final String? replyAuthor;
  final String? replyMessage;
}

SpotChatComposerState buildSpotChatComposerState({
  required bool isReplying,
  required bool isEditingReply,
  required bool isEditingPost,
  required bool canPublish,
  required bool isSubmitting,
  required SpotChatEntry? replyEntry,
}) {
  final usesReplyComposer = isReplying || isEditingReply;
  final title = isReplying
      ? 'Respondiendo'
      : isEditingReply
      ? 'Editando respuesta'
      : (isEditingPost ? 'Editando mensaje' : null);
  final hintText = !canPublish
      ? (usesReplyComposer
            ? 'Inicia sesion para responder...'
            : 'Inicia sesion para escribir en este spot.')
      : (usesReplyComposer
            ? 'Escribe tu respuesta...'
            : 'Escribe al chat del spot...');
  final canAttach =
      canPublish &&
      !isSubmitting &&
      (!isEditingPost || isReplying) &&
      !isEditingReply;

  return SpotChatComposerState(
    usesReplyComposer: usesReplyComposer,
    isEditingReply: isEditingReply,
    isEditingPost: isEditingPost,
    canAttach: canAttach,
    sendLabel: usesReplyComposer
        ? (isEditingReply ? 'Guardar' : 'Responder')
        : (isEditingPost ? 'Guardar' : 'Enviar'),
    title: title,
    hintText: hintText,
    replyAuthor: replyEntry?.authorDisplayName,
    replyMessage: _spotChatReplyPreviewMessage(replyEntry),
  );
}

String? _spotChatReplyPreviewMessage(SpotChatEntry? replyEntry) {
  if (replyEntry == null) {
    return null;
  }
  if (replyEntry.message.isNotEmpty) {
    return replyEntry.message;
  }
  if (replyEntry.attachments.isNotEmpty) {
    return 'Adjunto';
  }
  return '';
}
