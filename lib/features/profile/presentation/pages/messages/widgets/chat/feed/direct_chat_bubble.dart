import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/chat/feed/direct_chat_message_view_model.dart';

class DirectChatBubble extends StatelessWidget {
  const DirectChatBubble({
    super.key,
    required this.message,
    required this.textTheme,
    required this.colorScheme,
    required this.timeLabel,
    required this.participantLabel,
    required this.participantInitials,
    this.participantAvatarPath,
    required this.isSelectedForEdit,
    required this.onTap,
  });

  final DirectChatMessageViewModel message;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final String timeLabel;
  final String participantLabel;
  final String participantInitials;
  final String? participantAvatarPath;
  final bool isSelectedForEdit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = message.isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final bubbleTextColor = message.isMine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final participantAvatarImage = _avatarImageProvider(participantAvatarPath);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment:
            message.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMine) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: colorScheme.secondaryContainer,
              foregroundColor: colorScheme.onSecondaryContainer,
              backgroundImage: participantAvatarImage,
              child: participantAvatarImage == null
                  ? Text(
                      participantInitials,
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Align(
              alignment:
                  message.isMine ? Alignment.centerRight : Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: Radius.circular(message.isMine ? 20 : 6),
                    bottomRight: Radius.circular(message.isMine ? 6 : 20),
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.sm,
                      AppSpacing.xs,
                      AppSpacing.sm,
                      AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: Radius.circular(message.isMine ? 20 : 6),
                        bottomRight: Radius.circular(message.isMine ? 6 : 20),
                      ),
                      border: isSelectedForEdit
                          ? Border.all(color: colorScheme.primary, width: 1.5)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${message.isMine ? 'Tú' : participantLabel} · $timeLabel',
                                style: textTheme.bodySmall?.copyWith(
                                  color: message.isMine
                                      ? colorScheme.onPrimaryContainer
                                          .withValues(alpha: 0.72)
                                      : colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (message.replyToMessageId != null) ...[
                          const SizedBox(height: 6),
                          _ReplyQuoteCard(
                            content: message.replyToContent,
                            type: message.replyToType,
                            authorLabel: (message.isReplyToMine ?? false)
                                ? 'Tú'
                                : participantLabel,
                            colorScheme: colorScheme,
                            textTheme: textTheme,
                            isMine: message.isMine,
                          ),
                        ],
                        if (message.type == DirectChatMessageTypeView.text &&
                            message.content.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            message.content,
                            style: textTheme.bodyMedium?.copyWith(
                              color: bubbleTextColor,
                            ),
                          ),
                        ],
                        if (message.type == DirectChatMessageTypeView.image) ...[
                          const SizedBox(height: 4),
                          _ChatImageBubble(
                            url: message.mediaUrl,
                            onTap: message.mediaUrl == null ||
                                    message.mediaUrl!.isEmpty
                                ? null
                                : () => _showImagePreview(context, message.mediaUrl!),
                          ),
                        ],
                        if (message.type == DirectChatMessageTypeView.video) ...[
                          const SizedBox(height: 4),
                          _ChatVideoBubble(
                            url: message.mediaUrl,
                            fileName: message.fileName,
                            onTap: message.mediaUrl == null ||
                                    message.mediaUrl!.isEmpty
                                ? null
                                : () => _showVideoPreview(
                                      context,
                                      url: message.mediaUrl!,
                                      fileName: message.fileName,
                                    ),
                          ),
                        ],
                        if (message.type != DirectChatMessageTypeView.text &&
                            message.content.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            message.content,
                            style: textTheme.bodyMedium?.copyWith(
                              color: bubbleTextColor,
                            ),
                          ),
                        ],
                        if (message.isEdited) ...[
                          const SizedBox(height: 6),
                          Text(
                            'editado',
                            style: textTheme.bodySmall?.copyWith(
                              color: bubbleTextColor.withValues(alpha: 0.72),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (message.isMine) ...[
            const SizedBox(width: AppSpacing.xs),
            CircleAvatar(
              radius: 14,
              backgroundColor: colorScheme.primaryContainer,
              foregroundColor: colorScheme.onPrimaryContainer,
              child: Text(
                'T',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  ImageProvider<Object>? _avatarImageProvider(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }
    final trimmedPath = path.trim();
    final uri = Uri.tryParse(trimmedPath);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(trimmedPath);
    }
    if (!kIsWeb) {
      return FileImage(File(trimmedPath));
    }
    return null;
  }
}

Future<void> _showImagePreview(BuildContext context, String url) {
  return showDialog<void>(
    context: context,
    builder: (_) => Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.lg),
                        child: Text('No se pudo abrir la imagen.'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> _showVideoPreview(
  BuildContext context, {
  required String url,
  String? fileName,
}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _DirectChatVideoPreviewDialog(
      url: url,
      fileName: fileName,
    ),
  );
}


class _ReplyQuoteCard extends StatelessWidget {
  const _ReplyQuoteCard({
    required this.content,
    required this.type,
    required this.authorLabel,
    required this.colorScheme,
    required this.textTheme,
    required this.isMine,
  });

  final String? content;
  final DirectChatMessageTypeView? type;
  final String authorLabel;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final preview = (content != null && content!.trim().isNotEmpty)
        ? content!.trim()
        : switch (type) {
            DirectChatMessageTypeView.image => 'Foto',
            DirectChatMessageTypeView.video => 'Vídeo',
            _ => 'Mensaje',
          };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: BoxDecoration(
        color: isMine
            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.10)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isMine ? colorScheme.onPrimaryContainer : colorScheme.primary,
            width: 3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            authorLabel,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isMine
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: isMine
                  ? colorScheme.onPrimaryContainer.withValues(alpha: 0.88)
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatImageBubble extends StatelessWidget {
  const _ChatImageBubble({required this.url, this.onTap});

  final String? url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const SizedBox(
        width: 220,
        height: 120,
        child: Center(child: Text('Imagen no disponible')),
      );
    }
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url!,
          width: 220,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox(
            width: 220,
            height: 120,
            child: Center(child: Text('No se pudo cargar la imagen')),
          ),
        ),
      ),
    );
  }
}

