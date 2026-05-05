part of '../spots_page.dart';

class _SpotAddSheetContent extends StatelessWidget {
  const _SpotAddSheetContent({
    required this.allowCustomMode,
    required this.snapshot,
    required this.customMode,
    required this.customPoint,
    required this.backgroundImagePath,
    required this.nameController,
    required this.areaController,
    required this.suggestedSpots,
    required this.error,
    required this.onPickCustomPoint,
    required this.onPickBackgroundImage,
    required this.onRemoveBackgroundImage,
    required this.onSuggestedSpotSelected,
    required this.onSave,
  });

  final bool allowCustomMode;
  final _SpotAddSheetStateSnapshot snapshot;
  final bool customMode;
  final _CustomSpotPoint? customPoint;
  final String? backgroundImagePath;
  final TextEditingController nameController;
  final TextEditingController areaController;
  final List<_AvailableSpot> suggestedSpots;
  final String? error;
  final VoidCallback onPickCustomPoint;
  final ValueChanged<ImageSource> onPickBackgroundImage;
  final VoidCallback onRemoveBackgroundImage;
  final ValueChanged<_AvailableSpot> onSuggestedSpotSelected;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SpotAddHeader(
            allowCustomMode: allowCustomMode,
            onPickCustomPoint: onPickCustomPoint,
          ),
          _SpotAddStatusMessages(
            customPoint: customPoint,
            selectedOfficialSpot: snapshot.selectedOfficialSpot,
            hasSelectedOfficialSpot: snapshot.hasSelectedOfficialSpot,
            requiresCoordinates: snapshot.requiresCoordinates,
            allowTextFields: snapshot.allowTextFields,
          ),
          if (snapshot.allowTextFields && customMode) ...[
            const SizedBox(height: AppSpacing.sm),
            _SpotBackgroundImagePicker(
              imagePath: backgroundImagePath,
              onPick: onPickBackgroundImage,
              onRemove: onRemoveBackgroundImage,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          _SpotAddFormFields(
            nameController: nameController,
            areaController: areaController,
            allowTextFields: snapshot.allowTextFields,
            suggestedSpots: suggestedSpots,
            onSuggestedSpotSelected: onSuggestedSpotSelected,
            onSubmitted: onSave,
          ),
          _SpotAddErrorMessage(error: error),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: snapshot.canSave ? onSave : null,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: const Text('Guardar spot'),
            ),
          ),
        ],
      ),
    );
  }
}
