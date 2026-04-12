import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/forms/fields/profile_gear_text_field.dart';

class ProfileBarForm extends StatelessWidget {
  const ProfileBarForm({
    super.key,
    required this.brandController,
    required this.modelController,
    required this.lineLengthController,
    required this.widthController,
    required this.yearController,
    required this.priceController,
  });

  final TextEditingController brandController;
  final TextEditingController modelController;
  final TextEditingController lineLengthController;
  final TextEditingController widthController;
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
            label: 'Marca barra',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: modelController,
            label: 'Modelo barra',
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: lineLengthController,
            label: 'Longitud lineas (m)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: widthController,
            label: 'Ancho barra (cm)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: yearController,
            label: 'Ano barra',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.xs),
          ProfileGearTextField(
            controller: priceController,
            label: 'Precio barra (EUR)',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }
}
