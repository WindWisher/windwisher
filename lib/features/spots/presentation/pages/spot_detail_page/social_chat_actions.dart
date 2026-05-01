// ignore_for_file: invalid_use_of_protected_member

part of '../spot_detail_page.dart';

extension _SpotDetailSocialChatActions on _SpotDetailPageState {
  void _removePendingSocialAttachment({
    required bool forReply,
    required int index,
  }) {
    setState(() {
      if (forReply) {
        _pendingSocialReplyAttachments = removePendingSpotChatAttachmentAt(
          _pendingSocialReplyAttachments,
          index,
        );
      } else {
        _pendingSocialPostAttachments = removePendingSpotChatAttachmentAt(
          _pendingSocialPostAttachments,
          index,
        );
      }
    });
  }

  void _resetSocialPostComposerState() {
    _editingPostId = null;
    _socialPostController.clear();
    _pendingSocialPostAttachments = const <SpotSocialAttachmentDraft>[];
  }

  void _resetSocialReplyComposerState() {
    _editingReplyId = null;
    _editingReplyPostId = null;
    _replyingPostId = null;
    _replyingReplyId = null;
    _socialReplyController.clear();
    _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
  }

  void _resetSocialComposerState() {
    _resetSocialPostComposerState();
    _resetSocialReplyComposerState();
  }

  void _insertOptimisticSocialPost({
    required String tempId,
    required String message,
    required List<SpotSocialAttachmentDraft> attachments,
  }) {
    final optimisticPost = optimisticSpotChatPost(
      tempId: tempId,
      spotName: widget.name,
      spotArea: widget.area,
      profile: _currentSocialProfile,
      message: message,
      attachments: attachments,
    );
    setState(() {
      _socialFeed = <SpotSocialPost>[optimisticPost, ..._socialFeed];
    });
    _scheduleFocusSocialSection();
  }

  void _insertOptimisticSocialReply({
    required String tempId,
    required String postId,
    required String? parentReplyId,
    required String message,
    required List<SpotSocialAttachmentDraft> attachments,
  }) {
    final optimisticReply = optimisticSpotChatReply(
      tempId: tempId,
      postId: postId,
      parentReplyId: parentReplyId,
      profile: _currentSocialProfile,
      message: message,
      attachments: attachments,
    );
    setState(() {
      _socialFeed = appendOptimisticSpotChatReply(
        feed: _socialFeed,
        postId: postId,
        parentReplyId: parentReplyId,
        reply: optimisticReply,
      );
    });
    _scheduleFocusSocialSection();
  }

  Future<void> _publishSocialPost() async {
    final submission = buildSpotChatPostSubmission(
      text: _socialPostController.text,
      attachments: _pendingSocialPostAttachments,
      isSubmitting: _isSocialSubmitting,
      editingPostId: _editingPostId,
    );
    if (submission == null) {
      return;
    }
    if (!_canPublishSocial) {
      _showSocialSnackBar('Inicia sesion para escribir en el chat del spot.');
      return;
    }

    await _runSocialSubmission(
      onSuccess: _resetSocialComposerState,
      action: () => _submitSocialPost(submission),
    );
  }

  Future<void> _submitSocialPost(SpotChatPostSubmission submission) async {
    if (submission.isEditing) {
      await _spotSocialClient.updatePost(
        postId: submission.editingPostId!,
        message: submission.text,
      );
      return;
    }
    _insertOptimisticSocialPost(
      tempId: submission.tempId,
      message: submission.text,
      attachments: submission.attachments,
    );
    await _spotSocialClient.addPost(
      spotName: widget.name,
      spotArea: widget.area,
      authorUsername: _normalizedSocialUsername(),
      authorDisplayName: _socialDisplayName(),
      message: submission.text,
      attachments: submission.attachments,
    );
  }

