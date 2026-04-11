import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_public_preview_button.dart';

class ProfileSummaryBanner extends StatelessWidget {
  const ProfileSummaryBanner({
    super.key,
    required this.userRole,
    required this.bannerImage,
    required this.hasBannerImage,
    this.onPublicPreviewPressed,
  });

  final String userRole;
  final ImageProvider<Object>? bannerImage;
  final bool hasBannerImage;
  final VoidCallback? onPublicPreviewPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 172,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: !hasBannerImage
            ? LinearGradient(
                colors: [
                  colorScheme.primaryContainer,
                  colorScheme.tertiaryContainer,
                  colorScheme.secondaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        image: !hasBannerImage
            ? null
            : DecorationImage(image: bannerImage!, fit: BoxFit.cover),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.05),
              Colors.black.withValues(alpha: 0.35),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  userRole,
                  style: textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (onPublicPreviewPressed != null)
                ProfileSummaryPublicPreviewButton(
                  onPressed: onPublicPreviewPressed!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
