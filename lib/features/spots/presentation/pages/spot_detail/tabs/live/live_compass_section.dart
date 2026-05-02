part of '../../spot_detail_page.dart';

extension _SpotDetailLiveCompassSection on _SpotDetailPageState {
  Widget _buildTraditionalCompassRoseFace() {
    final colorScheme = Theme.of(context).colorScheme;
    const contrastFillColor = Color(0xFFF9A825);
    final needleTint = colorScheme.primary.withValues(alpha: 0.14);
    TextStyle? labelStyle(String text) {
      final isCardinal = text.length == 1;
      final isNorth = text == 'N';
      return Theme.of(context).textTheme.labelSmall?.copyWith(
        fontWeight: isCardinal ? FontWeight.w800 : FontWeight.w700,
        fontSize: isCardinal ? 11 : 10,
        color: isNorth
            ? const Color(0xFFD32F2F)
            : colorScheme.onSurface.withValues(alpha: isCardinal ? 0.92 : 0.8),
      );
    }

    Widget roseLabel(String text, double angleDeg) {
      const ringRadius = 80.0;
      final angle = angleDeg * math.pi / 180;
      final dx = math.cos(angle) * ringRadius;
      final dy = math.sin(angle) * ringRadius;

      return Transform.translate(
        offset: Offset(dx, dy),
        child: Text(text, style: labelStyle(text)),
      );
    }

    return SizedBox(
      width: 252,
      height: 252,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: _TraditionalCompassRosePainter(
              ringColor: colorScheme.outline,
              majorColor: colorScheme.onSurface.withValues(alpha: 0.88),
              minorColor: colorScheme.onSurface.withValues(alpha: 0.45),
              lightPetalColor: Color.alphaBlend(
                needleTint,
                colorScheme.surfaceContainerHighest,
              ),
              darkPetalColor: Color.alphaBlend(
                needleTint,
                colorScheme.surfaceContainer,
              ),
              accentPetalColor: colorScheme.primary.withValues(alpha: 0.4),
              centerGlowColor: colorScheme.primary.withValues(alpha: 0.26),
              contrastFillColor: contrastFillColor,
            ),
          ),
          roseLabel('N', -90),
          roseLabel('NE', -45),
          roseLabel('E', 0),
          roseLabel('SE', 45),
          roseLabel('S', 90),
          roseLabel('SW', 135),
          roseLabel('W', 180),
          roseLabel('NW', 225),
        ],
      ),
    );
  }

  Widget _buildWindRose(
    _StationLiveData data, {
    double? compassHeadingDeg,
    bool headingAvailable = true,
  }) {
    final windKnots = data.windKnots;
    final windDeg = data.windDeg;
    if (windKnots == null) {
      return _buildLiveEmptyWindCard();
    }
    final windKnotsValue = windKnots;
    final navigability = switch (windKnotsValue) {
      < 10 => (
        label: 'No navegable',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.block,
      ),
      >= 10 && < 14 => (
        label: 'Viento muy flojo',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.warning_amber_rounded,
      ),
      >= 14 && < 18 => (
        label: 'Viento flojo',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.check_circle,
      ),
      >= 18 && <= 26 => (
        label: 'Viento optimo',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.check_circle,
      ),
      > 26 && <= 32 => (
        label: 'Viento fuerte',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.warning_amber_rounded,
      ),
      > 32 && <= 40 => (
        label: 'Viento muy fuerte',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.warning_amber_rounded,
      ),
      _ => (
        label: 'Viento super fuerte',
        color: _windSemaforoColor(windKnotsValue.toDouble()),
        icon: Icons.block,
      ),
    };

    final windDirection = windDeg == null
        ? null
        : _normalizeDegrees(windDeg.toDouble());
    final normalizedHeading = compassHeadingDeg == null
        ? null
        : _normalizeDegrees(compassHeadingDeg);
    final compassScreenNorth = normalizedHeading == null
        ? null
        : _headingToScreenNorthDegrees(normalizedHeading);
    final headingDelta = normalizedHeading == null || windDirection == null
        ? null
        : _headingDelta(windDirection, normalizedHeading);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            ActionChip(
              avatar: Icon(navigability.icon, color: Colors.white, size: 18),
              label: Text(
                navigability.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              tooltip: 'Leyenda del semaforo',
              onPressed: _showWindSemaforoLegendDialog,
              backgroundColor: navigability.color,
              side: BorderSide.none,
              shape: const StadiumBorder(),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: 252,
              height: 252,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildTraditionalCompassRoseFace(),
                  if (windDirection != null)
                    _buildWindClockHand(
                      directionDeg: windDirection,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  if (normalizedHeading != null)
                    _buildCompassNeedle(
                      directionDeg: compassScreenNorth!,
                      northColor: const Color(0xFFD32F2F),
                      southColor: const Color(0xFF263238),
                      showPoleLabels: true,
                    ),
                  if (normalizedHeading != null)
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              _formatWindRoseValue(windKnotsValue),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (windDirection == null) ...[
              const SizedBox(height: AppSpacing.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Text(
                  'Direccion del viento no disponible.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
            if (_compassOverlayMode != _CompassOverlayMode.off) ...[
              const SizedBox(height: AppSpacing.xs),
              if (!headingAvailable)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    'Brujula no disponible. Revisa permisos/sensor.',
                    textAlign: TextAlign.center,
                  ),
                )
              else if (normalizedHeading != null &&
                  headingDelta != null &&
                  windDirection != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Brujula: ${normalizedHeading.toStringAsFixed(0)}${_SpotDetailPageState._degreeSymbol}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Viento: ${windDirection.toStringAsFixed(0)}${_SpotDetailPageState._degreeSymbol} ${_degreesToCardinal(windDirection)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWindRoseWithCompassOverlay(_StationLiveData data) {
    switch (_compassOverlayMode) {
      case _CompassOverlayMode.off:
        return _buildWindRose(data);
      case _CompassOverlayMode.realtime:
        if (kIsWeb) {
          return StreamBuilder<double?>(
            stream: webCompassHeadingStream,
            builder: (context, snapshot) {
              final heading = snapshot.data;
              if (heading == null) {
                return _buildWindRose(data, headingAvailable: false);
              }
              return _buildWindRose(data, compassHeadingDeg: heading);
            },
          );
        }
        return StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            final heading = snapshot.data?.heading;
            if (heading == null) {
              return _buildWindRose(data, headingAvailable: false);
            }
            return _buildWindRose(data, compassHeadingDeg: heading);
          },
        );
    }
  }

  Widget _buildLiveEmptyWindCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Icon(
              Icons.air_rounded,
              size: 32,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Viento no disponible',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'La estacion seleccionada no reporta viento ahora mismo.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  double _normalizeDegrees(double degrees) {
    final normalized = degrees % 360;
    if (normalized < 0) {
      return normalized + 360;
    }
    return normalized;
  }

  double _bearingDegrees({
    required double latitudeA,
    required double longitudeA,
    required double latitudeB,
    required double longitudeB,
  }) {
    final lat1 = _toRadians(latitudeA);
    final lat2 = _toRadians(latitudeB);
    final deltaLon = _toRadians(longitudeB - longitudeA);
    final y = math.sin(deltaLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);
    final bearing = math.atan2(y, x) * (180 / math.pi);
    return _normalizeDegrees(bearing);
  }

  double _distanceKm({
    required double latitudeA,
    required double longitudeA,
    required double latitudeB,
    required double longitudeB,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = _toRadians(latitudeB - latitudeA);
    final dLon = _toRadians(longitudeB - longitudeA);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(latitudeA)) *
            math.cos(_toRadians(latitudeB)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _toRadians(double value) => value * (math.pi / 180);

  double _headingDelta(double a, double b) {
    final diff = (_normalizeDegrees(a) - _normalizeDegrees(b)).abs();
    return diff > 180 ? 360 - diff : diff;
  }

  double _headingToScreenNorthDegrees(double headingDeg) {
    // FlutterCompass reports where the top of the device is pointing.
    // The visible north needle has to move in the opposite direction.
    return -_normalizeDegrees(headingDeg);
  }

  String _degreesToCardinal(double degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final normalized = _normalizeDegrees(degrees);
    final index = ((normalized + 22.5) ~/ 45) % directions.length;
    return directions[index];
  }

  Widget _buildCompassNeedle({
    required double directionDeg,
    required Color northColor,
    required Color southColor,
    double needleLength = 74,
    double needleWidth = 3,
    bool showPoleLabels = false,
  }) {
    return Transform.rotate(
      angle: (directionDeg * math.pi) / 180,
      child: SizedBox(
        width: math.max(needleWidth + 4, 30),
        height: needleLength * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(needleWidth * 4.2, needleLength * 2),
              painter: _CompassDiamondNeedlePainter(
                northColor: northColor,
                southColor: southColor,
              ),
            ),
            if (showPoleLabels) ...[
              Positioned(
                top: 53,
                child: Text(
                  'N',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 53,
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWindClockHand({
    required double directionDeg,
    required Color color,
  }) {
    return Transform.rotate(
      angle: ((_normalizeDegrees(directionDeg) + 180) * math.pi) / 180,
      child: SizedBox(
        width: 22,
        height: 220,
        child: CustomPaint(painter: _WindClockHandPainter(color: color)),
      ),
    );
  }
}
