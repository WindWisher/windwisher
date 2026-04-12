import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_avatar.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_banner.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_edit_button.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_gear_setups.dart';
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
    this.savedGearSetups = const <GearSetup>[],
    this.findKite,
    this.findBar,
    this.findBoard,
    this.findHarness,
    this.findWetsuit,
    this.findHelmet,
    this.findVest,
    this.showPublicPreviewButton = true,
    this.showEditButton = true,
  });

  final UserProfileData profile;
  final ProfileKpiSnapshot kpis;
  final VoidCallback? onPublicPreviewPressed;
  final VoidCallback? onEditPressed;
  final VoidCallback? onFollowersPressed;
  final VoidCallback? onFollowingPressed;
  final List<GearSetup> savedGearSetups;
  final KiteItem? Function(String id)? findKite;
  final BarItem? Function(String id)? findBar;
  final BoardItem? Function(String id)? findBoard;
  final HarnessItem? Function(String id)? findHarness;
  final WetsuitItem? Function(String id)? findWetsuit;
  final HelmetItem? Function(String id)? findHelmet;
  final VestItem? Function(String id)? findVest;
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
    final tagline = profile.publicTagline.trim();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ProfileSummaryBanner(
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
                if (tagline.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    tagline,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ] else
                  const SizedBox(height: AppSpacing.sm),
                ProfileSummaryStats(
                  kpis: kpis,
                  onFollowersPressed: onFollowersPressed,
                  onFollowingPressed: onFollowingPressed,
                ),
                if (savedGearSetups.isNotEmpty &&
                    findKite != null &&
                    findBar != null &&
                    findBoard != null &&
                    findHarness != null &&
                    findWetsuit != null &&
                    findHelmet != null &&
                    findVest != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  ProfileSummaryGearSetups(
                    savedGearSetups: savedGearSetups,
                    findKite: findKite!,
                    findBar: findBar!,
                    findBoard: findBoard!,
                    findHarness: findHarness!,
                    findWetsuit: findWetsuit!,
                    findHelmet: findHelmet!,
                    findVest: findVest!,
                  ),
                ],
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
    return _profileImageProvider(profile.bannerLocalPath);
  }

  ImageProvider<Object>? _avatarImage() {
    return _profileImageProvider(profile.avatarLocalPath);
  }

  ImageProvider<Object>? _profileImageProvider(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }
    final trimmedPath = path.trim();
    final uri = Uri.tryParse(trimmedPath);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(trimmedPath);
    }
    if (!kIsWeb) {
      return FileImage(File(trimmedPath));
    }
    return null;
  }
}
