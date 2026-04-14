import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';

class CommunityUserListCard extends StatelessWidget {
  const CommunityUserListCard({
    super.key,
    required this.user,
    required this.identityLabel,
    required this.isFollowing,
    required this.avatar,
    required this.onTap,
    required this.onToggleFollowing,
  });

  final CommunityUserSummary user;
  final String identityLabel;
  final bool isFollowing;
  final Widget avatar;
  final VoidCallback onTap;
  final VoidCallback onToggleFollowing;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: avatar,
        title: Text(identityLabel),
        subtitle: Text(
          user.mainSpot.trim().isEmpty
              ? 'Big Air ${user.bigAirScore} · Actividad ${user.activityScore}'
              : '${user.mainSpot} · Big Air ${user.bigAirScore} · Actividad ${user.activityScore}',
        ),
        trailing: TextButton(
          onPressed: onToggleFollowing,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          ),
          child: Text(isFollowing ? 'Siguiendo' : 'Seguir'),
        ),
      ),
    );
  }
}
