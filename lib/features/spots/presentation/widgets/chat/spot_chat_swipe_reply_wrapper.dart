import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:windwisher/core/theme/app_spacing.dart';

class SpotChatSwipeReplyWrapper extends StatefulWidget {
  const SpotChatSwipeReplyWrapper({
    super.key,
    required this.child,
    required this.onReplyTriggered,
    required this.accentColor,
    required this.manageColor,
    this.onManageTriggered,
  });

  final Widget child;
  final VoidCallback onReplyTriggered;
  final Color accentColor;
  final Color manageColor;
  final VoidCallback? onManageTriggered;

  @override
  State<SpotChatSwipeReplyWrapper> createState() =>
      _SpotChatSwipeReplyWrapperState();
}

class _SpotChatSwipeReplyWrapperState extends State<SpotChatSwipeReplyWrapper> {
  static const double _maxReveal = 72;
  static const double _triggerThreshold = 44;

  double _dragOffset = 0;
  _SwipeMessageAction? _triggeredAction;
  _SwipeMessageAction? _crossedThresholdAction;

  @override
  Widget build(BuildContext context) {
    final leftRevealProgress = (-_dragOffset / _maxReveal).clamp(0.0, 1.0);
    final rightRevealProgress = (_dragOffset / _maxReveal).clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragStart: (_) {
        _triggeredAction = null;
        _crossedThresholdAction = null;
      },
      onHorizontalDragUpdate: (details) {
        final minOffset = widget.onManageTriggered == null
            ? -_maxReveal
            : -_maxReveal;
        final maxOffset = widget.onManageTriggered == null ? 0.0 : _maxReveal;
        final nextOffset = (_dragOffset + details.delta.dx).clamp(
          minOffset,
          maxOffset,
        );
        if (nextOffset == _dragOffset) {
          return;
        }
        final crossedThresholdAction = nextOffset <= -_triggerThreshold
            ? _SwipeMessageAction.reply
            : (nextOffset >= _triggerThreshold &&
                  widget.onManageTriggered != null)
            ? _SwipeMessageAction.manage
            : null;
        if (crossedThresholdAction != null &&
            crossedThresholdAction != _crossedThresholdAction) {
          _crossedThresholdAction = crossedThresholdAction;
          HapticFeedback.selectionClick();
        } else if (crossedThresholdAction == null &&
            _crossedThresholdAction != null) {
          _crossedThresholdAction = null;
        }
        setState(() {
          _dragOffset = nextOffset;
        });
      },
      onHorizontalDragEnd: (_) {
        if (_triggeredAction == null && _dragOffset <= -_triggerThreshold) {
          _triggeredAction = _SwipeMessageAction.reply;
          widget.onReplyTriggered();
        } else if (_triggeredAction == null &&
            _dragOffset >= _triggerThreshold &&
            widget.onManageTriggered != null) {
          _triggeredAction = _SwipeMessageAction.manage;
          widget.onManageTriggered!.call();
        }
        setState(() {
          _dragOffset = 0;
        });
        _crossedThresholdAction = null;
      },
      onHorizontalDragCancel: () {
        setState(() {
          _dragOffset = 0;
        });
        _crossedThresholdAction = null;
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.onManageTriggered != null)
            Positioned(
              left: AppSpacing.sm,
              child: Opacity(
                opacity: rightRevealProgress,
                child: Transform.scale(
                  scale: 0.8 + (rightRevealProgress * 0.28),
                  child: Icon(
                    Icons.edit_note_rounded,
                    color: widget.manageColor.withValues(alpha: 0.88),
                  ),
                ),
              ),
            ),
          Positioned(
            right: AppSpacing.sm,
            child: Opacity(
              opacity: leftRevealProgress,
              child: Transform.scale(
                scale: 0.8 + (leftRevealProgress * 0.28),
                child: Icon(
                  Icons.reply_rounded,
                  color: widget.accentColor.withValues(alpha: 0.88),
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(_dragOffset, 0, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

enum _SwipeMessageAction { reply, manage }
