import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/fields/profile_gear_text_field.dart';

class ProfileHarnessForm extends StatelessWidget {
  const ProfileHarnessForm({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.sizeController,
    required this.yearController,
    required this.priceController,
  });

  final TextEditingController brandController;
  final TextEditingController modelController;
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
            label: 'Marca arnes',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: modelController,
            label: 'Modelo arnes',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: sizeController,
            label: 'Talla arnes',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: yearController,
            label: 'Ano arnes',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: priceController,
            label: 'Precio arnes (EUR)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }
}
