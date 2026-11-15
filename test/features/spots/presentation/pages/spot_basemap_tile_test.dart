import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:windwisher/features/spots/presentation/pages/spots/widgets/spot_basemap_tile.dart';

void main() {
  testWidgets(
    'basemap palette follows theme without filtering sibling markers',
    (tester) async {
      const tileKey = Key('tile');
      const markerKey = Key('marker');
      for (final brightness in Brightness.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: brightness),
            home: const Stack(
              children: [
                SpotBasemapTile(child: SizedBox(key: tileKey)),
                SizedBox(key: markerKey),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        final filter = tester.widget<ColorFiltered>(find.byType(ColorFiltered));
        expect(
          filter.colorFilter,
          brightness == Brightness.dark
              ? SpotBasemapTile.darkPalette
              : SpotBasemapTile.lightPalette,
        );
        expect(
          find.descendant(
            of: find.byType(ColorFiltered),
            matching: find.byKey(tileKey),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(ColorFiltered),
            matching: find.byKey(markerKey),
          ),
          findsNothing,
        );
      }
    },
  );
}
