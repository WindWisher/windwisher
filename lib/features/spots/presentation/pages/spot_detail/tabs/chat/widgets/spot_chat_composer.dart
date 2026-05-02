import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class SpotChatComposer extends StatelessWidget {
  const SpotChatComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.pendingAttachments,
    required this.hintText,
    required this.enabled,
    required this.canSend,
    required this.isReplyComposer,
    required this.isEditingReply,
    required this.isEditingPost,
    required this.isPickingMedia,
    required this.sendLabel,
    required this.onChanged,
    required this.onSend,
    required this.onCancel,
    this.title,
    this.replyAuthor,
    this.replyMessage,
    this.onAttach,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Widget pendingAttachments;
  final String hintText;
  final bool enabled;
  final bool canSend;
  final bool isReplyComposer;
  final bool isEditingReply;
  final bool isEditingPost;
  final bool isPickingMedia;
  final String sendLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final VoidCallback onCancel;
  final String? title;
  final String? replyAuthor;
  final String? replyMessage;
  final VoidCallback? onAttach;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasCancelAction = isReplyComposer || isEditingPost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) Text(title!, style: textTheme.titleSmall),
        if (replyAuthor != null && replyMessage != null)
          _ReplyPreview(
            author: replyAuthor!,
            message: replyMessage!,
            onCancel: onCancel,
          ),
        pendingAttachments,
        TextField(
          controller: controller,
          focusNode: focusNode,
          minLines: 1,
          maxLines: isReplyComposer ? 3 : 5,
          onChanged: onChanged,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hintText,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: colorScheme.surfaceContainerLowest,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              tooltip: 'Adjuntar foto o video',
              onPressed: onAttach,
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
                if (hasCancelAction)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Cancelar'),
                  ),
                const SizedBox(width: AppSpacing.xs),
                FilledButton.icon(
                  onPressed: canSend ? onSend : null,
                  icon: const Icon(Icons.send_rounded),
                  label: Text(sendLabel),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({
    required this.author,
    required this.message,
    required this.onCancel,
  });

  final String author;
  final String message;
  final VoidCallback onCancel;

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
        border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  author,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
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
            tooltip: 'Cancelar respuesta',
            onPressed: onCancel,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}
