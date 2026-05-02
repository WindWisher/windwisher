part of '../../../spot_detail_page.dart';

class _LiveWindChartPainter extends CustomPainter {
  const _LiveWindChartPainter({
    required this.points,
    required this.gustPoints,
    required this.timeLabels,
    required this.pointXFractions,
    required this.forecastPoints,
    required this.markerDirectionsDeg,
    required this.markerDirectionKinds,
    required this.overlayMarkers,
    required this.timeGuides,
    required this.dayStartIndexes,
    required this.dayStartLabels,
    required this.realLineColor,
    required this.gustLineColor,
    required this.forecastLineColor,
    required this.gridMajorColor,
    required this.gridMinorColor,
    required this.textColor,
    required this.windSpeedUnit,
  });

  final List<double> points;
  final List<double?>? gustPoints;
  final List<String> timeLabels;
  final List<double> pointXFractions;
  final List<double?>? forecastPoints;
  final List<int?> markerDirectionsDeg;
  final List<_HistoricalDirectionKind?> markerDirectionKinds;
  final List<_ChartArrowMarker> overlayMarkers;
  final List<_ChartTimeGuide> timeGuides;
  final List<int> dayStartIndexes;
  final List<String> dayStartLabels;
  final Color realLineColor;
  final Color gustLineColor;
  final Color forecastLineColor;
  final Color gridMajorColor;
  final Color gridMinorColor;
  final Color textColor;
  final _WindSpeedUnit windSpeedUnit;

  static const _yMin = 0.0;

  double _normalizeDirectionDeg(double degrees) {
    final normalized = degrees % 360;
    return normalized < 0 ? normalized + 360 : normalized;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.width <= 0 || size.height <= 0) return;

    double computedMax = 0;
    for (final v in points) {
      final display = _displayWindValue(v, windSpeedUnit);
      if (display > computedMax) computedMax = display;
    }
    if (gustPoints != null) {
      for (final v in gustPoints!) {
        if (v == null) continue;
        final display = _displayWindValue(v, windSpeedUnit);
        if (display > computedMax) computedMax = display;
      }
    }
    if (forecastPoints != null) {
      for (final v in forecastPoints!) {
        if (v == null) continue;
        final display = _displayWindValue(v, windSpeedUnit);
        if (display > computedMax) computedMax = display;
      }
    }
    final minChartMax = _historicalMinChartMax(windSpeedUnit);
    final minorStep = _historicalMinorStep(windSpeedUnit);
    final majorStep = _historicalMajorStep(windSpeedUnit);
    final yMax = math.max(
      minChartMax,
      (computedMax / minorStep).ceil() * minorStep + minorStep,
    );

    final leftPad = _liveChartLeftPad;
    final rightPad = 12.0;
    final topPad = 12.0;
    final bottomPad = 32.0;
    final plot = Rect.fromLTWH(
      leftPad,
      topPad,
      size.width - leftPad - rightPad,
      size.height - topPad - bottomPad,
    );
    if (plot.width <= 0 || plot.height <= 0) return;

