// ignore_for_file: invalid_use_of_protected_member

part of '../../spot_detail_page.dart';

extension _SpotDetailSocialChatAttachments on _SpotDetailPageState {
  Future<void> _showSocialAttachmentOptions({required bool forReply}) async {
    if (_isPickingSocialMedia || _isSocialSubmitting || !_canPublishSocial) {
      return;
    }
    final selection = await showSpotChatAttachmentSourceSheet(context);
    if (selection == null) {
      _restoreSocialChatViewport();
      return;
    }
    if (selection == ImageSource.gallery) {
      await _pickSocialMediaFromGallery(forReply: forReply);
      return;
    }
    if (!mounted) {
      return;
    }
    final captureSelection = await showSpotChatCameraCaptureTypeSheet(context);
    if (captureSelection == null) {
      _restoreSocialChatViewport();
      return;
    }
    await _pickSocialAttachment(
      forReply: forReply,
      isVideo: captureSelection.isVideo,
      source: captureSelection.source,
    );
  }

  Future<void> _pickSocialMediaFromGallery({required bool forReply}) async {
    if (_isPickingSocialMedia) {
      return;
    }
    setState(() {
      _isPickingSocialMedia = true;
    });
    try {
      final XFile? picked = await _socialMediaPicker.pickMedia();
      if (picked == null || !mounted) {
        _restoreSocialChatViewport();
        return;
      }
      final draft = await spotChatAttachmentDraftFromPickedMedia(picked);
      _appendPendingSocialAttachment(forReply: forReply, draft: draft);
    } catch (_) {
      _showSocialSnackBar('No se pudo adjuntar el archivo seleccionado.');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingSocialMedia = false;
        });
        _restoreSocialChatViewport();
      }
    }
  }

  Future<void> _pickSocialAttachment({
    required bool forReply,
    required bool isVideo,
    required ImageSource source,
  }) async {
    if (_isPickingSocialMedia) {
      return;
    }
    setState(() {
      _isPickingSocialMedia = true;
    });
    try {
      final XFile? picked = isVideo
          ? await _socialMediaPicker.pickVideo(source: source)
          : await _socialMediaPicker.pickImage(source: source);
      if (picked == null || !mounted) {
        _restoreSocialChatViewport();
        return;
      }
      final draft = await spotChatAttachmentDraftFromPickedFile(
        picked,
        isVideo: isVideo,
      );
      _appendPendingSocialAttachment(forReply: forReply, draft: draft);
    } catch (_) {
      _showSocialSnackBar('No se pudo adjuntar el archivo seleccionado.');
    } finally {
      if (mounted) {
        setState(() {
          _isPickingSocialMedia = false;
        });
        _restoreSocialChatViewport();
      }
    }
  }

  void _appendPendingSocialAttachment({
    required bool forReply,
    required SpotSocialAttachmentDraft draft,
  }) {
    setState(() {
      if (forReply) {
        _pendingSocialReplyAttachments = appendPendingSpotChatAttachment(
          _pendingSocialReplyAttachments,
          draft,
        );
      } else {
        _pendingSocialPostAttachments = appendPendingSpotChatAttachment(
          _pendingSocialPostAttachments,
          draft,
        );
      }
    });
  }
}
