import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';

class SessionStopRecordingDialog extends StatelessWidget {
  const SessionStopRecordingDialog({
    super.key,
    required this.data,
  });

  final SessionStopRecordingDialogData data;

  static Future<bool> show(
    BuildContext context, {
    required SessionStopRecordingDialogData data,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => SessionStopRecordingDialog(data: data),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text(data.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data.primaryMessage),
          const SizedBox(height: AppSpacing.sm),
          Text(data.secondaryMessage),
          if (data.requirementsMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(data.requirementsMessage!),
          ],
          if (data.gpsWarningMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(data.gpsWarningMessage!),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            data.lossWarningMessage,
            style: textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Seguir grabando'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(data.confirmLabel),
        ),
      ],
    );
  }
}
