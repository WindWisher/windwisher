import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/fields/profile_gear_dropdown_field.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/fields/profile_gear_text_field.dart';

class ProfileBoardForm extends StatelessWidget {
  const ProfileBoardForm({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.boardType,
    required this.onBoardTypeChanged,
    required this.sizeController,
    required this.yearController,
    required this.priceController,
  });

  final TextEditingController brandController;
  final TextEditingController modelController;
  final String boardType;
  final ValueChanged<String?> onBoardTypeChanged;
  final TextEditingController sizeController;
  final TextEditingController yearController;
  final TextEditingController priceController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileGearTextField(
            controller: brandController,
            label: 'Marca tabla',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: modelController,
            label: 'Modelo tabla',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearDropdownField<String>(
            value: boardType,
            label: 'Tipo tabla',
            items: const ['Twin tip', 'Surf', 'Foil']
                .map(
                  (value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                .toList(),
            onChanged: onBoardTypeChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: sizeController,
            label: 'Tamano tabla (cm)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: yearController,
            label: 'Ano tabla',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: priceController,
            label: 'Precio tabla (EUR)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }
}
