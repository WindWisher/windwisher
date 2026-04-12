import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/community/application/use_cases/community_session_comments_use_cases.dart';
import 'package:windwisher/features/community/application/use_cases/community_following_preferences_use_cases.dart';
import 'package:windwisher/features/community/application/use_cases/community_session_reactions_use_cases.dart';
import 'package:windwisher/features/community/application/services/community_orchestration_service.dart';
import 'package:windwisher/features/community/di/community_module.dart';
import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/entities/session_comment.dart';
import 'package:windwisher/features/community/domain/entities/session_like_state.dart';
import 'package:windwisher/features/community/presentation/pages/community_user_profile_page.dart';
import 'package:windwisher/features/community/presentation/pages/community_user_sessions_page.dart';
import 'package:windwisher/features/community/presentation/support/community_identity_mapper.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';
import 'package:windwisher/features/sessions/presentation/pages/session_detail_page.dart';

typedef _CommunityUser = CommunityUserSummary;
typedef _FollowingSession = FollowingSession;

class CommunityPage extends StatefulWidget {
  const CommunityPage({
    super.key,
    this.useLocalPersistence = EnvConfig.communityLocalPersistenceEnabled,
  });

  final bool useLocalPersistence;

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  static const int _pageSize = 50;
  static const List<_KpiFilterOption> _kpiOrderOptions = [
    _KpiFilterOption.metric('salto_mas_alto', 'Salto mas alto', 'm'),
    _KpiFilterOption.metric('big_air_score', 'Big Air score', 'pts'),
    _KpiFilterOption.metric('numero_saltos', 'Numero de saltos', 'count'),
    _KpiFilterOption.divider(),
    _KpiFilterOption.group('Core Session'),
    _KpiFilterOption.metric('duracion_total', 'Duracion total', 'min'),
    _KpiFilterOption.metric('tiempo_activo', 'Tiempo activo', 'min'),
    _KpiFilterOption.metric('tiempo_parado', 'Tiempo parado', 'min'),
    _KpiFilterOption.metric('ratio_activo_parado', 'Ratio activo/parado', 'x'),
    _KpiFilterOption.metric('distancia_total', 'Distancia total', 'km'),
    _KpiFilterOption.metric('distancia_planeo', 'Distancia en planeo', 'km'),
    _KpiFilterOption.metric('distancia_upwind', 'Distancia upwind', 'km'),
    _KpiFilterOption.metric('distancia_downwind', 'Distancia downwind', 'km'),
    _KpiFilterOption.metric('velocidad_media', 'Velocidad media', 'kt'),
    _KpiFilterOption.metric('velocidad_max', 'Velocidad maxima', 'kt'),
    _KpiFilterOption.metric('velocidad_p95', 'Velocidad alta sostenida', 'kt'),
    _KpiFilterOption.metric('transiciones', 'Transiciones', 'count'),
    _KpiFilterOption.metric(
      'transiciones_hora',
      'Transiciones por hora',
      'count/h',
    ),
    _KpiFilterOption.group('Big Air'),
    _KpiFilterOption.metric('top5_saltos', 'Top 5 saltos', 'm'),
    _KpiFilterOption.metric(
      'altura_media_saltos',
      'Altura media de saltos',
      'm',
    ),
    _KpiFilterOption.metric('hangtime_max', 'Hangtime maximo', 's'),
    _KpiFilterOption.metric('hangtime_p95', 'Top hangtime estable', 's'),
    _KpiFilterOption.metric(
      'eficiencia_salto_viento',
      'Eficiencia salto/viento',
      'm/kt',
    ),
    _KpiFilterOption.metric(
      'cadencia_saltos',
      'Cadencia de saltos',
      'min/salto',
    ),
    _KpiFilterOption.metric(
      'consistencia_alturas',
      'Variacion de alturas',
      '%',
    ),
    _KpiFilterOption.group('Maniobras'),
    _KpiFilterOption.metric('intentos_truco', 'Intentos de maniobra', 'count'),
    _KpiFilterOption.metric('exito_truco', 'Exito de maniobra', '%'),
    _KpiFilterOption.metric('combo_rate', 'Secuencia de maniobras', '%'),
    _KpiFilterOption.metric(
      'dificultad_media',
      'Intensidad de maniobra',
      '/10',
    ),
    _KpiFilterOption.metric('caidas_intento', 'Caidas por maniobra', 'count'),
    _KpiFilterOption.metric('progresion_truco', 'Progresion de maniobra', '%'),
    _KpiFilterOption.group('Freeride / Navegacion'),
    _KpiFilterOption.metric('vmg_upwind', 'Velocidad efectiva upwind', 'kt'),
    _KpiFilterOption.metric(
      'vmg_downwind',
      'Velocidad efectiva downwind',
      'kt',
    ),
    _KpiFilterOption.metric('angulo_cenida', 'Angulo de cenida', 'deg'),
    _KpiFilterOption.metric('eficiencia_bordos', 'Eficiencia de bordos', '%'),
    _KpiFilterOption.metric('tiempo_sweetspot', 'Tiempo en sweet spot', '%'),
    _KpiFilterOption.metric('deriva_neta', 'Deriva neta', 'km'),
    _KpiFilterOption.metric('cobertura_area', 'Cobertura de area', 'km2'),
    _KpiFilterOption.group('Saltos'),
    _KpiFilterOption.metric('takeoff_speed', 'Velocidad de despegue', 'kt'),
    _KpiFilterOption.metric('landing_speed', 'Velocidad de aterrizaje', 'kt'),
    _KpiFilterOption.metric('clean_landing_rate', 'Clean landing rate', '%'),
    _KpiFilterOption.metric('impact_score', 'Impact score', '/10'),
    _KpiFilterOption.group('Control tecnico'),
    _KpiFilterOption.metric(
      'variabilidad_velocidad',
      'Variabilidad de velocidad',
      'kt',
    ),
    _KpiFilterOption.metric(
      'estabilidad_direccional',
      'Estabilidad direccional',
      '%',
    ),
    _KpiFilterOption.metric('calidad_jibe', 'Calidad del giro downwind', '%'),
    _KpiFilterOption.metric(
      'perdida_vel_transiciones',
      'Perdida vel. en transiciones',
      'kt',
    ),
    _KpiFilterOption.metric(
      'recuperacion_planeo',
      'Recuperacion de planeo',
      's',
    ),
    _KpiFilterOption.metric(
      'smoothness_score',
      'Suavidad de navegacion',
      '/10',
    ),
    _KpiFilterOption.group('Condiciones meteo-contexto'),
    _KpiFilterOption.metric('viento_medio', 'Viento medio', 'kt'),
    _KpiFilterOption.metric('viento_rango', 'Rango de viento', 'kt'),
    _KpiFilterOption.metric(
      'direccion_dominante',
      'Direccion dominante',
      'deg',
    ),
    _KpiFilterOption.metric('gust_factor', 'Gust factor', 'x'),
    _KpiFilterOption.metric('temperatura', 'Temperatura', 'C'),
    _KpiFilterOption.metric('presion', 'Presion', 'hPa'),
    _KpiFilterOption.metric('lluvia', 'Lluvia', 'bin'),
    _KpiFilterOption.group('Seguridad y riesgo'),
    _KpiFilterOption.metric('caidas_hora', 'Caidas por hora', 'count/h'),
    _KpiFilterOption.metric(
      'eventos_sobrepotencia',
      'Eventos de sobrepotencia',
      'count',
    ),
    _KpiFilterOption.metric(
      'distancia_max_costa',
      'Distancia maxima a costa',
      'km',
    ),
    _KpiFilterOption.metric(
      'tiempo_zona_riesgo',
      'Tiempo en zona de riesgo',
      'min',
    ),
    _KpiFilterOption.metric('alertas_atendidas', 'Alertas atendidas', '%'),
    _KpiFilterOption.metric('fatiga_estimada', 'Fatiga estimada', '%'),
    _KpiFilterOption.group('Dispositivo y calidad de datos'),
    _KpiFilterOption.metric('bateria_hora', 'Bateria por hora', '%/h'),
    _KpiFilterOption.metric('calidad_gps', 'Calidad GPS', '%'),
    _KpiFilterOption.metric('samples_perdidos', 'Samples perdidos', '%'),
    _KpiFilterOption.metric('latencia_sync', 'Latencia de sincronizacion', 's'),
    _KpiFilterOption.metric('health_dataset', 'Health score del dataset', '%'),
    _KpiFilterOption.group('KPIs compuestos'),
    _KpiFilterOption.metric('session_score', 'Session score', 'pts'),
    _KpiFilterOption.metric('freestyle_score', 'Score de maniobras', 'pts'),
    _KpiFilterOption.metric('freeride_score', 'Freeride score', 'pts'),
    _KpiFilterOption.metric('safety_score', 'Safety score', 'pts'),
    _KpiFilterOption.metric('progress_score', 'Progress score', 'pts'),
  ];

