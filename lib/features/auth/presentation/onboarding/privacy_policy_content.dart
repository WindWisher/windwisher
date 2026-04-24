import 'dart:convert';

import 'package:flutter/services.dart';

class PrivacyPolicyContent {
  const PrivacyPolicyContent({
    required this.version,
    required this.title,
    required this.introParagraphs,
    required this.bullets,
    required this.closingParagraph,
  });

  static const current = PrivacyPolicyContent(
    version: currentVersion,
    title: 'Politica de privacidad',
    introParagraphs: [
      'Esta politica de privacidad describe de forma provisional como WindWisher puede recoger, guardar y mostrar informacion vinculada a tu cuenta.',
      'Este texto es una base funcional inicial y debe sustituirse por la version legal definitiva antes de considerarlo como politica de privacidad cerrada.',
    ],
    bullets: [
      'La app puede almacenar datos de perfil, sesiones, material, mensajes y preferencias para prestar sus funciones principales.',
      'Algunos datos pueden mostrarse de forma publica dentro del producto si estan asociados a superficies comunitarias, como tu handle, nombre visible o sesiones publicas.',
      'La app puede usar servicios de terceros necesarios para autenticacion, almacenamiento, notificaciones y sincronizacion de datos.',
      'Puedes solicitar cambios futuros sobre tu informacion a traves de las herramientas que el producto vaya incorporando en ajustes o perfil.',
    ],
    closingParagraph:
        'Si no estas de acuerdo con esta base provisional de privacidad, te recomendamos no continuar usando la app hasta disponer del texto legal definitivo.',
  );

  static const currentVersion = '2026-04-draft-1';
  static const currentAssetPath =
      'assets/legal/privacy_policy_2026_04_draft_1.json';

  final String version;
  final String title;
  final List<String> introParagraphs;
  final List<String> bullets;
  final String closingParagraph;

  static Future<PrivacyPolicyContent> loadCurrent() async {
    try {
      final raw = await rootBundle.loadString(currentAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return current;
      }
      return PrivacyPolicyContent.fromJson(decoded);
    } catch (_) {
      return current;
    }
  }

  factory PrivacyPolicyContent.fromJson(Map<String, dynamic> json) {
    return PrivacyPolicyContent(
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
