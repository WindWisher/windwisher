import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class SessionFileImportCard extends StatelessWidget {
  const SessionFileImportCard({
    super.key,
    required this.onImportPressed,
    this.hintText,
  });

  final VoidCallback onImportPressed;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'O importar sesion de archivo',
              style: textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            OutlinedButton.icon(
              onPressed: onImportPressed,
              icon: const Icon(Icons.file_upload_rounded),
              label: const Text('Importar sesion real'),
            ),
            if (hintText != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                hintText!,
                style: textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
