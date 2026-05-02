import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/spots/domain/entities/spot_social_post.dart';
import 'package:windwisher/features/spots/infrastructure/services/spot_social_client.dart';
import 'package:windwisher/features/spots/presentation/pages/spot_detail/tabs/chat/widgets/spot_chat_attachment_cards.dart';

class PendingSpotSocialAttachmentsList extends StatelessWidget {
  const PendingSpotSocialAttachmentsList({
    super.key,
    required this.attachments,
    required this.onRemove,
  });

  final List<SpotSocialAttachmentDraft> attachments;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: [
          for (var index = 0; index < attachments.length; index += 1)
            PendingSpotSocialAttachmentCard(
              attachment: attachments[index],
              onRemove: () => onRemove(index),
            ),
        ],
      ),
    );
  }
}

class SpotSocialAttachmentsList extends StatelessWidget {
  const SpotSocialAttachmentsList({
    super.key,
    required this.attachments,
    required this.compact,
  });

  final List<SpotSocialAttachment> attachments;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.xs,
        runSpacing: AppSpacing.xs,
        children: attachments
            .map(
              (attachment) => SpotSocialAttachmentCard(
                attachment: attachment,
                compact: compact,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}
