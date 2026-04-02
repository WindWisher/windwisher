import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';

enum SessionDetailSource { mySessions, community }

enum SessionDetailActionType { edit, delete }

class SessionDetailAction {
  const SessionDetailAction(this.type);

  final SessionDetailActionType type;
}

extension on SessionDetailSource {
  String get label {
    switch (this) {
      case SessionDetailSource.mySessions:
        return 'My Sessions';
      case SessionDetailSource.community:
        return 'Community';
    }
  }
}

class SessionDetailPage extends StatefulWidget {
  const SessionDetailPage({
    super.key,
    required this.title,
    required this.deviceName,
    required this.endedAt,
    required this.durationLabel,
    required this.summary,
    required this.source,
    this.gearSetupName,
    this.hasSessionPhoto = false,
    this.sessionMediaLabel,
    this.sessionPhotoLocalPath,
    this.spotBackgroundImagePath,
    required this.insights,
  });

  final String title;
  final String deviceName;
  final DateTime endedAt;
  final String durationLabel;
  final String summary;
  final SessionDetailSource source;
  final String? gearSetupName;
  final bool hasSessionPhoto;
  final String? sessionMediaLabel;
  final String? sessionPhotoLocalPath;
  final String? spotBackgroundImagePath;
  final SessionInsightData insights;

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  String? _selectedGroupTitle;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _summarySectionKey = GlobalKey();
  final GlobalKey _timelineSectionKey = GlobalKey();
  final GlobalKey _jumpHistorySectionKey = GlobalKey();
  final GlobalKey _eventsSectionKey = GlobalKey();
  final GlobalKey _advancedSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedGroupTitle = widget.insights.groups.isEmpty
        ? null
        : widget.insights.groups.first.title;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final selectedGroup = widget.insights.groups.where(
      (group) => group.title == _selectedGroupTitle,
    );
    final activeGroup = selectedGroup.isEmpty ? null : selectedGroup.first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de sesion'),
        actions: [
          if (widget.source == SessionDetailSource.mySessions)
            PopupMenuButton<SessionDetailActionType>(
              onSelected: (action) {
                Navigator.of(context).pop(SessionDetailAction(action));
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: SessionDetailActionType.edit,
                  child: Text('Editar'),
                ),
                PopupMenuItem(
                  value: SessionDetailActionType.delete,
                  child: Text('Eliminar'),
                ),
              ],
            ),
        ],
      ),
      body: ScrollConfiguration(
        behavior: const _NoStretchScrollBehavior(),
        child: ListView(
          controller: _scrollController,
          physics: kAppBouncingScrollPhysics,
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _buildSessionHeaderCard(textTheme),
            const SizedBox(height: AppSpacing.sm),
            _buildGearCard(textTheme),
            const SizedBox(height: AppSpacing.sm),
            _buildContextCard(textTheme),
            const SizedBox(height: AppSpacing.sm),
            _buildMediaCard(textTheme),
            const SizedBox(height: AppSpacing.sm),
            _buildQuickNavigationCard(textTheme),
            const SizedBox(height: AppSpacing.sm),
            if (widget.insights.routePoints.isNotEmpty) ...[
              _buildTrackCard(textTheme),
              const SizedBox(height: AppSpacing.sm),
            ],
            if (widget.insights.recordedPointCount != null ||
                widget.insights.autoPauseCount != null) ...[
              _buildCaptureQualityCard(textTheme),
              const SizedBox(height: AppSpacing.sm),
            ],
            Card(
              key: _summarySectionKey,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen post-sesion', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _MetricKpiTile(
                          label: 'Salto mas alto',
                          value: widget.insights.maxJumpHeightMeters == null
                              ? '--'
                              : '${widget.insights.maxJumpHeightMeters!.toStringAsFixed(1)} m',
                          icon: Icons.vertical_align_top_rounded,
                        ),
                        _MetricKpiTile(
                          label: 'Saltos',
                          value: widget.insights.jumpsCount == null
                              ? '--'
                              : '${widget.insights.jumpsCount}',
                          icon: Icons.waves_rounded,
                        ),
                        _MetricKpiTile(
                          label: 'Hangtime maximo',
                          value: widget.insights.maxHangtimeSeconds == null
                              ? '--'
                              : '${widget.insights.maxHangtimeSeconds!.toStringAsFixed(1)} s',
                          icon: Icons.timer_rounded,
                        ),
                        _MetricKpiTile(
                          label: 'Duracion sesion',
                          value: widget.durationLabel,
                          icon: Icons.av_timer_rounded,
                        ),
                        _MetricKpiTile(
                          label: 'Velocidad max',
                          value: widget.insights.maxSpeedKnots == null
                              ? '--'
                              : '${widget.insights.maxSpeedKnots!.toStringAsFixed(1)} kt',
                          icon: Icons.speed_rounded,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              key: _timelineSectionKey,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Timeline de rendimiento',
                      style: textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.insights.avgSpeedKnots == null
                          ? 'Sin datos de velocidad para construir timeline.'
                          : 'Velocidad media ${widget.insights.avgSpeedKnots!.toStringAsFixed(1)} kt',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: widget.insights.timelineKnots.isEmpty
                          ? DecoratedBox(
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  'No disponible para este dispositivo',
                                ),
                              ),
                            )
                          : CustomPaint(
                              key: const Key('session_timeline_chart'),
                              painter: _SessionTimelinePainter(
                                widget.insights.timelineKnots,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              key: _jumpHistorySectionKey,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Historico de saltos', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Nº, altura, hangtime, velocidad de caida y momento exacto del salto.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (widget.insights.jumpHistory.isEmpty)
                      const Text('No disponible para este dispositivo')
                    else
                      _JumpHistoryTable(records: widget.insights.jumpHistory),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              key: _eventsSectionKey,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eventos detectados', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    ...widget.insights.events.map(
                      (event) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.flag_rounded),
                        title: Text(event),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              key: _advancedSectionKey,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mediciones avanzadas', style: textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Elige la familia de KPIs que quieres revisar para evitar una pantalla demasiado larga.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (widget.insights.groups.isEmpty)
                      const Text(
                        'No hay mediciones disponibles en esta sesion.',
                      )
                    else ...[
                      _buildAdvancedGroupDropdown(),
                      const SizedBox(height: AppSpacing.sm),
                      if (activeGroup != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeGroup.title,
                                style: textTheme.titleSmall,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              ...activeGroup.items.map(
                                (item) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item.label),
                                  trailing: Text(
                                    item.available
                                        ? item.value
                                        : 'No disponible en este dispositivo',
                                    style: textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackCard(TextTheme textTheme) {
    final routePoints = widget.insights.routePoints;
    final latLngPoints = routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList(growable: false);
    final center = _trackCenter(latLngPoints);
    final zoom = _trackZoom(latLngPoints);
    final startPoint = latLngPoints.first;
    final endPoint = latLngPoints.last;
    final fastestPoint = routePoints.reduce(
      (best, current) =>
          current.speedKnots > best.speedKnots ? current : best,
    );
    final colorScheme = Theme.of(context).colorScheme;

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
                      flags: InteractiveFlag.drag |
                          InteractiveFlag.pinchZoom |
                          InteractiveFlag.doubleTapZoom,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                                border: Border.all(color: Colors.white, width: 2),
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
                                border: Border.all(color: Colors.white, width: 2),
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
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _TrackChip(
                  icon: Icons.route_rounded,
                  label: widget.insights.distanceKm == null
                      ? 'Distancia no disponible'
                      : '${widget.insights.distanceKm!.toStringAsFixed(2)} km',
                ),
                _TrackChip(
                  icon: Icons.timer_outlined,
                  label: widget.durationLabel,
                ),
                _TrackChip(
                  icon: Icons.schedule_rounded,
                  label:
                      '${_formatTrackTime(routePoints.first.recordedAt)}-${_formatTrackTime(routePoints.last.recordedAt)}',
                ),
                _TrackChip(
                  icon: Icons.bolt_rounded,
                  label: '${fastestPoint.speedKnots.toStringAsFixed(1)} kt',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: const [
                _TrackLegendChip(
                  color: Colors.blue,
                  icon: Icons.play_arrow_rounded,
                  label: 'Inicio',
                ),
                _TrackLegendChip(
                  color: Colors.red,
                  icon: Icons.flag_rounded,
                  label: 'Fin',
                ),
                _TrackLegendChip(
                  color: Color(0xFFF57C00),
                  icon: Icons.bolt_rounded,
                  label: 'Punta maxima',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureQualityCard(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Calidad de captura', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Resumen tecnico de como se ha registrado esta sesion real.',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _MetricKpiTile(
                  label: 'Puntos GPS validos',
                  value: widget.insights.recordedPointCount == null
                      ? '--'
                      : '${widget.insights.recordedPointCount}',
                  icon: Icons.gps_fixed_rounded,
                ),
                _MetricKpiTile(
                  label: 'Auto-pausas',
                  value: widget.insights.autoPauseCount == null
                      ? '--'
                      : '${widget.insights.autoPauseCount}',
                  icon: Icons.pause_circle_filled_rounded,
                ),
                _MetricKpiTile(
                  label: 'Media en movimiento',
                  value: widget.insights.movingAvgSpeedKnots == null
                      ? '--'
                      : '${widget.insights.movingAvgSpeedKnots!.toStringAsFixed(1)} kt',
                  icon: Icons.speed_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTrackTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  LatLng _trackCenter(List<LatLng> points) {
    if (points.length == 1) {
      return points.first;
    }
    final lat = points.map((point) => point.latitude).reduce((a, b) => a + b) /
        points.length;
    final lon = points
            .map((point) => point.longitude)
            .reduce((a, b) => a + b) /
        points.length;
    return LatLng(lat, lon);
  }

  double _trackZoom(List<LatLng> points) {
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

  Widget _buildQuickNavigationCard(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Navegacion rapida', style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _sectionChip('Resumen', _summarySectionKey),
                _sectionChip('Timeline', _timelineSectionKey),
                _sectionChip('Saltos', _jumpHistorySectionKey),
                _sectionChip('Eventos', _eventsSectionKey),
                _sectionChip('Avanzadas', _advancedSectionKey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionChip(String label, GlobalKey key) {
    return ActionChip(
      avatar: const Icon(Icons.arrow_downward_rounded, size: 16),
      label: Text(label),
      onPressed: () => _scrollToSection(key),
    );
  }

  Future<void> _scrollToSection(GlobalKey key) async {
    final targetContext = key.currentContext;
    if (targetContext == null) {
      return;
    }
    await Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.05,
    );
  }

  Widget _buildAdvancedGroupDropdown() {
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: '__header',
        enabled: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFCFD8DC),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Categoría de metricas',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    ];

    for (final group in widget.insights.groups) {
      items.add(
        DropdownMenuItem<String>(
          value: group.title,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _advancedGroupItemColor(group.title),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(group.title, overflow: TextOverflow.ellipsis),
          ),
        ),
      );
    }

    final selected = _selectedGroupTitle;
    final hasSelected =
        selected != null &&
        widget.insights.groups.any((group) => group.title == selected);

    return DropdownButtonFormField<String>(
      initialValue: hasSelected ? selected : widget.insights.groups.first.title,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Categoria de metricas',
        border: OutlineInputBorder(),
      ),
      items: items,
      onChanged: (value) {
        if (value == null || value.startsWith('__')) {
          return;
        }
        setState(() {
          _selectedGroupTitle = value;
        });
      },
    );
  }

  Color _advancedGroupItemColor(String groupTitle) {
    switch (groupTitle) {
      case 'Core Session':
        return const Color(0xFFE3F2FD);
      case 'Big Air':
        return const Color(0xFFFFF8E1);
      case 'Freestyle':
        return const Color(0xFFF3E5F5);
      case 'Freeride / Navegacion':
        return const Color(0xFFE8F5E9);
      case 'Saltos':
        return const Color(0xFFFFF3E0);
      case 'Control tecnico':
        return const Color(0xFFE0F7FA);
      case 'Condiciones meteo-contexto':
        return const Color(0xFFE8EAF6);
      case 'Seguridad y riesgo':
        return const Color(0xFFFFEBEE);
      case 'Dispositivo y calidad de datos':
        return const Color(0xFFEDE7F6);
      case 'KPIs compuestos':
        return const Color(0xFFE0F2F1);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Widget _buildSessionHeaderCard(TextTheme textTheme) {
    final hasBackground =
        widget.spotBackgroundImagePath != null &&
        widget.spotBackgroundImagePath!.isNotEmpty;
    final header = Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: textTheme.titleLarge?.copyWith(
              color: hasBackground ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${widget.endedAt.day.toString().padLeft(2, '0')}/${widget.endedAt.month.toString().padLeft(2, '0')} ${widget.endedAt.hour.toString().padLeft(2, '0')}:${widget.endedAt.minute.toString().padLeft(2, '0')}',
            style: textTheme.bodySmall?.copyWith(
              color: hasBackground ? Colors.white : null,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              Chip(
                avatar: const Icon(Icons.watch_rounded, size: 16),
                label: Text(widget.deviceName),
              ),
              Chip(
                avatar: const Icon(Icons.timer_rounded, size: 16),
                label: Text(widget.durationLabel),
              ),
              if (widget.gearSetupName != null &&
                  widget.gearSetupName!.isNotEmpty)
                Chip(
                  avatar: const Icon(Icons.checkroom_rounded, size: 16),
                  label: Text(widget.gearSetupName!),
                ),
            ],
          ),
        ],
      ),
    );

    if (!hasBackground) {
      return Card(child: header);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.file(
              File(widget.spotBackgroundImagePath!),
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.black.withValues(alpha: 0.2),
                  ],
                ),
              ),
            ),
          ),
          header,
        ],
      ),
    );
  }

  Widget _buildGearCard(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const Icon(Icons.checkroom_rounded),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Equipo utilizado', style: textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    widget.gearSetupName == null ||
                            widget.gearSetupName!.isEmpty
                        ? 'No especificado al subir sesion.'
                        : widget.gearSetupName!,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextCard(TextTheme textTheme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contexto de sesion', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Chip(
              avatar: const Icon(Icons.alt_route_rounded, size: 16),
              label: Text('Origen: ${widget.source.label}'),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(widget.summary),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard(TextTheme textTheme) {
    final localPhotoPath = widget.sessionPhotoLocalPath;
    final hasLocalPhoto =
        localPhotoPath != null && File(localPhotoPath).existsSync();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Media de sesion', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  gradient: widget.hasSessionPhoto
                      ? const LinearGradient(
                          colors: [Color(0xFF90CAF9), Color(0xFF42A5F5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : const LinearGradient(
                          colors: [Color(0xFFC8E6C9), Color(0xFF80CBC4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: hasLocalPhoto
                    ? Image.file(File(localPhotoPath), fit: BoxFit.cover)
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.hasSessionPhoto
                                  ? Icons.photo_camera_back_rounded
                                  : Icons.map_rounded,
                              size: 34,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.hasSessionPhoto
                                  ? 'Foto de la sesion'
                                  : 'Pantallazo del mapa del spot',
                              style: textTheme.titleSmall?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            if (widget.sessionMediaLabel != null &&
                                widget.sessionMediaLabel!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                widget.sessionMediaLabel!,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoStretchScrollBehavior extends AppScrollBehavior {
  const _NoStretchScrollBehavior();
}

class _MetricKpiTile extends StatelessWidget {
  const _MetricKpiTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 4),
          Text(label, style: textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value, style: textTheme.titleSmall),
        ],
      ),
    );
  }
}

class _SessionTimelinePainter extends CustomPainter {
  _SessionTimelinePainter(this.values);

  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) {
      return;
    }

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : maxV - minV;

    final gridPaint = Paint()
      ..color = const Color(0x33000000)
      ..strokeWidth = 1;
    for (var i = 1; i <= 4; i++) {
      final y = size.height * (i / 5);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? 0.0
          : size.width * (i / (values.length - 1));
      final normalized = (values[i] - minV) / range;
      final y = size.height - (normalized * (size.height - 6)) - 3;
      points.add(Offset(x, y));
    }

    final fillPath = Path()..moveTo(points.first.dx, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(points.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = const Color(0x223A86FF));

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = const Color(0xFF1565C0)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );

    for (final point in points) {
      canvas.drawCircle(point, 2.6, Paint()..color = const Color(0xFF0D47A1));
    }
  }

  @override
  bool shouldRepaint(covariant _SessionTimelinePainter oldDelegate) {
    if (oldDelegate.values.length != values.length) {
      return true;
    }
    for (var i = 0; i < values.length; i++) {
      if (oldDelegate.values[i] != values[i]) {
        return true;
      }
    }
    return false;
  }
}

class _JumpHistoryTable extends StatelessWidget {
  const _JumpHistoryTable({required this.records});

  final List<SessionJumpRecord> records;

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.labelMedium;
    final rowStyle = Theme.of(context).textTheme.bodySmall;

    Widget buildRow({
      required String left,
      required String h,
      required String t,
      required String fall,
      required String when,
      bool header = false,
    }) {
      final style = header ? headerStyle : rowStyle;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(width: 34, child: Text(left, style: style)),
            Expanded(child: Text(h, style: style)),
            Expanded(child: Text(t, style: style)),
            Expanded(child: Text(fall, style: style)),
            SizedBox(width: 70, child: Text(when, style: style)),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          buildRow(
            left: '#',
            h: 'Altura',
            t: 'Hangtime',
            fall: 'Caida',
            when: 'Min:Seg',
            header: true,
          ),
          const Divider(height: 10),
          ...records.map(
            (record) => buildRow(
              left: '${record.jumpNumber}',
              h: '${record.heightMeters.toStringAsFixed(1)} m',
              t: '${record.hangtimeSeconds.toStringAsFixed(1)} s',
              fall: '${record.fallSpeedMetersPerSecond.toStringAsFixed(1)} m/s',
              when: record.timeLabel,
            ),
          ),
        ],
      ),
    );
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
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _TrackLegendChip extends StatelessWidget {
  const _TrackLegendChip({
    required this.color,
    required this.icon,
    required this.label,
  });

  final Color color;
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
            DecoratedBox(
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(icon, size: 12, color: Colors.white),
              ),
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class SessionInsightData {
  const SessionInsightData({
    required this.distanceKm,
    required this.maxSpeedKnots,
    required this.avgSpeedKnots,
    required this.movingAvgSpeedKnots,
    required this.planingMinutes,
    required this.recordedPointCount,
    required this.autoPauseCount,
    required this.batteryStart,
    required this.batteryEnd,
    required this.jumpsCount,
    required this.maxJumpHeightMeters,
    required this.maxHangtimeSeconds,
    required this.jumpHistory,
    required this.timelineKnots,
    required this.routePoints,
    required this.events,
    required this.groups,
  });

  final double? distanceKm;
  final double? maxSpeedKnots;
  final double? avgSpeedKnots;
  final double? movingAvgSpeedKnots;
  final int? planingMinutes;
  final int? recordedPointCount;
  final int? autoPauseCount;
  final int? batteryStart;
  final int? batteryEnd;
  final int? jumpsCount;
  final double? maxJumpHeightMeters;
  final double? maxHangtimeSeconds;
  final List<SessionJumpRecord> jumpHistory;
  final List<double> timelineKnots;
  final List<SessionTrackPoint> routePoints;
  final List<String> events;
  final List<SessionKpiGroup> groups;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'distanceKm': distanceKm,
      'maxSpeedKnots': maxSpeedKnots,
      'avgSpeedKnots': avgSpeedKnots,
      'movingAvgSpeedKnots': movingAvgSpeedKnots,
      'planingMinutes': planingMinutes,
      'recordedPointCount': recordedPointCount,
      'autoPauseCount': autoPauseCount,
      'batteryStart': batteryStart,
      'batteryEnd': batteryEnd,
      'jumpsCount': jumpsCount,
      'maxJumpHeightMeters': maxJumpHeightMeters,
      'maxHangtimeSeconds': maxHangtimeSeconds,
      'jumpHistory': jumpHistory
          .map((entry) => entry.toJson())
          .toList(growable: false),
      'timelineKnots': timelineKnots,
      'routePoints': routePoints
          .map((entry) => entry.toJson())
          .toList(growable: false),
      'events': events,
      'groups': groups.map((entry) => entry.toJson()).toList(growable: false),
    };
  }

  static SessionInsightData fromJson(Map<String, dynamic> json) {
    return SessionInsightData(
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      maxSpeedKnots: (json['maxSpeedKnots'] as num?)?.toDouble(),
      avgSpeedKnots: (json['avgSpeedKnots'] as num?)?.toDouble(),
      movingAvgSpeedKnots: (json['movingAvgSpeedKnots'] as num?)?.toDouble(),
      planingMinutes: (json['planingMinutes'] as num?)?.toInt(),
      recordedPointCount: (json['recordedPointCount'] as num?)?.toInt(),
      autoPauseCount: (json['autoPauseCount'] as num?)?.toInt(),
      batteryStart: (json['batteryStart'] as num?)?.toInt(),
      batteryEnd: (json['batteryEnd'] as num?)?.toInt(),
      jumpsCount: (json['jumpsCount'] as num?)?.toInt(),
      maxJumpHeightMeters: (json['maxJumpHeightMeters'] as num?)?.toDouble(),
      maxHangtimeSeconds: (json['maxHangtimeSeconds'] as num?)?.toDouble(),
      jumpHistory: (json['jumpHistory'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionJumpRecord.fromJson)
          .toList(growable: false),
      timelineKnots: (json['timelineKnots'] as List<dynamic>? ?? const [])
          .whereType<num>()
          .map((entry) => entry.toDouble())
          .toList(growable: false),
      routePoints: (json['routePoints'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionTrackPoint.fromJson)
          .toList(growable: false),
      events: (json['events'] as List<dynamic>? ?? const [])
          .map((entry) => entry.toString())
          .toList(growable: false),
      groups: (json['groups'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionKpiGroup.fromJson)
          .toList(growable: false),
    );
  }

  SessionInsightData copyWith({
    double? distanceKm,
    double? maxSpeedKnots,
    double? avgSpeedKnots,
    double? movingAvgSpeedKnots,
    int? planingMinutes,
    int? recordedPointCount,
    int? autoPauseCount,
    int? batteryStart,
    int? batteryEnd,
    int? jumpsCount,
    double? maxJumpHeightMeters,
    double? maxHangtimeSeconds,
    List<SessionJumpRecord>? jumpHistory,
    List<double>? timelineKnots,
    List<SessionTrackPoint>? routePoints,
    List<String>? events,
    List<SessionKpiGroup>? groups,
  }) {
    return SessionInsightData(
      distanceKm: distanceKm ?? this.distanceKm,
      maxSpeedKnots: maxSpeedKnots ?? this.maxSpeedKnots,
      avgSpeedKnots: avgSpeedKnots ?? this.avgSpeedKnots,
      movingAvgSpeedKnots: movingAvgSpeedKnots ?? this.movingAvgSpeedKnots,
      planingMinutes: planingMinutes ?? this.planingMinutes,
      recordedPointCount: recordedPointCount ?? this.recordedPointCount,
      autoPauseCount: autoPauseCount ?? this.autoPauseCount,
      batteryStart: batteryStart ?? this.batteryStart,
      batteryEnd: batteryEnd ?? this.batteryEnd,
      jumpsCount: jumpsCount ?? this.jumpsCount,
      maxJumpHeightMeters: maxJumpHeightMeters ?? this.maxJumpHeightMeters,
      maxHangtimeSeconds: maxHangtimeSeconds ?? this.maxHangtimeSeconds,
      jumpHistory: jumpHistory ?? this.jumpHistory,
      timelineKnots: timelineKnots ?? this.timelineKnots,
      routePoints: routePoints ?? this.routePoints,
      events: events ?? this.events,
      groups: groups ?? this.groups,
    );
  }

  static const List<String> capabilityOrder = [
    'gps',
    'speed',
    'motion',
    'altitude',
    'heart_rate',
    'barometer',
    'battery',
    'network',
    'weather',
  ];

  static const Map<String, String> capabilityLabels = {
    'gps': 'GPS',
    'speed': 'Velocidad',
    'motion': 'Movimiento',
    'altitude': 'Altitud',
    'heart_rate': 'Ritmo cardiaco',
    'barometer': 'Barometro',
    'battery': 'Bateria',
    'network': 'Conectividad',
    'weather': 'Meteo',
  };

  static SessionInsightData fromSession({
    required String title,
    required String deviceName,
    required String deviceKind,
    required DateTime endedAt,
    required String durationLabel,
  }) {
    final duration = _parseDuration(durationLabel);
    final durationMinutes = duration.inMinutes <= 0 ? 45 : duration.inMinutes;
    final seed = _seedFrom(title, deviceName, endedAt, deviceKind);
    final capabilities = _sensorSetForKind(deviceKind);

    final maxSpeed = 19 + (seed % 24) * 0.7;
    final avgSpeed = math.max(11.5, maxSpeed - (3.5 + (seed % 5) * 0.55));
    final distance = durationMinutes * (avgSpeed / 30);
    final planing = math.max(
      6,
      (durationMinutes * (0.28 + (seed % 5) * 0.02)).round(),
    );
    final batteryStart = 100 - (seed % 12);
    final batteryEnd = math.max(9, batteryStart - (18 + (seed % 32)));
    final jumps = 5 + (seed % 16);
    final maxJumpHeight = 3.0 + ((seed % 100) / 100) * 10.5;
    final maxHangtime = 2.2 + (seed % 40) / 10;
    const knotsToMetersPerSecond = 0.514444;
    final jumpDistanceEstimate =
        maxSpeed * knotsToMetersPerSecond * maxHangtime;
    final jumpHistory = _buildJumpHistory(
      seed: seed,
      jumpsCount: jumps,
      maxJumpHeight: maxJumpHeight,
      maxHangtime: maxHangtime,
      duration: duration,
      hasJumpSensors:
          capabilities.contains('altitude') && capabilities.contains('motion'),
    );

    final timeline = capabilities.contains('speed')
        ? List<double>.generate(14, (index) {
            final angle = (index / 13) * math.pi * 2;
            final wave = math.sin(angle) * (1.6 + (seed % 4) * 0.25);
            final gust = math.cos(angle * 2.2) * 0.9;
            final value = avgSpeed + wave + gust;
            return value.clamp(8.0, maxSpeed + 1.2);
          })
        : const <double>[];

    final values = <String, String>{
      'duracion_total': '${duration.inMinutes} min',
      'tiempo_activo':
          '${math.max(1, (duration.inMinutes * 0.86).round())} min',
      'tiempo_parado':
          '${math.max(0, (duration.inMinutes * 0.14).round())} min',
      'ratio_activo_parado': '${(6.1 + (seed % 20) / 10).toStringAsFixed(1)}:1',
      'distancia_total': '${distance.toStringAsFixed(1)} km',
      'distancia_planeo': '${(distance * 0.82).toStringAsFixed(1)} km',
      'distancia_upwind': '${(distance * 0.36).toStringAsFixed(1)} km',
      'distancia_downwind': '${(distance * 0.41).toStringAsFixed(1)} km',
      'velocidad_media': '${avgSpeed.toStringAsFixed(1)} kt',
      'velocidad_max': '${maxSpeed.toStringAsFixed(1)} kt',
      'velocidad_p95': '${(maxSpeed * 0.93).toStringAsFixed(1)} kt',
      'racha_max': '${(maxSpeed * 1.09).toStringAsFixed(1)} kt',
      'racha_10s': '${(maxSpeed * 1.03).toStringAsFixed(1)} kt',
      'transiciones': '${8 + (seed % 18)}',
      'transiciones_hora': ((8 + (seed % 18)) / (duration.inMinutes / 60))
          .toStringAsFixed(1),
      'top5_saltos': '${(maxJumpHeight * 0.94).toStringAsFixed(1)} m',
      'altura_media_saltos': '${(maxJumpHeight * 0.58).toStringAsFixed(1)} m',
      'hangtime_max': '${maxHangtime.toStringAsFixed(1)} s',
      'hangtime_p95': '${(1.8 + (seed % 35) / 10).toStringAsFixed(1)} s',
      'eficiencia_salto_viento':
          '${(maxJumpHeight / avgSpeed).toStringAsFixed(2)} m/kt',
      'cadencia_saltos':
          '${(durationMinutes / math.max(1, jumps)).toStringAsFixed(1)} min/salto',
      'consistencia_alturas': (0.6 + (seed % 30) / 100).toStringAsFixed(2),
      'intentos_truco': '${6 + (seed % 16)}',
      'exito_truco': '${45 + (seed % 45)}%',
      'combo_rate': '${12 + (seed % 38)}%',
      'dificultad_media': '${(5 + (seed % 50) / 10).toStringAsFixed(1)}/10',
      'caidas_intento': (0.2 + (seed % 25) / 100).toStringAsFixed(2),
      'progresion_truco': 'Mejora ultimos 30 dias: +${6 + (seed % 18)}%',
      'vmg_upwind': '${(avgSpeed * 0.56).toStringAsFixed(1)} kt',
      'vmg_downwind': '${(avgSpeed * 0.67).toStringAsFixed(1)} kt',
      'angulo_cenida': '${34 + (seed % 14)}°',
      'eficiencia_bordos': '${62 + (seed % 28)}%',
      'tiempo_sweetspot': '${38 + (seed % 42)}%',
      'deriva_neta': '${(0.2 + (seed % 28) / 10).toStringAsFixed(1)} km',
      'cobertura_area': '${(0.8 + (seed % 25) / 10).toStringAsFixed(1)} km2',
      'salto_mas_alto': '${maxJumpHeight.toStringAsFixed(1)} m',
      'distancia_salto_estimada':
          '${jumpDistanceEstimate.toStringAsFixed(0)} m',
      'distribucion_alturas':
          'Tipica: ${(maxJumpHeight * 0.54).toStringAsFixed(1)} m\nMaxima habitual: ${(maxJumpHeight * 0.91).toStringAsFixed(1)} m',
      'takeoff_speed': '${(avgSpeed * 1.18).toStringAsFixed(1)} kt',
      'landing_speed': '${(1.2 + (seed % 28) / 10).toStringAsFixed(1)} G',
      'clean_landing_rate': '${60 + (seed % 35)}%',
      'impact_score': '${(2.3 + (seed % 25) / 10).toStringAsFixed(1)}/10',
      'variabilidad_velocidad':
          '${(1.8 + (seed % 30) / 10).toStringAsFixed(1)} kt',
      'estabilidad_direccional': '${66 + (seed % 26)}%',
      'calidad_jibe': '${58 + (seed % 33)}%',
      'perdida_vel_transiciones':
          '${(1.2 + (seed % 24) / 10).toStringAsFixed(1)} kt',
      'recuperacion_planeo': '${(4 + (seed % 20)).toString()} s',
      'smoothness_score': '${(6.0 + (seed % 35) / 10).toStringAsFixed(1)}/10',
      'viento_medio': '${(avgSpeed * 0.85).toStringAsFixed(1)} kt',
      'viento_rango':
          '${(avgSpeed * 0.6).toStringAsFixed(1)}-${(maxSpeed * 1.1).toStringAsFixed(1)} kt',
      'direccion_dominante': '${45 + (seed % 280)}°',
      'gust_factor': ((maxSpeed * 1.09) / math.max(1.0, avgSpeed))
          .toStringAsFixed(2),
      'temperatura': '${(14 + (seed % 16)).toString()} C',
      'presion': '${(1007 + (seed % 22)).toString()} hPa',
      'lluvia': (seed % 8) == 0 ? 'si' : 'no',
      'caidas_hora': (0.8 + (seed % 22) / 10).toStringAsFixed(1),
      'eventos_sobrepotencia': '${seed % 6}',
      'distancia_max_costa':
          '${(0.4 + (seed % 35) / 10).toStringAsFixed(1)} km',
      'tiempo_zona_riesgo': '${seed % 12} min',
      'alertas_atendidas': '${68 + (seed % 29)}%',
      'fatiga_estimada': '${24 + (seed % 46)}%',
      'bateria_hora': '${(8 + (seed % 13)).toString()}%/h',
      'calidad_gps': '${74 + (seed % 24)}%',
      'samples_perdidos': '${seed % 9}%',
      'latencia_sync': '${(4 + (seed % 80)).toString()} s',
      'health_dataset': '${78 + (seed % 19)}%',
      'session_score': '${(62 + (seed % 34)).toString()}/100',
      'big_air_score': '${(58 + (seed % 39)).toString()}/100',
      'freestyle_score': '${(54 + (seed % 42)).toString()}/100',
      'freeride_score': '${(60 + (seed % 37)).toString()}/100',
      'safety_score': '${(66 + (seed % 28)).toString()}/100',
      'progress_score': '${(57 + (seed % 33)).toString()}/100',
    };

    final groups = <SessionKpiGroup>[
      SessionKpiGroup(
        title: 'Core Session',
        items: [
          _item(values, capabilities, 'duracion_total', const {}),
          _item(values, capabilities, 'tiempo_activo', {'motion'}),
          _item(values, capabilities, 'tiempo_parado', {'motion'}),
          _item(values, capabilities, 'ratio_activo_parado', {'motion'}),
          _item(values, capabilities, 'distancia_total', {'gps'}),
          _item(values, capabilities, 'distancia_planeo', {'gps', 'speed'}),
          _item(values, capabilities, 'distancia_upwind', {'gps'}),
          _item(values, capabilities, 'distancia_downwind', {'gps'}),
          _item(values, capabilities, 'velocidad_media', {'speed'}),
          _item(values, capabilities, 'velocidad_max', {'speed'}),
          _item(values, capabilities, 'velocidad_p95', {'speed'}),
          _item(values, capabilities, 'racha_max', {'speed'}),
          _item(values, capabilities, 'racha_10s', {'speed'}),
          _item(values, capabilities, 'transiciones', {'motion'}),
          _item(values, capabilities, 'transiciones_hora', {'motion'}),
        ],
      ),
      SessionKpiGroup(
        title: 'Big Air',
        items: [
          _item(values, capabilities, 'top5_saltos', {'altitude', 'motion'}),
          _item(values, capabilities, 'altura_media_saltos', {
            'altitude',
            'motion',
          }),
          _item(values, capabilities, 'hangtime_max', {'altitude', 'motion'}),
          _item(values, capabilities, 'hangtime_p95', {'altitude', 'motion'}),
          _item(values, capabilities, 'eficiencia_salto_viento', {
            'altitude',
            'speed',
          }),
          _item(values, capabilities, 'cadencia_saltos', {
            'altitude',
            'motion',
          }),
          _item(values, capabilities, 'consistencia_alturas', {'altitude'}),
        ],
      ),
      SessionKpiGroup(
        title: 'Freestyle',
        items: [
          _item(values, capabilities, 'intentos_truco', {'motion'}),
          _item(values, capabilities, 'exito_truco', {'motion'}),
          _item(values, capabilities, 'combo_rate', {'motion'}),
          _item(values, capabilities, 'dificultad_media', {'motion'}),
          _item(values, capabilities, 'caidas_intento', {'motion'}),
          _item(values, capabilities, 'progresion_truco', {'motion'}),
        ],
      ),
      SessionKpiGroup(
        title: 'Freeride / Navegacion',
        items: [
          _item(values, capabilities, 'vmg_upwind', {'gps', 'speed'}),
          _item(values, capabilities, 'vmg_downwind', {'gps', 'speed'}),
          _item(values, capabilities, 'angulo_cenida', {'gps'}),
          _item(values, capabilities, 'eficiencia_bordos', {'gps', 'motion'}),
          _item(values, capabilities, 'tiempo_sweetspot', {'speed'}),
          _item(values, capabilities, 'deriva_neta', {'gps'}),
          _item(values, capabilities, 'cobertura_area', {'gps'}),
        ],
      ),
      SessionKpiGroup(
        title: 'Saltos',
        items: [
          _item(values, capabilities, 'salto_mas_alto', {'altitude', 'motion'}),
          _item(values, capabilities, 'distancia_salto_estimada', {
            'speed',
            'altitude',
            'motion',
          }),
          _item(values, capabilities, 'distribucion_alturas', {'altitude'}),
          _item(values, capabilities, 'takeoff_speed', {'speed', 'altitude'}),
          _item(values, capabilities, 'landing_speed', {'speed', 'altitude'}),
          _item(values, capabilities, 'clean_landing_rate', {'motion'}),
          _item(values, capabilities, 'impact_score', {'motion'}),
        ],
      ),
      SessionKpiGroup(
        title: 'Control tecnico',
        items: [
          _item(values, capabilities, 'variabilidad_velocidad', {'speed'}),
          _item(values, capabilities, 'estabilidad_direccional', {
            'gps',
            'motion',
          }),
          _item(values, capabilities, 'calidad_jibe', {'motion', 'speed'}),
          _item(values, capabilities, 'perdida_vel_transiciones', {
            'motion',
            'speed',
          }),
          _item(values, capabilities, 'recuperacion_planeo', {
            'motion',
            'speed',
          }),
          _item(values, capabilities, 'smoothness_score', {'motion'}),
        ],
      ),
      SessionKpiGroup(
        title: 'Condiciones meteo-contexto',
        items: [
          _item(values, capabilities, 'viento_medio', {'weather'}),
          _item(values, capabilities, 'viento_rango', {'weather'}),
          _item(values, capabilities, 'direccion_dominante', {'weather'}),
          _item(values, capabilities, 'gust_factor', {'weather'}),
          _item(values, capabilities, 'temperatura', {'weather'}),
          _item(values, capabilities, 'presion', {'weather', 'barometer'}),
          _item(values, capabilities, 'lluvia', {'weather'}),
        ],
      ),
      SessionKpiGroup(
        title: 'Seguridad y riesgo',
        items: [
          _item(values, capabilities, 'caidas_hora', {'motion'}),
          _item(values, capabilities, 'eventos_sobrepotencia', {
            'motion',
            'speed',
          }),
          _item(values, capabilities, 'distancia_max_costa', {'gps'}),
          _item(values, capabilities, 'tiempo_zona_riesgo', {'gps'}),
          _item(values, capabilities, 'alertas_atendidas', {'network'}),
          _item(values, capabilities, 'fatiga_estimada', {'heart_rate'}),
        ],
      ),
      SessionKpiGroup(
        title: 'Dispositivo y calidad de datos',
        items: [
          _item(values, capabilities, 'bateria_hora', {'battery'}),
          _item(values, capabilities, 'calidad_gps', {'gps'}),
          _item(values, capabilities, 'samples_perdidos', {'network'}),
          _item(values, capabilities, 'latencia_sync', {'network'}),
          _item(values, capabilities, 'health_dataset', {'network'}),
        ],
      ),
      SessionKpiGroup(
        title: 'KPIs compuestos',
        items: [
          _item(values, capabilities, 'session_score', {'gps', 'speed'}),
          _item(values, capabilities, 'big_air_score', {'altitude', 'speed'}),
          _item(values, capabilities, 'freestyle_score', {'motion'}),
          _item(values, capabilities, 'freeride_score', {'gps', 'speed'}),
          _item(values, capabilities, 'safety_score', {'motion', 'gps'}),
          _item(values, capabilities, 'progress_score', {'network'}),
        ],
      ),
    ];

    final eventsCatalog = [
      'Racha fuerte registrada',
      'Planeo sostenido en tramo largo',
      'Jibe limpio completado',
      'Salto con recepcion estable',
      'Cambio de direccion con control',
      'Sincronizacion de sensores finalizada',
    ];
    final eventsCount = 3 + (seed % 3);
    final events = List<String>.generate(
      eventsCount,
      (index) => eventsCatalog[(seed + index) % eventsCatalog.length],
    );

    return SessionInsightData(
      distanceKm: capabilities.contains('gps') ? distance : null,
      maxSpeedKnots: capabilities.contains('speed') ? maxSpeed : null,
      avgSpeedKnots: capabilities.contains('speed') ? avgSpeed : null,
      movingAvgSpeedKnots: capabilities.contains('speed') ? avgSpeed : null,
      planingMinutes: capabilities.contains('motion') ? planing : null,
      recordedPointCount: null,
      autoPauseCount: null,
      batteryStart: capabilities.contains('battery') ? batteryStart : null,
      batteryEnd: capabilities.contains('battery') ? batteryEnd : null,
      jumpsCount: capabilities.contains('altitude') ? jumps : null,
      maxJumpHeightMeters: capabilities.contains('altitude')
          ? maxJumpHeight
          : null,
      maxHangtimeSeconds: capabilities.contains('altitude')
          ? maxHangtime
          : null,
      jumpHistory: jumpHistory,
      timelineKnots: timeline,
      routePoints: const <SessionTrackPoint>[],
      events: events,
      groups: groups,
    );
  }

  static SessionKpiItem _item(
    Map<String, String> values,
    Set<String> capabilities,
    String key,
    Set<String> required,
  ) {
    final available = required.every(capabilities.contains);
    return SessionKpiItem(
      label: _kpiLabels[key] ?? key,
      value: values[key] ?? '--',
      available: available,
    );
  }

  static Set<String> _sensorSetForKind(String kind) {
    switch (kind) {
      case 'Woo Sports':
        return {
          'gps',
          'speed',
          'motion',
          'altitude',
          'battery',
          'network',
          'weather',
        };
      case 'Apple Watch':
      case 'Smartwatch':
        return {
          'gps',
          'speed',
          'motion',
          'altitude',
          'heart_rate',
          'barometer',
          'battery',
          'network',
          'weather',
        };
      case 'SurfR':
        return {'gps', 'speed', 'motion', 'battery', 'network', 'weather'};
      case 'Android':
      case 'Dispositivo Android':
        return {'gps', 'speed', 'motion', 'battery', 'network', 'weather'};
      case 'iPhone':
        return {'gps', 'speed', 'motion', 'battery', 'network', 'weather'};
      case 'Web':
        return {'network', 'weather'};
      default:
        return {'gps', 'motion', 'battery'};
    }
  }

  static Set<String> capabilitiesForDeviceKind(String kind) {
    return _sensorSetForKind(kind);
  }

  static int _seedFrom(
    String title,
    String deviceName,
    DateTime endedAt,
    String deviceKind,
  ) {
    final source =
        '$title|$deviceName|$deviceKind|${endedAt.millisecondsSinceEpoch}';
    var acc = 0;
    for (final codeUnit in source.codeUnits) {
      acc = (acc * 31 + codeUnit) % 100000;
    }
    return acc;
  }

  static Duration _parseDuration(String label) {
    final parts = label.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0]) ?? 0;
      final s = int.tryParse(parts[1]) ?? 0;
      return Duration(minutes: m, seconds: s);
    }
    if (parts.length == 3) {
      final h = int.tryParse(parts[0]) ?? 0;
      final m = int.tryParse(parts[1]) ?? 0;
      final s = int.tryParse(parts[2]) ?? 0;
      return Duration(hours: h, minutes: m, seconds: s);
    }
    return const Duration(minutes: 45);
  }

  static List<SessionJumpRecord> _buildJumpHistory({
    required int seed,
    required int jumpsCount,
    required double maxJumpHeight,
    required double maxHangtime,
    required Duration duration,
    required bool hasJumpSensors,
  }) {
    if (!hasJumpSensors || duration.inSeconds <= 0) {
      return const <SessionJumpRecord>[];
    }

    final count = jumpsCount.clamp(6, 18);
    final records = <SessionJumpRecord>[];

    for (var i = 0; i < count; i++) {
      final ratio = (i + 1) / (count + 1);
      final sinus = (math.sin((seed + i * 17) * 0.13) + 1) / 2;
      final height = (maxJumpHeight * (0.42 + sinus * 0.56)).clamp(
        1.8,
        maxJumpHeight,
      );
      final hangtime = (maxHangtime * (0.5 + sinus * 0.45)).clamp(1.2, 8.5);
      final fallSpeed = (4.0 + (height / math.max(1.0, hangtime)) * 1.7).clamp(
        3.8,
        11.8,
      );
      final secondOfSession = (duration.inSeconds * ratio).round();
      final minute = secondOfSession ~/ 60;
      final second = secondOfSession % 60;

      records.add(
        SessionJumpRecord(
          jumpNumber: i + 1,
          heightMeters: height,
          hangtimeSeconds: hangtime,
          fallSpeedMetersPerSecond: fallSpeed,
          timeLabel:
              '${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')}',
        ),
      );
    }

    return records;
  }
}

class SessionTrackPoint {
  const SessionTrackPoint({
    required this.latitude,
    required this.longitude,
    required this.speedKnots,
    required this.recordedAt,
  });

  final double latitude;
  final double longitude;
  final double speedKnots;
  final DateTime recordedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      'speedKnots': speedKnots,
      'recordedAt': recordedAt.toIso8601String(),
    };
  }

  static SessionTrackPoint fromJson(Map<String, dynamic> json) {
    return SessionTrackPoint(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      speedKnots: (json['speedKnots'] as num?)?.toDouble() ?? 0,
      recordedAt: DateTime.tryParse(json['recordedAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class SessionJumpRecord {
  const SessionJumpRecord({
    required this.jumpNumber,
    required this.heightMeters,
    required this.hangtimeSeconds,
    required this.fallSpeedMetersPerSecond,
    required this.timeLabel,
  });

  final int jumpNumber;
  final double heightMeters;
  final double hangtimeSeconds;
  final double fallSpeedMetersPerSecond;
  final String timeLabel;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'jumpNumber': jumpNumber,
      'heightMeters': heightMeters,
      'hangtimeSeconds': hangtimeSeconds,
      'fallSpeedMetersPerSecond': fallSpeedMetersPerSecond,
      'timeLabel': timeLabel,
    };
  }

  static SessionJumpRecord fromJson(Map<String, dynamic> json) {
    return SessionJumpRecord(
      jumpNumber: (json['jumpNumber'] as num?)?.toInt() ?? 0,
      heightMeters: (json['heightMeters'] as num?)?.toDouble() ?? 0,
      hangtimeSeconds: (json['hangtimeSeconds'] as num?)?.toDouble() ?? 0,
      fallSpeedMetersPerSecond:
          (json['fallSpeedMetersPerSecond'] as num?)?.toDouble() ?? 0,
      timeLabel: json['timeLabel'] as String? ?? '00:00',
    );
  }
}

class SessionKpiGroup {
  const SessionKpiGroup({required this.title, required this.items});

  final String title;
  final List<SessionKpiItem> items;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'title': title,
      'items': items.map((entry) => entry.toJson()).toList(growable: false),
    };
  }

  static SessionKpiGroup fromJson(Map<String, dynamic> json) {
    return SessionKpiGroup(
      title: json['title'] as String? ?? 'KPIs',
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(SessionKpiItem.fromJson)
          .toList(growable: false),
    );
  }
}

