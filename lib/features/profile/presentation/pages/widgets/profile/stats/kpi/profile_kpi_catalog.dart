import 'package:windwisher/features/profile/domain/entities/profile_session_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
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

  static ProfileKpiDialogData build(
    UserProfileData profile,
    ProfileSessionStatsSnapshot stats,
  ) {
    return ProfileKpiDialogData(
      sections: [
        ProfileKpiSectionData(
          title: 'Volumen',
          description: 'Cuanto tiempo y cuantas sesiones acumula el rider.',
          items: [
            ProfileKpiItemData(
              label: 'Sesiones totales',
              value: stats.totalSessionsLabel,
              hydrated: true,
              pendingSourceLabel: 'Agregado de sesiones',
            ),
            ProfileKpiItemData(
              label: 'Horas en agua',
              value: stats.waterHoursLabel,
              hydrated: true,
              pendingSourceLabel: 'Agregado de sesiones',
            ),
            ProfileKpiItemData(
              label: 'Dias activos',
              value: stats.activeDaysLabel,
              hydrated: stats.activeDays > 0,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
            ProfileKpiItemData(
              label: 'Sesiones este mes',
              value: stats.sessionsThisMonthLabel,
              hydrated: stats.sessionsThisMonth > 0,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
            const ProfileKpiItemData(
              label: 'Racha actual',
              value: '-- dias',
              hydrated: false,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
            const ProfileKpiItemData(
              label: 'Racha maxima',
              value: '-- dias',
              hydrated: false,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
          ],
        ),
        ProfileKpiSectionData(
          title: 'Rendimiento',
          description: 'Metricas puras de salto, hangtime y velocidad.',
          items: [
            ProfileKpiItemData(
              label: 'Salto mas alto',
              value: stats.highestJumpLabel,
              hydrated: stats.highestJumpMeters != null,
              sessionMetricKey: SessionMetricKeys.highestJump,
            ),
            ProfileKpiItemData(
              label: 'Max hangtime',
              value: stats.maxHangtimeLabel,
              hydrated: stats.maxHangtimeSeconds != null,
              sessionMetricKey: SessionMetricKeys.maxHangtime,
            ),
            ProfileKpiItemData(
              label: 'Velocidad maxima',
              value: stats.maxSpeedLabel,
              hydrated: stats.maxSpeedKnots != null,
              sessionMetricKey: SessionMetricKeys.maxSpeed,
              pendingSourceLabel: 'Pendiente desde advanced metrics',
            ),
            const ProfileKpiItemData(
              label: 'Velocidad media',
              value: '-- kt',
              hydrated: false,
              sessionMetricKey: SessionMetricKeys.avgSpeed,
              pendingSourceLabel: 'Pendiente desde advanced metrics',
            ),
            ProfileKpiItemData(
              label: 'Saltos totales',
              value: stats.totalJumpsLabel,
              hydrated: true,
              sessionMetricKey: SessionMetricKeys.totalJumps,
            ),
            ProfileKpiItemData(
              label: 'Saltos por sesion',
              value: stats.avgJumpsPerSessionLabel,
              hydrated: stats.totalSessions > 0,
              pendingSourceLabel: 'Derivado de sesiones',
            ),
          ],
        ),
        ProfileKpiSectionData(
          title: 'Consistencia',
          description: 'Patrones medios y repetibilidad de la actividad.',
          items: [
            ProfileKpiItemData(
              label: 'Promedio por sesion',
              value: stats.avgSessionHoursLabel,
              hydrated: stats.totalSessions > 0,
              pendingSourceLabel: 'Derivado de sesiones',
            ),
            const ProfileKpiItemData(
              label: 'Promedio de altura',
              value: '-- m',
              hydrated: false,
              sessionMetricKey: SessionMetricKeys.highestJump,
              pendingSourceLabel: 'Pendiente desde advanced metrics',
            ),
            const ProfileKpiItemData(
              label: 'Promedio de hangtime',
              value: '-- s',
              hydrated: false,
              sessionMetricKey: SessionMetricKeys.maxHangtime,
              pendingSourceLabel: 'Pendiente desde advanced metrics',
            ),
            ProfileKpiItemData(
              label: 'Sesiones con saltos',
              value: stats.sessionsWithJumpsPercentLabel,
              hydrated: stats.totalSessions > 0,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
            ProfileKpiItemData(
              label: 'Mejor mes',
              value: stats.bestMonthLabel ?? '--',
              hydrated: stats.bestMonthLabel != null,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
            ProfileKpiItemData(
              label: 'Spot mas usado',
              value: stats.mostUsedSpot ?? '--',
              hydrated: stats.mostUsedSpot != null,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
          ],
        ),
        ProfileKpiSectionData(
          title: 'Progresion',
          description: 'Como evoluciona el rider en el tiempo.',
          items: [
            ProfileKpiItemData(
              label: 'Record reciente',
              value: stats.latestRecordLabel ?? '--',
              hydrated: stats.latestRecordLabel != null,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
            const ProfileKpiItemData(
              label: 'Ultimos 30 dias',
              value: '--',
              hydrated: false,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
            const ProfileKpiItemData(
              label: '30 dias anteriores',
              value: '--',
              hydrated: false,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
            const ProfileKpiItemData(
              label: 'Tiempo desde el ultimo record',
              value: '--',
              hydrated: false,
              pendingSourceLabel: 'Pendiente desde sesiones',
            ),
            const ProfileKpiItemData(
              label: 'Evolucion salto mas alto',
              value: '--',
              hydrated: false,
              sessionMetricKey: SessionMetricKeys.highestJump,
              pendingSourceLabel: 'Pendiente desde advanced metrics',
            ),
            const ProfileKpiItemData(
              label: 'Evolucion hangtime',
              value: '--',
              hydrated: false,
              sessionMetricKey: SessionMetricKeys.maxHangtime,
              pendingSourceLabel: 'Pendiente desde advanced metrics',
            ),
          ],
        ),
        ProfileKpiSectionData(
          title: 'Comunidad',
          description: 'Indicadores sociales y de presencia publica.',
          items: [
            ProfileKpiItemData(
              label: 'Seguidores',
              value: profile.followers,
              hydrated: true,
            ),
            ProfileKpiItemData(
              label: 'Siguiendo',
              value: profile.following,
              hydrated: true,
            ),
            ProfileKpiItemData(
              label: 'Ranking local',
              value: profile.ranking,
              hydrated: true,
            ),
            const ProfileKpiItemData(
              label: 'Sesiones compartidas',
              value: '--',
              hydrated: false,
              pendingSourceLabel: 'Pendiente social',
            ),
            const ProfileKpiItemData(
              label: 'Comentarios',
              value: '--',
              hydrated: false,
              pendingSourceLabel: 'Pendiente social',
            ),
            const ProfileKpiItemData(
              label: 'Likes recibidos',
              value: '--',
              hydrated: false,
              pendingSourceLabel: 'Pendiente social',
            ),
          ],
        ),
      ],
      contextRows: [
        ProfileDetailRowData(
          'Rol de usuario',
          profile.userRole,
          hydrated: true,
        ),
        ProfileDetailRowData('Spot base', profile.baseSpot, hydrated: true),
        ProfileDetailRowData('Mejor spot', profile.bestSpot, hydrated: true),
        ProfileDetailRowData(
          'Ultima sesion subida',
          profile.latestSession,
          hydrated: true,
        ),
        ProfileDetailRowData(
          'Ultimo comentario',
          profile.latestComment,
          hydrated: true,
        ),
        ProfileDetailRowData(
          'Hilo destacado',
          profile.featuredThread,
          hydrated: true,
        ),
      ],
    );
  }
}
