import 'package:flutter/material.dart';
import 'package:windwisher/features/auth/presentation/onboarding/legal_document_dialog_shell.dart';
import 'package:windwisher/features/auth/presentation/onboarding/legal_notice_content.dart';

class LegalNoticeDialog extends StatelessWidget {
  const LegalNoticeDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const LegalNoticeDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LegalNoticeContent>(
      future: LegalNoticeContent.loadCurrent(),
      builder: (context, snapshot) {
        final content = snapshot.data ?? LegalNoticeContent.current;
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
