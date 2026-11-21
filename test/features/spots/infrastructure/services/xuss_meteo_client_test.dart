import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/xuss_meteo_client.dart';

void main() {
  Future<XussMeteoSnapshot?> read(String date) => XussMeteoClient(
    fetchText: (_) async =>
        'Ultima grabación a: $date'
        '<table><tr><td>Velocidad media del viento</td>'
        '<td>18,52 kmh (10 kts)</td></tr></table>',
  ).fetchDeniaSnapshot();

  for (final month in ['November', 'noviembre', 'NOV', 'nov']) {
    test(
      'reads $month and Madrid winter time independently of device zone',
      () async {
        final result = await read('08:42 Data: 21 $month 2026');
        expect(result?.observedAt, DateTime.utc(2026, 11, 21, 7, 42));
        expect(result?.windKnots, 10);
      },
    );
  }
  test('uses Madrid daylight saving time in summer', () async {
    final result = await read('08:42 Data: 21 July 2026');
    expect(result?.observedAt, DateTime.utc(2026, 7, 21, 6, 42));
  });
  for (final date in [
    '08:42 Data: 31 November 2026',
    '24:42 Data: 21 November 2026',
    '08:60 Data: 21 November 2026',
    '08:42 Data: 21 unknown 2026',
    'unavailable',
  ]) {
    test('does not invent a timestamp for $date', () async {
      expect((await read(date))?.observedAt, isNull);
    });
  }
}
