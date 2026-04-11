import 'package:flutter/material.dart';

class ProfileGearSetupDialogActions extends StatelessWidget {
  const ProfileGearSetupDialogActions({
    super.key,
    required this.canSave,
    required this.onCancel,
    required this.onSave,
  });

  final bool canSave;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(onPressed: onCancel, child: const Text('Cancelar')),
        FilledButton(
          onPressed: canSave ? onSave : null,
          child: const Text('Guardar equipacion'),
        ),
      ],
    );
  }
}
