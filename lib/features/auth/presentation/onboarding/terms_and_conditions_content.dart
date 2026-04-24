import 'dart:convert';

import 'package:flutter/services.dart';

class TermsAndConditionsContent {
  const TermsAndConditionsContent({
    required this.version,
    required this.title,
    required this.introParagraphs,
    required this.bullets,
    required this.closingParagraph,
  });

  static const current = TermsAndConditionsContent(
    version: currentVersion,
    title: 'Terminos y condiciones',
    introParagraphs: [
      'Para continuar usando WindWisher debes aceptar los terminos y condiciones de la app.',
      'Este texto es una base funcional provisional para poder cerrar el flujo de primer acceso. Debe sustituirse por la version legal definitiva antes de considerar este paso como compliance final.',
    ],
    bullets: [
      'La app puede guardar y mostrar informacion de perfil, sesiones, material y preferencias vinculadas a tu cuenta.',
      'Parte de la informacion puede mostrarse de forma publica si asi lo permite el producto, como tu handle, nombre visible, estadisticas o sesiones publicas.',
      'Eres responsable de revisar la informacion que compartes y de mantener tus credenciales de acceso bajo control.',
      'La app puede enviar notificaciones y usar servicios conectados para mejorar la experiencia.',
    ],
    closingParagraph:
        'Si no aceptas estos terminos, no podras completar el acceso inicial a la app.',
  );

  static const currentVersion = '2026-04-draft-1';
  static const currentAssetPath =
      'assets/legal/terms_and_conditions_2026_04_draft_1.json';

  final String version;
  final String title;
  final List<String> introParagraphs;
  final List<String> bullets;
  final String closingParagraph;

  static Future<TermsAndConditionsContent> loadCurrent() async {
    try {
      final raw = await rootBundle.loadString(currentAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return current;
      }
      return TermsAndConditionsContent.fromJson(decoded);
    } catch (_) {
      return current;
    }
  }

  factory TermsAndConditionsContent.fromJson(Map<String, dynamic> json) {
    return TermsAndConditionsContent(
      version: (json['version'] as String?)?.trim().isNotEmpty == true
          ? json['version'] as String
          : currentVersion,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? json['title'] as String
          : current.title,
      introParagraphs: _readStringList(
        json['introParagraphs'],
        fallback: current.introParagraphs,
      ),
      bullets: _readStringList(json['bullets'], fallback: current.bullets),
      closingParagraph:
          (json['closingParagraph'] as String?)?.trim().isNotEmpty == true
          ? json['closingParagraph'] as String
          : current.closingParagraph,
    );
  }

  static List<String> _readStringList(
    Object? raw, {
    required List<String> fallback,
  }) {
    if (raw is! List) {
      return fallback;
    }
    final values = raw
        .whereType<String>()
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (values.isEmpty) {
      return fallback;
    }
    return values;
  }
}
