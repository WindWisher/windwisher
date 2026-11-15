import 'package:flutter/material.dart';

/// Display-only palette; source tiles and attribution remain unchanged.
class SpotBasemapTile extends StatelessWidget {
  const SpotBasemapTile({super.key, required this.child});

  final Widget child;

  static const lightPalette = ColorFilter.matrix([
    0.396,
    0.504,
    0.1,
    0,
    0,
    0.216,
    0.684,
    0.1,
    0,
    0,
    0.216,
    0.504,
    0.28,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  // Invert luminance into slate, not RGB into complementary map colors.
  static const darkPalette = ColorFilter.matrix([
    -0.149,
    -0.501,
    -0.05,
    0,
    202,
    -0.149,
    -0.501,
    -0.05,
    0,
    208,
    -0.149,
    -0.501,
    -0.05,
    0,
    214,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: Theme.of(context).brightness == Brightness.dark
          ? darkPalette
          : lightPalette,
      child: child,
    );
  }
}