  Future<void> _runSocialSubmission({
    required Future<void> Function() action,
    required VoidCallback onSuccess,
  }) async {
    setState(() {
      _isSocialSubmitting = true;
    });
    try {
      await action();
      onSuccess();
      await _broadcastTypingState(isTyping: false);
      await _loadSocialFeed();
    } catch (error) {
      await _loadSocialFeed();
      _showSocialSnackBar(error.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSocialSubmitting = false;
        });
      }
    }
  }

  void _startEditPost(SpotSocialPost post) {
    setState(() {
      _resetSocialReplyComposerState();
      _editingPostId = post.id;
      _socialPostController.text = post.message;
      _pendingSocialPostAttachments = const <SpotSocialAttachmentDraft>[];
    });
  }

  void _startEditReply({
    required String postId,
    required SpotSocialReply reply,
  }) {
    setState(() {
      _setEditingReplyComposerState(postId: postId, reply: reply);
      _socialReplyController.text = reply.message;
      _pendingSocialReplyAttachments = const <SpotSocialAttachmentDraft>[];
    });
    _focusSocialReplyComposer();
  }

  void _setEditingReplyComposerState({
    required String postId,
    required SpotSocialReply reply,
  }) {
    _resetSocialPostComposerState();
    _editingReplyId = reply.id;
    _editingReplyPostId = postId;
    _replyingPostId = null;
    _replyingReplyId = null;
  }

  Future<void> _deletePost(SpotSocialPost post) async {
    await _runSocialDelete(
      action: () => _spotSocialClient.deletePost(postId: post.id),
      onDeleted: () {
        if (_editingPostId == post.id) {
          _resetSocialPostComposerState();
        }
        if (_replyingPostId == post.id) {
          _resetSocialReplyComposerState();
        }
      },
    );
  }

  Future<void> _runSocialDelete({
    required Future<void> Function() action,
    required VoidCallback onDeleted,
  }) async {
    try {
      await action();
      if (!mounted) {
        return;
      }
      setState(() {
        onDeleted();
      });
      await _loadSocialFeed();
    } catch (error) {
      _showSocialSnackBar(error.toString());
    }
  }

  Future<void> _deleteReply({
    required String postId,
    required SpotSocialReply reply,
  }) async {
    await _runSocialDelete(
      action: () => _spotSocialClient.deleteReply(replyId: reply.id),
      onDeleted: () {
        if (_editingReplyId == reply.id) {
          _resetSocialReplyComposerState();
        }
        if (_replyingReplyId == reply.id) {
          _resetSocialReplyComposerState();
        } else if (_replyingPostId == postId && _replyingReplyId == null) {
          _resetSocialReplyComposerState();
        }
      },
    );
  }

  SpotSocialPost? _findSocialPostById(String postId) {
    return findSpotChatPostById(_socialFeed, postId);
  }

  SpotSocialReply? _findSocialReplyById(String replyId) {
    return findSpotChatReplyById(_socialFeed, replyId);
  }

  bool _canManageSocialEntry(SpotChatEntry entry) {
    return entry.isMine || _canModerateSocialMessages;
  }

  Future<void> _showSocialMessageActions(SpotChatEntry entry) async {
    if (!_canManageSocialEntry(entry)) {
      return;
    }
    final action = await showSpotChatMessageActionsSheet(context);
    if (!mounted || action == null) {
      return;
    }
    if (entry.isReply) {
      await _handleSocialReplyAction(entry: entry, action: action);
      return;
    }
    await _handleSocialPostAction(entry: entry, action: action);
  }

  Future<void> _handleSocialReplyAction({
    required SpotChatEntry entry,
    required SpotChatMessageAction action,
  }) async {
    final reply = _findSocialReplyById(entry.id);
    if (reply == null) {
      return;
    }
    if (action == SpotChatMessageAction.edit) {
      _startEditReply(postId: entry.postId, reply: reply);
    } else if (action == SpotChatMessageAction.delete) {
      await _deleteReply(postId: entry.postId, reply: reply);
    }
  }

  Future<void> _handleSocialPostAction({
    required SpotChatEntry entry,
    required SpotChatMessageAction action,
  }) async {
    final post = _findSocialPostById(entry.id);
    if (post == null) {
      return;
    }
    if (action == SpotChatMessageAction.edit) {
      _startEditPost(post);
    } else if (action == SpotChatMessageAction.delete) {
      await _deletePost(post);
    }
  }

  void _openReplyComposerForPost(String postId) {
    _openReplyComposer(postId: postId);
  }

  void _openReplyComposerForReply(String postId, String replyId) {
    _openReplyComposer(postId: postId, replyId: replyId);
  }

  void _openReplyComposer({required String postId, String? replyId}) {
    setState(() {
      _resetSocialReplyComposerState();
      _replyingPostId = postId;
      _replyingReplyId = replyId;
    });
    _focusSocialReplyComposer();
  }

  void _focusSocialReplyComposer() {
    _scheduleEnsureSocialComposerVisible();
    _scheduleFocusSocialComposerInput(forReply: true);
  }

  void _cancelReplyComposer() {
    setState(() {
      _resetSocialReplyComposerState();
    });
    unawaited(_broadcastTypingState(isTyping: false));
  }

  Future<void> _publishReply() async {
    final submission = buildSpotChatReplySubmission(
      text: _socialReplyController.text,
      attachments: _pendingSocialReplyAttachments,
      isSubmitting: _isSocialSubmitting,
      replyingPostId: _replyingPostId,
      replyingReplyId: _replyingReplyId,
      editingReplyId: _editingReplyId,
      editingReplyPostId: _editingReplyPostId,
    );
    if (submission == null) {
      return;
    }
    if (!_canPublishSocial) {
      _showSocialSnackBar('Inicia sesion para responder en el chat del spot.');
      return;
    }

    await _runSocialSubmission(
      onSuccess: _resetSocialReplyComposerState,
      action: () => _submitSocialReply(submission),
    );
  }

  Future<void> _submitSocialReply(SpotChatReplySubmission submission) async {
    if (submission.isEditing) {
      await _spotSocialClient.updateReply(
        replyId: submission.editingReplyId!,
        message: submission.text,
      );
      return;
    }
    _insertOptimisticSocialReply(
      tempId: submission.tempId,
      postId: submission.postId,
      parentReplyId: submission.parentReplyId,
      message: submission.text,
      attachments: submission.attachments,
    );
    await _spotSocialClient.addReply(
      postId: submission.postId,
      parentReplyId: submission.parentReplyId,
      authorUsername: _normalizedSocialUsername(),
      authorDisplayName: _socialDisplayName(),
      message: submission.text,
      attachments: submission.attachments,
    );
  }

  Widget _buildPendingSocialAttachments({
    required List<SpotSocialAttachmentDraft> attachments,
    required bool forReply,
  }) {
    return PendingSpotSocialAttachmentsList(
      attachments: attachments,
      onRemove: (index) =>
          _removePendingSocialAttachment(forReply: forReply, index: index),
    );
  }

  SpotChatEntry? _activeReplyEntry() {
    final postId = _replyingPostId;
    if (postId == null) {
      return null;
    }
    final replyId = _replyingReplyId;
    for (final entry in buildSpotChatEntries(_socialFeed)) {
      if (replyId != null) {
        if (entry.id == replyId) {
          return entry;
        }
      } else if (entry.id == postId && !entry.isReply) {
        return entry;
      }
    }
    return null;
  }

  Widget _buildSocialComposer(TextTheme textTheme, ColorScheme colorScheme) {
    final isEditingReply = _editingReplyId != null;
    final isReplying = !isEditingReply && _replyingPostId != null;
    final composerState = buildSpotChatComposerState(
      isReplying: isReplying,
      isEditingReply: isEditingReply,
      isEditingPost: _editingPostId != null,
      canPublish: _canPublishSocial,
      isSubmitting: _isSocialSubmitting,
      replyEntry: isReplying ? _activeReplyEntry() : null,
    );
    final usesReplyComposer = composerState.usesReplyComposer;
    final controller = usesReplyComposer
        ? _socialReplyController
        : _socialPostController;
    final pendingAttachments = usesReplyComposer
        ? _pendingSocialReplyAttachments
        : _pendingSocialPostAttachments;
    final canSend = usesReplyComposer
        ? _canSendSocialReply
        : _canSendSocialPost;
    final focusNode = usesReplyComposer
        ? _socialReplyFocusNode
        : _socialPostFocusNode;
    final onAttach = composerState.canAttach
        ? () => _showSocialAttachmentOptions(forReply: usesReplyComposer)
        : null;

    return SpotChatComposer(
      controller: controller,
      focusNode: focusNode,
      pendingAttachments: _buildPendingSocialAttachments(
        attachments: pendingAttachments,
        forReply: usesReplyComposer,
      ),
      hintText: composerState.hintText,
      enabled: _canPublishSocial && !_isSocialSubmitting,
      canSend: _canPublishSocial && canSend,
      isReplyComposer: usesReplyComposer,
      isEditingReply: composerState.isEditingReply,
      isEditingPost: composerState.isEditingPost,
      isPickingMedia: _isPickingSocialMedia,
      sendLabel: composerState.sendLabel,
      title: composerState.title,
      replyAuthor: composerState.replyAuthor,
      replyMessage: composerState.replyMessage,
      onAttach: onAttach,
      onChanged: (value) =>
          _handleSocialComposerChanged(value, forReply: usesReplyComposer),
      onSend: usesReplyComposer ? _publishReply : _publishSocialPost,
      onCancel: usesReplyComposer
          ? _cancelReplyComposer
          : () {
              setState(() {
                _resetSocialPostComposerState();
              });
              unawaited(_broadcastTypingState(isTyping: false));
            },
    );
  }
}
