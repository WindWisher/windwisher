import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_avatar.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_banner.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_edit_button.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_stats.dart';

class ProfileSummaryCard extends StatelessWidget {
  const ProfileSummaryCard({
    super.key,
    required this.profile,
    required this.kpis,
    this.onPublicPreviewPressed,
    this.onEditPressed,
    this.onFollowersPressed,
    this.onFollowingPressed,
    this.showPublicPreviewButton = true,
    this.showEditButton = true,
  });

  final UserProfileData profile;
  final ProfileKpiSnapshot kpis;
  final VoidCallback? onPublicPreviewPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onFollowersPressed;
  final VoidCallback? onFollowingPressed;
  final bool showPublicPreviewButton;
  final bool showEditButton;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bannerImage = _bannerImage();
    final avatarImage = _avatarImage();
    final hasBannerImage = bannerImage != null;
    final hasAvatarImage = avatarImage != null;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ProfileSummaryBanner(
                userRole: profile.userRole,
                bannerImage: bannerImage,
                hasBannerImage: hasBannerImage,
                onPublicPreviewPressed: showPublicPreviewButton
                    ? onPublicPreviewPressed
                    : null,
              ),
              Positioned(
                left: AppSpacing.lg,
                bottom: -34,
                child: ProfileSummaryAvatar(
                  avatarImage: avatarImage,
                  hasAvatarImage: hasAvatarImage,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              46,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.displayName,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profile.handle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (kpis.rankingLabel != '--') ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 16,
                        color: colorScheme.tertiary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Ranking global ${kpis.rankingLabel}',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                Text(
                  profile.publicTagline,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ProfileSummaryStats(
                  kpis: kpis,
                  onFollowersPressed: onFollowersPressed,
                  onFollowingPressed: onFollowingPressed,
                ),
                if (showEditButton && onEditPressed != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ProfileSummaryEditButton(onPressed: onEditPressed!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider<Object>? _bannerImage() {
    if (!kIsWeb && profile.bannerLocalPath != null) {
      return FileImage(File(profile.bannerLocalPath!));
    }
    return null;
  }

  ImageProvider<Object>? _avatarImage() {
    if (!kIsWeb && profile.avatarLocalPath != null) {
      return FileImage(File(profile.avatarLocalPath!));
    }
    return null;
  }
}
