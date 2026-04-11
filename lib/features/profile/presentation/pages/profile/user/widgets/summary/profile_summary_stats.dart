import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';

class ProfileSummaryStats extends StatelessWidget {
  const ProfileSummaryStats({
    super.key,
    required this.kpis,
    this.onFollowersPressed,
    this.onFollowingPressed,
  });

  final ProfileKpiSnapshot kpis;
  final VoidCallback? onFollowersPressed;
  final VoidCallback? onFollowingPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.lg,
          runSpacing: AppSpacing.sm,
          children: [
            _SocialCount(
              value: kpis.followersLabel,
              label: 'Seguidores',
              onPressed: onFollowersPressed,
            ),
            _SocialCount(
              value: kpis.followingLabel,
              label: 'Siguiendo',
              onPressed: onFollowingPressed,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _StatPill(
              label: 'Sesiones',
              value: kpis.totalSessionsLabel,
              icon: Icons.waves_rounded,
            ),
            _StatPill(
              label: 'Horas en agua',
              value: kpis.waterHoursLabel,
              icon: Icons.schedule_rounded,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _StatPill(
                label: 'Salto mas alto',
                value: kpis.highestJumpLabel,
                icon: Icons.height_rounded,
                expand: true,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _StatPill(
                label: 'Max hangtime',
                value: kpis.maxHangtimeLabel,
                icon: Icons.timer_outlined,
                expand: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialCount extends StatefulWidget {
  const _SocialCount({
    required this.value,
    required this.label,
    this.onPressed,
  });

  final String value;
  final String label;
  final VoidCallback? onPressed;

  @override
  State<_SocialCount> createState() => _SocialCountState();
}

class _SocialCountState extends State<_SocialCount> {
  bool _pressed = false;

  Future<void> _handleTap() async {
    if (!_pressed) {
      setState(() {
        _pressed = true;
      });
    }
    await Future<void>.delayed(const Duration(milliseconds: 160));
    if (mounted) {
      setState(() {
        _pressed = false;
      });
    }
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (widget.onPressed == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: RichText(
          text: TextSpan(
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.2,
            ),
            children: [
              TextSpan(
                text: widget.value,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: ' ${widget.label}',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _pressed
              ? colorScheme.primaryContainer.withValues(alpha: 0.45)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: Colors.transparent,
          onHighlightChanged: (value) {
            if (!value || _pressed == value) {
              return;
            }
            setState(() {
              _pressed = true;
            });
          },
          onTap: _handleTap,
          onTapCancel: () {
            if (!_pressed) {
              return;
            }
            setState(() {
              _pressed = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xs,
              vertical: AppSpacing.xs,
            ),
            child: RichText(
              text: TextSpan(
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.2,
                ),
                children: [
                  TextSpan(
                    text: widget.value,
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(
                    text: ' ${widget.label}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    this.expand = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: value,
                    style: textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: ' $label',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
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
