import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class LegalDocumentDialogShell extends StatelessWidget {
  const LegalDocumentDialogShell({
    super.key,
    required this.title,
    required this.version,
    required this.introParagraphs,
    required this.bullets,
    required this.closingParagraph,
    this.requireAcceptance = false,
    this.isLoading = false,
  });

  final String title;
  final String version;
  final List<String> introParagraphs;
  final List<String> bullets;
  final String closingParagraph;
  final bool requireAcceptance;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.lg,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.gavel_rounded,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Documento legal consultable dentro de la app',
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!requireAcceptance)
                    IconButton(
                      tooltip: 'Cerrar',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (isLoading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  for (var index = 0; index < introParagraphs.length; index++) ...[
                    _LegalParagraph(introParagraphs[index]),
                    if (index < introParagraphs.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  for (final bullet in bullets) _LegalBullet(bullet),
                  const SizedBox(height: AppSpacing.md),
                  _LegalParagraph(closingParagraph),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Version: $version',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(requireAcceptance ? false : null),
                    child: Text(requireAcceptance ? 'Salir' : 'Cerrar'),
                  ),
                  const Spacer(),
                  if (requireAcceptance)
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Aceptar y continuar'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalParagraph extends StatelessWidget {
  const _LegalParagraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}

class _LegalBullet extends StatelessWidget {
  const _LegalBullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
