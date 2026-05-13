import 'dart:convert';

String normalizeAemetText(
  dynamic value, {
  String fallback = '-',
  bool stripAccents = false,
}) {
  if (value is! String || value.trim().isEmpty) {
    return fallback;
  }
  final withoutTags = value.replaceAll(RegExp(r'<[^>]*>'), ' ');
  final decodedEntities = _decodeHtmlEntities(withoutTags);
  final repaired = _repairMojibake(decodedEntities);
  final normalized = _repairReplacementCharacters(
    repaired,
  ).replaceAll('\u00a0', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (normalized.isEmpty) {
    return fallback;
  }
  return stripAccents ? _stripSpanishAccents(normalized) : normalized;
}

String _decodeHtmlEntities(String input) {
  final named = input
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&apos;', "'")
      .replaceAll('&deg;', '\u00b0')
      .replaceAll('&ordm;', '\u00ba')
      .replaceAll('&aacute;', '\u00e1')
      .replaceAll('&eacute;', '\u00e9')
      .replaceAll('&iacute;', '\u00ed')
      .replaceAll('&oacute;', '\u00f3')
      .replaceAll('&uacute;', '\u00fa')
      .replaceAll('&Aacute;', '\u00c1')
      .replaceAll('&Eacute;', '\u00c9')
      .replaceAll('&Iacute;', '\u00cd')
      .replaceAll('&Oacute;', '\u00d3')
      .replaceAll('&Uacute;', '\u00da')
      .replaceAll('&ntilde;', '\u00f1')
      .replaceAll('&Ntilde;', '\u00d1')
      .replaceAll('&uuml;', '\u00fc')
      .replaceAll('&Uuml;', '\u00dc')
      .replaceAll('&ccedil;', '\u00e7')
      .replaceAll('&Ccedil;', '\u00c7');

  return named.replaceAllMapped(RegExp(r'&#(x?[0-9a-fA-F]+);'), (match) {
    final raw = match.group(1);
    if (raw == null || raw.isEmpty) {
      return match.group(0) ?? '';
    }
    final isHex = raw.startsWith('x') || raw.startsWith('X');
    final codePoint = int.tryParse(
      isHex ? raw.substring(1) : raw,
      radix: isHex ? 16 : 10,
    );
    if (codePoint == null) {
      return match.group(0) ?? '';
    }
    return String.fromCharCode(codePoint);
  });
}

String _repairMojibake(String input) {
  var current = _repairKnownMojibake(input);
  for (var attempt = 0; attempt < 3; attempt += 1) {
    if (!current.contains('Ã') &&
        !current.contains('Â') &&
        !current.contains('â')) {
      return current;
    }
    try {
      final repaired = utf8.decode(latin1.encode(current));
      if (repaired == current) {
        return current;
      }
      current = repaired;
    } catch (_) {
      return current;
    }
  }
  return current;
}

String _repairKnownMojibake(String input) {
  return input
      .replaceAll('ÃƒÂ¡', 'á')
      .replaceAll('ÃƒÂ©', 'é')
      .replaceAll('ÃƒÂ­', 'í')
      .replaceAll('ÃƒÂ³', 'ó')
      .replaceAll('ÃƒÂº', 'ú')
      .replaceAll('ÃƒÂ±', 'ñ')
      .replaceAll('ÃƒÂ¼', 'ü')
      .replaceAll('Ã‚Âº', 'º')
      .replaceAll('Ã‚Â°', '°')
      .replaceAll('Ã¡', 'á')
      .replaceAll('Ã©', 'é')
      .replaceAll('Ã­', 'í')
      .replaceAll('Ã³', 'ó')
      .replaceAll('Ãº', 'ú')
      .replaceAll('Ã±', 'ñ')
      .replaceAll('Ã¼', 'ü')
      .replaceAll('Âº', 'º')
      .replaceAll('Â°', '°');
}

String _repairReplacementCharacters(String input) {
  return input
      .replaceAll('Predicci�n', 'Predicción')
      .replaceAll('predicci�n', 'predicción')
      .replaceAll('mar�tima', 'marítima')
      .replaceAll('Mar�tima', 'Marítima')
      .replaceAll('situaci�n', 'situación')
      .replaceAll('Situaci�n', 'Situación')
      .replaceAll('sensaci�n', 'sensación')
      .replaceAll('Sensaci�n', 'Sensación')
      .replaceAll('informaci�n', 'información')
      .replaceAll('Informaci�n', 'Información')
      .replaceAll('emisi�n', 'emisión')
      .replaceAll('Emisi�n', 'Emisión')
      .replaceAll('elaboraci�n', 'elaboración')
      .replaceAll('Elaboraci�n', 'Elaboración')
      .replaceAll('direcci�n', 'dirección')
      .replaceAll('Direcci�n', 'Dirección')
      .replaceAll('presi�n', 'presión')
      .replaceAll('Presi�n', 'Presión')
      .replaceAll('precipitaci�n', 'precipitación')
      .replaceAll('Precipitaci�n', 'Precipitación')
      .replaceAll('t�rmica', 'térmica')
      .replaceAll('T�rmica', 'Térmica')
      .replaceAll('ma�ana', 'mañana')
      .replaceAll('Ma�ana', 'Mañana')
      .replaceAll('d�a', 'día')
      .replaceAll('D�a', 'Día')
      .replaceAll('d�bil', 'débil')
      .replaceAll('D�bil', 'Débil')
      .replaceAll('m�xima', 'máxima')
      .replaceAll('M�xima', 'Máxima')
      .replaceAll('m�nima', 'mínima')
      .replaceAll('M�nima', 'Mínima')
      .replaceAll('m�ximo', 'máximo')
      .replaceAll('M�ximo', 'Máximo')
      .replaceAll('m�nimo', 'mínimo')
      .replaceAll('M�nimo', 'Mínimo')
      .replaceAll('v�lido', 'válido')
      .replaceAll('V�lido', 'Válido')
      .replaceAll('pr�ximo', 'próximo')
      .replaceAll('Pr�ximo', 'Próximo')
      .replaceAll('pr�xima', 'próxima')
      .replaceAll('Pr�xima', 'Próxima')
      .replaceAll('pr�ximas', 'próximas')
      .replaceAll('Pr�ximas', 'Próximas')
      .replaceAll('m�s', 'más')
      .replaceAll('M�s', 'Más')
      .replaceAll('ser�', 'será')
      .replaceAll('Ser�', 'Será')
      .replaceAll('tambi�n', 'también')
      .replaceAll('Tambi�n', 'También')
      .replaceAll('d�biles', 'débiles')
      .replaceAll('D�biles', 'Débiles')
      .replaceAll('Mediterr�neo', 'Mediterráneo')
      .replaceAll('mediterr�neo', 'mediterráneo')
      .replaceAll('Atl�ntico', 'Atlántico')
      .replaceAll('atl�ntico', 'atlántico')
      .replaceAll('Cant�brico', 'Cantábrico')
      .replaceAll('cant�brico', 'cantábrico')
      .replaceAll('Catalu�a', 'Cataluña')
      .replaceAll('catalu�a', 'cataluña')
      .replaceAll('Coru�a', 'Coruña')
      .replaceAll('coru�a', 'coruña')
      .replaceAll('Almer�a', 'Almería')
      .replaceAll('almer�a', 'almería')
      .replaceAll('Andaluc�a', 'Andalucía')
      .replaceAll('andaluc�a', 'andalucía')
      .replaceAll('M�laga', 'Málaga')
      .replaceAll('m�laga', 'málaga')
      .replaceAll('C�diz', 'Cádiz')
      .replaceAll('c�diz', 'cádiz')
      .replaceAll('D�nia', 'Dénia')
      .replaceAll('D�NIA', 'DÉNIA')
      .replaceAll('�', '');
}

String _stripSpanishAccents(String input) {
  return input
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('Á', 'A')
      .replaceAll('É', 'E')
      .replaceAll('Í', 'I')
      .replaceAll('Ó', 'O')
      .replaceAll('Ú', 'U')
      .replaceAll('ñ', 'n')
      .replaceAll('Ñ', 'N')
      .replaceAll('ü', 'u')
      .replaceAll('Ü', 'U')
      .replaceAll('ç', 'c')
      .replaceAll('Ç', 'C');
}
