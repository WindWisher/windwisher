part of '../spots_page.dart';

class _SpotEditSheetContent extends StatelessWidget {
  const _SpotEditSheetContent({
    required this.spot,
    required this.nameController,
    required this.areaController,
    required this.backgroundImagePath,
    required this.onPickBackgroundImage,
    required this.onRemoveBackgroundImage,
    required this.onSave,
  });

  final _SpotItem spot;
  final TextEditingController nameController;
  final TextEditingController areaController;
  final String? backgroundImagePath;
  final ValueChanged<ImageSource> onPickBackgroundImage;
  final VoidCallback onRemoveBackgroundImage;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Editar spot', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        _SpotBackgroundImagePicker(
          imagePath: backgroundImagePath,
          onPick: onPickBackgroundImage,
          onRemove: onRemoveBackgroundImage,
        ),
        TextField(
          controller: nameController,
          enabled: spot.isCustom,
          decoration: const InputDecoration(labelText: 'Nombre del spot'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: areaController,
          enabled: spot.isCustom,
          decoration: const InputDecoration(labelText: 'Zona / provincia'),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onSave,
            child: const Text('Guardar cambios'),
          ),
        ),
      ],
    );
  }
}
