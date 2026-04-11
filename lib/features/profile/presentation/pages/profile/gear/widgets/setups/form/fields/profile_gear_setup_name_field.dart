import 'package:flutter/material.dart';

class ProfileGearSetupNameField extends StatelessWidget {
  const ProfileGearSetupNameField({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Nombre de equipacion',
        hintText: 'Ej: Big Air 25-35kt',
      ),
      onChanged: onChanged,
    );
  }
}
