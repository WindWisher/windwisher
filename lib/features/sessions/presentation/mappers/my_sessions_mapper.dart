import 'package:windwisher/features/sessions/presentation/models/my_sessions_models.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

class MySessionsPresentationMapper {
  const MySessionsPresentationMapper._();

  static MySessionCardData buildCardData({
    required String title,
    required DateTime endedAt,
    required String summary,
    required String deviceName,
    required SessionInsightData insights,
    required String? gearSetupName,
    required String? localPhotoPath,
    required String defaultSessionSummary,
    required String durationLabel,
    required String? jumpLabel,
    required String? hangtimeLabel,
    required String? maxSpeedLabel,
  }) {
    final sessionDate = endedAt.day.toString().padLeft(2, '0');
    final sessionMonth = endedAt.month.toString().padLeft(2, '0');
    final sessionHour = endedAt.hour.toString().padLeft(2, '0');
    final sessionMinute = endedAt.minute.toString().padLeft(2, '0');
    return MySessionCardData(
      title: title,
      subtitle: '$sessionDate/$sessionMonth · $sessionHour:$sessionMinute',
      summary:
          summary.isNotEmpty && summary != defaultSessionSummary
          ? summary
          : '',
      deviceName: deviceName,
      deviceKind: insights.deviceKind ?? 'Dispositivo Android',
      gearSetupName: gearSetupName,
      localPhotoPath: localPhotoPath,
      durationLabel: durationLabel,
      jumpLabel: jumpLabel,
      hangtimeLabel: hangtimeLabel,
      maxSpeedLabel: maxSpeedLabel,
    );
  }

  static MySessionsEmptyStateData buildEmptyStateData({
    required bool hasActiveSearch,
  }) {
    if (hasActiveSearch) {
      return const MySessionsEmptyStateData(
        message: 'No hay sesiones que coincidan con esta busqueda.',
        showClearSearchAction: true,
      );
    }
    return const MySessionsEmptyStateData(
      message:
          'Todavía no hay sesiones finalizadas. Al sincronizar una sesión en Start Session aparecerá aquí.',
      showClearSearchAction: false,
    );
  }

  static MySessionsSearchFieldData buildSearchFieldData({
    required bool hasActiveSearch,
  }) {
    return MySessionsSearchFieldData(
      hintText: 'Buscar por sesión, spot, equipo o dispositivo...',
      showClearAction: hasActiveSearch,
    );
  }

  static MySessionsPageData buildPageData({
    required bool hasActiveSearch,
    required bool hasSessions,
  }) {
    return MySessionsPageData(
      searchFieldData: buildSearchFieldData(
        hasActiveSearch: hasActiveSearch,
      ),
      emptyStateData: buildEmptyStateData(
        hasActiveSearch: hasActiveSearch,
      ),
      hasSessions: hasSessions,
    );
  }
}
