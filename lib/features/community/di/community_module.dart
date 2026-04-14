import 'package:flutter/foundation.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/community/application/use_cases/community_following_feed_use_cases.dart';
import 'package:windwisher/features/community/application/use_cases/community_following_preferences_use_cases.dart';
import 'package:windwisher/features/community/application/use_cases/community_leaderboard_use_cases.dart';
import 'package:windwisher/features/community/application/services/community_orchestration_service.dart';
import 'package:windwisher/features/community/infrastructure/adapters/in_memory/in_memory_community_following_feed_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/in_memory/in_memory_community_following_preferences_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/in_memory/in_memory_community_leaderboard_adapter.dart';
import 'package:windwisher/features/community/application/use_cases/community_session_reactions_use_cases.dart';
import 'package:windwisher/features/community/application/use_cases/community_session_comments_use_cases.dart';
import 'package:windwisher/features/community/infrastructure/adapters/in_memory/in_memory_community_session_comments_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/in_memory/in_memory_community_session_reactions_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/local/local_file_community_following_preferences_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/local/local_file_community_session_comments_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/local/local_file_community_session_reactions_adapter.dart';
import 'package:windwisher/features/community/infrastructure/persistence/community_social_state_store.dart';
import 'package:windwisher/features/community/infrastructure/adapters/supabase/supabase_community_following_preferences_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/supabase/supabase_community_following_feed_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/supabase/supabase_community_leaderboard_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/supabase/supabase_community_session_comments_adapter.dart';
import 'package:windwisher/features/community/infrastructure/adapters/supabase/supabase_community_session_reactions_adapter.dart';

class CommunityModule {
  const CommunityModule({
    required this.getFollowingSessions,
    required this.getCommunityUsers,
    required this.orchestration,
    required this.getSessionLikeState,
    required this.toggleSessionLike,
    required this.getSessionComments,
    required this.addSessionComment,
    required this.getFollowingUsernames,
    required this.getFollowerUsernames,
    required this.saveFollowingUsernames,
  });

  final GetCommunityFollowingSessionsUseCase getFollowingSessions;
  final GetCommunityUsersUseCase getCommunityUsers;
  final CommunityOrchestrationService orchestration;
  final GetSessionLikeStateUseCase getSessionLikeState;
  final ToggleSessionLikeUseCase toggleSessionLike;
  final GetSessionCommentsUseCase getSessionComments;
  final AddSessionCommentUseCase addSessionComment;
  final GetFollowingUsernamesUseCase getFollowingUsernames;
  final GetFollowerUsernamesUseCase getFollowerUsernames;
  final SaveFollowingUsernamesUseCase saveFollowingUsernames;

  factory CommunityModule.inMemory() {
    final followingFeed = InMemoryCommunityFollowingFeedAdapter();
    final seedSessions = followingFeed.getFollowingSessions();
    final leaderboard = InMemoryCommunityLeaderboardAdapter();
    final sessionReactions = InMemoryCommunitySessionReactionsAdapter(
      initialSessions: seedSessions,
    );
    final sessionComments = InMemoryCommunitySessionCommentsAdapter();
    final followingPreferences = InMemoryCommunityFollowingPreferencesAdapter();
    return CommunityModule(
      getFollowingSessions: GetCommunityFollowingSessionsUseCase(followingFeed),
      getCommunityUsers: GetCommunityUsersUseCase(leaderboard),
      orchestration: const CommunityOrchestrationService(),
      getSessionLikeState: GetSessionLikeStateUseCase(sessionReactions),
      toggleSessionLike: ToggleSessionLikeUseCase(sessionReactions),
      getSessionComments: GetSessionCommentsUseCase(sessionComments),
      addSessionComment: AddSessionCommentUseCase(sessionComments),
      getFollowingUsernames: GetFollowingUsernamesUseCase(followingPreferences),
      getFollowerUsernames: GetFollowerUsernamesUseCase(followingPreferences),
      saveFollowingUsernames: SaveFollowingUsernamesUseCase(
        followingPreferences,
      ),
    );
  }