class SessionKpiItem {
  const SessionKpiItem({
    required this.label,
    required this.value,
    required this.available,
  });

  final String label;
  final String value;
  final bool available;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'label': label,
      'value': value,
      'available': available,
    };
  }

  static SessionKpiItem fromJson(Map<String, dynamic> json) {
    return SessionKpiItem(
      label: json['label'] as String? ?? '--',
      value: json['value'] as String? ?? '--',
      available: json['available'] as bool? ?? false,
    );
  }
}

const Map<String, String> _kpiLabels = {
  'duracion_total': 'Duracion total',
  'tiempo_activo': 'Tiempo activo',
  'tiempo_parado': 'Tiempo parado',
  'ratio_activo_parado': 'Ratio activo/parado',
  'distancia_total': 'Distancia total',
  'distancia_planeo': 'Distancia en planeo',
  'distancia_upwind': 'Distancia upwind',
  'distancia_downwind': 'Distancia downwind',
  'velocidad_media': 'Velocidad media',
  'velocidad_max': 'Velocidad maxima',
  'velocidad_p95': 'Top velocidad estable',
  'racha_max': 'Racha maxima',
  'racha_10s': 'Racha sostenida (10s)',
  'transiciones': 'Transiciones',
  'transiciones_hora': 'Transiciones por hora',
  'top5_saltos': 'Top 5 saltos',
  'altura_media_saltos': 'Altura media de saltos',
  'hangtime_max': 'Hangtime maximo',
  'hangtime_p95': 'Top hangtime estable',
  'eficiencia_salto_viento': 'Eficiencia salto/viento',
  'cadencia_saltos': 'Cadencia de saltos',
  'consistencia_alturas': 'Variacion de alturas',
  'intentos_truco': 'Intentos por trick',
  'exito_truco': 'Tasa de exito por trick',
  'combo_rate': 'Combo rate',
  'dificultad_media': 'Dificultad media',
  'caidas_intento': 'Caidas por intento',
  'progresion_truco': 'Progresion por trick',
  'vmg_upwind': 'Velocidad efectiva upwind',
  'vmg_downwind': 'Velocidad efectiva downwind',
  'angulo_cenida': 'Angulo de cenida',
  'eficiencia_bordos': 'Eficiencia de bordos',
  'tiempo_sweetspot': 'Tiempo en sweet spot',
  'deriva_neta': 'Deriva neta',
  'cobertura_area': 'Cobertura de area',
  'salto_mas_alto': 'Salto mas alto',
  'distancia_salto_estimada': 'Distancia salto (estimada)',
  'distribucion_alturas': 'Distribucion de alturas',
  'takeoff_speed': 'Takeoff speed',
  'landing_speed': 'Fuerza G al aterrizar',
  'clean_landing_rate': 'Clean landing rate',
  'impact_score': 'Impact score',
  'variabilidad_velocidad': 'Variabilidad de velocidad',
  'estabilidad_direccional': 'Estabilidad direccional',
  'calidad_jibe': 'Calidad del giro downwind',
  'perdida_vel_transiciones': 'Perdida vel. en transiciones',
  'recuperacion_planeo': 'Recuperacion de planeo',
  'smoothness_score': 'Smoothness score',
  'viento_medio': 'Viento medio',
  'viento_rango': 'Rango de viento',
  'direccion_dominante': 'Direccion dominante',
  'gust_factor': 'Gust factor',
  'temperatura': 'Temperatura',
  'presion': 'Presion',
  'lluvia': 'Lluvia',
  'caidas_hora': 'Caidas por hora',
  'eventos_sobrepotencia': 'Eventos de sobrepotencia',
  'distancia_max_costa': 'Distancia maxima a costa',
  'tiempo_zona_riesgo': 'Tiempo en zona de riesgo',
  'alertas_atendidas': 'Alertas atendidas',
  'fatiga_estimada': 'Fatiga estimada',
  'bateria_hora': 'Bateria por hora',
  'calidad_gps': 'Calidad GPS',
  'samples_perdidos': 'Samples perdidos',
  'latencia_sync': 'Latencia de sincronizacion',
  'health_dataset': 'Health score del dataset',
  'pb_altura': 'PB altura',
  'pb_velocidad': 'PB velocidad',
  'evolucion_30d': 'Evolucion 30 dias',
  'consistencia_semanal': 'Consistencia semanal',
  'percentil_comunidad': 'Percentil comunidad',
  'retos_cumplidos': 'Retos cumplidos',
  'session_score': 'Session score',
  'big_air_score': 'Big Air score',
  'freestyle_score': 'Freestyle score',
  'freeride_score': 'Freeride score',
  'safety_score': 'Safety score',
  'progress_score': 'Progress score',
};
