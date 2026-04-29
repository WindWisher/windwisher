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
      'Estos terminos regulan el acceso y uso de WindWisher como app orientada a viento, spots, sesiones, comunidad y herramientas de apoyo para actividades en el agua.',
      'Se trata de un borrador de producto mucho mas alineado con el funcionamiento real de la app en Espana. Sigue siendo una version de trabajo y debe pasar revision legal final antes de considerarse texto definitivo.',
    ],
    bullets: [
      'Para usar ciertas funciones de WindWisher necesitas una cuenta y eres responsable de custodiar tus credenciales, asi como de la actividad realizada desde tu acceso.',
      'La app puede permitir crear perfil, guardar sesiones, registrar material, participar en rankings, seguir a otros usuarios, enviar mensajes, comentar y compartir contenido o metricas deportivas.',
      'Parte de la informacion de tu cuenta o de tus sesiones puede mostrarse dentro de superficies publicas o comunitarias del producto si asi lo permite la configuracion y el diseno funcional de la app.',
      'No puedes usar WindWisher para manipular rankings, falsear sesiones, suplantar identidad, subir contenido ilicito, acosar a otros usuarios ni interferir tecnicamente con el servicio.',
      'WindWisher puede suspender funciones, moderar contenido o limitar cuentas cuando sea necesario para seguridad, cumplimiento normativo, integridad del producto o proteccion de la comunidad.',
      'Las metricas, rankings, integraciones, sesiones y resultados mostrados por la app pueden incluir calculos automaticos, estimaciones o datos de terceros, por lo que no constituyen una garantia tecnica absoluta.',
      'El uso de la app no sustituye el criterio personal del usuario, la observacion del entorno, las normas locales, las instrucciones del fabricante ni las decisiones de seguridad en el agua.',
    ],
    closingParagraph:
        'Si no aceptas estos terminos, no debes usar WindWisher ni completar el acceso inicial a la app.',
  );

  static const currentVersion = '2026-05-draft-1';
  static const currentAssetPath =
      'assets/legal/terms_and_conditions_2026_05_draft_1.json';

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
