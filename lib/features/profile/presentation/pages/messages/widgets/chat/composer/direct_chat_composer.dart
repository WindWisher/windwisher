import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_message_view_model.dart';

class DirectChatComposer extends StatelessWidget {
  const DirectChatComposer({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.isPickingMedia,
    required this.isEditing,
    required this.onSubmitted,
    required this.onChanged,
    required this.onAttachMedia,
    required this.onCancelEditing,
    this.replyingTo,
    required this.replyParticipantLabel,
    required this.onCancelReply,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final bool isPickingMedia;
  final bool isEditing;
  final VoidCallback onSubmitted;
  final ValueChanged<String> onChanged;
  final VoidCallback onAttachMedia;
  final VoidCallback onCancelEditing;
  final DirectChatMessageViewModel? replyingTo;
  final String replyParticipantLabel;
  final VoidCallback onCancelReply;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isReplying = !isEditing && replyingTo != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing)
            _ComposerContextCard(
              title: 'Editando mensaje',
              subtitle: 'Guarda los cambios o cancela para volver al chat.',
              accentColor: colorScheme.primary,
              onClose: isSubmitting ? null : onCancelEditing,
            ),
          if (isReplying)
            _ComposerContextCard(
              title: 'Respondiendo',
              subtitle:
                  '${replyingTo!.isMine ? 'Tú' : replyParticipantLabel}: ${_replyPreview(replyingTo!)}',
              accentColor: colorScheme.primary,
              onClose: isSubmitting ? null : onCancelReply,
            ),
          TextField(
            controller: controller,
            enabled: !isSubmitting,
            minLines: 1,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: isEditing
                  ? 'Edita el mensaje seleccionado...'
                  : isReplying
                  ? 'Escribe tu respuesta...'
                  : 'Escribe al chat del spot...',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: colorScheme.surfaceContainerLowest,
            ),
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton.filledTonal(
                tooltip: 'Adjuntar foto o vídeo',
                onPressed: isPickingMedia || isSubmitting
                    ? null
                    : onAttachMedia,
                icon: isPickingMedia
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_rounded),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isEditing)
                    TextButton(
                      onPressed: isSubmitting ? null : onCancelEditing,
                      child: const Text('Cancelar'),
                    )
                  else if (isReplying)
                    TextButton(
                      onPressed: isSubmitting ? null : onCancelReply,
                      child: const Text('Cancelar'),
                    ),
                  FilledButton.icon(
                    onPressed: isSubmitting ? null : onSubmitted,
                    icon: Icon(
                      isEditing
                          ? Icons.save_rounded
                          : isReplying
                          ? Icons.reply_rounded
                          : Icons.send_rounded,
                    ),
                    label: Text(
                      isEditing
                          ? 'Guardar'
                          : isReplying
                          ? 'Responder'
                          : 'Enviar',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _replyPreview(DirectChatMessageViewModel message) {
    if (message.content.trim().isNotEmpty) {
      return message.content.trim();
    }
    return switch (message.type) {
      DirectChatMessageTypeView.image => 'Foto',
      DirectChatMessageTypeView.video => 'Vídeo',
      DirectChatMessageTypeView.text => 'Mensaje',
    };
  }
}

class _ComposerContextCard extends StatelessWidget {
  const _ComposerContextCard({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onClose,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accentColor, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelSmall?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cancelar',
            onPressed: onClose,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}
