import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/aemet_text_normalizer.dart';

void main() {
  group('normalizeAemetText', () {
    test('decodes html entities and strips tags', () {
      expect(
        normalizeAemetText('<p>Situaci&oacute;n&nbsp;general &amp; viento</p>'),
        'Situación general & viento',
      );
    });

    test('repairs common mojibake from AEMET payloads', () {
      expect(
        normalizeAemetText('Cielo poco nuboso. Temperatura: 21 ÂºC'),
        'Cielo poco nuboso. Temperatura: 21 ºC',
      );
      expect(
        normalizeAemetText('PredicciÃ³n marÃ­tima'),
        'Predicción marítima',
      );
      expect(
        normalizeAemetText('PredicciÃƒÂ³n marÃƒÂ­tima'),
        'Predicción marítima',
      );
    });

    test('repairs common replacement characters in known AEMET words', () {
      expect(
        normalizeAemetText('Predicci�n mar�tima. Sensaci�n t�rmica.'),
        'Predicción marítima. Sensación térmica.',
      );
      expect(
        normalizeAemetText('Ma�ana: temperatura m�xima'),
        'Mañana: temperatura máxima',
      );
      expect(normalizeAemetText('Ma�ana: d�bil'), 'Mañana: débil');
      expect(
        normalizeAemetText(
          'V�lido para las pr�ximas horas. Presi�n y direcci�n del viento.',
        ),
        'Válido para las próximas horas. Presión y dirección del viento.',
      );
      expect(
        normalizeAemetText('Mediterr�neo, Catalu�a, D�NIA y M�laga.'),
        'Mediterráneo, Cataluña, DÉNIA y Málaga.',
      );
    });

    test('removes unknown replacement characters as a last resort', () {
      expect(normalizeAemetText('Texto extra�o'), 'Texto extrao');
    });

    test('can strip accents for long coastal bulletin text', () {
      expect(
        normalizeAemetText(
          'Predicci�n mar�tima. Situaci�n general en D�NIA.',
          stripAccents: true,
        ),
        'Prediccion maritima. Situacion general en DENIA.',
      );
    });

    test('uses fallback for empty values', () {
      expect(normalizeAemetText('', fallback: 'Sin dato'), 'Sin dato');
      expect(normalizeAemetText(null, fallback: 'Sin dato'), 'Sin dato');
    });
  });
}
