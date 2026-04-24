import 'package:flutter/material.dart';
import 'package:windwisher/features/auth/presentation/onboarding/legal_document_dialog_shell.dart';
import 'package:windwisher/features/auth/presentation/onboarding/privacy_policy_content.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  const PrivacyPolicyDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PrivacyPolicyDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PrivacyPolicyContent>(
      future: PrivacyPolicyContent.loadCurrent(),
      builder: (context, snapshot) {
        final content = snapshot.data ?? PrivacyPolicyContent.current;
        return LegalDocumentDialogShell(
          title: content.title,
          version: content.version,
          introParagraphs: content.introParagraphs,
          bullets: content.bullets,
          closingParagraph: content.closingParagraph,
          isLoading: snapshot.connectionState == ConnectionState.waiting,
        );
      },
    );
  }
}
