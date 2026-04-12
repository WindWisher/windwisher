import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/summary/profile_summary_public_preview_button.dart';

class ProfileSummaryBanner extends StatelessWidget {
  const ProfileSummaryBanner({
    super.key,
    required this.bannerImage,
    required this.hasBannerImage,
    this.onPublicPreviewPressed,
  });

  final ImageProvider<Object>? bannerImage;
  final bool hasBannerImage;
  final VoidCallback? onPublicPreviewPressed;

  @override
  Widget build(BuildContext context) {
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