    final plotBackground = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [gridMajorColor.withValues(alpha: 0.05), Colors.transparent],
      ).createShader(plot);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plot, const Radius.circular(10)),
      plotBackground,
    );

    final majorGrid = Paint()
      ..color = gridMajorColor
      ..strokeWidth = 0.8;
    final minorGrid = Paint()
      ..color = gridMinorColor
      ..strokeWidth = 0.6;

    for (var k = _yMin; k <= yMax; k += minorStep) {
      final t = (k - _yMin) / (yMax - _yMin);
      final y = plot.bottom - (t * plot.height);
      final isMajor =
          ((k / majorStep).roundToDouble() - (k / majorStep)).abs() < 0.001;
      canvas.drawLine(
        Offset(plot.left, y),
        Offset(plot.right, y),
        isMajor ? majorGrid : minorGrid,
      );
      if (!isMajor) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: _formatHistoricalAxisValue(k, windSpeedUnit),
          style: TextStyle(
            fontSize: 10,
            color: textColor.withValues(alpha: 0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(plot.left - tp.width - 4, y - (tp.height / 2)));
    }

    if (timeGuides.isNotEmpty) {
      for (final guide in timeGuides) {
        final x = plot.left + (plot.width * guide.xFraction);
        canvas.drawLine(
          Offset(x, plot.top),
          Offset(x, plot.bottom),
          guide.isMajor
              ? (Paint()
                  ..color = gridMajorColor.withValues(alpha: 0.9)
                  ..strokeWidth = 1.0)
              : (Paint()
                  ..color = gridMinorColor.withValues(alpha: 0.75)
                  ..strokeWidth = 0.6),
        );
        if (guide.label == null) continue;
        final tp = TextPainter(
          text: TextSpan(
            text: guide.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.9),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - (tp.width / 2), plot.bottom + 6));
      }
    } else {
      final labelStep = points.length > 96
          ? 12
          : points.length > 48
          ? 6
          : 3;
      for (var i = 0; i < points.length; i++) {
        if (i % labelStep != 0) continue;
        final x = pointXFractions.length == points.length
            ? plot.left + (plot.width * pointXFractions[i])
            : points.length == 1
            ? plot.left
            : plot.left + (plot.width * i / (points.length - 1));
        canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), majorGrid);
        if (i < timeLabels.length) {
          final tp = TextPainter(
            text: TextSpan(
              text: timeLabels[i],
              style: TextStyle(
                fontSize: 10,
                color: textColor.withValues(alpha: 0.86),
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tp.paint(canvas, Offset(x - (tp.width / 2), plot.bottom + 6));
        }
      }
    }

    for (var i = 0; i < dayStartIndexes.length; i++) {
      final index = dayStartIndexes[i];
      if (index < 0 || index >= points.length) continue;
      final x = pointXFractions.length == points.length
          ? plot.left + (plot.width * pointXFractions[index])
          : points.length == 1
          ? plot.left
          : plot.left + (plot.width * index / (points.length - 1));
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        Paint()
          ..color = realLineColor.withValues(alpha: 0.28)
          ..strokeWidth = 1.4,
      );
      if (i >= dayStartLabels.length) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: dayStartLabels[i],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: textColor.withValues(alpha: 0.92),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = (x + 4).clamp(plot.left, plot.right - tp.width);
      tp.paint(canvas, Offset(dx, plot.top - 2));
    }

    Offset toOffset(int i, double v) {
      final x = pointXFractions.length == points.length
          ? plot.left + (plot.width * pointXFractions[i])
          : points.length == 1
          ? plot.left
          : plot.left + (plot.width * i / (points.length - 1));
      final displayValue = _displayWindValue(v, windSpeedUnit);
      final clamped = displayValue.clamp(_yMin, yMax);
      final y =
          plot.bottom - ((clamped - _yMin) / (yMax - _yMin)) * plot.height;
      return Offset(x, y);
    }

    Path buildPath(List<double> values) {
      final path = Path();
      for (var i = 0; i < values.length; i++) {
        final p = toOffset(i, values[i]);
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      return path;
    }

    Path buildStepPath(List<double> values) {
      final path = Path();
      if (values.isEmpty) {
        return path;
      }
      final first = toOffset(0, values[0]);
      path.moveTo(first.dx, first.dy);
      for (var i = 1; i < values.length; i++) {
        final previous = toOffset(i - 1, values[i - 1]);
        final current = toOffset(i, values[i]);
        path.lineTo(current.dx, previous.dy);
        path.lineTo(current.dx, current.dy);
      }
      return path;
    }

    Path buildSmoothPath(List<double> values) {
      if (values.length < 3) {
        return buildPath(values);
      }
      final path = Path();
      var previous = toOffset(0, values[0]);
      path.moveTo(previous.dx, previous.dy);
      for (var i = 1; i < values.length; i++) {
        final current = toOffset(i, values[i]);
        final mid = Offset(
          (previous.dx + current.dx) / 2,
          (previous.dy + current.dy) / 2,
        );
        path.quadraticBezierTo(previous.dx, previous.dy, mid.dx, mid.dy);
        previous = current;
      }
      path.lineTo(previous.dx, previous.dy);
      return path;
    }

    final useSteppedWindScale = windSpeedUnit == _WindSpeedUnit.beaufort;
    final realSeriesPath = useSteppedWindScale
        ? buildStepPath(points)
        : buildSmoothPath(points);
    final realFill = Path.from(realSeriesPath)
      ..lineTo(plot.right, plot.bottom)
      ..lineTo(plot.left, plot.bottom)
      ..close();
    canvas.drawPath(
      realFill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            realLineColor.withValues(alpha: 0.22),
            realLineColor.withValues(alpha: 0.02),
          ],
        ).createShader(plot),
    );

    canvas.drawPath(
      realSeriesPath,
      Paint()
        ..color = realLineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round,
    );

    if (gustPoints != null && gustPoints!.any((value) => value != null)) {
      final gustPath = _buildPathForIndexedValues(
        List<int>.generate(
          gustPoints!.length,
          (index) => index,
          growable: false,
        ),
        gustPoints!.map((value) => value ?? double.nan).toList(growable: false),
        toOffset,
        useSteppedWindScale,
        skipNaN: true,
      );
      canvas.drawPath(
        gustPath,
        Paint()
          ..color = gustLineColor.withValues(alpha: 0.92)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
      );
    }

    if (forecastPoints != null &&
        forecastPoints!.any((value) => value != null)) {
      _drawDashedNullableSeries(
        canvas,
        forecastPoints!,
        toOffset,
        Paint()
          ..color = forecastLineColor.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8
          ..strokeCap = StrokeCap.round,
        useSteppedWindScale,
      );
    }

    Color semaforoColor(double knots) => _windSemaforoColor(knots);

    final arrowBase = Path()
      ..moveTo(0, -11.5)
      ..lineTo(8.5, 8.5)
      ..lineTo(0, 4.4)
      ..lineTo(-8.5, 8.5)
      ..close();

    void drawArrowMarker({
      required double xFraction,
      required double windKnots,
      required int directionDeg,
      required _HistoricalDirectionKind directionKind,
    }) {
      final displayValue = _displayWindValue(windKnots, windSpeedUnit);
      final p = Offset(
        plot.left + (plot.width * xFraction),
        plot.bottom -
            (((displayValue.clamp(_yMin, yMax) - _yMin) / (yMax - _yMin)) *
                plot.height),
      );
      final markerColor = semaforoColor(windKnots);
      final flowDirectionDeg =
          (_normalizeDirectionDeg(directionDeg.toDouble()) + 180) % 360;
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate((flowDirectionDeg * math.pi) / 180);
      canvas.drawPath(
        arrowBase,
        Paint()
          ..color = markerColor.withValues(alpha: 1)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        arrowBase,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.72)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );
      canvas.drawShadow(
        arrowBase,
        Colors.black.withValues(alpha: 0.22),
        2.8,
        true,
      );
      canvas.drawPath(
        arrowBase,
        Paint()
          ..color = markerColor
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    }

    for (final marker in overlayMarkers) {
      drawArrowMarker(
        xFraction: marker.xFraction,
        windKnots: marker.windKnots,
        directionDeg: marker.directionDeg,
        directionKind: marker.kind,
      );
    }

    for (var i = 0; i < points.length; i++) {
      final directionDeg = i < markerDirectionsDeg.length
          ? markerDirectionsDeg[i]
          : null;
      final directionKind = i < markerDirectionKinds.length
          ? markerDirectionKinds[i]
          : null;
      if (directionDeg == null || directionKind == null) continue;
      final xFraction = pointXFractions.length == points.length
          ? pointXFractions[i]
          : points.length <= 1
          ? 0.0
          : i / (points.length - 1);
      drawArrowMarker(
        xFraction: xFraction,
        windKnots: points[i],
        directionDeg: directionDeg,
        directionKind: directionKind,
      );
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dash = 5.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var dist = 0.0;
      while (dist < metric.length) {
        final next = math.min(metric.length, dist + dash);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist += dash + gap;
      }
    }
  }

  void _drawDashedNullableSeries(
    Canvas canvas,
    List<double?> values,
    Offset Function(int index, double value) toOffset,
    Paint paint,
    bool stepped,
  ) {
    final activeIndexes = <int>[];
    final activeValues = <double>[];

    void flush() {
      if (activeIndexes.isEmpty) {
        return;
      }
      if (activeIndexes.length == 1) {
        final point = toOffset(activeIndexes.first, activeValues.first);
        canvas.drawLine(
          Offset(point.dx - 4, point.dy),
          Offset(point.dx + 4, point.dy),
          paint,
        );
      } else {
        _drawDashedPath(
          canvas,
          _buildPathForIndexedValues(
            activeIndexes,
            activeValues,
            toOffset,
            stepped,
          ),
          paint,
        );
      }
      activeIndexes.clear();
      activeValues.clear();
    }

    for (var i = 0; i < values.length; i++) {
      final value = values[i];
      if (value == null) {
        flush();
        continue;
      }
      activeIndexes.add(i);
      activeValues.add(value);
    }
    flush();
  }

  Path _buildPathForIndexedValues(
    List<int> indexes,
    List<double> values,
    Offset Function(int index, double value) toOffset,
    bool stepped, {
    bool skipNaN = false,
  }) {
    if (indexes.length != values.length || indexes.isEmpty) {
      return Path();
    }
    if (skipNaN) {
      final filteredIndexes = <int>[];
      final filteredValues = <double>[];
      for (var i = 0; i < values.length; i++) {
        final value = values[i];
        if (value.isNaN) {
          continue;
        }
        filteredIndexes.add(indexes[i]);
        filteredValues.add(value);
      }
      if (filteredIndexes.isEmpty) {
        return Path();
      }
      return _buildPathForIndexedValues(
        filteredIndexes,
        filteredValues,
        toOffset,
        stepped,
      );
    }
    if (stepped) {
      final path = Path();
      final first = toOffset(indexes[0], values[0]);
      path.moveTo(first.dx, first.dy);
      for (var i = 1; i < indexes.length; i++) {
        final previous = toOffset(indexes[i - 1], values[i - 1]);
        final current = toOffset(indexes[i], values[i]);
        path.lineTo(current.dx, previous.dy);
        path.lineTo(current.dx, current.dy);
      }
      return path;
    }
    if (indexes.length < 3) {
      final path = Path();
      for (var i = 0; i < indexes.length; i++) {
        final point = toOffset(indexes[i], values[i]);
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      return path;
    }
    final path = Path();
    var previous = toOffset(indexes[0], values[0]);
    path.moveTo(previous.dx, previous.dy);
    for (var i = 1; i < indexes.length; i++) {
      final current = toOffset(indexes[i], values[i]);
      final mid = Offset(
        (previous.dx + current.dx) / 2,
        (previous.dy + current.dy) / 2,
      );
      path.quadraticBezierTo(previous.dx, previous.dy, mid.dx, mid.dy);
      previous = current;
    }
    path.lineTo(previous.dx, previous.dy);
    return path;
  }

  @override
  bool shouldRepaint(covariant _LiveWindChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.gustPoints != gustPoints ||
        oldDelegate.timeLabels != timeLabels ||
        oldDelegate.pointXFractions != pointXFractions ||
        oldDelegate.forecastPoints != forecastPoints ||
        oldDelegate.markerDirectionsDeg != markerDirectionsDeg ||
        oldDelegate.markerDirectionKinds != markerDirectionKinds ||
        oldDelegate.overlayMarkers != overlayMarkers ||
        oldDelegate.timeGuides != timeGuides ||
        oldDelegate.dayStartIndexes != dayStartIndexes ||
        oldDelegate.dayStartLabels != dayStartLabels ||
        oldDelegate.realLineColor != realLineColor ||
        oldDelegate.gustLineColor != gustLineColor ||
        oldDelegate.forecastLineColor != forecastLineColor ||
        oldDelegate.gridMajorColor != gridMajorColor ||
        oldDelegate.gridMinorColor != gridMinorColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.windSpeedUnit != windSpeedUnit;
  }
}

