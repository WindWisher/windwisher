import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/fields/profile_gear_text_field.dart';

class ProfileWetsuitForm extends StatelessWidget {
  const ProfileWetsuitForm({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.thicknessController,
    required this.sizeController,
    required this.yearController,
  });

  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController thicknessController;
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
            label: 'Marca traje',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: modelController,
            label: 'Modelo traje',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: thicknessController,
            label: 'Grosor traje (mm)',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: sizeController,
            label: 'Talla traje',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: yearController,
            label: 'Ano traje',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
