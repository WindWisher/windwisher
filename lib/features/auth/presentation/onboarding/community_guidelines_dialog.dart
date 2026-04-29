import 'package:flutter/material.dart';
import 'package:windwisher/features/auth/presentation/onboarding/community_guidelines_content.dart';
import 'package:windwisher/features/auth/presentation/onboarding/legal_document_dialog_shell.dart';

class CommunityGuidelinesDialog extends StatelessWidget {
  const CommunityGuidelinesDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const CommunityGuidelinesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CommunityGuidelinesContent>(
      future: CommunityGuidelinesContent.loadCurrent(),
      builder: (context, snapshot) {
        final content = snapshot.data ?? CommunityGuidelinesContent.current;
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
