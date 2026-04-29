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
      'Este aviso legal informa de forma general sobre las condiciones de acceso a WindWisher, la naturaleza del servicio y algunas limitaciones de responsabilidad asociadas al uso de la app.',
      'Es una version de trabajo pensada para aproximarse a un aviso legal conforme al entorno espanol. Debe completarse con la identificacion definitiva del responsable, contacto juridico y cualquier dato mercantil que resulte exigible.',
    ],
    bullets: [
      'WindWisher es una aplicacion digital en evolucion y puede modificar funciones, integraciones, disponibilidad, contenidos, estructura de pantallas o criterios internos de producto con el tiempo.',
      'Parte del contenido visible en la app puede proceder de usuarios, sensores, algoritmos, calculos propios, integraciones tecnicas o proveedores externos, por lo que puede no ser completo, exacto o continuo en todo momento.',
      'Los textos, elementos visuales, nombre de producto, logotipos, interfaces y demas contenidos propios de la app estan sujetos a los derechos que correspondan a sus titulares y no pueden reutilizarse sin base legitima suficiente.',
      'El usuario accede y usa la app bajo su propia responsabilidad, especialmente cuando la informacion mostrada influya en decisiones relacionadas con navegacion, viento, mar, desplazamientos o seguridad en el agua.',
      'WindWisher no sustituye fuentes oficiales, instrucciones tecnicas, formacion especializada, normativa local ni la comprobacion directa de las condiciones reales del entorno.',
      'La app puede enlazar, consumir o mostrar servicios, datos o materiales de terceros y dichos elementos quedan sometidos tambien a las condiciones, disponibilidad y licencias de sus respectivos titulares.',
    ],
    closingParagraph:
        'Si necesitas informacion legal adicional o ejercer derechos relacionados con el servicio, la version final de este aviso legal debera incluir un canal de contacto identificable y estable.',
  );

  static const currentVersion = '2026-05-draft-1';
  static const currentAssetPath =
      'assets/legal/legal_notice_2026_05_draft_1.json';

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