  final ScrollController _leaderboardScrollController = ScrollController();
  late final CommunityModule _communityModule;
  late final CommunityOrchestrationService _orchestration;
  late final GetSessionCommentsUseCase _getSessionComments;
  late final AddSessionCommentUseCase _addSessionComment;
  late final GetSessionLikeStateUseCase _getSessionLikeState;
  late final ToggleSessionLikeUseCase _toggleSessionLike;
  late final GetFollowingUsernamesUseCase _getFollowingUsernames;
  late final SaveFollowingUsernamesUseCase _saveFollowingUsernames;

  _CommunityTab _selectedTab = _CommunityTab.leaderboard;
  _SocialPeopleTab _socialPeopleTab = _SocialPeopleTab.feed;
  String _followingSearchQuery = '';
  String _followersSearchQuery = '';
  String _exploreSearchQuery = '';
  String _draftPeriod = '7d';
  String _draftSpot = 'Todos';
  String _draftScope = 'Global';
  String _draftOrder = 'salto_mas_alto';

  String _appliedPeriod = '7d';
  String _appliedSpot = 'Todos';
  String _appliedScope = 'Global';
  String _appliedOrder = 'salto_mas_alto';
  bool _showLeaderboardFilters = false;

  int _visibleLeaderboardCount = _pageSize;

  late final String _myUsername;
  late final String _myDisplayName;
  late final String? _myAvatarLocalPath;
  late final String? _myBannerLocalPath;

  static const Set<String> _defaultFollowingUsernames = {
    'air_lucas',
    'mara_bigair',
    'nico_loop',
  };

  final Set<String> _followingUsernames = <String>{};

  final Set<String> _followerUsernames = {
    'sofi_wind',
    'alex_wave',
    'javi_foil',
    'you_rider_fan',
  };

  final List<_CommunityUser> _users = [];

  final List<_FollowingSession> _sessions = [];
  final Map<String, List<SessionComment>> _sessionCommentsBySessionId = {};
  final Map<String, SessionLikeState> _sessionLikeStatesBySessionId = {};

