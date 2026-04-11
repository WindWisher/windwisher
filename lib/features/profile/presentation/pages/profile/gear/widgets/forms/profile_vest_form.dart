import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/fields/profile_gear_text_field.dart';

class ProfileVestForm extends StatelessWidget {
  const ProfileVestForm({
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
            label: 'Marca chaleco',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: modelController,
            label: 'Modelo chaleco',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: sizeController,
            label: 'Talla chaleco',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: yearController,
            label: 'Ano chaleco',
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
