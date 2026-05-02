part of '../../../spot_detail_page.dart';

class _CompassDiamondNeedlePainter extends CustomPainter {
  const _CompassDiamondNeedlePainter({
    required this.northColor,
    required this.southColor,
  });

  final Color northColor;
  final Color southColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final northPath = Path()
      ..moveTo(center.dx, 0)
      ..lineTo(size.width, center.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(0, center.dy)
      ..close();

    final southPath = Path()
      ..moveTo(0, center.dy)
      ..lineTo(center.dx, center.dy)
      ..lineTo(size.width, center.dy)
      ..lineTo(center.dx, size.height)
      ..close();

    canvas.drawPath(northPath, Paint()..color = northColor);
    canvas.drawPath(southPath, Paint()..color = southColor);
  }

  @override
  bool shouldRepaint(covariant _CompassDiamondNeedlePainter oldDelegate) {
    return oldDelegate.northColor != northColor ||
        oldDelegate.southColor != southColor;
  }
}

class _WindClockHandPainter extends CustomPainter {
  const _WindClockHandPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final headTipY = 2.0;
    final headBaseY = 20.0;
    final tailY = size.height - 2;

    canvas.drawLine(
      Offset(centerX, tailY + 1),
      Offset(centerX, headBaseY + 1),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round,
    );

    final shaftPaint = Paint()
      ..color = color.withValues(alpha: 0.92)
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, tailY),
      Offset(centerX, headBaseY),
      shaftPaint,
    );

    final headPath = Path()
      ..moveTo(centerX, headTipY)
      ..lineTo(centerX + 7, headBaseY)
      ..lineTo(centerX - 7, headBaseY)
      ..close();
    canvas.drawPath(
      headPath.shift(const Offset(0, 1)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );
    canvas.drawPath(headPath, Paint()..color = color);

    canvas.drawLine(
      Offset(centerX, headTipY + 3),
      Offset(centerX, headBaseY - 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22)
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      Offset(centerX, centerY),
      2.8,
      Paint()..color = color.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _WindClockHandPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _TraditionalCompassRosePainter extends CustomPainter {
  const _TraditionalCompassRosePainter({
    required this.ringColor,
    required this.majorColor,
    required this.minorColor,
    required this.lightPetalColor,
    required this.darkPetalColor,
    required this.accentPetalColor,
    required this.centerGlowColor,
    required this.contrastFillColor,
  });

  final Color ringColor;
  final Color majorColor;
  final Color minorColor;
  final Color lightPetalColor;
  final Color darkPetalColor;
  final Color accentPetalColor;
  final Color centerGlowColor;
  final Color contrastFillColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final outerRadius = radius - 4;
    final starRadius = radius * 0.66;

    final radialFill = Paint()
      ..color = contrastFillColor.withValues(alpha: 0.36);
    canvas.drawCircle(center, outerRadius, radialFill);

    final outerRingPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = ringColor;
    canvas.drawCircle(center, outerRadius, outerRingPaint);
    canvas.drawCircle(center, outerRadius * 0.68, outerRingPaint);
    canvas.drawCircle(
      center,
      outerRadius * 0.9,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = minorColor,
    );

    for (var i = 0; i < 32; i++) {
      final angle = (i * 360 / 32) * math.pi / 180;
      final isMajor = i % 4 == 0;
      final start = Offset(
        center.dx + math.cos(angle) * (outerRadius - (isMajor ? 16 : 8)),
        center.dy + math.sin(angle) * (outerRadius - (isMajor ? 16 : 8)),
      );
      final end = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );
      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = isMajor ? majorColor : minorColor
          ..strokeWidth = isMajor ? 1.4 : 1,
      );
    }

    for (var i = 0; i < 8; i++) {
      final angle = (i * 45 - 90) * math.pi / 180;
      final nextAngle = ((i + 1) * 45 - 90) * math.pi / 180;
      final prevAngle = ((i - 1) * 45 - 90) * math.pi / 180;
      final tip = Offset(
        center.dx + math.cos(angle) * starRadius,
        center.dy + math.sin(angle) * starRadius,
      );
      final left = Offset(
        center.dx + math.cos(prevAngle) * (starRadius * 0.35),
        center.dy + math.sin(prevAngle) * (starRadius * 0.35),
      );
      final right = Offset(
        center.dx + math.cos(nextAngle) * (starRadius * 0.35),
        center.dy + math.sin(nextAngle) * (starRadius * 0.35),
      );
      final path = Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(center.dx, center.dy)
        ..lineTo(right.dx, right.dy)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = i.isEven ? darkPetalColor : lightPetalColor,
      );

      final innerTip = Offset(
        center.dx + math.cos(angle) * (starRadius * 0.38),
        center.dy + math.sin(angle) * (starRadius * 0.38),
      );
      final innerLeft = Offset(
        center.dx + math.cos(prevAngle) * (starRadius * 0.16),
        center.dy + math.sin(prevAngle) * (starRadius * 0.16),
      );
      final innerRight = Offset(
        center.dx + math.cos(nextAngle) * (starRadius * 0.16),
        center.dy + math.sin(nextAngle) * (starRadius * 0.16),
      );
      final innerPath = Path()
        ..moveTo(innerTip.dx, innerTip.dy)
        ..lineTo(innerLeft.dx, innerLeft.dy)
        ..lineTo(center.dx, center.dy)
        ..lineTo(innerRight.dx, innerRight.dy)
        ..close();
      canvas.drawPath(
        innerPath,
        Paint()
          ..style = PaintingStyle.fill
          ..color = i.isEven ? accentPetalColor : Colors.transparent,
      );
    }

    canvas.drawCircle(
      center,
      radius * 0.08,
      Paint()..color = ringColor.withValues(alpha: 0.9),
    );
    canvas.drawCircle(
      center,
      radius * 0.04,
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
  }

  @override
  bool shouldRepaint(covariant _TraditionalCompassRosePainter oldDelegate) {
    return oldDelegate.ringColor != ringColor ||
        oldDelegate.majorColor != majorColor ||
        oldDelegate.minorColor != minorColor ||
        oldDelegate.lightPetalColor != lightPetalColor ||
        oldDelegate.darkPetalColor != darkPetalColor ||
        oldDelegate.accentPetalColor != accentPetalColor ||
        oldDelegate.centerGlowColor != centerGlowColor;
  }
}
