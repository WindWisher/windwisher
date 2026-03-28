import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:windwisher/features/spots/application/services/spots_external_data_clients.dart';
import 'package:windwisher/features/spots/application/services/wind_semaforo_scale.dart';

class WindMapSample {
  const WindMapSample({
    required this.time,
    required this.windKnots,
    required this.windDeg,
    this.gustKnots,
    this.waveM,
  });

  final DateTime time;
  final int windKnots;
  final int windDeg;
  final int? gustKnots;
  final double? waveM;
}

class WindMapPage extends StatefulWidget {
  const WindMapPage({
    super.key,
    required this.spotName,
    required this.center,
    required this.samples,
    required this.providerLabel,
    required this.modelLabel,
    this.gridSnapshots = const <OpenMeteoWindMapGridSnapshot>[],
  });

  final String spotName;
  final LatLng center;
  final List<WindMapSample> samples;
  final String providerLabel;
  final String modelLabel;
  final List<OpenMeteoWindMapGridSnapshot> gridSnapshots;

  @override
  State<WindMapPage> createState() => _WindMapPageState();
}

class _WindMapPageState extends State<WindMapPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isPlaying = false;
  _WindMapLayer _selectedLayer = _WindMapLayer.wind;
  _PlaybackSpeed _playbackSpeed = _PlaybackSpeed.normal;
  late final AnimationController _streaksController;
  late final AnimationController _playbackController;

  @override
  void initState() {
    super.initState();
    _streaksController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _playbackController = AnimationController(
      vsync: this,
      duration: _PlaybackSpeed.normal.duration,
    )
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed || !_isPlaying || !mounted) {
          return;
        }
        setState(() {
          if (_selectedIndex >= widget.samples.length - 1) {
            _selectedIndex = 0;
          } else {
            _selectedIndex += 1;
          }
        });
        _playbackController.forward(from: 0);
      });
  }

  @override
  void dispose() {
    _playbackController.dispose();
    _streaksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa de viento')),
      body: AnimatedBuilder(
        animation: _playbackController,
        builder: (context, _) => _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasSamples = widget.samples.isNotEmpty;
    final hasWaveData = widget.samples.any((sample) => sample.waveM != null);
    final isFineTemporalResolution = _estimatedSampleStepMinutes() <= 60;
    final useReducedOverlayQuality = isFineTemporalResolution && _isPlaying;
    final activeLayer =
        !hasWaveData && _selectedLayer == _WindMapLayer.wave
            ? _WindMapLayer.wind
            : _selectedLayer;
    final currentSample = hasSamples ? widget.samples[_selectedIndex] : null;
    final nextSample = hasSamples && widget.samples.length > 1
        ? widget.samples[(_selectedIndex + 1) % widget.samples.length]
        : currentSample;
    final playbackT =
        _isPlaying && currentSample != null && nextSample != null
            ? Curves.easeInOut.transform(_playbackController.value)
            : 0.0;
    final sample = currentSample == null || nextSample == null
        ? null
        : _interpolateSample(currentSample, nextSample, playbackT);
    final gridSnapshot =
        currentSample == null ? null : _gridSnapshotForTime(currentSample.time);
    final nextGridSnapshot =
        nextSample == null ? null : _gridSnapshotForTime(nextSample.time);
    final displayKnots = sample == null
        ? null
        : _layerIntensityForSample(sample, activeLayer);
    final fieldModel = hasSamples
        ? _buildFieldModel(
            center: widget.center,
            sample: sample!,
            selectedLayer: activeLayer,
            gridSnapshot: gridSnapshot,
            nextGridSnapshot: nextGridSnapshot,
            playbackT: playbackT,
            useReducedGridDensity: useReducedOverlayQuality,
          )
        : const _WindFieldModel();
    final fieldNodes =
        activeLayer == _WindMapLayer.wave ? const <_WindFieldNode>[] : fieldModel.fieldNodes;

    return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.spotName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.providerLabel} · ${widget.modelLabel}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (sample != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _WindMapMetaChip(
                        icon: Icons.air_rounded,
                        label: '${activeLayer.label}: ${_layerReadingLabel(sample, activeLayer)}',
                      ),
                      _WindMapMetaChip(
                        icon: Icons.navigation_rounded,
                        label:
                            '${sample.windDeg}° ${_windDirectionLabel(sample.windDeg)}',
                      ),
                      if (sample.gustKnots != null)
                        _WindMapMetaChip(
                          icon: Icons.flash_on_rounded,
                          label: 'Racha ${sample.gustKnots} kt',
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: hasSamples
                ? Stack(
                    children: [
                      RepaintBoundary(
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: widget.center,
                            initialZoom: 10.5,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}{r}.png',
                              subdomains: const ['a', 'b', 'c', 'd'],
                              userAgentPackageName: 'com.windwisher.app',
                            ),
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: widget.center,
                                  radius: 42,
                                  useRadiusInMeter: true,
                                  color: colorScheme.primary.withValues(alpha: 0.08),
                                  borderStrokeWidth: 1.5,
                                  borderColor: colorScheme.primary.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: widget.center,
                                  width: 112,
                                  height: 68,
                                  child: _SpotWindMarker(
                                    sample: sample!,
                                    displayKnots:
                                        displayKnots ?? sample.windKnots,
                                    selectedLayer: activeLayer,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (activeLayer != _WindMapLayer.wave)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: RepaintBoundary(
                              child: CustomPaint(
                                painter: _WindFieldBackdropPainter(
                                  fieldNodes: fieldNodes,
                                  referenceWindDeg: sample.windDeg,
                                  animationValue: _streaksController.value,
                                  reducedQuality: useReducedOverlayQuality,
                                  repaint: _streaksController,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.air_outlined,
                            size: 32,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay muestras forecast compatibles para este mapa.',
                            textAlign: TextAlign.center,
                            style: textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Prueba con un proveedor y modelo que expongan serie horaria reutilizable.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          if (hasSamples)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SegmentedButton<_WindMapLayer>(
                              segments: [
                                const ButtonSegment<_WindMapLayer>(
                                  value: _WindMapLayer.wind,
                                  icon: Icon(Icons.air_rounded),
                                  label: Text('Viento'),
                                ),
                                if (hasWaveData)
                                  const ButtonSegment<_WindMapLayer>(
                                    value: _WindMapLayer.wave,
                                    icon: Icon(Icons.waves_rounded),
                                    label: Text('Olas'),
                                  ),
                              ],
                              selected: <_WindMapLayer>{activeLayer},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _selectedLayer = selection.first;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _PlaybackSpeedChip(
                          label: 'x2',
                          selected: _playbackSpeed == _PlaybackSpeed.x2,
                          onSelected: (selected) => _setPlaybackSpeed(
                            selected ? _PlaybackSpeed.x2 : _PlaybackSpeed.normal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _PlaybackSpeedChip(
                          label: 'x10',
                          selected: _playbackSpeed == _PlaybackSpeed.x10,
                          onSelected: (selected) => _setPlaybackSpeed(
                            selected
                                ? _PlaybackSpeed.x10
                                : _PlaybackSpeed.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        FilledButton.tonal(
                          onPressed:
                              widget.samples.length < 2 ? null : _togglePlayback,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(52, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          child: Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: _sliderValue(playbackT),
                            min: 0,
                            max: (widget.samples.length - 1).toDouble(),
                            divisions: math.max(1, widget.samples.length - 1),
                            label: _formatSampleTime(
                              sample?.time ?? widget.samples[_selectedIndex].time,
                            ),
                            onChanged: (value) {
                              _stopPlayback();
                              setState(() {
                                _selectedIndex = value.round();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _formatSampleTime(widget.samples.first.time),
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ),
                        Text(
                          _formatSampleTime(
                            sample?.time ?? widget.samples[_selectedIndex].time,
                          ),
                          style: textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _formatSampleTime(widget.samples.last.time),
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
    );
  }

  String _formatSampleTime(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _stopPlayback();
      return;
    }
    setState(() {
      _isPlaying = true;
    });
    _playbackController.forward(from: 0);
  }

  void _setPlaybackSpeed(_PlaybackSpeed speed) {
    if (_playbackSpeed == speed) {
      return;
    }
    final progress = _playbackController.value;
    final wasAnimating = _isPlaying;
    setState(() {
      _playbackSpeed = speed;
      _playbackController.duration = speed.duration;
    });
    if (wasAnimating) {
      _playbackController.forward(from: progress);
    }
  }

  void _stopPlayback() {
    _playbackController.stop();
    if (!_isPlaying) {
      return;
    }
    setState(() {
      _isPlaying = false;
    });
  }

  _WindFieldModel _buildFieldModel({
    required LatLng center,
    required WindMapSample sample,
    required _WindMapLayer selectedLayer,
    OpenMeteoWindMapGridSnapshot? gridSnapshot,
    OpenMeteoWindMapGridSnapshot? nextGridSnapshot,
    double playbackT = 0.0,
    bool useReducedGridDensity = false,
  }) {
    if (gridSnapshot != null && selectedLayer == _WindMapLayer.wind) {
      return _WindFieldModel(
        fieldNodes: playbackT > 0 &&
                nextGridSnapshot != null &&
                nextGridSnapshot.nodes.length == gridSnapshot.nodes.length
            ? _interpolatedGridFieldNodesBetween(
                gridSnapshot,
                nextGridSnapshot,
                playbackT,
                reducedDensity: useReducedGridDensity,
              )
            : _interpolatedGridFieldNodes(
                gridSnapshot,
                reducedDensity: useReducedGridDensity,
              ),
      );
    }
    const visibleSeeds =
        <({
          double lat,
          double lon,
          double alignX,
          double alignY,
        })>[
          (
            lat: 0.18,
            lon: -0.22,
            alignX: 0.26,
            alignY: 0.28,
          ),
          (
            lat: 0.18,
            lon: 0.22,
            alignX: 0.74,
            alignY: 0.30,
          ),
          (
            lat: -0.18,
            lon: -0.22,
            alignX: 0.28,
            alignY: 0.72,
          ),
          (
            lat: -0.18,
            lon: 0.22,
            alignX: 0.72,
            alignY: 0.70,
          ),
        ];
    final baseKnots = _layerIntensityForSample(sample, selectedLayer);
    final hiddenSeeds = _hiddenFieldSeeds(reducedDensity: useReducedGridDensity);
    final fieldNodes = <_WindFieldNode>[
      _WindFieldNode(
        alignX: 0.5,
        alignY: 0.5,
        windDeg: sample.windDeg,
        windKnots: baseKnots,
      ),
      ...visibleSeeds.map((seed) {
        final fieldValue = _deriveFieldValue(
          baseKnots: baseKnots,
          baseDeg: sample.windDeg,
          alignX: seed.alignX,
          alignY: seed.alignY,
        );
        return _WindFieldNode(
          alignX: seed.alignX,
          alignY: seed.alignY,
          windDeg: fieldValue.windDeg,
          windKnots: fieldValue.windKnots,
        );
      }),
      ...hiddenSeeds.map((seed) {
        final fieldValue = _deriveFieldValue(
          baseKnots: baseKnots,
          baseDeg: sample.windDeg,
          alignX: seed.alignX,
          alignY: seed.alignY,
        );
        return _WindFieldNode(
          alignX: seed.alignX,
          alignY: seed.alignY,
          windDeg: fieldValue.windDeg,
          windKnots: fieldValue.windKnots,
        );
      }),
    ];

    return _WindFieldModel(
      fieldNodes: fieldNodes,
    );
  }

  double _sliderValue(double playbackT) {
    if (!_isPlaying || _selectedIndex >= widget.samples.length - 1) {
      return _selectedIndex.toDouble();
    }
    return _selectedIndex + playbackT;
  }

  WindMapSample _interpolateSample(
    WindMapSample current,
    WindMapSample next,
    double t,
  ) {
    if (t <= 0) {
      return current;
    }
    if (t >= 1) {
      return next;
    }
    final timeDelta = next.time.difference(current.time);
    return WindMapSample(
      time: current.time.add(
        Duration(milliseconds: (timeDelta.inMilliseconds * t).round()),
      ),
      windKnots: (current.windKnots + (next.windKnots - current.windKnots) * t)
          .round(),
      windDeg: _lerpDegrees(current.windDeg, next.windDeg, t).round(),
      gustKnots: _lerpNullableInt(current.gustKnots, next.gustKnots, t),
      waveM: _lerpNullableDouble(current.waveM, next.waveM, t),
    );
  }

  int? _lerpNullableInt(int? current, int? next, double t) {
    if (current == null || next == null) {
      return null;
    }
    return (current + (next - current) * t).round();
  }

  double? _lerpNullableDouble(double? current, double? next, double t) {
    if (current == null || next == null) {
      return null;
    }
    return double.parse((current + (next - current) * t).toStringAsFixed(1));
  }

  double _lerpDegrees(int startDeg, int endDeg, double t) {
    final diff = (((endDeg - startDeg) + 540) % 360) - 180;
    return ((startDeg + (diff * t)) % 360 + 360) % 360;
  }

  List<_WindFieldNode> _interpolatedGridFieldNodes(
    OpenMeteoWindMapGridSnapshot snapshot,
    {bool reducedDensity = false}
  ) {
    if (snapshot.nodes.isEmpty) {
      return const <_WindFieldNode>[];
    }
    const denseXs = <double>[
      0.02, 0.08, 0.11, 0.17, 0.20, 0.26, 0.29, 0.35, 0.38, 0.44, 0.47,
      0.53, 0.56, 0.62, 0.65, 0.71, 0.74, 0.80, 0.83, 0.89, 0.92, 0.98,
    ];
    const reducedXs = <double>[
      0.03, 0.10, 0.18, 0.26, 0.34, 0.42, 0.50, 0.58, 0.66, 0.74, 0.82, 0.90, 0.97,
    ];
    final xs = reducedDensity ? reducedXs : denseXs;
    final ys = reducedDensity ? reducedXs : denseXs;
    final denseNodes = <_WindFieldNode>[];
    for (final y in ys) {
      for (final x in xs) {
        denseNodes.add(_interpolateGridNode(snapshot.nodes, x, y));
      }
    }
    return denseNodes;
  }

  List<_WindFieldNode> _interpolatedGridFieldNodesBetween(
    OpenMeteoWindMapGridSnapshot current,
    OpenMeteoWindMapGridSnapshot next,
    double t,
    {bool reducedDensity = false}
  ) {
    final currentNodes = _interpolatedGridFieldNodes(
      current,
      reducedDensity: reducedDensity,
    );
    final nextNodes = _interpolatedGridFieldNodes(
      next,
      reducedDensity: reducedDensity,
    );
    if (currentNodes.length != nextNodes.length) {
      return currentNodes;
    }

    return List<_WindFieldNode>.generate(currentNodes.length, (index) {
      final from = currentNodes[index];
      final to = nextNodes[index];
      return _WindFieldNode(
        alignX: from.alignX,
        alignY: from.alignY,
        windDeg: _lerpDegrees(from.windDeg, to.windDeg, t).round(),
        windKnots:
            (from.windKnots + (to.windKnots - from.windKnots) * t).round(),
      );
    }, growable: false);
  }

  _WindFieldNode _interpolateGridNode(
    List<OpenMeteoWindMapGridNode> nodes,
    double alignX,
    double alignY,
  ) {
    double sumSin = 0;
    double sumCos = 0;
    double sumWeight = 0;
    double weightedKnots = 0;

    for (final node in nodes) {
      final dx = alignX - node.alignX;
      final dy = alignY - node.alignY;
      final distance2 = (dx * dx) + (dy * dy);
      final weight = 1 / (0.006 + distance2);
      final angle = _flowAngleRadians(node.windDeg);
      sumCos += math.cos(angle) * weight;
      sumSin += math.sin(angle) * weight;
      weightedKnots += node.windKnots * weight;
      sumWeight += weight;
    }

    final averagedAngle = math.atan2(sumSin, sumCos);
    final normalizedAngle = _meteorologicalDegreesFromFlowAngle(averagedAngle);
    final averagedKnots =
        sumWeight == 0 ? 0 : math.max(1, (weightedKnots / sumWeight).round());

    return _WindFieldNode(
      alignX: alignX,
      alignY: alignY,
      windDeg: normalizedAngle,
      windKnots: averagedKnots,
    );
  }

  ({int windKnots, int windDeg}) _deriveFieldValue({
    required int baseKnots,
    required int baseDeg,
    required double alignX,
    required double alignY,
  }) {
    final dx = alignX - 0.5;
    final dy = alignY - 0.5;
    final angle = _flowAngleRadians(baseDeg);
    final along = (dx * math.cos(angle)) + (dy * math.sin(angle));
    final cross = (-dx * math.sin(angle)) + (dy * math.cos(angle));
    final radial = math.sqrt((dx * dx) + (dy * dy));
    final channeling = math.cos(cross * math.pi * 1.7) * 1.8;
    final compression = -along * (2.8 + (baseKnots / 18));
    final edgeDrop = -radial * (2.6 + (baseKnots / 32));
    final shear = cross * (5.0 + (baseKnots / 5));
    final swirl = math.sin((along * 5.4) + (cross * 3.2)) * 5.5;
    final knotsBias = (compression + edgeDrop + channeling).round();
    final degBias = (shear + swirl).round();
    final windDeg = ((baseDeg + degBias) % 360 + 360) % 360;
    return (
      windKnots: math.max(1, baseKnots + knotsBias),
      windDeg: windDeg,
    );
  }

  List<({double alignX, double alignY})> _hiddenFieldSeeds({
    bool reducedDensity = false,
  }) {
    const denseXs = <double>[0.04, 0.13, 0.22, 0.31, 0.40, 0.50, 0.60, 0.69, 0.78, 0.87, 0.96];
    const reducedXs = <double>[0.06, 0.18, 0.30, 0.42, 0.54, 0.66, 0.78, 0.90];
    final xs = reducedDensity ? reducedXs : denseXs;
    const ys = <double>[0.04, 0.13, 0.22, 0.31, 0.40, 0.50, 0.60, 0.69, 0.78, 0.87, 0.96];
    return [
      for (final y in ys)
        for (final x in xs)
          if ((x - 0.5).abs() > 0.03 || (y - 0.5).abs() > 0.03)
            (alignX: x, alignY: y),
    ];
  }

  int _estimatedSampleStepMinutes() {
    if (widget.samples.length < 2) {
      return 180;
    }
    final deltas = <int>[];
    for (var i = 0; i < widget.samples.length - 1; i++) {
      final delta = widget.samples[i + 1].time.difference(widget.samples[i].time).inMinutes;
      if (delta > 0) {
        deltas.add(delta);
      }
    }
    if (deltas.isEmpty) {
      return 180;
    }
    deltas.sort();
    return deltas[deltas.length ~/ 2];
  }

  int _layerIntensityForSample(WindMapSample sample, _WindMapLayer layer) {
    switch (layer) {
      case _WindMapLayer.wind:
        return sample.windKnots;
      case _WindMapLayer.wave:
        return ((sample.waveM ?? 0) * 10).round();
    }
  }

  String _layerReadingLabel(WindMapSample sample, _WindMapLayer layer) {
    switch (layer) {
      case _WindMapLayer.wind:
        return '${sample.windKnots} kt';
      case _WindMapLayer.wave:
        final waveM = sample.waveM;
        return waveM == null ? 's/d' : '${waveM.toStringAsFixed(1)} m';
    }
  }

  String _windDirectionLabel(int degrees) {
    const labels = <String>[
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW',
    ];
    final normalized = ((degrees % 360) + 360) % 360;
    final index = (((normalized + 11.25) % 360) / 22.5).floor();
    return labels[index];
  }

  OpenMeteoWindMapGridSnapshot? _gridSnapshotForTime(DateTime time) {
    for (final snapshot in widget.gridSnapshots) {
      if (snapshot.time == time) {
        return snapshot;
      }
    }
    return null;
  }
}

class _WindFieldModel {
  const _WindFieldModel({
    this.fieldNodes = const <_WindFieldNode>[],
  });

  final List<_WindFieldNode> fieldNodes;
}

class _WindFieldNode {
  const _WindFieldNode({
    required this.alignX,
    required this.alignY,
    required this.windDeg,
    required this.windKnots,
  });

  final double alignX;
  final double alignY;
  final int windDeg;
  final int windKnots;
}

enum _WindMapLayer {
  wind('Viento'),
  wave('Olas');

  const _WindMapLayer(this.label);

  final String label;
}

enum _PlaybackSpeed {
  normal('x1', Duration(milliseconds: 1400)),
  x2('x2', Duration(milliseconds: 700)),
  x10('x10', Duration(milliseconds: 140));

  const _PlaybackSpeed(this.label, this.duration);

  final String label;
  final Duration duration;
}

class _SpotWindMarker extends StatelessWidget {
  const _SpotWindMarker({
    required this.sample,
    required this.displayKnots,
    required this.selectedLayer,
  });

  final WindMapSample sample;
  final int displayKnots;
  final _WindMapLayer selectedLayer;

  @override
  Widget build(BuildContext context) {
    final color = switch (selectedLayer) {
      _WindMapLayer.wave => _waveColor(sample.waveM),
      _ => _windColor(displayKnots),
    };
    final icon = switch (selectedLayer) {
      _WindMapLayer.wave => Icons.waves_rounded,
      _ => Icons.near_me_rounded,
    };
    final label = switch (selectedLayer) {
      _WindMapLayer.wave => sample.waveM == null ? 's/d' : '${sample.waveM!.toStringAsFixed(1)} m',
      _ => '$displayKnots kt',
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selectedLayer == _WindMapLayer.wave)
                  Icon(icon, size: 22, color: color)
                else
                  Transform.rotate(
                    angle: _flowAngleRadians(sample.windDeg) + (math.pi / 4),
                    child: Icon(icon, size: 24, color: color),
                  ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Icon(
          Icons.location_on_rounded,
          color: Colors.redAccent,
          size: 20,
        ),
      ],
    );
  }
}

class _WindMapMetaChip extends StatelessWidget {
  const _WindMapMetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class _PlaybackSpeedChip extends StatelessWidget {
  const _PlaybackSpeedChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _WindFieldBackdropPainter extends CustomPainter {
  const _WindFieldBackdropPainter({
    required this.fieldNodes,
    required this.referenceWindDeg,
    required this.animationValue,
    required this.reducedQuality,
    required Listenable repaint,
  }) : super(repaint: repaint);

  final List<_WindFieldNode> fieldNodes;
  final int referenceWindDeg;
  final double animationValue;
  final bool reducedQuality;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty || fieldNodes.isEmpty) {
      return;
    }
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    _paintContinuousField(canvas, size);
    for (final node in fieldNodes) {
      final center = Offset(size.width * node.alignX, size.height * node.alignY);
      final color = _windColor(node.windKnots);
      final radius =
          (reducedQuality ? 40 : 46) + (node.windKnots * (reducedQuality ? 1.7 : 2.1));
      final rect = Rect.fromCircle(center: center, radius: radius);
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          [
            color.withValues(alpha: reducedQuality ? 0.028 : 0.04),
            color.withValues(alpha: reducedQuality ? 0.017 : 0.024),
            color.withValues(alpha: reducedQuality ? 0.007 : 0.010),
            color.withValues(alpha: 0.0),
          ],
          const [0.0, 0.42, 0.78, 1.0],
        );
      canvas.drawOval(rect, paint);
    }
    _paintDirectionStreaks(canvas, size);
    canvas.restore();
  }

  void _paintContinuousField(Canvas canvas, Size size) {
    final xs = fieldNodes.map((node) => node.alignX).toSet().toList()..sort();
    final ys = fieldNodes.map((node) => node.alignY).toSet().toList()..sort();
    if (xs.length < 2 || ys.length < 2) {
      return;
    }

    final nodeByKey = <String, _WindFieldNode>{
      for (final node in fieldNodes) _nodeKey(node.alignX, node.alignY): node,
    };
    final stride = reducedQuality ? 2 : 1;

    for (var yIndex = 0; yIndex < ys.length; yIndex += stride) {
      final y = ys[yIndex];
      final top = yIndex == 0 ? 0.0 : (ys[yIndex - 1] + y) / 2;
      final bottom = yIndex == ys.length - 1 ? 1.0 : (y + ys[yIndex + 1]) / 2;

      for (var xIndex = 0; xIndex < xs.length; xIndex += stride) {
        final x = xs[xIndex];
        final node = nodeByKey[_nodeKey(x, y)];
        if (node == null) {
          continue;
        }
        final left = xIndex == 0 ? 0.0 : (xs[xIndex - 1] + x) / 2;
        final right = xIndex == xs.length - 1 ? 1.0 : (x + xs[xIndex + 1]) / 2;
        final rect = Rect.fromLTRB(
          left * size.width,
          top * size.height,
          right * size.width,
          bottom * size.height,
        );
        final paint = Paint()
          ..color = _windColor(node.windKnots).withValues(
            alpha: reducedQuality ? 0.012 : 0.018,
          );
        canvas.drawRect(rect, paint);
      }
    }
  }

  void _paintDirectionStreaks(Canvas canvas, Size size) {
    final xs = fieldNodes.map((node) => node.alignX).toSet().toList()..sort();
    final ys = fieldNodes.map((node) => node.alignY).toSet().toList()..sort();
    if (xs.length < 2 || ys.length < 2) {
      return;
    }

    final nodeByKey = <String, _WindFieldNode>{
      for (final node in fieldNodes) _nodeKey(node.alignX, node.alignY): node,
    };

    final streakStride = reducedQuality ? 4 : 3;
    for (var yIndex = 1; yIndex < ys.length; yIndex += streakStride) {
      final y = ys[yIndex];
      for (var xIndex = 1; xIndex < xs.length; xIndex += streakStride) {
        final x = xs[xIndex];
        final node = nodeByKey[_nodeKey(x, y)];
        if (node == null) {
          continue;
        }
        final center = Offset(size.width * node.alignX, size.height * node.alignY);
        final blendedDeg = _blendedStreakDirectionDeg(
          referenceWindDeg,
          node.windDeg,
        );
        final angle = _flowAngleRadians(blendedDeg);
        final direction = Offset(math.cos(angle), math.sin(angle));
        final baseLength = 10.0 + (node.windKnots * 0.55);
        final travel = baseLength * 1.4;
        final seed = ((xIndex * 37) + (yIndex * 17)) % 100 / 100;
        final progress = (animationValue + seed) % 1.0;
        final tip = center + direction * ((progress - 0.5) * travel);
        final shaftStart = tip - direction * baseLength;
        final tailCenter = tip - direction * (baseLength * 0.72);
        final headLeftDirection = Offset(
          math.cos(angle + (math.pi * 0.84)),
          math.sin(angle + (math.pi * 0.84)),
        );
        final headRightDirection = Offset(
          math.cos(angle - (math.pi * 0.84)),
          math.sin(angle - (math.pi * 0.84)),
        );
        final paint = Paint()
          ..color = Colors.white.withValues(alpha: reducedQuality ? 0.28 : 0.36)
          ..style = PaintingStyle.stroke
          ..strokeWidth = reducedQuality ? 1.3 : 1.6
          ..strokeCap = StrokeCap.round;
        final tailPaint = Paint()
          ..color = Colors.white.withValues(alpha: reducedQuality ? 0.12 : 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = reducedQuality ? 1.0 : 1.2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(
          shaftStart,
          tip,
          paint,
        );
        canvas.drawLine(
          tailCenter - (direction * (baseLength * 0.18)),
          tailCenter + (direction * (baseLength * 0.08)),
          tailPaint,
        );
        final headLength = math.max(3.4, baseLength * 0.24);
        canvas.drawLine(
          tip,
          tip + (headLeftDirection * headLength),
          paint,
        );
        canvas.drawLine(
          tip,
          tip + (headRightDirection * headLength),
          paint,
        );
      }
    }
  }

  int _blendedStreakDirectionDeg(int referenceDeg, int nodeDeg) {
    final delta = _shortestAngleDelta(
      referenceDeg.toDouble(),
      nodeDeg.toDouble(),
    );
    final limitedDelta = delta.clamp(-20.0, 20.0);
    return _normalizeDegrees(referenceDeg + limitedDelta).round();
  }

  double _shortestAngleDelta(double startDeg, double endDeg) {
    return (((endDeg - startDeg) + 540) % 360) - 180;
  }

  double _normalizeDegrees(double value) {
    return ((value % 360) + 360) % 360;
  }

  String _nodeKey(double x, double y) => '${x.toStringAsFixed(3)}:${y.toStringAsFixed(3)}';

  @override
  bool shouldRepaint(covariant _WindFieldBackdropPainter oldDelegate) {
    if (oldDelegate.fieldNodes.length != fieldNodes.length) {
      return true;
    }
    for (var i = 0; i < fieldNodes.length; i++) {
      final current = fieldNodes[i];
      final previous = oldDelegate.fieldNodes[i];
      if (current.alignX != previous.alignX ||
          current.alignY != previous.alignY ||
          current.windKnots != previous.windKnots ||
          current.windDeg != previous.windDeg ||
          referenceWindDeg != oldDelegate.referenceWindDeg ||
          reducedQuality != oldDelegate.reducedQuality ||
          animationValue != oldDelegate.animationValue) {
        return true;
      }
    }
    return false;
  }
}

double _flowAngleRadians(int meteorologicalDegrees) {
  return (((meteorologicalDegrees % 360) + 450) % 360) * math.pi / 180;
}

int _meteorologicalDegreesFromFlowAngle(double angleRadians) {
  final degrees = (angleRadians * 180 / math.pi).round();
  return ((degrees - 90) % 360 + 360) % 360;
}

Color _windColor(int knots) {
  return windSemaforoColor(knots.toDouble());
}

Color _waveColor(double? meters) {
  final value = meters ?? 0;
  if (value < 0.8) return const Color(0xFF80DEEA);
  if (value < 1.3) return const Color(0xFF26C6DA);
  if (value < 2.0) return const Color(0xFF26A69A);
  return const Color(0xFF00796B);
}
