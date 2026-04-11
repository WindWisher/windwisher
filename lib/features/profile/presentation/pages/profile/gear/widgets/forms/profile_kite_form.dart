import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/fields/profile_gear_text_field.dart';

class ProfileKiteForm extends StatelessWidget {
  const ProfileKiteForm({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.sizeController,
    required this.yearController,
  });

  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController sizeController;
  final TextEditingController yearController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ProfileGearTextField(
            controller: brandController,
            label: 'Marca cometa',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: modelController,
            label: 'Modelo cometa',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: sizeController,
            label: 'Tamano cometa (m)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: yearController,
            label: 'Ano cometa',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