  @override
  void initState() {
    super.initState();
    final myProfile = _resolveCurrentProfile();
    _myUsername = _normalizedUsername(myProfile.handle);
    _myDisplayName = myProfile.displayName;
    _myAvatarLocalPath = myProfile.avatarLocalPath;
    _myBannerLocalPath = myProfile.bannerLocalPath;

    _communityModule = widget.useLocalPersistence
        ? CommunityModule.auto()
        : CommunityModule.inMemory();
    _orchestration = _communityModule.orchestration;
    _getSessionComments = _communityModule.getSessionComments;
    _addSessionComment = _communityModule.addSessionComment;
    _getSessionLikeState = _communityModule.getSessionLikeState;
    _toggleSessionLike = _communityModule.toggleSessionLike;
    _getFollowingUsernames = _communityModule.getFollowingUsernames;
    _saveFollowingUsernames = _communityModule.saveFollowingUsernames;
    _users.addAll(_communityModule.getCommunityUsers());
    _upsertCurrentUserSummary(myProfile);
    _hydrateFollowingUsernames();
    _sessions.addAll(_communityModule.getFollowingSessions());
    for (final session in _sessions) {
      _sessionCommentsBySessionId[session.id] = _getSessionComments(
        sessionId: session.id,
      );
      _sessionLikeStatesBySessionId[session.id] = _getSessionLikeState(
        sessionId: session.id,
        username: _myUsername,
      );
    }
    _leaderboardScrollController.addListener(_onLeaderboardScroll);
    _hydrateCommunityData();
  }

  Future<void> _hydrateCommunityData() async {
    final users = await _communityModule.getCommunityUsers.load();
    final sessions = await _communityModule.getFollowingSessions.load();
    final commentsEntries = await Future.wait(
      sessions.map((session) async {
        final comments = await _getSessionComments.load(sessionId: session.id);
        return MapEntry(session.id, comments);
      }),
    );
    final likeEntries = await Future.wait(
      sessions.map((session) async {
        final likeState = await _getSessionLikeState.load(
          sessionId: session.id,
          username: _myUsername,
        );
        return MapEntry(session.id, likeState);
      }),
    );
    if (!mounted) {
      return;
    }

    final myProfile = _resolveCurrentProfile();
    setState(() {
      _users
        ..clear()
        ..addAll(users);
      _upsertCurrentUserSummary(myProfile);
      _sessions
        ..clear()
        ..addAll(sessions);
      _sessionCommentsBySessionId
        ..clear()
        ..addEntries(commentsEntries);
      _sessionLikeStatesBySessionId
        ..clear()
        ..addEntries(likeEntries);
    });
  }

  Future<void> _hydrateFollowingUsernames() async {
    final persisted = await _getFollowingUsernames.load();
    if (!mounted) {
      return;
    }
    if (persisted == null) {
      _followingUsernames
        ..clear()
        ..addAll(_defaultFollowingUsernames);
      unawaited(_saveFollowingUsernames(Set<String>.from(_followingUsernames)));
      return;
    }

    setState(() {
      _followingUsernames
        ..clear()
        ..addAll(persisted);
    });
  }

  UserProfileData _resolveCurrentProfile() {
    if (widget.useLocalPersistence &&
        EnvConfig.profileLocalPersistenceEnabled) {
      return ProfileModule.auto().profileController.profile;
    }
    return ProfileModule.inMemory().profileController.profile;
  }

  String _normalizedUsername(String handle) {
    return CommunityIdentityMapper.normalizedUsername(handle);
  }

  void _upsertCurrentUserSummary(UserProfileData profile) {
    final currentUsername = _normalizedUsername(profile.handle);
    _users.removeWhere((user) => user.username == currentUsername);

    final seed = currentUsername.codeUnits.fold<int>(
      0,
      (sum, code) => sum + code,
    );
    _users.add(
      CommunityUserSummary(
        username: currentUsername,
        bigAirScore: int.tryParse(profile.totalSessions) ?? 0,
        highestJumpMeters:
            double.tryParse(profile.topJump.replaceAll('m', '').trim()) ?? 0,
        mainSpot: '',
        avatarColorValue: 0xFF455A64 + (seed % 0x00020202),
      ),
    );
  }

  List<SessionComment> _sessionComments(_FollowingSession session) {
    return _sessionCommentsBySessionId[session.id] ?? const <SessionComment>[];
  }

  String _commentCountLabel(int count) {
    final suffix = count == 1 ? 'comentario' : 'comentarios';
    return '$count $suffix';
  }

  String _likeCountLabel(int count) {
    final suffix = count == 1 ? 'like' : 'likes';
    return '$count $suffix';
  }

