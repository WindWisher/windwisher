import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class ProfileGearManagementControls extends StatelessWidget {
  const ProfileGearManagementControls({
    required this.value,
    required this.fieldLabel,
    required this.items,
    required this.onChanged,
    required this.onEdit,
    required this.onDelete,
    required this.onConfirmDelete,
    super.key,
  });

  final String? value;
  final String fieldLabel;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Future<bool> Function() onConfirmDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          key: ValueKey(
            'manage-$fieldLabel-${items.length}-${value ?? 'none'}',
          ),
          initialValue: value,
          decoration: InputDecoration(labelText: fieldLabel),
          items: items,
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
            const SizedBox(width: AppSpacing.xs),
            TextButton.icon(
              onPressed: onDelete == null
                  ? null
                  : () async {
                      final confirmed = await onConfirmDelete();
                      if (confirmed) {
                        onDelete!();
                      }
                    },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Eliminar'),
            ),
          ],
        ),
      ],
    );
  }
}
