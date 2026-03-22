import 'dart:io';

import 'package:flutter/material.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/community/presentation/support/community_identity_mapper.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

class CommunityUserSessionsPage extends StatelessWidget {
  const CommunityUserSessionsPage({
    super.key,
    required this.username,
    this.useLocalPersistence = EnvConfig.profileLocalPersistenceEnabled,
  });

  final String username;
  final bool useLocalPersistence;

  UserProfileData _resolveProfile(String username) {
    final currentProfile = useLocalPersistence
        ? ProfileModule.localFile().profileController.profile
        : ProfileModule.inMemory().profileController.profile;
    return CommunityIdentityMapper.profileForUsername(
      username: username,
      currentProfile: currentProfile,
    );
  }

  List<_SessionPreview> _buildSessions() {
    final seed = username.codeUnits.fold(0, (sum, code) => sum + code);
    const spots = ['Tarifa', 'Fuerteventura', 'El Medano', 'Gandia'];

    return List<_SessionPreview>.generate(10, (index) {
      final jump = 12.0 + ((seed + (index * 7)) % 120) / 10;
      final distance = 4.0 + ((seed + (index * 11)) % 240) / 10;
      final durationMin = 45 + ((seed + (index * 5)) % 130);
      final daysAgo = index + 1;

      return _SessionPreview(
        title: 'Sesion ${index + 1} · ${spots[index % spots.length]}',
        subtitle:
            '${jump.toStringAsFixed(1)} m · ${distance.toStringAsFixed(1)} km · $durationMin min',
        dateLabel: 'Hace $daysAgo dia${daysAgo == 1 ? '' : 's'}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final sessions = _buildSessions();
    final profile = _resolveProfile(username);

    return Scaffold(
      appBar: AppBar(title: const Text('Sesiones de usuario')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 92,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: profile.bannerLocalPath == null
                        ? const LinearGradient(
                            colors: [Color(0xFF81D4FA), Color(0xFF4DB6AC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    image: profile.bannerLocalPath == null
                        ? null
                        : DecorationImage(
                            image: FileImage(File(profile.bannerLocalPath!)),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF1E88E5),
                        backgroundImage: profile.avatarLocalPath == null
                            ? null
                            : FileImage(File(profile.avatarLocalPath!)),
                        child: profile.avatarLocalPath == null
                            ? Text(
                                profile.displayName
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.displayName,
                              style: Theme.of(context).textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              profile.handle,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: const [
              Chip(label: Text('Todas')),
              Chip(label: Text('Big Air')),
              Chip(label: Text('Freeride')),
              Chip(label: Text('Recientes')),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...sessions.map(
            (session) => Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.surfing_rounded)),
                title: Text(session.title),
                subtitle: Text(session.subtitle),
                trailing: Text(session.dateLabel),
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionPreview {
  const _SessionPreview({
    required this.title,
    required this.subtitle,
    required this.dateLabel,
  });

  final String title;
  final String subtitle;
  final String dateLabel;
}
