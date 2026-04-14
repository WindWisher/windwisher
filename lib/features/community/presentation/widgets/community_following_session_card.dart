import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/entities/session_like_state.dart';

class CommunityFollowingSessionCard extends StatelessWidget {
  const CommunityFollowingSessionCard({
    super.key,
    required this.session,
    required this.displayName,
    required this.avatar,
    required this.likeState,
    required this.likeCountLabel,
    required this.commentCountLabel,
    required this.onToggleLike,
    required this.onOpenComments,
    required this.onViewSession,
  });

  final FollowingSession session;
  final String displayName;
  final Widget avatar;
  final SessionLikeState likeState;
  final String likeCountLabel;
  final String commentCountLabel;
  final VoidCallback onToggleLike;
  final VoidCallback onOpenComments;
  final VoidCallback onViewSession;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: session.hasSessionPhoto
                    ? const LinearGradient(
                        colors: [Color(0xFF90CAF9), Color(0xFF42A5F5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [Color(0xFFC8E6C9), Color(0xFF80CBC4)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      session.hasSessionPhoto
                          ? Icons.photo_camera_back_rounded
                          : Icons.map_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.hasSessionPhoto
                          ? 'Foto de la sesion'
                          : 'Pantallazo del mapa del spot',
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                avatar,
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        '@${session.username}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(session.dateLabel),
              ],
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _SessionStatChip(
                  icon: Icons.height_rounded,
                  label: '${session.highestJumpMeters.toStringAsFixed(1)} m',
                ),
                _SessionStatChip(
                  icon: Icons.route_rounded,
                  label: '${session.distanceKm.toStringAsFixed(1)} km',
                ),
                _SessionStatChip(
                  icon: Icons.timer_outlined,
                  label: session.durationLabel,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${session.spot} · ${session.equipmentLabel}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Divider(height: 1),
            const SizedBox(height: 4),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: 2,
              children: [Text(likeCountLabel), Text(commentCountLabel)],
            ),
            const SizedBox(height: 2),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton(
                  key: ValueKey<String>('session_like_${session.id}'),
                  onPressed: onToggleLike,
                  tooltip: likeState.isLikedByUser ? 'Quitar like' : 'Dar like',
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: Icon(
                      likeState.isLikedByUser
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      key: ValueKey<bool>(likeState.isLikedByUser),
                      color: likeState.isLikedByUser ? Colors.red : null,
                    ),
                  ),
                ),
                IconButton(
                  key: ValueKey<String>('session_comment_${session.id}'),
                  onPressed: onOpenComments,
                  tooltip: 'Comentar',
                  icon: const Icon(Icons.mode_comment_outlined),
                ),
                OutlinedButton.icon(
                  key: ValueKey<String>('session_view_${session.id}'),
                  style: OutlinedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 8,
                    ),
                  ),
                  onPressed: onViewSession,
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Ver sesion'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionStatChip extends StatelessWidget {
  const _SessionStatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
