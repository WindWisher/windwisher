import 'package:flutter/material.dart';
import 'package:windwisher/features/auth/presentation/onboarding/data_sources_licenses_content.dart';
import 'package:windwisher/features/auth/presentation/onboarding/legal_document_dialog_shell.dart';

class DataSourcesLicensesDialog extends StatelessWidget {
  const DataSourcesLicensesDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DataSourcesLicensesDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DataSourcesLicensesContent>(
      future: DataSourcesLicensesContent.loadCurrent(),
      builder: (context, snapshot) {
        final content = snapshot.data ?? DataSourcesLicensesContent.current;
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
