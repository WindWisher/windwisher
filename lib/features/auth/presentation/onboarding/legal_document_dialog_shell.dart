import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class LegalDocumentDialogShell extends StatefulWidget {
  const LegalDocumentDialogShell({
    super.key,
    required this.title,
    required this.version,
    required this.introParagraphs,
    required this.bullets,
    required this.closingParagraph,
    this.requireAcceptance = false,
    this.isLoading = false,
    this.requireScrollToAccept = false,
  });

  final String title;
  final String version;
  final List<String> introParagraphs;
  final List<String> bullets;
  final String closingParagraph;
  final bool requireAcceptance;
  final bool isLoading;
  final bool requireScrollToAccept;

  @override
  State<LegalDocumentDialogShell> createState() =>
      _LegalDocumentDialogShellState();
}

class _LegalDocumentDialogShellState extends State<LegalDocumentDialogShell> {
  late final ScrollController _scrollController;
  bool _hasReachedEnd = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_updateHasReachedEnd);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHasReachedEnd());
  }

  @override
  void didUpdateWidget(covariant LegalDocumentDialogShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isLoading != widget.isLoading ||
        oldWidget.bullets.length != widget.bullets.length ||
        oldWidget.introParagraphs.length != widget.introParagraphs.length ||
        oldWidget.closingParagraph != widget.closingParagraph) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _updateHasReachedEnd(),
      );
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_updateHasReachedEnd)
      ..dispose();
    super.dispose();
  }

  void _updateHasReachedEnd() {
    if (!mounted || !_scrollController.hasClients) {
      return;
    }
    final position = _scrollController.position;
    final reachedEnd =
        position.maxScrollExtent <= 0 ||
        position.pixels >= position.maxScrollExtent - 12;
    if (reachedEnd != _hasReachedEnd) {
      setState(() => _hasReachedEnd = reachedEnd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final acceptEnabled =
        widget.requireAcceptance &&
        !widget.isLoading &&
        (!widget.requireScrollToAccept || _hasReachedEnd);
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
                          widget.title,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Documento legal consultable dentro de la app',
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!widget.requireAcceptance)
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
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  if (widget.isLoading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  for (
                    var index = 0;
                    index < widget.introParagraphs.length;
                    index++
                  ) ...[
                    _LegalParagraph(widget.introParagraphs[index]),
                    if (index < widget.introParagraphs.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  for (final bullet in widget.bullets) _LegalBullet(bullet),
                  const SizedBox(height: AppSpacing.md),
                  _LegalParagraph(widget.closingParagraph),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Version: ${widget.version}',
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
                    ).pop(widget.requireAcceptance ? false : null),
                    child: Text(
                      widget.requireAcceptance ? 'Cancelar' : 'Cerrar',
                    ),
                  ),
                  const Spacer(),
                  if (widget.requireAcceptance)
                    FilledButton(
                      onPressed: acceptEnabled
                          ? () => Navigator.of(context).pop(true)
                          : null,
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