class _LiveWindYAxisPainter extends CustomPainter {
  const _LiveWindYAxisPainter({
    required this.points,
    required this.gustPoints,
    required this.forecastPoints,
    required this.gridMajorColor,
    required this.gridMinorColor,
    required this.textColor,
    required this.backgroundColor,
    required this.windSpeedUnit,
  });

  final List<double> points;
  final List<double?>? gustPoints;
  final List<double?>? forecastPoints;
  final Color gridMajorColor;
  final Color gridMinorColor;
  final Color textColor;
  final Color backgroundColor;
  final _WindSpeedUnit windSpeedUnit;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    double computedMax = 0;
    for (final v in points) {
      final display = _displayWindValue(v, windSpeedUnit);
      if (display > computedMax) computedMax = display;
    }
    if (gustPoints != null) {
      for (final v in gustPoints!) {
        if (v == null) continue;
        final display = _displayWindValue(v, windSpeedUnit);
        if (display > computedMax) computedMax = display;
      }
    }
    if (forecastPoints != null) {
      for (final v in forecastPoints!) {
        if (v == null) continue;
        final display = _displayWindValue(v, windSpeedUnit);
        if (display > computedMax) computedMax = display;
      }
    }
    final minChartMax = _historicalMinChartMax(windSpeedUnit);
    final minorStep = _historicalMinorStep(windSpeedUnit);
    final majorStep = _historicalMajorStep(windSpeedUnit);
    final yMax = math.max(
      minChartMax,
      (computedMax / minorStep).ceil() * minorStep + minorStep,
    );

