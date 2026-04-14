import 'package:flutter/material.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/community/di/community_module.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/presentation/support/community_identity_mapper.dart';
import 'package:windwisher/features/community/presentation/support/community_public_profile_loader.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/profile_media_image_provider.dart';

class CommunityUserSessionsPage extends StatefulWidget {
  const CommunityUserSessionsPage({
    super.key,
    required this.username,
    this.useLocalPersistence = EnvConfig.profileLocalPersistenceEnabled,
  });

  final String username;
  final bool useLocalPersistence;

  @override
  State<CommunityUserSessionsPage> createState() =>
      _CommunityUserSessionsPageState();
}

class _CommunityUserSessionsPageState extends State<CommunityUserSessionsPage> {
  late final CommunityModule _communityModule;
  late final UserProfileData _currentProfile;
  late UserProfileData _profile;
  List<FollowingSession> _sessions = const <FollowingSession>[];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentProfile = widget.useLocalPersistence
        ? ProfileModule.localFile().profileController.profile
        : ProfileModule.inMemory().profileController.profile;
    _profile = CommunityIdentityMapper.fallbackProfileForUsername(
      username: widget.username,
      currentProfile: _currentProfile,
    );
    _communityModule = EnvConfig.communityLocalPersistenceEnabled
        ? CommunityModule.auto()
        : CommunityModule.inMemory();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    UserProfileData? loadedProfile;
    if (EnvConfig.supabaseUrl.trim().isNotEmpty &&
        EnvConfig.supabaseAnonKey.trim().isNotEmpty) {
      loadedProfile = await CommunityPublicProfileLoader().loadByUsername(
        widget.username,
      );
    }
    final sessions = await _communityModule.getFollowingSessions.load();
    if (!mounted) {
      return;
    }
    final filtered = sessions
        .where((session) => session.username == widget.username)
        .toList(growable: false)
      ..sort((left, right) => right.endedAt.compareTo(left.endedAt));
    setState(() {
      _profile = loadedProfile ?? _profile;
      _sessions = filtered;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final totalDistance = _sessions.fold<double>(
      0,
      (sum, session) => sum + session.distanceKm,
    );
    final bestJump = _sessions.fold<double>(
      0,
      (maxValue, session) =>
          session.highestJumpMeters > maxValue
          ? session.highestJumpMeters
          : maxValue,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Sesiones de usuario')),
      body: RefreshIndicator(
        onRefresh: _loadSessions,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 112,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: _profile.bannerLocalPath == null
                          ? const LinearGradient(
                              colors: [Color(0xFF81D4FA), Color(0xFF4DB6AC)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      image: profileMediaImageProvider(_profile.bannerLocalPath) == null
                          ? null
                          : DecorationImage(
                              image: profileMediaImageProvider(_profile.bannerLocalPath)!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: const Color(0xFF1E88E5),
                              backgroundImage: profileMediaImageProvider(
                                _profile.avatarLocalPath,
                              ),
                              child: profileMediaImageProvider(
                                    _profile.avatarLocalPath,
                                  ) ==
                                  null
                                  ? Text(
                                      _profile.displayName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _profile.displayName,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    _profile.handle,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _CommunitySessionsKpiChip(
                              icon: Icons.route_rounded,
                              label: '${_sessions.length} sesiones',
                            ),
                            _CommunitySessionsKpiChip(
                              icon: Icons.air_rounded,
                              label: bestJump == 0
                                  ? 'Sin salto'
                                  : '${bestJump.toStringAsFixed(1)} m max',
                            ),
                            _CommunitySessionsKpiChip(
                              icon: Icons.straighten_rounded,
                              label: totalDistance == 0
                                  ? '0.0 km'
                                  : '${totalDistance.toStringAsFixed(1)} km',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_sessions.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      Icon(
                        Icons.surfing_rounded,
                        size: 36,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Todavia no hay sesiones visibles de este rider.',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._sessions.map(
                (session) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.primaryContainer,
                        child: Icon(
                          session.hasSessionPhoto
                              ? Icons.photo_camera_back_rounded
                              : Icons.surfing_rounded,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      title: Text(session.title),
                      subtitle: Text(
                        '${session.spot} · ${session.highestJumpMeters.toStringAsFixed(1)} m · ${session.distanceKm.toStringAsFixed(1)} km · ${session.durationLabel}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            session.dateLabel,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${session.likesCount} likes',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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

class _CommunitySessionsKpiChip extends StatelessWidget {
  const _CommunitySessionsKpiChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}
