import 'package:flutter/material.dart';
import 'package:windwisher/features/auth/presentation/onboarding/legal_document_dialog_shell.dart';
import 'package:windwisher/features/auth/presentation/onboarding/weather_safety_disclaimer_content.dart';

class WeatherSafetyDisclaimerDialog extends StatelessWidget {
  const WeatherSafetyDisclaimerDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const WeatherSafetyDisclaimerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WeatherSafetyDisclaimerContent>(
      future: WeatherSafetyDisclaimerContent.loadCurrent(),
      builder: (context, snapshot) {
        final content = snapshot.data ?? WeatherSafetyDisclaimerContent.current;
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
