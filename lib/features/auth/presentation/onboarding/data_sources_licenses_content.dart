import 'dart:convert';

import 'package:flutter/services.dart';

class DataSourcesLicensesContent {
  const DataSourcesLicensesContent({
    required this.version,
    required this.title,
    required this.introParagraphs,
    required this.bullets,
    required this.closingParagraph,
  });

  static const current = DataSourcesLicensesContent(
    version: currentVersion,
    title: 'Fuentes de datos y licencias',
    introParagraphs: [
      'WindWisher puede apoyarse en datos propios, datos aportados por usuarios, sensores, dispositivos conectados, servicios meteorologicos, mapas, integraciones tecnicas y otros proveedores externos.',
      'Este documento resume como debe entenderse el uso de esas fuentes dentro de la app y que limites generales existen sobre disponibilidad, atribucion y reutilizacion.',
    ],
    bullets: [
      'Los datos meteorologicos, de spots, mapas, sensores, sesiones o terceros pueden estar sujetos a condiciones, licencias, restricciones tecnicas o politicas de disponibilidad de sus respectivos titulares.',
      'Cuando un proveedor exija atribucion, limitaciones de uso o condiciones especificas, WindWisher debera mostrarlas o enlazarlas de forma razonable dentro del producto o de su documentacion legal.',
      'La presencia de datos de terceros en la app no implica que WindWisher controle su exactitud, continuidad, actualizacion, disponibilidad ni cambios futuros de licencia o acceso.',
      'Los usuarios no deben reutilizar, extraer masivamente, revender, redistribuir o automatizar el acceso a datos mostrados en WindWisher salvo que tengan autorizacion suficiente y respeten las licencias aplicables.',
      'El contenido generado por usuarios, como fotos, comentarios, sesiones o descripciones de spots, puede estar sujeto a derechos propios o de terceros y debe compartirse solo cuando exista permiso o base legitima.',
      'Si una fuente externa cambia, falla, deja de estar disponible o modifica sus condiciones, WindWisher puede adaptar, suspender o retirar las funciones que dependan de ella.',
    ],
    closingParagraph:
        'La version final de este documento debera listar las fuentes concretas usadas por WindWisher, sus atribuciones obligatorias y cualquier condicion especifica relevante para la app.',
  );

  static const currentVersion = '2026-05-draft-1';
  static const currentAssetPath =
      'assets/legal/data_sources_licenses_2026_05_draft_1.json';

  final String version;
  final String title;
  final List<String> introParagraphs;
  final List<String> bullets;
  final String closingParagraph;

  static Future<DataSourcesLicensesContent> loadCurrent() async {
    try {
      final raw = await rootBundle.loadString(currentAssetPath);
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return current;
      }
      return DataSourcesLicensesContent.fromJson(decoded);
    } catch (_) {
      return current;
    }
  }

  factory DataSourcesLicensesContent.fromJson(Map<String, dynamic> json) {
    return DataSourcesLicensesContent(
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
