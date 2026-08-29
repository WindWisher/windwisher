import 'dart:async';

import 'package:windwisher/features/spots/application/services/spot_social_service.dart';

class SpotChatRealtimeController {
  SpotChatRealtimeController({
    required SpotSocialService client,
    required String spotName,
    required String spotArea,
    required Future<void> Function() onFeedChanged,
    required void Function(int count) onPresenceChanged,
    required void Function(Set<String> typingUsers) onTypingChanged,
    required String Function() displayName,
  }) : _client = client,
       _spotName = spotName,
       _spotArea = spotArea,
       _onFeedChanged = onFeedChanged,
       _onPresenceChanged = onPresenceChanged,
       _onTypingChanged = onTypingChanged,
       _displayName = displayName;

  final SpotSocialService _client;
  final String _spotName;
  final String _spotArea;
  final Future<void> Function() _onFeedChanged;
  final void Function(int count) _onPresenceChanged;
  final void Function(Set<String> typingUsers) _onTypingChanged;
  final String Function() _displayName;

  StreamSubscription<void>? _feedSubscription;
  StreamSubscription<int>? _presenceSubscription;
  StreamSubscription<Set<String>>? _typingSubscription;
  Timer? _feedRefreshDebounce;
  Timer? _typingDebounce;
  bool _isSendingTypingState = false;

  bool get isBound => _feedSubscription != null;

  void bindAll() {
    bindFeed();
    bindPresence();
    bindTyping();
  }

  void bindFeed() {
    _feedSubscription?.cancel();
    _feedSubscription = _client
        .watchSpotFeed(spotName: _spotName, spotArea: _spotArea)
        .listen((_) {
          _feedRefreshDebounce?.cancel();
          _feedRefreshDebounce = Timer(const Duration(milliseconds: 280), () {
            unawaited(_onFeedChanged());
          });
        });
  }

  void bindPresence() {
    _presenceSubscription?.cancel();
    _presenceSubscription = _client
        .watchSpotPresence(spotName: _spotName, spotArea: _spotArea)
        .listen(_onPresenceChanged);
  }

  void bindTyping() {
    _typingSubscription?.cancel();
    _typingSubscription = _client
        .watchSpotTyping(spotName: _spotName, spotArea: _spotArea)
        .listen(_onTypingChanged);
  }

  void unbindAll() {
    unbindFeed();
    unbindPresence();
    unbindTyping();
  }

  void unbindFeed() {
    _feedRefreshDebounce?.cancel();
    _feedRefreshDebounce = null;
    _feedSubscription?.cancel();
    _feedSubscription = null;
  }

  void unbindPresence() {
    _presenceSubscription?.cancel();
    _presenceSubscription = null;
  }

  void unbindTyping() {
    _typingDebounce?.cancel();
    _typingDebounce = null;
    _typingSubscription?.cancel();
    _typingSubscription = null;
    _isSendingTypingState = false;
  }

  void handleComposerChanged(String value) {
    final hasText = value.trim().isNotEmpty;
    _typingDebounce?.cancel();
    if (hasText) {
      unawaited(sendTypingState(isTyping: true));
      _typingDebounce = Timer(const Duration(milliseconds: 1400), () {
        unawaited(sendTypingState(isTyping: false));
      });
    } else {
      unawaited(sendTypingState(isTyping: false));
    }
  }

  Future<void> sendTypingState({required bool isTyping}) async {
    if (_isSendingTypingState == isTyping) {
      return;
    }
    _isSendingTypingState = isTyping;
    await _client.sendTypingState(
      spotName: _spotName,
      spotArea: _spotArea,
      displayName: _displayName(),
      isTyping: isTyping,
    );
  }

  void dispose() {
    unbindAll();
  }
}
