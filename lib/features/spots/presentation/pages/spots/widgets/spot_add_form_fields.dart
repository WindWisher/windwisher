part of '../spots_page.dart';

class _SpotAddFormFields extends StatelessWidget {
  const _SpotAddFormFields({
    required this.nameController,
    required this.areaController,
    required this.allowTextFields,
    required this.suggestedSpots,
    required this.onSuggestedSpotSelected,
    required this.onSubmitted,
  });

  final TextEditingController nameController;
  final TextEditingController areaController;
  final bool allowTextFields;
  final List<_AvailableSpot> suggestedSpots;
  final ValueChanged<_AvailableSpot> onSuggestedSpotSelected;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: nameController,
          textInputAction: TextInputAction.next,
          enabled: allowTextFields,
          decoration: const InputDecoration(labelText: 'Nombre del spot'),
        ),
        if (suggestedSpots.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          _SpotSuggestionsList(
            spots: suggestedSpots,
            onSelected: onSuggestedSpotSelected,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: areaController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmitted(),
          enabled: allowTextFields,
          decoration: const InputDecoration(
            labelText: 'Zona / provincia / pais (opcional)',
          ),
        ),
      ],
    );
  }
}
