import 'dart:convert';

import 'package:flutter/services.dart';

class LegalNoticeContent {
  const LegalNoticeContent({
    required this.version,
    required this.title,
    required this.introParagraphs,
    required this.bullets,
    required this.closingParagraph,
  });

  static const current = LegalNoticeContent(
    version: currentVersion,
    title: 'Aviso legal',
    introParagraphs: [
      'Este aviso legal resume de forma provisional algunas condiciones generales de uso e informacion basica sobre WindWisher dentro de la app.',
      'Es un texto funcional inicial y debera sustituirse por la version legal definitiva antes de considerarlo cierre normativo.',
    ],
    bullets: [
      'WindWisher es una app en evolucion y algunas funciones, datos o integraciones pueden cambiar con el tiempo.',
      'El contenido mostrado en la app puede depender de datos aportados por usuarios, sensores, servicios conectados o proveedores externos.',
      'La informacion mostrada por la app no sustituye recomendaciones profesionales, instrucciones del fabricante ni criterios de seguridad en el agua.',
      'El usuario debe revisar el uso responsable del producto y valorar por si mismo las condiciones reales de navegacion antes de actuar.',
    ],
    closingParagraph:
        'Si detectas contenido incorrecto o necesitas informacion legal adicional, este bloque podra ampliarse en futuras versiones.',
  );

  static const currentVersion = '2026-04-draft-1';
  static const currentAssetPath =
      'assets/legal/legal_notice_2026_04_draft_1.json';

  final String version;
  final String title;
  final List<String> introParagraphs;
  final List<String> bullets;
  final String closingParagraph;

  static Future<LegalNoticeContent> loadCurrent() async {
    try {
      final raw = await rootBundle.loadString(currentAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return current;
      }
      return LegalNoticeContent.fromJson(decoded);
    } catch (_) {
      return current;
    }
  }

  factory LegalNoticeContent.fromJson(Map<String, dynamic> json) {
    return LegalNoticeContent(
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