class _ChatVideoBubble extends StatelessWidget {
  const _ChatVideoBubble({
    required this.url,
    required this.fileName,
    this.onTap,
  });

  final String? url;
  final String? fileName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final resolvedFileName = (fileName != null && fileName!.trim().isNotEmpty)
        ? fileName!.trim()
        : _labelFromUrl(url);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.play_circle_fill_rounded, size: 28),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                resolvedFileName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _labelFromUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'video';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || uri.pathSegments.isEmpty) {
      return 'video';
    }
    return uri.pathSegments.last;
  }
}

class _DirectChatVideoPreviewDialog extends StatefulWidget {
  const _DirectChatVideoPreviewDialog({required this.url, this.fileName});

  final String url;
  final String? fileName;

  @override
  State<_DirectChatVideoPreviewDialog> createState() =>
      _DirectChatVideoPreviewDialogState();
}

class _DirectChatVideoPreviewDialogState
    extends State<_DirectChatVideoPreviewDialog> {
  VideoPlayerController? _controller;
  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await controller.initialize();
      await controller.setLooping(false);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isReady = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasError = true;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = (widget.fileName != null && widget.fileName!.trim().isNotEmpty)
        ? widget.fileName!.trim()
        : 'Vídeo';

    return Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.md),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Center(
                  child: _hasError
                      ? const Text('No se pudo abrir el vídeo.')
                      : !_isReady || _controller == null
                          ? const CircularProgressIndicator()
                          : AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: VideoPlayer(_controller!),
                              ),
                            ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  if (_isReady && _controller != null && !_hasError)
                    FilledButton.icon(
                      onPressed: () async {
                        if (_controller!.value.isPlaying) {
                          await _controller!.pause();
                        } else {
                          await _controller!.play();
                        }
                        if (mounted) {
                          setState(() {});
                        }
                      },
                      icon: Icon(
                        _controller!.value.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                      label: Text(
                        _controller!.value.isPlaying ? 'Pausar' : 'Reproducir',
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
