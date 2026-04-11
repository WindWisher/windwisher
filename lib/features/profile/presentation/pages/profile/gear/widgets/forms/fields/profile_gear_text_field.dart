import 'package:flutter/material.dart';

class ProfileGearTextField extends StatelessWidget {
  const ProfileGearTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      keyboardType: keyboardType,
    );
  }
}
