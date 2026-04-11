import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';
import 'package:windwisher/features/sessions/presentation/widgets/session_detail/advanced_metrics_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/session_detail/session_hero_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/session_detail/session_summary_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/session_detail/session_track_card.dart';
import 'package:windwisher/features/sessions/presentation/widgets/shared/session_device_dialog.dart';
import 'package:windwisher/features/sessions/presentation/widgets/shared/session_gear_dialog.dart';

enum SessionDetailSource { mySessions, community }

enum SessionDetailActionType { edit, delete }

class SessionDetailAction {
  const SessionDetailAction(this.type);

  final SessionDetailActionType type;
}

class SessionDetailPage extends StatefulWidget {
  const SessionDetailPage({
    super.key,
    required this.title,
    required this.deviceName,
    required this.deviceKind,
    required this.endedAt,
    required this.durationLabel,
    required this.summary,
    required this.source,
    this.deviceSensorKeys = const <String>[],
    this.gearSetupName,
    this.gearSetupDetailLines = const <String>[],
    this.hasSessionPhoto = false,
    this.sessionMediaLabel,
    this.sessionPhotoLocalPath,
    this.spotBackgroundImagePath,
    required this.insights,
  });

  final String title;
  final String deviceName;
  final String deviceKind;
  final DateTime endedAt;
  final String durationLabel;
  final String summary;
  final SessionDetailSource source;
  final List<String> deviceSensorKeys;
  final String? gearSetupName;
  final List<String> gearSetupDetailLines;
  final bool hasSessionPhoto;
  final String? sessionMediaLabel;
  final String? sessionPhotoLocalPath;
  final String? spotBackgroundImagePath;
  final SessionInsightData insights;

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _summarySectionKey = GlobalKey();
  final GlobalKey _jumpHistorySectionKey = GlobalKey();
  final GlobalKey _advancedSectionKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de sesión'),
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
            SessionHeroCard(
              title: widget.title,
              endedAt: widget.endedAt,
              summary: widget.summary,
              deviceName: widget.deviceName,
              deviceKind: widget.deviceKind,
              gearSetupName: widget.gearSetupName,
              sessionPhotoLocalPath: widget.sessionPhotoLocalPath,
              spotBackgroundImagePath: widget.spotBackgroundImagePath,
              onDevicePressed: _showDeviceCapabilitiesDialog,
              onGearPressed: _showGearSetupDialog,
            ),
            const SizedBox(height: AppSpacing.sm),
            SessionSummaryCard(
              key: _summarySectionKey,
              insights: widget.insights,
              durationLabel: widget.durationLabel,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (widget.insights.routePoints.isNotEmpty) ...[
              SessionTrackCard(
                insights: widget.insights,
                durationLabel: widget.durationLabel,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Card(
              key: _jumpHistorySectionKey,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: widget.insights.jumpHistory.isEmpty
                    ? _buildCompactEmptyJumpHistory(context)
                    : _buildFullJumpHistory(context),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            AdvancedMetricsCard(
              key: _advancedSectionKey,
              groups: widget.insights.advancedMetrics.groups,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showGearSetupDialog() async {
    if (widget.gearSetupName == null || widget.gearSetupName!.isEmpty) {
      return;
    }
    await SessionGearDialog.show(
      context,
      gearSetupName: widget.gearSetupName!,
      gearSetupDetailLines: widget.gearSetupDetailLines,
    );
  }

  Widget _buildCompactEmptyJumpHistory(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historial de saltos', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            Chip(
              label: Text(
                _jumpDetectionModeChipLabel(widget.insights.jumpDetectionMode),
              ),
            ),
            const Chip(label: Text('0 saltos')),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          _jumpHistoryEmptyLabel(widget.insights.jumpDetectionMode),
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildFullJumpHistory(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historial de saltos', style: textTheme.titleMedium),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _jumpHistoryDescription(widget.insights.jumpDetectionMode),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _jumpDetectionModeLabel(widget.insights.jumpDetectionMode),
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            Chip(
              label: Text(
                _jumpDetectionModeChipLabel(widget.insights.jumpDetectionMode),
              ),
            ),
            Chip(label: Text('${widget.insights.jumpHistory.length} saltos')),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            Chip(
              label: Text(
                '${_maxJumpHeightPrefix(widget.insights.jumpDetectionMode)} ${_maxJumpHeightLabel(widget.insights.jumpHistory)}',
              ),
            ),
            Chip(
              label: Text(
                'Hangtime: ${_maxHangtimeLabel(widget.insights.jumpHistory)}',
              ),
            ),
            Chip(
              label: Text(
                'Maniobra: ${_avgManeuverGLabel(widget.insights.jumpHistory)}',
              ),
            ),
            if (_avgManeuverRotationLabel(widget.insights.jumpHistory)
                case final rotationLabel?)
              Chip(label: Text('Rotacion: $rotationLabel')),
            Chip(
              label: Text(
                'Recepcion: ${_avgLandingGLabel(widget.insights.jumpHistory)}',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        _JumpHistoryTable(
          records: widget.insights.jumpHistory,
          jumpDetectionMode: widget.insights.jumpDetectionMode,
        ),
      ],
    );
  }

  String _jumpDetectionModeLabel(String mode) {
    switch (mode) {
      case 'barometric':
        return 'Saltos calculados con perfil vertical barometrico.';
      case 'inertial_fallback':
      default:
        return 'Saltos calculados con fallback inercial del dispositivo.';
    }
  }

  String _jumpHistoryDescription(String mode) {
    switch (mode) {
      case 'barometric':
        return 'Nº, altura real, hangtime, G de maniobra, G de recepcion y momento exacto del salto.';
      case 'inertial_fallback':
      default:
        return 'Nº, altura estimada, hangtime, G de maniobra, G de recepcion y momento exacto del salto.';
    }
  }

  String _jumpDetectionModeChipLabel(String mode) {
    switch (mode) {
      case 'barometric':
        return 'Modo: Barometrico';
      case 'inertial_fallback':
      default:
        return 'Modo: Inercial';
    }
  }

  String _jumpHistoryEmptyLabel(String mode) {
    switch (mode) {
      case 'barometric':
        return 'No se han detectado saltos con perfil vertical barometrico en esta sesion.';
      case 'inertial_fallback':
      default:
        return 'No se han detectado saltos con el fallback inercial de esta sesion.';
    }
  }

  String _maxJumpHeightLabel(List<SessionJumpRecord> records) {
    final heightValues = records
        .map((record) => record.heightMeters)
        .where((value) => value > 0)
        .toList(growable: false);
    if (heightValues.isEmpty) {
      return 'No disponible';
    }
    final value = heightValues.reduce((a, b) => a > b ? a : b);
    return '${value.toStringAsFixed(1)} m';
  }

  String _maxJumpHeightPrefix(String mode) {
    switch (mode) {
      case 'barometric':
        return 'Max:';
      case 'inertial_fallback':
      default:
        return 'Max est.:';
    }
  }

  String _maxHangtimeLabel(List<SessionJumpRecord> records) {
    final value = records
        .map((record) => record.hangtimeSeconds)
        .reduce((a, b) => a > b ? a : b);
    return '${value.toStringAsFixed(1)} s';
  }

  String _avgLandingGLabel(List<SessionJumpRecord> records) {
    final value =
        records.map((record) => record.landingG).reduce((a, b) => a + b) /
        records.length;
    return '${value.toStringAsFixed(1)} G';
  }

  String _avgManeuverGLabel(List<SessionJumpRecord> records) {
    final values = records
        .map((record) => record.maneuverG)
        .whereType<double>()
        .toList(growable: false);
    if (values.isEmpty) {
      return '--';
    }
    final value = values.reduce((a, b) => a + b) / values.length;
    return '${value.toStringAsFixed(1)} G';
  }

  String? _avgManeuverRotationLabel(List<SessionJumpRecord> records) {
    final values = records
        .map((record) => record.maneuverRotationDegPerSec)
        .whereType<double>()
        .toList(growable: false);
    if (values.isEmpty) {
      return null;
    }
    final value = values.reduce((a, b) => a + b) / values.length;
    return '${value.toStringAsFixed(0)} °/s';
  }

  Future<void> _showDeviceCapabilitiesDialog() async {
    await SessionDeviceDialog.show(
      context,
      deviceName: widget.deviceName,
      deviceKind: widget.deviceKind,
      deviceSensorKeys: widget.deviceSensorKeys.isNotEmpty
          ? widget.deviceSensorKeys
          : SessionInsightData.physicalSensorsForDeviceKind(
              widget.deviceKind,
            ).toList(growable: false),
    );
  }
}

class _NoStretchScrollBehavior extends AppScrollBehavior {
  const _NoStretchScrollBehavior();
}

class _JumpHistoryTable extends StatelessWidget {
  const _JumpHistoryTable({
    required this.records,
    required this.jumpDetectionMode,
  });

  final List<SessionJumpRecord> records;
  final String jumpDetectionMode;

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.labelMedium;
    final rowStyle = Theme.of(context).textTheme.bodySmall;

    Widget buildRow({
      required String left,
      required String h,
      required String t,
      required String maneuver,
      required String landing,
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
            Expanded(child: Text(maneuver, style: style)),
            Expanded(child: Text(landing, style: style)),
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
            h: jumpDetectionMode == 'barometric' ? 'Altura' : 'Altura est.',
            t: 'Hangtime',
            maneuver: 'Maniobra',
            landing: 'Recepción',
            when: 'Min:Seg',
            header: true,
          ),
          const Divider(height: 10),
          ...records.map(
            (record) => buildRow(
              left: '${record.jumpNumber}',
              h: record.heightMeters > 0
                  ? '${record.heightMeters.toStringAsFixed(1)} m'
                  : '--',
              t: '${record.hangtimeSeconds.toStringAsFixed(1)} s',
              maneuver: record.maneuverG == null
                  ? '--'
                  : '${record.maneuverG!.toStringAsFixed(1)} G',
              landing: '${record.landingG.toStringAsFixed(1)} G',
              when: record.timeLabel,
            ),
          ),
        ],
      ),
    );
  }
}
