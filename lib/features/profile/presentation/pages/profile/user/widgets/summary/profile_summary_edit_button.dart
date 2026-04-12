import 'package:flutter/material.dart';

class ProfileSummaryEditButton extends StatelessWidget {
  const ProfileSummaryEditButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Editar usuario'),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          textStyle: textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
