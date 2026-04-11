import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

class SessionTrackCard extends StatelessWidget {
  const SessionTrackCard({
    super.key,
    required this.insights,
    required this.durationLabel,
  });

  final SessionInsightData insights;
  final String durationLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final routePoints = insights.routePoints;
    final latLngPoints = routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    final center = _trackCenter(latLngPoints);
    final zoom = _trackZoom(latLngPoints);
    final startPoint = latLngPoints.first;
    final endPoint = latLngPoints.last;
    final fastestPoint = routePoints.reduce(
      (best, current) => current.speedKnots > best.speedKnots ? current : best,
    );
    final distanceLabel = insights.resolvedDistanceKm == null
        ? 'Distancia no disponible'
        : '${insights.resolvedDistanceKm!.toStringAsFixed(2)} km';
    final maxSpeedLabel = insights.resolvedMaxSpeedKnots == null
        ? '${fastestPoint.speedKnots.toStringAsFixed(1)} kt'
        : '${insights.resolvedMaxSpeedKnots!.toStringAsFixed(1)} kt';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ruta GPS real', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Track real registrado con el telefono durante la sesion.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: center,
                    initialZoom: zoom,
                    interactionOptions: const InteractionOptions(
                      flags:
                          InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.windwisher.app',
                    ),
                    if (latLngPoints.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: latLngPoints,
                            strokeWidth: 4,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: startPoint,
                          width: 34,
                          height: 34,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        if (latLngPoints.length > 1)
                          Marker(
                            point: endPoint,
                            width: 34,
                            height: 34,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorScheme.error,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.flag_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        if (fastestPoint.speedKnots > 0)
                          Marker(
                            point: LatLng(
                              fastestPoint.latitude,
                              fastestPoint.longitude,
                            ),
                            width: 34,
                            height: 34,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF57C00),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.bolt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _TrackChip(icon: Icons.route_rounded, label: distanceLabel),
                    _TrackChip(icon: Icons.bolt_rounded, label: maxSpeedLabel),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _TrackChip(
                      icon: Icons.timer_outlined,
                      label: durationLabel,
                    ),
                    _TrackChip(
                      icon: Icons.schedule_rounded,
                      label:
                          '${_formatTrackTime(routePoints.first.recordedAt)}-${_formatTrackTime(routePoints.last.recordedAt)}',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatTrackTime(DateTime value) {
    final localValue = value.toLocal();
    final hour = localValue.hour.toString().padLeft(2, '0');
    final minute = localValue.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static LatLng _trackCenter(List<LatLng> points) {
    if (points.length == 1) {
      return points.first;
    }
    final lat =
        points.map((point) => point.latitude).reduce((a, b) => a + b) /
        points.length;
    final lon =
        points.map((point) => point.longitude).reduce((a, b) => a + b) /
        points.length;
    return LatLng(lat, lon);
  }

  static double _trackZoom(List<LatLng> points) {
    if (points.length <= 1) {
      return 15.5;
    }
    final latitudes = points.map((point) => point.latitude);
    final longitudes = points.map((point) => point.longitude);
    final latSpan = latitudes.reduce(math.max) - latitudes.reduce(math.min);
    final lonSpan = longitudes.reduce(math.max) - longitudes.reduce(math.min);
    final span = math.max(latSpan, lonSpan);
    if (span <= 0.0015) return 16.5;
    if (span <= 0.003) return 15.5;
    if (span <= 0.006) return 14.5;
    if (span <= 0.015) return 13.5;
    if (span <= 0.04) return 12.5;
    return 11.5;
  }
}

class _TrackChip extends StatelessWidget {
  const _TrackChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
