// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailSocialChatLifecycle on _SpotDetailPageState {
  void _initializeSocialChat() {
    _spotSocialClient = SpotsModule.createSocialService();
    _spotChatRealtimeController = SpotChatRealtimeController(
      client: _spotSocialClient,
      spotName: widget.name,
      spotArea: widget.area,
      onFeedChanged: () async {
        if (!mounted) {
          return;
        }
        await _loadSocialFeed();
      },
      onPresenceChanged: (count) {
        if (!mounted) {
          return;
        }
        setState(() {
          _socialOnlineCount = count;
        });
      },
      onTypingChanged: (typingUsers) {
        if (!mounted) {
          return;
        }
        setState(() {
          _socialTypingUsers = typingUsers;
        });
      },
      displayName: _socialDisplayName,
    );
    _profileModule = ProfileModule.auto();
    _fallbackSocialProfile = UserProfileData.initial().copyWith(
      displayName: 'Rider',
      handle: '@rider',
    );
    _currentSocialProfile = _fallbackSocialProfile;
  }

  void _hydrateSocialChat() {
    _loadSocialIdentity();
    unawaited(_loadSocialModerationPermissions());
    _loadSocialFeed();
  }

  void _resumeSocialChatIfVisible() {
    if (_section != _SpotDetailSection.social) {
      return;
    }
    if (!_spotChatRealtimeController.isBound) {
      _spotChatRealtimeController.bindAll();
    }
    unawaited(_loadSocialFeed());
    _scheduleFocusSocialSection();
  }

  void _focusOrStartSocialChat() {
    if (!_spotChatRealtimeController.isBound) {
      _spotChatRealtimeController.bindAll();
      unawaited(_loadSocialFeed());
      return;
    }
    _scheduleFocusSocialSection();
  }

  void _enterSocialChatSection({bool loadFeed = true}) {
    _spotChatRealtimeController.bindAll();
    if (loadFeed) {
      unawaited(_loadSocialFeed());
    }
    _scheduleFocusSocialSection();
  }

  void _leaveSocialChatSection() {
    unawaited(_broadcastTypingState(isTyping: false));
    _spotChatRealtimeController.unbindAll();
    _socialOnlineCount = 0;
    _socialTypingUsers = const <String>{};
  }

  void _disposeSocialChat() {
    unawaited(_broadcastTypingState(isTyping: false));
    _spotChatRealtimeController.dispose();
    _socialFeedScrollController.dispose();
    _socialPostFocusNode.dispose();
    _socialReplyFocusNode.dispose();
    _socialPostController.dispose();
    _socialReplyController.dispose();
  }

  Future<void> _broadcastTypingState({required bool isTyping}) async {
    await _spotChatRealtimeController.sendTypingState(isTyping: isTyping);
  }

  void _handleSocialComposerChanged(String value, {required bool forReply}) {
    setState(() {});
    if (_section != _SpotDetailSection.social) {
      return;
    }
    _spotChatRealtimeController.handleComposerChanged(value);
  }

  void _restoreSocialChatViewport() {
    if (!mounted || _section != _SpotDetailSection.social) {
      return;
    }
    FocusScope.of(context).unfocus();
    _scheduleFocusSocialSection();
  }

  Future<void> _loadSocialIdentity() async {
    try {
      final profile = await _profileModule.profileController.loadProfile();
      if (!mounted) {
        return;
      }
      setState(() {
        _currentSocialProfile = profile;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentSocialProfile = _fallbackSocialProfile;
      });
    }
  }

  Future<void> _loadSocialModerationPermissions() async {
    try {
      final client = Supabase.instance.client;
      if (client.auth.currentUser == null) {
        if (!mounted) {
          return;
        }
        setState(() {
          _canModerateSocialMessages = false;
        });
        return;
      }
      final spotKey = buildSpotSocialKey(
        spotName: widget.name,
        spotArea: widget.area,
      );
      final result = await client.rpc(
        'can_moderate_spot',
        params: <String, dynamic>{'target_spot_key': spotKey},
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _canModerateSocialMessages = result == true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _canModerateSocialMessages = false;
      });
    }
  }

  Future<void> _loadSocialFeed() async {
    if (mounted) {
      setState(() {
        _isSocialLoading = true;
        _socialErrorMessage = null;
      });
    }
    try {
      final posts = await _spotSocialClient.loadPosts(
        spotName: widget.name,
        spotArea: widget.area,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _socialFeed = posts;
      });
      _scheduleScrollSocialFeedToBottom();
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _socialErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSocialLoading = false;
        });
        if (_section == _SpotDetailSection.social && _socialFeed.isNotEmpty) {
          unawaited(_scrollSocialFeedToBottomAfterLayout());
        }
      }
    }
  }

  Future<void> _scrollSocialFeedToBottomAfterLayout({
    bool animated = false,
  }) async {
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_socialFeedScrollController.hasClients) {
        return;
      }
      final targetOffset = _socialFeedScrollController.position.maxScrollExtent;
      if (animated) {
        unawaited(
          _socialFeedScrollController.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
          ),
        );
      } else {
        _socialFeedScrollController.jumpTo(targetOffset);
      }
    });
  }

  void _scheduleEnsureSocialComposerVisible() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final currentContext = _socialComposerKey.currentContext;
      if (currentContext == null) {
        return;
      }
      Scrollable.ensureVisible(
        currentContext,
        alignment: 0.72,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  void _scheduleFocusSocialComposerInput({required bool forReply}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final focusNode = forReply ? _socialReplyFocusNode : _socialPostFocusNode;
      if (!focusNode.canRequestFocus) {
        return;
      }
      focusNode.requestFocus();
    });
  }

  void _scheduleFocusSocialSection() {
    _scheduleScrollSocialFeedToBottom(animated: true);
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (!mounted || _section != _SpotDetailSection.social) {
        return;
      }
      _scheduleEnsureSocialComposerVisible();
      Future<void>.delayed(const Duration(milliseconds: 120), () {
        if (!mounted || _section != _SpotDetailSection.social) {
          return;
        }
        _scheduleScrollSocialFeedToBottom();
      });
    });
  }

  void _scheduleScrollSocialFeedToBottom({bool animated = false}) {
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (!mounted || _section != _SpotDetailSection.social) {
        return;
      }
      unawaited(_scrollSocialFeedToBottomAfterLayout(animated: animated));
    });
  }

  String _normalizedSocialUsername() {
    return normalizedSpotChatUsername(_currentSocialProfile);
  }

  String _socialDisplayName() {
    return spotChatDisplayName(_currentSocialProfile);
  }

  bool get _canPublishSocial => _spotSocialClient.canWrite;

  bool get _canSendSocialPost =>
      !_isSocialSubmitting &&
      (_socialPostController.text.trim().isNotEmpty ||
          _pendingSocialPostAttachments.isNotEmpty);

  bool get _canSendSocialReply =>
      !_isSocialSubmitting &&
      (_socialReplyController.text.trim().isNotEmpty ||
          _pendingSocialReplyAttachments.isNotEmpty);
}
