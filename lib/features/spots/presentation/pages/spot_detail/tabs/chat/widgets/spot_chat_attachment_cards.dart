import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/spots/domain/entities/spot_social_post.dart';
import 'package:windwisher/features/spots/application/services/spot_social_service.dart';

class PendingSpotSocialAttachmentCard extends StatelessWidget {
  const PendingSpotSocialAttachmentCard({
    super.key,
    required this.attachment,
    required this.onRemove,
  });

  final SpotSocialAttachmentDraft attachment;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final isImage = attachment.type == SpotSocialAttachmentType.image;
    return Stack(
      children: [
        Container(
          width: isImage ? 120 : 180,
          padding: EdgeInsets.all(isImage ? 0 : AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: isImage
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    attachment.bytes,
                    width: 120,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 120,
                      height: 100,
                      child: Center(child: Text('Imagen no disponible')),
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_circle_fill_rounded),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        attachment.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: IconButton.filledTonal(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            iconSize: 16,
            icon: const Icon(Icons.close_rounded),
          ),
        ),
      ],
    );
  }
}

class SpotSocialAttachmentCard extends StatelessWidget {
  const SpotSocialAttachmentCard({
    super.key,
    required this.attachment,
    required this.compact,
  });

  final SpotSocialAttachment attachment;
  final bool compact;

  Future<void> _openAttachment(BuildContext context) async {
    if (attachment.type == SpotSocialAttachmentType.image &&
        attachment.url.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return Dialog.fullscreen(
            child: Stack(
              children: [
                Container(
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: InteractiveViewer(
                    child: Image.network(
                      attachment.url,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          'No se pudo cargar la imagen.',
                          style: Theme.of(
                            dialogContext,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: IconButton.filled(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          );
        },
      );
      return;
    }

    if (attachment.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el adjunto.')),
      );
      return;
    }

    if (attachment.type == SpotSocialAttachmentType.video) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return _SpotSocialVideoViewerDialog(
            videoUrl: attachment.url,
            fileName: attachment.fileName,
          );
        },
      );
      return;
    }

    final uri = Uri.tryParse(attachment.url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el adjunto.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = compact ? 132.0 : 176.0;
    final height = compact ? 96.0 : 132.0;
    if (attachment.type == SpotSocialAttachmentType.image &&
        attachment.url.isNotEmpty) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openAttachment(context),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Image.network(
            attachment.url,
            width: width,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => _SpotSocialAttachmentFallback(
              label: attachment.fileName,
              icon: Icons.broken_image_outlined,
              width: width,
            ),
          ),
        ),
      );
    }
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _openAttachment(context),
      child: _SpotSocialAttachmentFallback(
        label: attachment.fileName,
        icon: attachment.type == SpotSocialAttachmentType.video
            ? Icons.play_circle_fill_rounded
            : Icons.image_rounded,
        width: width,
      ),
    );
  }
}

class _SpotSocialVideoViewerDialog extends StatefulWidget {
  const _SpotSocialVideoViewerDialog({
    required this.videoUrl,
    required this.fileName,
  });

  final String videoUrl;
  final String fileName;

  @override
  State<_SpotSocialVideoViewerDialog> createState() =>
      _SpotSocialVideoViewerDialogState();
}

class _SpotSocialVideoViewerDialogState
    extends State<_SpotSocialVideoViewerDialog> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  Object? _loadError;

  String _formatVideoDuration(Duration duration) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.videoUrl);
    if (uri == null) {
      _loadError = 'URL de video no valida.';
      return;
    }
    final controller = VideoPlayerController.networkUrl(uri);
    _controller = controller;
    _initializeFuture = controller
        .initialize()
        .then((_) {
          controller.play();
          controller.setLooping(true);
        })
        .catchError((error) {
          _loadError = error;
        });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Center(
                child: _loadError != null
                    ? Text(
                        'No se pudo reproducir el video.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
                      )
                    : FutureBuilder<void>(
                        future: _initializeFuture,
                        builder: (context, snapshot) {
                          final controller = _controller;
                          if (snapshot.connectionState !=
                                  ConnectionState.done ||
                              controller == null ||
                              !controller.value.isInitialized) {
                            return const CircularProgressIndicator();
                          }
                          return AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: ValueListenableBuilder<VideoPlayerValue>(
                              valueListenable: controller,
                              builder: (context, value, _) {
                                return GestureDetector(
                                  onTap: () {
                                    if (value.isPlaying) {
                                      controller.pause();
                                    } else {
                                      controller.play();
                                    }
                                  },
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      VideoPlayer(controller),
                                      if (!value.isPlaying)
                                        const Icon(
                                          Icons.play_circle_fill_rounded,
                                          color: Colors.white,
                                          size: 72,
                                        ),
                                      Positioned(
                                        left: AppSpacing.md,
                                        right: AppSpacing.md,
                                        bottom: AppSpacing.md,
                                        child: Container(
                                          padding: const EdgeInsets.all(
                                            AppSpacing.sm,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(
                                              alpha: 0.52,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              VideoProgressIndicator(
                                                controller,
                                                allowScrubbing: true,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: AppSpacing.xs,
                                                    ),
                                                colors:
                                                    const VideoProgressColors(
                                                      playedColor: Colors.white,
                                                      bufferedColor:
                                                          Colors.white24,
                                                      backgroundColor:
                                                          Colors.white12,
                                                    ),
                                              ),
                                              const SizedBox(
                                                height: AppSpacing.xs,
                                              ),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      if (value.isPlaying) {
                                                        controller.pause();
                                                      } else {
                                                        controller.play();
                                                      }
                                                    },
                                                    icon: Icon(
                                                      value.isPlaying
                                                          ? Icons.pause_rounded
                                                          : Icons
                                                                .play_arrow_rounded,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      '${_formatVideoDuration(value.position)} / ${_formatVideoDuration(value.duration)}',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
              Positioned(
                top: AppSpacing.md,
                right: AppSpacing.md,
                child: IconButton.filled(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                right: AppSpacing.md,
                bottom: AppSpacing.md,
                child: IgnorePointer(
                  child: Text(
                    widget.fileName,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotSocialAttachmentFallback extends StatelessWidget {
  const _SpotSocialAttachmentFallback({
    required this.label,
    required this.icon,
    required this.width,
  });

  final String label;
  final IconData icon;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
