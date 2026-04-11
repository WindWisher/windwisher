import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/sessions/presentation/models/session_advanced_metrics_models.dart';

class ProfileKpiSectionData {
  const ProfileKpiSectionData({
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<ProfileKpiItemData> items;
}

class ProfileKpiItemData {
  const ProfileKpiItemData({
    required this.label,
    required this.value,
    required this.hydrated,
    this.sessionMetricKey,
    this.pendingSourceLabel,
  });

  final String label;
  final String value;
  final bool hydrated;
  final String? sessionMetricKey;
  final String? pendingSourceLabel;
}

class ProfileDetailRowData {
  const ProfileDetailRowData(this.label, this.value, {this.hydrated = false});

  final String label;
  final String value;
  final bool hydrated;
}

class ProfileKpiDialogData {
  const ProfileKpiDialogData({
    required this.sections,
    required this.contextRows,
  });

  final List<ProfileKpiSectionData> sections;
  final List<ProfileDetailRowData> contextRows;
}

class ProfileKpiCatalog {
  const ProfileKpiCatalog._();

  static ProfileKpiDialogData build(ProfileKpiSnapshot kpis) {
    final sections = [
      ProfileKpiSectionData(
        title: 'Volumen',
        description: 'Cuanta actividad acumula el rider a lo largo del tiempo.',
        items: [
          ProfileKpiItemData(
            label: 'Sesiones totales',
            value: kpis.totalSessionsLabel,
            hydrated: true,
            pendingSourceLabel: 'Agregado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Horas en agua',
            value: kpis.waterHoursLabel,
            hydrated: true,
            pendingSourceLabel: 'Agregado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Dias con sesion registrada',
            value: kpis.activeDaysLabel,
            hydrated: kpis.hasActiveDays,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Sesiones registradas este mes',
            value: kpis.sessionsThisMonthLabel,
            hydrated: kpis.hasSessionsThisMonth,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Distancia total acumulada',
            value: kpis.totalPlaningDistanceLabel,
            hydrated: kpis.hasTotalPlaningDistance,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Distancia media por sesion',
            value: kpis.avgPlaningDistanceLabel,
            hydrated: kpis.hasAvgPlaningDistance,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          const ProfileKpiItemData(
            label: 'Tiempo total en planeo',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde advanced metrics agregados',
          ),
          const ProfileKpiItemData(
            label: 'Tiempo medio en planeo por sesion',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde advanced metrics agregados',
          ),
          const ProfileKpiItemData(
            label: 'Sesion mas larga',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde sesiones',
          ),
          const ProfileKpiItemData(
            label: 'Sesion con mayor distancia',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde advanced metrics agregados',
          ),
        ],
      ),
      ProfileKpiSectionData(
        title: 'Rendimiento',
        description:
            'Mejores registros de salto, hangtime, velocidad y ejecucion.',
        items: [
          ProfileKpiItemData(
            label: 'Salto mas alto',
            value: kpis.highestJumpLabel,
            hydrated: kpis.highestJumpLabel != '--',
            sessionMetricKey: SessionMetricKeys.highestJump,
          ),
          ProfileKpiItemData(
            label: 'Hangtime maximo',
            value: kpis.maxHangtimeLabel,
            hydrated: kpis.maxHangtimeLabel != '--',
            sessionMetricKey: SessionMetricKeys.maxHangtime,
          ),
          ProfileKpiItemData(
            label: 'Velocidad maxima',
            value: kpis.maxSpeedLabel,
            hydrated: kpis.maxSpeedLabel != '--',
            sessionMetricKey: SessionMetricKeys.maxSpeed,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Velocidad media',
            value: kpis.avgSpeedLabel,
            hydrated: kpis.hasAvgSpeed,
            sessionMetricKey: SessionMetricKeys.avgSpeed,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Saltos totales',
            value: kpis.totalJumpsLabel,
            hydrated: true,
            sessionMetricKey: SessionMetricKeys.totalJumps,
          ),
          ProfileKpiItemData(
            label: 'Promedio de saltos por sesion',
            value: kpis.avgJumpsPerSessionLabel,
            hydrated: kpis.hasSessionActivity,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Velocidad p95',
            value: kpis.avgSpeedP95Label,
            hydrated: kpis.hasAvgSpeedP95,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Takeoff speed media',
            value: kpis.avgTakeoffSpeedLabel,
            hydrated: kpis.hasAvgTakeoffSpeed,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Landing speed media',
            value: kpis.avgLandingSpeedLabel,
            hydrated: kpis.hasAvgLandingSpeed,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          const ProfileKpiItemData(
            label: 'Top 5 saltos medio',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde jump history agregado',
          ),
          const ProfileKpiItemData(
            label: 'Top 10 saltos medio',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde jump history agregado',
          ),
          const ProfileKpiItemData(
            label: 'Hangtime p95',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde jump history agregado',
          ),
        ],
      ),
      ProfileKpiSectionData(
        title: 'Consistencia',
        description:
            'Promedios y regularidad para entender como navega de forma habitual.',
        items: [
          ProfileKpiItemData(
            label: 'Duracion media por sesion',
            value: kpis.avgSessionHoursLabel,
            hydrated: kpis.hasSessionActivity,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Altura media de salto',
            value: kpis.avgJumpHeightLabel,
            hydrated: kpis.hasAvgJumpHeight,
            sessionMetricKey: SessionMetricKeys.highestJump,
            pendingSourceLabel: 'Derivado de jump history',
          ),
          ProfileKpiItemData(
            label: 'Hangtime medio por salto',
            value: kpis.avgHangtimeLabel,
            hydrated: kpis.hasAvgHangtime,
            sessionMetricKey: SessionMetricKeys.maxHangtime,
            pendingSourceLabel: 'Derivado de jump history',
          ),
          ProfileKpiItemData(
            label: 'Porcentaje de sesiones con saltos',
            value: kpis.sessionsWithJumpsPercentLabel,
            hydrated: kpis.hasSessionActivity,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Mes con mas sesiones',
            value: kpis.bestMonthLabel,
            hydrated: kpis.hasBestMonth,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Spot mas utilizado',
            value: kpis.mostUsedSpotLabel,
            hydrated: kpis.hasMostUsedSpot,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          const ProfileKpiItemData(
            label: 'Spot con mejores saltos',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde sesiones agregadas',
          ),
          const ProfileKpiItemData(
            label: 'Spot con mejor hangtime',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde sesiones agregadas',
          ),
          const ProfileKpiItemData(
            label: 'Sesion con mas saltos',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde sesiones',
          ),
          const ProfileKpiItemData(
            label: 'Altura p95',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde jump history agregado',
          ),
        ],
      ),
      ProfileKpiSectionData(
        title: 'Progresion',
        description:
            'Como evoluciona el rider en el tiempo y en sus records personales.',
        items: [
          ProfileKpiItemData(
            label: 'Ultimo record personal',
            value: kpis.latestRecordLabel,
            hydrated: kpis.hasLatestRecord,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Sesiones en los ultimos 30 dias',
            value: kpis.last30DaysSessionsLabel,
            hydrated: kpis.hasSessionActivity,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Sesiones en los 30 dias anteriores',
            value: kpis.previous30DaysSessionsLabel,
            hydrated: kpis.hasSessionActivity,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Dias desde el ultimo record personal',
            value: kpis.daysSinceLatestRecordLabel,
            hydrated: kpis.hasLatestRecord,
            pendingSourceLabel: 'Derivado de sesiones',
          ),
          ProfileKpiItemData(
            label: 'Cambio del mejor salto vs 30 dias previos',
            value: kpis.highestJumpTrendLabel,
            hydrated: kpis.hasHighestJumpTrend,
            sessionMetricKey: SessionMetricKeys.highestJump,
            pendingSourceLabel: 'Comparativa 30 dias',
          ),
          ProfileKpiItemData(
            label: 'Cambio del mejor hangtime vs 30 dias previos',
            value: kpis.hangtimeTrendLabel,
            hydrated: kpis.hasHangtimeTrend,
            sessionMetricKey: SessionMetricKeys.maxHangtime,
            pendingSourceLabel: 'Comparativa 30 dias',
          ),
          const ProfileKpiItemData(
            label: 'Mejor dia',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde sesiones agrupadas por fecha',
          ),
          const ProfileKpiItemData(
            label: 'Mejor semana',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde sesiones agrupadas por semana',
          ),
          const ProfileKpiItemData(
            label: 'Mejor mes historico',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde sesiones agrupadas por mes',
          ),
          const ProfileKpiItemData(
            label: 'Media de sesiones por mes',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde sesiones agregadas',
          ),
          const ProfileKpiItemData(
            label: 'Dias desde la ultima sesion',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde sesiones',
          ),
        ],
      ),
      ProfileKpiSectionData(
        title: 'Analitica avanzada',
        description:
            'Lectura tecnica mas profunda derivada de las sesiones guardadas.',
        items: [
          ProfileKpiItemData(
            label: 'Max aceleracion',
            value: kpis.maxAccelerationLabel,
            hydrated: kpis.hasMaxAcceleration,
            pendingSourceLabel: 'Derivado del resumen de sesion',
          ),
          ProfileKpiItemData(
            label: 'Max rotacion',
            value: kpis.maxRotationLabel,
            hydrated: kpis.hasMaxRotation,
            pendingSourceLabel: 'Derivado del resumen de sesion',
          ),
          ProfileKpiItemData(
            label: 'Transiciones totales',
            value: kpis.totalTransitionsLabel,
            hydrated: kpis.hasTransitions,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Transiciones por hora',
            value: kpis.avgTransitionsPerHourLabel,
            hydrated: kpis.hasAvgTransitionsPerHour,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Consistencia de alturas',
            value: kpis.avgJumpHeightConsistencyLabel,
            hydrated: kpis.hasAvgJumpHeightConsistency,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Eficiencia de bordos',
            value: kpis.avgTackEfficiencyLabel,
            hydrated: kpis.hasAvgTackEfficiency,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Tiempo en sweet spot',
            value: kpis.avgSweetspotLabel,
            hydrated: kpis.hasAvgSweetspot,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Estabilidad direccional',
            value: kpis.avgDirectionalStabilityLabel,
            hydrated: kpis.hasAvgDirectionalStability,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Calidad de jibe',
            value: kpis.avgJibeQualityLabel,
            hydrated: kpis.hasAvgJibeQuality,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Perdida de velocidad en transiciones',
            value: kpis.avgTransitionSpeedLossLabel,
            hydrated: kpis.hasAvgTransitionSpeedLoss,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Recuperacion media de planeo',
            value: kpis.avgPlaningRecoveryLabel,
            hydrated: kpis.hasAvgPlaningRecovery,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Variabilidad de velocidad',
            value: kpis.avgSpeedVariabilityLabel,
            hydrated: kpis.hasAvgSpeedVariability,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Clean landing rate',
            value: kpis.avgCleanLandingRateLabel,
            hydrated: kpis.hasAvgCleanLandingRate,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Impact score medio',
            value: kpis.avgImpactScoreLabel,
            hydrated: kpis.hasAvgImpactScore,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Big Air score maximo',
            value: kpis.maxBigAirScoreLabel,
            hydrated: kpis.hasMaxBigAirScore,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Big Air score medio',
            value: kpis.avgBigAirScoreLabel,
            hydrated: kpis.hasAvgBigAirScore,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Freeride score maximo',
            value: kpis.maxFreerideScoreLabel,
            hydrated: kpis.hasMaxFreerideScore,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Freeride score medio',
            value: kpis.avgFreerideScoreLabel,
            hydrated: kpis.hasAvgFreerideScore,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Safety score medio',
            value: kpis.avgSafetyScoreLabel,
            hydrated: kpis.hasAvgSafetyScore,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Mejor session score',
            value: kpis.maxSessionScoreLabel,
            hydrated: kpis.hasMaxSessionScore,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Cobertura de area acumulada',
            value: kpis.totalAreaCoverageLabel,
            hydrated: kpis.hasTotalAreaCoverage,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Deriva neta media',
            value: kpis.avgNetDriftLabel,
            hydrated: kpis.hasAvgNetDrift,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Distancia maxima a costa',
            value: kpis.maxDistanceCoastLabel,
            hydrated: kpis.hasMaxDistanceCoast,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Tiempo en zona de riesgo',
            value: kpis.totalRiskZoneTimeLabel,
            hydrated: kpis.hasRiskZoneTime,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Calidad GPS media',
            value: kpis.avgGpsQualityLabel,
            hydrated: kpis.hasAvgGpsQuality,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Eventos de sobrepotencia',
            value: kpis.totalOverpowerEventsLabel,
            hydrated: kpis.hasOverpowerEvents,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Caidas por hora',
            value: kpis.avgFallsPerHourLabel,
            hydrated: kpis.hasAvgFallsPerHour,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
          ProfileKpiItemData(
            label: 'Samples perdidos acumulados',
            value: kpis.avgLostSamplesLabel,
            hydrated: kpis.hasAvgLostSamples,
            pendingSourceLabel: 'Derivado de advanced metrics agregados',
          ),
        ],
      ),
      ProfileKpiSectionData(
        title: 'Comunidad',
        description:
            'Presencia social, interaccion y posicion del perfil dentro de la comunidad.',
        items: [
          ProfileKpiItemData(
            label: 'Seguidores',
            value: kpis.followersLabel,
            hydrated: true,
          ),
          ProfileKpiItemData(
            label: 'Siguiendo',
            value: kpis.followingLabel,
            hydrated: true,
          ),
          ProfileKpiItemData(
            label: 'Ranking global',
            value: kpis.rankingLabel,
            hydrated: true,
          ),
          ProfileKpiItemData(
            label: 'Sesiones compartidas',
            value: kpis.sharedSessionsCountLabel,
            hydrated: kpis.hasSharedSessions,
            pendingSourceLabel: 'Derivado de community',
          ),
          ProfileKpiItemData(
            label: 'Sesiones compartidas en 30 dias',
            value: kpis.sharedSessionsLast30DaysLabel,
            hydrated: kpis.hasSharedSessionsLast30Days,
            pendingSourceLabel: 'Derivado de community reciente',
          ),
          ProfileKpiItemData(
            label: 'Comentarios recibidos',
            value: kpis.commentsReceivedLabel,
            hydrated: kpis.hasCommentsReceived,
            pendingSourceLabel: 'Derivado de community',
          ),
          ProfileKpiItemData(
            label: 'Comentarios recibidos en 30 dias',
            value: kpis.commentsReceivedLast30DaysLabel,
            hydrated: kpis.hasCommentsReceivedLast30Days,
            pendingSourceLabel: 'Derivado de community reciente',
          ),
          ProfileKpiItemData(
            label: 'Likes recibidos',
            value: kpis.likesReceivedLabel,
            hydrated: kpis.hasLikesReceived,
            pendingSourceLabel: 'Derivado de community',
          ),
          ProfileKpiItemData(
            label: 'Likes por sesion compartida',
            value: kpis.likesPerSharedSessionLabel,
            hydrated: kpis.hasLikesPerSharedSession,
            pendingSourceLabel: 'Derivado de community agregado',
          ),
          ProfileKpiItemData(
            label: 'Comentarios por sesion compartida',
            value: kpis.commentsPerSharedSessionLabel,
            hydrated: kpis.hasCommentsPerSharedSession,
            pendingSourceLabel: 'Derivado de community agregado',
          ),
          ProfileKpiItemData(
            label: 'Ratio seguidores / siguiendo',
            value: kpis.followersFollowingRatioLabel,
            hydrated: kpis.hasFollowersFollowingRatio,
            pendingSourceLabel: 'Derivado de social agregado',
          ),
          ProfileKpiItemData(
            label: 'Sesion mas comentada',
            value: kpis.mostCommentedSessionLabel,
            hydrated: kpis.hasMostCommentedSession,
            pendingSourceLabel: 'Derivado de community agregado',
          ),
          ProfileKpiItemData(
            label: 'Sesion mas likeada',
            value: kpis.mostLikedSessionLabel,
            hydrated: kpis.hasMostLikedSession,
            pendingSourceLabel: 'Derivado de community agregado',
          ),
          ProfileKpiItemData(
            label: 'Tasa de interaccion',
            value: kpis.engagementRateLabel,
            hydrated: kpis.hasEngagementRate,
            pendingSourceLabel: 'Derivado de community agregado',
          ),
          const ProfileKpiItemData(
            label: 'Top regional',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde community rankings',
          ),
          const ProfileKpiItemData(
            label: 'Top por spot',
            value: '--',
            hydrated: false,
            pendingSourceLabel: 'Pendiente desde community rankings',
          ),
        ],
      ),
    ];

    return ProfileKpiDialogData(
      sections: sections
          .map(
            (section) => ProfileKpiSectionData(
              title: section.title,
              description: section.description,
              items: section.items.where((item) => item.hydrated).toList(),
            ),
          )
          .where((section) => section.items.isNotEmpty)
          .toList(),
      contextRows: [
        ProfileDetailRowData(
          'Rol de usuario',
          kpis.userRoleLabel,
          hydrated: kpis.userRoleLabel != '--',
        ),
        ProfileDetailRowData(
          'Spot base',
          kpis.baseSpotLabel,
          hydrated: kpis.baseSpotLabel != '--',
        ),
        ProfileDetailRowData(
          'Spot mas utilizado',
          kpis.mostUsedSpotLabel,
          hydrated: kpis.mostUsedSpotLabel != '--',
        ),
        ProfileDetailRowData(
          'Mes con mas sesiones',
          kpis.bestMonthLabel,
          hydrated: kpis.bestMonthLabel != '--',
        ),
        ProfileDetailRowData(
          'Ultimo record personal',
          kpis.latestRecordLabel,
          hydrated: kpis.latestRecordLabel != '--',
        ),
        ProfileDetailRowData(
          'Ranking global',
          kpis.rankingLabel,
          hydrated: kpis.rankingLabel != '--',
        ),
      ].where((row) => row.hydrated).toList(),
    );
  }
}
