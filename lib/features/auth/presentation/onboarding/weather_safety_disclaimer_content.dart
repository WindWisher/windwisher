import 'dart:convert';

import 'package:flutter/services.dart';

class WeatherSafetyDisclaimerContent {
  const WeatherSafetyDisclaimerContent({
    required this.version,
    required this.title,
    required this.introParagraphs,
    required this.bullets,
    required this.closingParagraph,
  });

  static const current = WeatherSafetyDisclaimerContent(
    version: currentVersion,
    title: 'Descargo de meteo y seguridad',
    introParagraphs: [
      'WindWisher puede mostrar previsiones, alertas, spots, sesiones, metricas y otra informacion relacionada con viento, mar y navegacion. Todo ese contenido tiene caracter orientativo e informativo.',
      'Este documento es una base legal provisional pensada para ajustarse mejor al uso real de la app en Espana. Debe revisarse y completarse antes de considerarlo texto legal definitivo.',
    ],
    bullets: [
      'La informacion meteorologica, oceanografica o de spot puede proceder de usuarios, sensores, calculos propios o proveedores externos y puede contener errores, retrasos, lagunas o desactualizacion.',
      'WindWisher no garantiza que una prevision, una alerta, un mapa, una sesion grabada o una metrica deportiva reflejen con exactitud las condiciones reales del agua o del viento en un momento concreto.',
      'Las decisiones de entrar al agua, navegar, saltar, entrenar o desplazarte a un spot son exclusivamente tuyas y deben basarse tambien en tu propia observacion, experiencia y criterio de seguridad.',
      'La app no sustituye avisos oficiales, instrucciones del fabricante, normativa local, socorrismo, formacion tecnica ni juicio profesional en materia de seguridad.',
      'Debes revisar por tu cuenta el estado real del spot, el material, tu nivel, el trafico en el agua y cualquier restriccion o riesgo especifico antes de actuar.',
      'Las metricas de sesiones, saltos, rankings, comunidad o integraciones de terceros pueden contener estimaciones o calculos automaticos y no deben interpretarse como garantia tecnica ni medico-deportiva.',
    ],
    closingParagraph:
        'Si utilizas WindWisher para navegar o planificar una actividad en el agua, aceptas que la app es una ayuda informativa y no una garantia de seguridad ni una fuente oficial de decision.',
  );

  static const currentVersion = '2026-04-draft-1';
  static const currentAssetPath =
      'assets/legal/weather_safety_disclaimer_2026_04_draft_1.json';

  final String version;
  final String title;
  final List<String> introParagraphs;
  final List<String> bullets;
  final String closingParagraph;

  static Future<WeatherSafetyDisclaimerContent> loadCurrent() async {
    try {
      final raw = await rootBundle.loadString(currentAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return current;
      }
      return WeatherSafetyDisclaimerContent.fromJson(decoded);
    } catch (_) {
      return current;
    }
  }

  factory WeatherSafetyDisclaimerContent.fromJson(Map<String, dynamic> json) {
    return WeatherSafetyDisclaimerContent(
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
