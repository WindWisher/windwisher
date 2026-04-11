import 'package:flutter/material.dart';

class ProfileGearDialogActions extends StatelessWidget {
  const ProfileGearDialogActions({
    super.key,
    required this.saveLabel,
    required this.onCancel,
    required this.onSave,
    this.canSave = true,
  });

  final String saveLabel;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final bool canSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        FilledButton(
          onPressed: canSave ? onSave : null,
          child: Text(saveLabel),
        ),
      ],
    );
  }
}
