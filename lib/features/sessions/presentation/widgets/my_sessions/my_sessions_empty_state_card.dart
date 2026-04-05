import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/my_sessions_models.dart';

class MySessionsEmptyStateCard extends StatelessWidget {
  const MySessionsEmptyStateCard({
    super.key,
    required this.data,
    required this.textStyle,
    required this.onClearSearchPressed,
  });

  final MySessionsEmptyStateData data;
  final TextStyle? textStyle;
  final VoidCallback onClearSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data.message, style: textStyle),
            if (data.showClearSearchAction) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton.icon(
                onPressed: onClearSearchPressed,
                icon: const Icon(Icons.close_rounded),
                label: const Text('Limpiar busqueda'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
