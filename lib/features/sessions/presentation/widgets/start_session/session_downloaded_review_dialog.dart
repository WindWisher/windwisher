import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class SessionDownloadedReviewDialog extends StatelessWidget {
  const SessionDownloadedReviewDialog({super.key, required this.data});

  final SessionDownloadedReviewData data;

  static Future<SessionDownloadedReviewAction?> show(
    BuildContext context, {
    required SessionDownloadedReviewData data,
  }) {
    return showDialog<SessionDownloadedReviewAction>(
      context: context,
      builder: (_) => SessionDownloadedReviewDialog(data: data),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: const Text('Revisar sesion descargada'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _ReviewLine(
              icon: Icons.watch_rounded,
              label: 'Dispositivo',
              value: data.deviceName,
            ),
            _ReviewLine(
              icon: Icons.event_rounded,
              label: 'Fecha',
              value: data.dateLabel,
            ),
            _ReviewLine(
              icon: Icons.timer_outlined,
              label: 'Duracion',
              value: data.durationLabel,
            ),
            _ReviewLine(
              icon: Icons.air_rounded,
              label: 'Saltos detectados',
              value: '${data.jumpCount}',
            ),
            _ReviewLine(
              icon: Icons.description_outlined,
              label: 'Formato de origen',
              value: data.sourceFormatLabel,
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen', style: textTheme.labelLarge),
                  const SizedBox(height: 4),
                  Text(data.summary, style: textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Ahora no'),
        ),
        TextButton.icon(
          onPressed: () =>
              Navigator.of(context).pop(SessionDownloadedReviewAction.delete),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Eliminar descarga'),
        ),
        FilledButton.icon(
          onPressed: () =>
              Navigator.of(context).pop(SessionDownloadedReviewAction.upload),
          icon: const Icon(Icons.cloud_upload_rounded),
          label: const Text('Continuar para subir'),
        ),
      ],
    );
  }
}

class _ReviewLine extends StatelessWidget {
  const _ReviewLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
