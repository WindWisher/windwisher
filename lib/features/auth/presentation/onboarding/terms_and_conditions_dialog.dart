import 'package:flutter/material.dart';
import 'package:windwisher/features/auth/presentation/onboarding/legal_document_dialog_shell.dart';
import 'package:windwisher/features/auth/presentation/onboarding/terms_and_conditions_content.dart';

class TermsAndConditionsDialog extends StatelessWidget {
  const TermsAndConditionsDialog({
    super.key,
    this.requireAcceptance = true,
  });

  final bool requireAcceptance;

  static Future<bool> show(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const TermsAndConditionsDialog(),
    );
    return accepted ?? false;
  }

  static Future<void> showReadOnly(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const TermsAndConditionsDialog(requireAcceptance: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<TermsAndConditionsContent>(
      future: TermsAndConditionsContent.loadCurrent(),
      builder: (context, snapshot) {
        final content = snapshot.data ?? TermsAndConditionsContent.current;
        return LegalDocumentDialogShell(
          title: content.title,
          version: content.version,
          introParagraphs: content.introParagraphs,
          bullets: content.bullets,
          closingParagraph: content.closingParagraph,
          requireAcceptance: requireAcceptance,
          isLoading: snapshot.connectionState == ConnectionState.waiting,
        );
      },
    );
  }
}