  factory CommunityModule.localFile() {
    final followingFeed = InMemoryCommunityFollowingFeedAdapter();
    final seedSessions = followingFeed.getFollowingSessions();
    final leaderboard = InMemoryCommunityLeaderboardAdapter();
    final socialStore = CommunitySocialStateStore(seedSessions: seedSessions);
    final sessionReactions = LocalFileCommunitySessionReactionsAdapter(
      socialStore,
    );
    final sessionComments = LocalFileCommunitySessionCommentsAdapter(
      socialStore,
    );
    final followingPreferences = LocalFileCommunityFollowingPreferencesAdapter(
      socialStore,
    );

    return CommunityModule(
      getFollowingSessions: GetCommunityFollowingSessionsUseCase(followingFeed),
      getCommunityUsers: GetCommunityUsersUseCase(leaderboard),
      orchestration: const CommunityOrchestrationService(),
      getSessionLikeState: GetSessionLikeStateUseCase(sessionReactions),
      toggleSessionLike: ToggleSessionLikeUseCase(sessionReactions),
      getSessionComments: GetSessionCommentsUseCase(sessionComments),
      addSessionComment: AddSessionCommentUseCase(sessionComments),
      getFollowingUsernames: GetFollowingUsernamesUseCase(followingPreferences),
      getFollowerUsernames: GetFollowerUsernamesUseCase(followingPreferences),
      saveFollowingUsernames: SaveFollowingUsernamesUseCase(
        followingPreferences,
      ),
    );
  }

  factory CommunityModule.auto() {
    final hasSupabase =
        EnvConfig.supabaseUrl.trim().isNotEmpty &&
        EnvConfig.supabaseAnonKey.trim().isNotEmpty;
    final followingFeed = hasSupabase
        ? SupabaseCommunityFollowingFeedAdapter()
        : InMemoryCommunityFollowingFeedAdapter();
    final leaderboard = hasSupabase
        ? SupabaseCommunityLeaderboardAdapter()
        : InMemoryCommunityLeaderboardAdapter();
    final seedSessions = followingFeed.getFollowingSessions();
    final socialStore = kIsWeb || hasSupabase
        ? null
        : CommunitySocialStateStore(seedSessions: seedSessions);
    final sessionReactions = hasSupabase
        ? SupabaseCommunitySessionReactionsAdapter()
        : kIsWeb
        ? InMemoryCommunitySessionReactionsAdapter(
            initialSessions: seedSessions,
          )
        : LocalFileCommunitySessionReactionsAdapter(socialStore!);
    final sessionComments = hasSupabase
        ? SupabaseCommunitySessionCommentsAdapter()
        : kIsWeb
        ? InMemoryCommunitySessionCommentsAdapter()
        : LocalFileCommunitySessionCommentsAdapter(socialStore!);
    final followingPreferences = hasSupabase
        ? SupabaseCommunityFollowingPreferencesAdapter()
        : kIsWeb
        ? InMemoryCommunityFollowingPreferencesAdapter()
        : LocalFileCommunityFollowingPreferencesAdapter(socialStore!);

    return CommunityModule(
      getFollowingSessions: GetCommunityFollowingSessionsUseCase(followingFeed),
      getCommunityUsers: GetCommunityUsersUseCase(leaderboard),
      orchestration: const CommunityOrchestrationService(),
      getSessionLikeState: GetSessionLikeStateUseCase(sessionReactions),
      toggleSessionLike: ToggleSessionLikeUseCase(sessionReactions),
      getSessionComments: GetSessionCommentsUseCase(sessionComments),
      addSessionComment: AddSessionCommentUseCase(sessionComments),
      getFollowingUsernames: GetFollowingUsernamesUseCase(followingPreferences),
      getFollowerUsernames: GetFollowerUsernamesUseCase(followingPreferences),
      saveFollowingUsernames: SaveFollowingUsernamesUseCase(
        followingPreferences,
      ),
    );
  }
}