  Widget _buildUserAvatar({
    required String username,
    required int avatarColorValue,
    double radius = 12,
  }) {
    final safeUsername = username.trim();
    final initials = safeUsername.isEmpty
        ? 'W'
        : safeUsername.characters.first.toUpperCase();
    final isCurrentUser = username == _myUsername;
    final avatarPath = _myAvatarLocalPath;
    final hasLocalAvatar =
        isCurrentUser && avatarPath != null && avatarPath.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: Color(avatarColorValue),
      backgroundImage: hasLocalAvatar ? FileImage(File(avatarPath)) : null,
      child: hasLocalAvatar
          ? null
          : Text(
              initials,
              style: TextStyle(fontSize: radius * 0.9, color: Colors.white),
            ),
    );
  }

  String _displayNameForUser(String username) {
    return username == _myUsername
        ? _myDisplayName
        : CommunityIdentityMapper.displayNameFromUsername(username);
  }

  String _identityLabelForUser(String username) {
    return '${_displayNameForUser(username)} · @$username';
  }

  Widget _buildSessionStatChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }

  SessionLikeState _sessionLikeState(_FollowingSession session) {
    return _sessionLikeStatesBySessionId[session.id] ??
        SessionLikeState(
          sessionId: session.id,
          likesCount: session.likesCount,
          isLikedByUser: false,
        );
  }

  Future<void> _onToggleLike(_FollowingSession session) async {
    HapticFeedback.selectionClick();
    final optimistic = _sessionLikeState(session);
    setState(() {
      _sessionLikeStatesBySessionId[session.id] = SessionLikeState(
        sessionId: session.id,
        likesCount: optimistic.isLikedByUser
            ? (optimistic.likesCount > 0 ? optimistic.likesCount - 1 : 0)
            : optimistic.likesCount + 1,
        isLikedByUser: !optimistic.isLikedByUser,
      );
    });
    final next = await _toggleSessionLike(
      sessionId: session.id,
      username: _myUsername,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _sessionLikeStatesBySessionId[session.id] = next;
    });
  }

  Future<void> _openComments(_FollowingSession session) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        var comments = _sessionComments(session);
        var draftComment = '';
        var inputRevision = 0;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  bottom:
                      MediaQuery.of(context).viewInsets.bottom + AppSpacing.md,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Comentarios (${comments.length})',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Cerrar comentarios',
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      SizedBox(
                        height: 220,
                        child: comments.isEmpty
                            ? const Center(
                                child: Text(
                                  'Todavia no hay comentarios.\nSe el primero en comentar.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.separated(
                                itemCount: comments.length,
                                separatorBuilder: (_, _) => const Divider(),
                                itemBuilder: (context, index) {
                                  final comment = comments[index];
                                  return ListTile(
                                    dense: true,
                                    contentPadding: EdgeInsets.zero,
                                    leading: _buildUserAvatar(
                                      username: comment.authorUsername,
                                      avatarColorValue:
                                          comment.authorUsername == _myUsername
                                          ? 0xFF1E88E5
                                          : 0xFF607D8B,
                                      radius: 14,
                                    ),
                                    title: Text(
                                      _identityLabelForUser(
                                        comment.authorUsername,
                                      ),
                                    ),
                                    subtitle: Text(comment.text),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: ValueKey<int>(inputRevision),
                              autofocus: true,
                              maxLength: 180,
                              minLines: 1,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Escribe un comentario',
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.send,
                              onChanged: (value) {
                                setSheetState(() {
                                  draftComment = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          FilledButton(
                            onPressed:
                                draftComment.trim().isEmpty ||
                                    draftComment.trim().length > 180
                                ? null
                                : () async {
                                    final text = draftComment.trim();
                                    final comment = await _addSessionComment(
                                      sessionId: session.id,
                                      authorUsername: _myUsername,
                                      text: text,
                                    );
                                    if (!mounted || !context.mounted) {
                                      return;
                                    }
                                    final updated = List<SessionComment>.from(
                                      _sessionComments(session),
                                    )..add(comment);
                                    setState(() {
                                      _sessionCommentsBySessionId[session.id] =
                                          updated;
                                    });
                                    setSheetState(() {
                                      comments = updated;
                                      draftComment = '';
                                      inputRevision++;
                                    });
                                    FocusScope.of(context).unfocus();
                                  },
                            child: const Text('Publicar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _leaderboardScrollController.dispose();
    super.dispose();
  }

  void _onLeaderboardScroll() {
    if (!_leaderboardScrollController.hasClients) {
      return;
    }
    final maxScroll = _leaderboardScrollController.position.maxScrollExtent;
    final offset = _leaderboardScrollController.offset;
    if (maxScroll - offset <= 220) {
      final total = _leaderboardRows().length;
      if (_visibleLeaderboardCount < total) {
        setState(() {
          final nextCount = _visibleLeaderboardCount + _pageSize;
          _visibleLeaderboardCount = nextCount > total ? total : nextCount;
        });
      }
    }
  }

  List<_LeaderboardRow> _leaderboardRows() {
    return _orchestration
        .buildLeaderboardRows(
          users: _users,
          followingUsernames: _followingUsernames,
          appliedPeriod: _appliedPeriod,
          appliedSpot: _appliedSpot,
          appliedScope: _appliedScope,
          appliedOrder: _appliedOrder,
          appliedOrderUnit: _selectedMetricOption().unit,
        )
        .map(
          (row) => _LeaderboardRow(
            user: row.user,
            score: row.score,
            metricValue: row.metricValue,
          ),
        )
        .toList(growable: false);
  }

  void _applyFilters() {
    setState(() {
      _appliedPeriod = _draftPeriod;
      _appliedSpot = _draftSpot;
      _appliedScope = _draftScope;
      _appliedOrder = _draftOrder;
      _visibleLeaderboardCount = _pageSize;
    });
    if (_leaderboardScrollController.hasClients) {
      _leaderboardScrollController.jumpTo(0);
    }
  }

  void _openProfile(String username) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityUserProfilePage(
          username: username,
          useLocalPersistence: widget.useLocalPersistence,
        ),
      ),
    );
  }

  void _openSessions(String username) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityUserSessionsPage(
          username: username,
          useLocalPersistence: widget.useLocalPersistence,
        ),
      ),
    );
  }

  void _openFriendSessionDetail(_FollowingSession session) {
    final deviceKind = 'Woo Sports';
    final deviceSensorKeys = SessionInsightData.physicalSensorsForDeviceKind(
      deviceKind,
    ).toList(growable: false);
    final measuredValues = <String, String>{
      'distancia_total': '${session.distanceKm.toStringAsFixed(1)} km',
      if (session.highestJumpMeters > 0)
        'salto_mas_alto': '${session.highestJumpMeters.toStringAsFixed(1)} m',
      if (session.bigAirScore > 0)
        'big_air_score': '${session.bigAirScore}/100',
    };
    final insights =
        SessionInsightData.empty(
          deviceKind: deviceKind,
          deviceSensorKeys: deviceSensorKeys,
          events: <String>[
            'Sesion compartida por ${_displayNameForUser(session.username)}',
          ],
        ).copyWith(
          distanceKm: session.distanceKm > 0 ? session.distanceKm : null,
          jumpsCount: session.highestJumpMeters > 0 ? 1 : null,
          maxJumpHeightMeters: session.highestJumpMeters > 0
              ? session.highestJumpMeters
              : null,
          advancedMetrics: SessionAdvancedMetrics(
            groups: SessionInsightData.buildGroupsForRecordedSession(
              values: measuredValues,
            ),
          ),
        );

    final summary =
        '${_displayNameForUser(session.username)} en ${session.spot} con salto maximo ${session.highestJumpMeters.toStringAsFixed(1)} m y ${session.distanceKm.toStringAsFixed(1)} km recorridos.';

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SessionDetailPage(
          title: session.title,
          deviceName: 'Woo Sports',
          deviceKind: deviceKind,
          deviceSensorKeys: insights.deviceSensorKeys,
          endedAt: session.endedAt,
          durationLabel: session.durationLabel,
          summary: summary,
          source: SessionDetailSource.community,
          hasSessionPhoto: session.hasSessionPhoto,
          sessionMediaLabel: session.hasSessionPhoto
              ? 'Foto subida por el usuario'
              : 'Mapa del spot (fallback)',
          spotBackgroundImagePath: null,
          insights: insights,
        ),
      ),
    );
  }

  Future<void> _openLeaderboardActions(_CommunityUser user) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: _buildUserAvatar(
                  username: user.username,
                  avatarColorValue: user.avatarColorValue,
                  radius: 16,
                ),
                title: Text(_identityLabelForUser(user.username)),
                subtitle: const Text('Acciones de usuario'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.person_rounded),
                title: const Text('Ver perfil'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openProfile(user.username);
                },
              ),
              ListTile(
                leading: const Icon(Icons.surfing_rounded),
                title: const Text('Ver sesiones'),
                onTap: () {
                  Navigator.of(context).pop();
                  _openSessions(user.username);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  List<_CommunityUser> _followerUsers() {
    return _users
        .where((user) => _followerUsernames.contains(user.username))
        .toList(growable: false);
  }

  List<_CommunityUser> _filterUsersByQuery(
    List<_CommunityUser> users,
    String query,
  ) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return users;
    }
    return users
        .where(
          (user) =>
              user.username.toLowerCase().contains(normalized) ||
              _displayNameForUser(
                user.username,
              ).toLowerCase().contains(normalized),
        )
        .toList(growable: false);
  }

  List<_CommunityUser> _exploreUsers() {
    return _users
        .where((user) => user.username != _myUsername)
        .toList(growable: false);
  }

  Future<void> _toggleFollowing(String username) async {
    final nextUsernames = Set<String>.from(_followingUsernames);
    setState(() {
      if (nextUsernames.contains(username)) {
        nextUsernames.remove(username);
      } else {
        nextUsernames.add(username);
      }
      _followingUsernames
        ..clear()
        ..addAll(nextUsernames);
    });
    await _saveFollowingUsernames(nextUsernames);
    if (!mounted) {
      return;
    }
    await _hydrateCommunityData();
  }

  List<_CommunityUser> _followedUsers() {
    return _orchestration.followedUsers(
      users: _users,
      followingUsernames: _followingUsernames,
    );
  }

  List<_FollowingSession> _followingSessions() {
    return _orchestration.followingSessions(
      sessions: _sessions,
      followingUsernames: _followingUsernames,
    );
  }

  Color? _podiumTint(int index) {
    switch (index) {
      case 0:
        return const Color(0x14C9A227);
      case 1:
        return const Color(0x14000000);
      case 2:
        return const Color(0x14A97142);
      default:
        return null;
    }
  }

  Color? _podiumBorder(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFC9A227);
      case 1:
        return const Color(0xFF9E9E9E);
      case 2:
        return const Color(0xFFA97142);
      default:
        return null;
    }
  }

  IconData? _podiumIcon(int index) {
    switch (index) {
      case 0:
        return Icons.workspace_premium_rounded;
      case 1:
        return Icons.military_tech_rounded;
      case 2:
        return Icons.military_tech_outlined;
      default:
        return null;
    }
  }

  _KpiFilterOption _selectedMetricOption() {
    return _kpiOrderOptions.firstWhere(
      (o) => o.key == _appliedOrder,
      orElse: () => _kpiOrderOptions.first,
    );
  }

  String _leaderboardMetricText(_LeaderboardRow row) {
    return _orchestration.formatMetricValue(
      value: row.metricValue,
      unit: _selectedMetricOption().unit,
    );
  }

  String _leaderboardMetricHeader() {
    final option = _selectedMetricOption();
    if (option.unit == 'count' || option.unit == 'bin') {
      return option.label;
    }
    return '${option.label} (${option.unit})';
  }

  Widget _buildLeaderboardCardRow(_LeaderboardRow row, int index) {
    final tint = _podiumTint(index);
    final borderColor = _podiumBorder(index);
    final podiumIcon = _podiumIcon(index);
    final isLeader = index == 0;

    return Card(
      color: tint,
      shape: borderColor == null
          ? null
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: borderColor, width: 1.2),
            ),
      child: InkWell(
        onTap: () => _openLeaderboardActions(row.user),
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: isLeader ? 72 : 64,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    '#${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildUserAvatar(
                      username: row.user.username,
                      avatarColorValue: row.user.avatarColorValue,
                      radius: 13,
                    ),
                    if (podiumIcon != null)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Icon(podiumIcon, size: 16, color: borderColor),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayNameForUser(row.user.username),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      Text(
                        '@${row.user.username}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  _leaderboardMetricText(row),
                  style:
                      (isLeader
                              ? Theme.of(context).textTheme.titleMedium
                              : Theme.of(context).textTheme.bodyLarge)
                          ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardTableRow(_LeaderboardRow row, int index) {
    return InkWell(
      onTap: () => _openLeaderboardActions(row.user),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0x22000000))),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 34,
              child: Text(
                '#${index + 1}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            _buildUserAvatar(
              username: row.user.username,
              avatarColorValue: row.user.avatarColorValue,
              radius: 12,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayNameForUser(row.user.username),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    '@${row.user.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(_leaderboardMetricText(row)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardView(BuildContext context) {
    final rows = _leaderboardRows();
    final hasPendingFilterChanges =
        _draftPeriod != _appliedPeriod ||
        _draftSpot != _appliedSpot ||
        _draftScope != _appliedScope ||
        _draftOrder != _appliedOrder;

    final visibleCount = _visibleLeaderboardCount > rows.length
        ? rows.length
        : _visibleLeaderboardCount;
    final visibleRows = rows.take(visibleCount).toList();

    final myRank = _orchestration.rankForUser(
      rows: rows
          .map(
            (row) => CommunityLeaderboardRowData(
              user: row.user,
              score: row.score,
              metricValue: row.metricValue,
            ),
          )
          .toList(growable: false),
      username: _myUsername,
    );
    final myUser = myRank == -1 ? null : rows[myRank - 1].user;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              key: const ValueKey<String>(
                'community_leaderboard_identity_card',
              ),
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    key: const ValueKey<String>(
                      'community_leaderboard_identity_banner',
                    ),
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: _myBannerLocalPath == null
                          ? const LinearGradient(
                              colors: [Color(0xFF81D4FA), Color(0xFF4DB6AC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      image: _myBannerLocalPath == null
                          ? null
                          : DecorationImage(
                              image: FileImage(File(_myBannerLocalPath)),
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        _buildUserAvatar(
                          username: _myUsername,
                          avatarColorValue: 0xFF1E88E5,
                          radius: 16,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            '$_myDisplayName · @$_myUsername',
                            key: const ValueKey<String>(
                              'community_leaderboard_identity_display_name',
                            ),
                            style: Theme.of(context).textTheme.titleSmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(Icons.sync_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Wrap(
              alignment: WrapAlignment.end,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.xs,
              runSpacing: 6,
              children: [
                TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _showLeaderboardFilters = !_showLeaderboardFilters;
                    });
                  },
                  icon: Icon(
                    _showLeaderboardFilters
                        ? Icons.expand_less_rounded
                        : Icons.tune_rounded,
                  ),
                  label: Text(
                    _showLeaderboardFilters
                        ? 'Ocultar filtros'
                        : 'Mostrar filtros',
                  ),
                ),
                FilledButton.icon(
                  onPressed: hasPendingFilterChanges ? _applyFilters : null,
                  icon: const Icon(Icons.filter_alt_rounded),
                  label: const Text('Aplicar filtros'),
                ),
              ],
            ),
            if (_showLeaderboardFilters) ...[
              const SizedBox(height: AppSpacing.xs),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 760;
                  final controls = [
                    _CommunityFilterField(
                      label: 'Periodo',
                      value: _draftPeriod,
                      values: const ['24h', '7d', '30d', 'All time'],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _draftPeriod = value);
                      },
                    ),
                    _CommunityFilterField(
                      label: 'Spot',
                      value: _draftSpot,
                      values: const [
                        'Todos',
                        'Tarifa',
                        'Fuerteventura',
                        'Gandia',
                        'Oliva Norte',
                        'El Medano',
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _draftSpot = value);
                      },
                    ),
                    _CommunityFilterField(
                      label: 'Scope',
                      value: _draftScope,
                      values: const ['Global', 'Friends'],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _draftScope = value);
                      },
                    ),
                    _KpiOrderFilterField(
                      label: 'Orden',
                      value: _draftOrder,
                      options: _kpiOrderOptions,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _draftOrder = value);
                      },
                    ),
                  ];

                  if (isNarrow) {
                    return Column(
                      children: [
                        for (var i = 0; i < controls.length; i++) ...[
                          controls[i],
                          if (i != controls.length - 1)
                            const SizedBox(height: AppSpacing.xs),
                        ],
                      ],
                    );
                  }

                  return Row(
                    children: [
                      for (var i = 0; i < controls.length; i++) ...[
                        Expanded(child: controls[i]),
                        if (i != controls.length - 1)
                          const SizedBox(width: AppSpacing.xs),
                      ],
                    ],
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.xs),
            Text(
              _leaderboardMetricHeader(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            if (rows.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text('No hay usuarios para los filtros actuales.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  controller: _leaderboardScrollController,
                  physics: kAppBouncingScrollPhysics,
                  padding: const EdgeInsets.only(bottom: 56),
                  itemCount: visibleRows.length,
                  itemBuilder: (context, index) {
                    final row = visibleRows[index];
                    if (index < 5) {
                      return _buildLeaderboardCardRow(row, index);
                    }
                    return _buildLeaderboardTableRow(row, index);
                  },
                ),
              ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 10,
              ),
              color: Theme.of(context).colorScheme.surface,
              child: myRank == -1 || myUser == null
                  ? Text(
                      '-- · @$_myUsername · #-- / ${rows.length}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge,
                    )
                  : Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.xs,
                      runSpacing: 4,
                      children: [
                        Text('#$myRank'),
                        _buildUserAvatar(
                          username: myUser.username,
                          avatarColorValue: myUser.avatarColorValue,
                          radius: 10,
                        ),
                        Text(_identityLabelForUser(myUser.username)),
                        Text('#$myRank / ${rows.length}'),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowingView(BuildContext context) {
    final followingUsers = _followedUsers();
    final followerUsers = _followerUsers();
    final sessions = _followingSessions();
    final filteredFollowing = _filterUsersByQuery(
      followingUsers,
      _followingSearchQuery,
    );
    final filteredFollowers = _filterUsersByQuery(
      followerUsers,
      _followersSearchQuery,
    );
    final filteredExplore = _filterUsersByQuery(
      _exploreUsers(),
      _exploreSearchQuery,
    );

    List<Widget> buildUserCards(List<_CommunityUser> users) {
      if (users.isEmpty) {
        return const [
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Text('No hay usuarios para mostrar.'),
            ),
          ),
        ];
      }

      return users
          .map(
            (user) => Card(
              child: ListTile(
                onTap: () => _openProfile(user.username),
                leading: _buildUserAvatar(
                  username: user.username,
                  avatarColorValue: user.avatarColorValue,
                  radius: 18,
                ),
                title: Text(_identityLabelForUser(user.username)),
                subtitle: Text(
                  user.mainSpot.trim().isEmpty
                      ? 'Big Air ${user.bigAirScore}'
                      : '${user.mainSpot} · Big Air ${user.bigAirScore}',
                ),
                trailing: TextButton(
                  onPressed: () => _toggleFollowing(user.username),
                  child: Text(
                    _followingUsernames.contains(user.username)
                        ? 'Siguiendo'
                        : 'Seguir',
                  ),
                ),
              ),
            ),
          )
          .toList(growable: false);
    }

    return ListView(
      physics: kAppBouncingScrollPhysics,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.group_rounded),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        'Tu red',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Siguiendo ${followingUsers.length} · Seguidores ${followerUsers.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<_SocialPeopleTab>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment<_SocialPeopleTab>(
                        value: _SocialPeopleTab.feed,
                        label: Text('Feed'),
                      ),
                      ButtonSegment<_SocialPeopleTab>(
                        value: _SocialPeopleTab.following,
                        label: Text('Siguiendo'),
                      ),
                      ButtonSegment<_SocialPeopleTab>(
                        value: _SocialPeopleTab.followers,
                        label: Text('Seguidores'),
                      ),
                      ButtonSegment<_SocialPeopleTab>(
                        value: _SocialPeopleTab.explore,
                        label: Text('Explorar'),
                      ),
                    ],
                    selected: {_socialPeopleTab},
                    onSelectionChanged: (value) {
                      setState(() {
                        _socialPeopleTab = value.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_socialPeopleTab == _SocialPeopleTab.feed) ...[
          Text(
            'Sesiones de amigos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (sessions.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Todavia no sigues a nadie. Usa Explorar para empezar a seguir cuentas.',
                ),
              ),
            )
          else
            ...sessions.map((session) {
              final likeState = _sessionLikeState(session);
              final comments = _sessionComments(session);
              final user = _users.firstWhere(
                (u) => u.username == session.username,
                orElse: () => const _CommunityUser(
                  username: 'unknown',
                  bigAirScore: 0,
                  highestJumpMeters: 0,
                  mainSpot: '',
                  avatarColorValue: 0xFF607D8B,
                ),
              );

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: session.hasSessionPhoto
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF90CAF9),
                                    Color(0xFF42A5F5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : const LinearGradient(
                                  colors: [
                                    Color(0xFFC8E6C9),
                                    Color(0xFF80CBC4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                session.hasSessionPhoto
                                    ? Icons.photo_camera_back_rounded
                                    : Icons.map_rounded,
                                size: 28,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                session.hasSessionPhoto
                                    ? 'Foto de la sesion'
                                    : 'Pantallazo del mapa del spot',
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          _buildUserAvatar(
                            username: session.username,
                            avatarColorValue: user.avatarColorValue,
                            radius: 12,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _displayNameForUser(session.username),
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Text(
                                  '@${session.username}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Text(session.dateLabel),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildSessionStatChip(
                            context,
                            icon: Icons.height_rounded,
                            label:
                                '${session.highestJumpMeters.toStringAsFixed(1)} m',
                          ),
                          _buildSessionStatChip(
                            context,
                            icon: Icons.route_rounded,
                            label:
                                '${session.distanceKm.toStringAsFixed(1)} km',
                          ),
                          _buildSessionStatChip(
                            context,
                            icon: Icons.timer_outlined,
                            label: session.durationLabel,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${session.spot} · ${session.equipmentLabel}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Divider(height: 1),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: 2,
                        children: [
                          Text(_likeCountLabel(likeState.likesCount)),
                          Text(_commentCountLabel(comments.length)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          IconButton(
                            key: ValueKey<String>('session_like_${session.id}'),
                            onPressed: () => _onToggleLike(session),
                            tooltip: likeState.isLikedByUser
                                ? 'Quitar like'
                                : 'Dar like',
                            icon: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutBack,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: animation,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                likeState.isLikedByUser
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                key: ValueKey<bool>(likeState.isLikedByUser),
                                color: likeState.isLikedByUser
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ),
                          IconButton(
                            key: ValueKey<String>(
                              'session_comment_${session.id}',
                            ),
                            onPressed: () => _openComments(session),
                            tooltip: 'Comentar',
                            icon: const Icon(Icons.mode_comment_outlined),
                          ),
                          OutlinedButton.icon(
                            key: ValueKey<String>('session_view_${session.id}'),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 8,
                              ),
                            ),
                            onPressed: () => _openFriendSessionDetail(session),
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                            ),
                            label: const Text('Ver sesion'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ] else if (_socialPeopleTab == _SocialPeopleTab.following) ...[
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Buscar en siguiendo',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _followingSearchQuery = value;
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ...buildUserCards(filteredFollowing),
        ] else if (_socialPeopleTab == _SocialPeopleTab.followers) ...[
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Buscar en seguidores',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _followersSearchQuery = value;
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ...buildUserCards(filteredFollowers),
        ] else ...[
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search_rounded),
              hintText: 'Buscar usuarios',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _exploreSearchQuery = value;
              });
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          ...buildUserCards(filteredExplore),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _NoStretchScrollBehavior(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: SegmentedButton<_CommunityTab>(
              segments: const [
                ButtonSegment<_CommunityTab>(
                  value: _CommunityTab.leaderboard,
                  label: Text('Leaderboard'),
                ),
                ButtonSegment<_CommunityTab>(
                  value: _CommunityTab.following,
                  label: Text('Amigos'),
                ),
              ],
              selected: {_selectedTab},
              onSelectionChanged: (value) {
                setState(() {
                  _selectedTab = value.first;
                });
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _selectedTab == _CommunityTab.leaderboard
                      ? _buildLeaderboardView(context)
                      : _buildFollowingView(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

enum _CommunityTab { leaderboard, following }

enum _SocialPeopleTab { feed, following, followers, explore }

class _LeaderboardRow {
  const _LeaderboardRow({
    required this.user,
    required this.score,
    required this.metricValue,
  });

  final _CommunityUser user;
  final int score;
  final double metricValue;
}

class _CommunityFilterField extends StatelessWidget {
  const _CommunityFilterField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: values
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _KpiFilterOption {
  const _KpiFilterOption.metric(this.key, this.label, this.unit)
    : isGroup = false,
      isDivider = false;

  const _KpiFilterOption.group(this.label)
    : key = null,
      unit = '',
      isGroup = true,
      isDivider = false;

  const _KpiFilterOption.divider()
    : key = null,
      label = '',
      unit = '',
      isGroup = false,
      isDivider = true;

  final String? key;
  final String label;
  final String unit;
  final bool isGroup;
  final bool isDivider;
}

class _KpiOrderFilterField extends StatelessWidget {
  const _KpiOrderFilterField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<_KpiFilterOption> options;
  final ValueChanged<String?> onChanged;

  Color _groupItemColor(String groupLabel) {
    switch (groupLabel) {
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

  Color _groupHeaderColor(String groupLabel) {
    switch (groupLabel) {
      case 'Core Session':
        return const Color(0xFFBBDEFB);
      case 'Big Air':
        return const Color(0xFFFFE082);
      case 'Freestyle':
        return const Color(0xFFE1BEE7);
      case 'Freeride / Navegacion':
        return const Color(0xFFC8E6C9);
      case 'Saltos':
        return const Color(0xFFFFCC80);
      case 'Control tecnico':
        return const Color(0xFFB2EBF2);
      case 'Condiciones meteo-contexto':
        return const Color(0xFFC5CAE9);
      case 'Seguridad y riesgo':
        return const Color(0xFFFFCDD2);
      case 'Dispositivo y calidad de datos':
        return const Color(0xFFD1C4E9);
      case 'KPIs compuestos':
        return const Color(0xFFB2DFDB);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = <DropdownMenuItem<String>>[];
    Color? activeGroupColor;

    for (var i = 0; i < options.length; i++) {
      final option = options[i];
      if (option.isDivider) {
        activeGroupColor = null;
        items.add(
          DropdownMenuItem<String>(
            value: '__divider_$i',
            enabled: false,
            child: const Divider(height: 1),
          ),
        );
        continue;
      }

      if (option.isGroup) {
        activeGroupColor = _groupItemColor(option.label);
        items.add(
          DropdownMenuItem<String>(
            value: '__group_$i',
            enabled: false,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: _groupHeaderColor(option.label),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                option.label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
        continue;
      }

      items.add(
        DropdownMenuItem<String>(
          value: option.key,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activeGroupColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(option.label, overflow: TextOverflow.ellipsis),
          ),
        ),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items,
      onChanged: (selected) {
        if (selected == null || selected.startsWith('__')) {
          return;
        }
        onChanged(selected);
      },
    );
  }
}

class _NoStretchScrollBehavior extends AppScrollBehavior {
  const _NoStretchScrollBehavior();
}
