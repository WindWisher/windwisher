import 'dart:convert';

import 'package:flutter/services.dart';

class CommunityGuidelinesContent {
  const CommunityGuidelinesContent({
    required this.version,
    required this.title,
    required this.introParagraphs,
    required this.bullets,
    required this.closingParagraph,
  });

  static const current = CommunityGuidelinesContent(
    version: currentVersion,
    title: 'Normas de comunidad y rankings',
    introParagraphs: [
      'WindWisher puede incluir perfiles, sesiones compartidas, rankings, comentarios, mensajes, follows, likes y otras funciones comunitarias relacionadas con viento, spots y actividad deportiva.',
      'Estas normas son una base de trabajo para proteger la convivencia, la integridad de los resultados y el uso responsable de las zonas publicas de la app.',
    ],
    bullets: [
      'Debes tratar a otros usuarios con respeto y no publicar amenazas, acoso, insultos, discriminacion, datos personales ajenos ni contenido que pueda ser ilegal o lesivo.',
      'El contenido que compartas, incluyendo fotos, comentarios, sesiones, spots o descripciones, debe respetar derechos de terceros y no debe inducir a error de forma deliberada.',
      'No esta permitido manipular sesiones, falsear metricas, simular actividad, alterar datos de sensores o usar medios tecnicos para obtener ventajas injustas en rankings o leaderboards.',
      'WindWisher puede moderar, ocultar, limitar o eliminar contenido y actividad comunitaria cuando sea necesario para proteger a usuarios, mantener la calidad del servicio o cumplir obligaciones legales.',
      'Los rankings y metricas comunitarias son referencias deportivas y sociales dentro de la app; pueden depender de algoritmos, sensores, integraciones o criterios de calidad que evolucionen con el tiempo.',
      'Si una sesion, comentario, perfil o interaccion publica genera riesgo, conflicto o informacion incorrecta, la app podra incorporar mecanismos de revision, reporte o actuacion proporcional.',
    ],
    closingParagraph:
        'El objetivo de estas normas es que WindWisher sea una comunidad util, segura y honesta para riders, spots y navegacion.',
  );

  static const currentVersion = '2026-05-draft-1';
  static const currentAssetPath =
      'assets/legal/community_guidelines_2026_05_draft_1.json';

  final String version;
  final String title;
  final List<String> introParagraphs;
  final List<String> bullets;
  final String closingParagraph;

  static Future<CommunityGuidelinesContent> loadCurrent() async {
    try {
      final raw = await rootBundle.loadString(currentAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return current;
      }
      return CommunityGuidelinesContent.fromJson(decoded);
    } catch (_) {
      return current;
    }
  }

  factory CommunityGuidelinesContent.fromJson(Map<String, dynamic> json) {
    return CommunityGuidelinesContent(
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