    const topPad = 12.0;
    const bottomPad = 32.0;
    final plot = Rect.fromLTWH(
      0,
      topPad,
      size.width,
      size.height - topPad - bottomPad,
    );
    if (plot.height <= 0) {
      return;
    }

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    final majorGrid = Paint()
      ..color = gridMajorColor
      ..strokeWidth = 0.8;
    final minorGrid = Paint()
      ..color = gridMinorColor
      ..strokeWidth = 0.6;

    for (var k = _LiveWindChartPainter._yMin; k <= yMax; k += minorStep) {
      final t =
          (k - _LiveWindChartPainter._yMin) /
          (yMax - _LiveWindChartPainter._yMin);
      final y = plot.bottom - (t * plot.height);
      final isMajor =
          ((k / majorStep).roundToDouble() - (k / majorStep)).abs() < 0.001;
      canvas.drawLine(
        Offset(size.width - 4, y),
        Offset(size.width, y),
        isMajor ? majorGrid : minorGrid,
      );
      if (!isMajor) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: _formatHistoricalAxisValue(k, windSpeedUnit),
          style: TextStyle(
            fontSize: 10,
            color: textColor.withValues(alpha: 0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - 6, y - (tp.height / 2)));
    }

    canvas.drawLine(
      Offset(size.width - 0.5, plot.top),
      Offset(size.width - 0.5, plot.bottom),
      Paint()
        ..color = gridMajorColor.withValues(alpha: 0.9)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _LiveWindYAxisPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.gustPoints != gustPoints ||
        oldDelegate.forecastPoints != forecastPoints ||
        oldDelegate.gridMajorColor != gridMajorColor ||
        oldDelegate.gridMinorColor != gridMinorColor ||
        oldDelegate.textColor != textColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.windSpeedUnit != windSpeedUnit;
  }
}
