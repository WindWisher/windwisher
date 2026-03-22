import 'package:flutter/material.dart';

Color windSemaforoColor(double knots) {
  const blueLight = Color(0xFF64B5F6);
  const blueDark = Color(0xFF1565C0);
  const cyanLight = Color(0xFF4DD0E1);
  const cyanDark = Color(0xFF00838F);
  const greenLight = Color(0xFF81C784);
  const greenDark = Color(0xFF2E7D32);
  const yellowLight = Color(0xFFFFEE58);
  const yellowDark = Color(0xFFF9A825);
  const orangeLight = Color(0xFFFFB74D);
  const orangeDark = Color(0xFFEF6C00);
  const redLight = Color(0xFFEF5350);
  const redDark = Color(0xFFC62828);
  const purpleLight = Color(0xFFBA68C8);
  const purpleDark = Color(0xFF7B1FA2);

  if (knots < 10) {
    final t = (knots / 10).clamp(0.0, 1.0);
    return Color.lerp(blueLight, blueDark, t)!;
  }
  if (knots < 14) {
    final t = ((knots - 10) / 4).clamp(0.0, 1.0);
    return Color.lerp(cyanLight, cyanDark, t)!;
  }
  if (knots < 18) {
    final t = ((knots - 14) / 4).clamp(0.0, 1.0);
    return Color.lerp(greenLight, greenDark, t)!;
  }
  if (knots < 26) {
    final t = ((knots - 18) / 8).clamp(0.0, 1.0);
    return Color.lerp(yellowLight, yellowDark, t)!;
  }
  if (knots < 32) {
    final t = ((knots - 26) / 6).clamp(0.0, 1.0);
    return Color.lerp(orangeLight, orangeDark, t)!;
  }
  if (knots <= 40) {
    final t = ((knots - 32) / 8).clamp(0.0, 1.0);
    return Color.lerp(redLight, redDark, t)!;
  }
  final t = ((knots - 40) / 10).clamp(0.0, 1.0);
  return Color.lerp(purpleLight, purpleDark, t)!;
}
