import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/sessions/presentation/models/start_session_models.dart';
import 'package:windwisher/features/sessions/presentation/widgets/start_session/session_downloaded_review_dialog.dart';

void main() {
  const data = SessionDownloadedReviewData(
    title: 'Sesion de prueba',
    deviceName: 'WindWisher Watch',
    dateLabel: '16/09 12:30',
    durationLabel: '42min 18s',
    summary: 'Track completo y validado.',
    sourceFormatLabel: 'JSONL',
    jumpCount: 7,
  );

  testWidgets('shows downloaded session information before upload', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SessionDownloadedReviewDialog(data: data)),
    );

    expect(find.text('Sesion de prueba'), findsOneWidget);
    expect(find.textContaining('WindWisher Watch'), findsOneWidget);
    expect(find.textContaining('42min 18s'), findsOneWidget);
    expect(find.textContaining('Track completo y validado.'), findsOneWidget);
    expect(find.text('Continuar para subir'), findsOneWidget);
    expect(find.text('Eliminar descarga'), findsOneWidget);
  });

  testWidgets('returns upload only after explicit confirmation', (
    tester,
  ) async {
    SessionDownloadedReviewAction? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await SessionDownloadedReviewDialog.show(
                context,
                data: data,
              );
            },
            child: const Text('Abrir'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar para subir'));
    await tester.pumpAndSettle();

    expect(result, SessionDownloadedReviewAction.upload);
  });
}
