import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/profile_media_image_provider.dart';

class PublicProfilePreviewPage extends StatelessWidget {
  final UserProfileData profile;
  final String title;

  const PublicProfilePreviewPage({
    super.key,
    required this.profile,
    this.title = 'Vista publica',
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 110,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: profileMediaImageProvider(
                                  profile.bannerLocalPath,
                                ) ==
                                null
                            ? LinearGradient(
                                colors: [
                                  Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                ],
                              )
                            : null,
                        image: profileMediaImageProvider(
                                  profile.bannerLocalPath,
                                ) ==
                                null
                            ? null
                            : DecorationImage(
                                image: profileMediaImageProvider(
                                  profile.bannerLocalPath,
                                )!,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.blue,
                        backgroundImage: profileMediaImageProvider(
                          profile.avatarLocalPath,
                        ),
                        child: profileMediaImageProvider(profile.avatarLocalPath) ==
                                null
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.displayName,
                              style: textTheme.titleLarge,
                            ),
                            Text(profile.handle, style: textTheme.bodySmall),
                          ],
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: () {},
                        child: const Text('Seguir'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Chip(label: Text('${profile.totalSessions} sesiones')),
                      Chip(label: Text('Top salto ${profile.topJump}')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Resumen publico',
                    style: textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.timelapse_rounded),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          '${profile.waterHours} en el agua · ${profile.jumps} saltos registrados',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
