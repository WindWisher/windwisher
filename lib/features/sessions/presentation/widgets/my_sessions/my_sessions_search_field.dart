import 'package:flutter/material.dart';
import 'package:windwisher/features/sessions/presentation/models/my_sessions_models.dart';

class MySessionsSearchField extends StatelessWidget {
  const MySessionsSearchField({
    super.key,
    required this.controller,
    required this.data,
    required this.onChanged,
    required this.onClearPressed,
  });

  final TextEditingController controller;
  final MySessionsSearchFieldData data;
  final ValueChanged<String> onChanged;
  final VoidCallback onClearPressed;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        hintText: data.hintText,
        border: const OutlineInputBorder(),
        suffixIcon: !data.showClearAction
            ? null
            : IconButton(
                tooltip: 'Limpiar busqueda',
                icon: const Icon(Icons.close_rounded),
                onPressed: onClearPressed,
              ),
      ),
      onChanged: onChanged,
    );
  }
}
