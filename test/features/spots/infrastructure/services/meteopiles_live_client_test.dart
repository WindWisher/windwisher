import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/infrastructure/services/meteopiles_live_client.dart';

void main() {
  Future<MeteopilesLiveSnapshot?> read(String timestamp) {
    final values = List<String>.filled(26, '0');
    values[0] = 'F=$timestamp';
    values[1] = '12:16:26';
    values[4] = '10';
    return MeteopilesLiveClient(
      fetchText: (_) async => values.join(','),
    ).fetchSnapshot();
  }

  test('does not relabel the stale 2020 feed as current', () async {
    expect(await read('3788594186'), isNull);
  });
  test('does not use today when the VWS timestamp is missing', () async {
    expect(await read('invalid'), isNull);
  });
  test('rejects future timestamps', () async {
    final future = DateTime.now().toUtc().add(const Duration(hours: 1));
    expect(
      await read('${future.difference(DateTime.utc(1900)).inSeconds}'),
      isNull,
    );
  });
  test('accepts a recent VWS timestamp and converts mph to knots', () async {
    final recent = DateTime.now().toUtc().subtract(const Duration(minutes: 5));
    final snapshot = await read(
      '${recent.difference(DateTime.utc(1900)).inSeconds}',
    );
    expect(snapshot?.windKnots, closeTo(8.68976242, .00001));
  });
}
