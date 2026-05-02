part of 'spots_page.dart';

class _SpotBackgroundImagePicker extends StatelessWidget {
  const _SpotBackgroundImagePicker({
    required this.imagePath,
    required this.onPick,
    required this.onRemove,
  });

  final String? imagePath;
  final ValueChanged<ImageSource> onPick;
  final VoidCallback onRemove;

  bool get _canRenderLocalImage {
    return !kIsWeb && imagePath != null && imagePath!.isNotEmpty;
  }

  Future<void> _confirmRemove(BuildContext context) async {
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Quitar foto'),
          content: const Text('Quieres eliminar la foto seleccionada?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    if (shouldRemove == true) {
      onRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            OutlinedButton.icon(
              onPressed: () => onPick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Galeria'),
            ),
            OutlinedButton.icon(
              onPressed: () => onPick(ImageSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Camara'),
            ),
          ],
        ),
        if (_canRenderLocalImage) ...[
          const SizedBox(height: AppSpacing.xs),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(imagePath!), fit: BoxFit.cover),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      tooltip: 'Eliminar foto',
                      icon: const Icon(Icons.close_rounded, size: 18),
                      color: Colors.white,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                      onPressed: () => _confirmRemove(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
