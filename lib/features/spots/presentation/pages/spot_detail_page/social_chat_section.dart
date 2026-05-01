part of '../spot_detail_page.dart';

extension _SpotDetailSocialChatSection on _SpotDetailPageState {
  Widget _buildSocialSection(TextTheme textTheme) {
    final colorScheme = Theme.of(context).colorScheme;
    final chatMaxHeight = math.min(
      520.0,
      math.max(280.0, MediaQuery.of(context).size.height * 0.46),
    );
    return SpotChatSection(
      header: SpotChatHeader(
        spotName: widget.name,
        spotArea: widget.area,
        onlineCount: _socialOnlineCount,
        typingUsers: _socialTypingUsers,
      ),
      feed: SpotChatFeed(
        maxHeight: chatMaxHeight,
        isLoading: _isSocialLoading,
        hasMessages: _socialFeed.isNotEmpty,
        errorMessage: _socialErrorMessage,
        scrollController: _socialFeedScrollController,
        messageChildren: [
          SpotChatMessageList(
            entries: buildSpotChatEntries(_socialFeed),
            lastMessageKey: _lastSocialMessageKey,
            currentUserAvatarLocalPath: _currentSocialProfile.avatarLocalPath,
            relativeTimeLabel: _relativeTimeLabel,
            canManageEntry: _canManageSocialEntry,
            onReply: (entry) => entry.isReply
                ? _openReplyComposerForReply(entry.postId, entry.id)
                : _openReplyComposerForPost(entry.id),
            onManage: (entry) => unawaited(_showSocialMessageActions(entry)),
          ),
        ],
      ),
      composerKey: _socialComposerKey,
      composer: _buildSocialComposer(textTheme, colorScheme),
    );
  }
}
