import 'package:flutter/material.dart';

class ProfileGearSetupSelectorField extends StatelessWidget {
  const ProfileGearSetupSelectorField({
    super.key,
    required this.fieldKey,
    required this.value,
    required this.label,
    required this.items,
    required this.onChanged,
  });

  final Key fieldKey;
  final String? value;
  final String label;
  final List<DropdownMenuItem<String?>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      key: fieldKey,
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: items,
      onChanged: (value) => onChanged(value),
    );
  }
}
