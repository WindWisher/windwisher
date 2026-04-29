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
      'Esta politica resume como WindWisher puede tratar datos personales vinculados a tu cuenta, perfil, sesiones, comunidad, notificaciones y uso general de la app.',
      'Es una version de trabajo orientada al producto real y pensada para converger con el marco espanol y europeo de proteccion de datos. Aun debe completarse con la revision legal final y con la informacion identificativa definitiva del responsable.',
    ],
    bullets: [
      'WindWisher puede tratar datos de registro y cuenta, perfil publico o privado, preferencias, material, sesiones deportivas, ubicacion asociada a sesiones o spots, mensajes, comentarios, likes, follows, contenido multimedia y configuraciones de notificaciones.',
      'Estos datos pueden utilizarse para prestar funciones principales de la app, sincronizar tu cuenta entre dispositivos, mostrar superficies comunitarias, mantener rankings, proteger la seguridad del servicio y mejorar la experiencia del producto.',
      'Algunas superficies de la app pueden mostrar datos de forma publica o semipublica, como handle, nombre visible, estadisticas, sesiones compartidas o interacciones comunitarias, segun el diseno del producto y los controles disponibles.',
      'La app puede apoyarse en proveedores externos para autenticacion, base de datos, almacenamiento, notificaciones push, mapas, integraciones meteorologicas, mensajeria tecnica o diagnostico de errores.',
      'WindWisher puede tratar datos de ubicacion y datos de actividad solo en la medida necesaria para funciones relacionadas con spots, sesiones, navegacion, comunidad o personalizacion, y su disponibilidad depende tambien de los permisos del dispositivo.',
      'El usuario podra ejercer progresivamente derechos de acceso, rectificacion, supresion, limitacion, oposicion o portabilidad a traves de las herramientas incorporadas en la app o de los canales de contacto que se publiquen en la version final.',
      'La informacion se conservara mientras sea necesaria para la prestacion del servicio, el cumplimiento legal, la seguridad del producto, la gestion de incidencias o la defensa frente a reclamaciones.',
    ],
    closingParagraph:
        'Si no estas de acuerdo con este tratamiento de datos en su version de trabajo, no deberias seguir usando WindWisher hasta disponer del texto legal definitivo y de los controles de privacidad que resulten aplicables.',
  );

  static const currentVersion = '2026-05-draft-1';
  static const currentAssetPath =
      'assets/legal/privacy_policy_2026_05_draft_1.json';

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
