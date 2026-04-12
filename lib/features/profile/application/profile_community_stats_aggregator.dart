import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/entities/session_comment.dart';
import 'package:windwisher/features/community/domain/entities/session_like_state.dart';
import 'package:windwisher/features/community/presentation/support/community_identity_mapper.dart';
import 'package:windwisher/features/profile/domain/entities/profile_community_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

class ProfileCommunityStatsAggregator {
  const ProfileCommunityStatsAggregator._();

  static ProfileCommunityStatsSnapshot build({
    required UserProfileData profile,
    required List<CommunityUserSummary> communityUsers,
    required Set<String> followingUsernames,
    required List<String>? followerUsernames,
    required List<FollowingSession> visibleSessions,
    required Map<String, List<SessionComment>> commentsBySessionId,
    required Map<String, SessionLikeState> likeStatesBySessionId,
  }) {
    final currentUsername =
        CommunityIdentityMapper.normalizedUsernameFromProfile(profile);
    final authoredSessions = visibleSessions
        .where((session) => session.username == currentUsername)
        .toList(growable: false);

    final sharedSessionsCount = authoredSessions.length;
    var commentsReceived = 0;
    var likesReceived = 0;
    for (final session in authoredSessions) {
      commentsReceived += commentsBySessionId[session.id]?.length ?? 0;
      likesReceived += likeStatesBySessionId[session.id]?.likesCount ?? 0;
    }

    final followingLabel = followingUsernames.isEmpty
        ? '--'
        : followingUsernames.length.toString();
    final followersLabel = followerUsernames == null
        ? '--'
        : followerUsernames.length.toString();
    final rankingLabel = _resolveRankingLabel(
      communityUsers: communityUsers,
      currentUsername: currentUsername,
    );
    final followersCount = _parseCount(followersLabel);
    final followingCount = _parseCount(followingLabel);
    final followersFollowingRatioLabel =
        followersCount == null || followingCount == null || followingCount == 0
        ? '--'
        : (followersCount / followingCount).toStringAsFixed(1);
    final commentsPerSharedSessionLabel = sharedSessionsCount == 0
        ? '--'
        : (commentsReceived / sharedSessionsCount).toStringAsFixed(1);
    final likesPerSharedSessionLabel = sharedSessionsCount == 0
        ? '--'
        : (likesReceived / sharedSessionsCount).toStringAsFixed(1);

    String mostCommentedSessionLabel = '--';
    String mostLikedSessionLabel = '--';
    var maxComments = 0;
    var maxLikes = 0;
    final now = DateTime.now();
    final recentThreshold = now.subtract(const Duration(days: 30));
    final sharedSessionsLast30Days = authoredSessions
        .where((session) => session.endedAt.isAfter(recentThreshold))
        .length;
    var commentsReceivedLast30Days = 0;
    for (final session in authoredSessions) {
      final sessionComments =
          commentsBySessionId[session.id] ?? const <SessionComment>[];
      final commentsCount = sessionComments.length;
      final likesCount = likeStatesBySessionId[session.id]?.likesCount ?? 0;
      commentsReceivedLast30Days += sessionComments
          .where((comment) => comment.createdAt.isAfter(recentThreshold))
          .length;
      if (commentsCount > maxComments) {
        maxComments = commentsCount;
        mostCommentedSessionLabel = '$commentsCount comentarios';
      }
      if (likesCount > maxLikes) {
        maxLikes = likesCount;
        mostLikedSessionLabel = '$likesCount likes';
      }
    }
    final engagementRateLabel = sharedSessionsCount == 0
        ? '--'
        : ((commentsReceived + likesReceived) / sharedSessionsCount)
              .toStringAsFixed(1);
    final sharedSessionsLast30DaysLabel = sharedSessionsLast30Days == 0
        ? '--'
        : sharedSessionsLast30Days.toString();
    final commentsReceivedLast30DaysLabel = commentsReceivedLast30Days == 0
        ? '--'
        : commentsReceivedLast30Days.toString();

    return ProfileCommunityStatsSnapshot(
      followersLabel: followersLabel,
      followingLabel: followingLabel,
      rankingLabel: rankingLabel,
      sharedSessionsCountLabel: sharedSessionsCount == 0
          ? '--'
          : sharedSessionsCount.toString(),
      commentsReceivedLabel: commentsReceived == 0
          ? '--'
          : commentsReceived.toString(),
      likesReceivedLabel: likesReceived == 0 ? '--' : likesReceived.toString(),
      followersFollowingRatioLabel: followersFollowingRatioLabel,
      commentsPerSharedSessionLabel: commentsPerSharedSessionLabel,
      likesPerSharedSessionLabel: likesPerSharedSessionLabel,
      mostCommentedSessionLabel: mostCommentedSessionLabel,
      mostLikedSessionLabel: mostLikedSessionLabel,
      engagementRateLabel: engagementRateLabel,
      sharedSessionsLast30DaysLabel: sharedSessionsLast30DaysLabel,
      commentsReceivedLast30DaysLabel: commentsReceivedLast30DaysLabel,
      hasSharedSessions: sharedSessionsCount > 0,
      hasCommentsReceived: commentsReceived > 0,
      hasLikesReceived: likesReceived > 0,
      hasFollowersFollowingRatio: followersFollowingRatioLabel != '--',
      hasCommentsPerSharedSession: commentsPerSharedSessionLabel != '--',
      hasLikesPerSharedSession: likesPerSharedSessionLabel != '--',
      hasMostCommentedSession: mostCommentedSessionLabel != '--',
      hasMostLikedSession: mostLikedSessionLabel != '--',
      hasEngagementRate: engagementRateLabel != '--',
      hasSharedSessionsLast30Days: sharedSessionsLast30DaysLabel != '--',
      hasCommentsReceivedLast30Days: commentsReceivedLast30DaysLabel != '--',
    );
  }

  static int? _parseCount(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty || normalized == '--') {
      return null;
    }
    return int.tryParse(normalized.replaceAll(RegExp(r'[^0-9-]'), ''));
  }

  static String _resolveRankingLabel({
    required List<CommunityUserSummary> communityUsers,
    required String currentUsername,
  }) {
    if (communityUsers.isEmpty) {
      return '--';
    }
    final sorted = communityUsers.toList(growable: false)
      ..sort((a, b) => b.bigAirScore.compareTo(a.bigAirScore));
    for (var index = 0; index < sorted.length; index++) {
      if (sorted[index].username == currentUsername) {
        return '#${index + 1}';
      }
    }
    return '--';
  }

}
