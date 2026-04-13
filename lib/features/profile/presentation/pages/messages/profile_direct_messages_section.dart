import 'package:flutter/material.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_user_candidate.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/profile_direct_messages_card.dart';

class ProfileDirectMessagesSection extends StatelessWidget {
  const ProfileDirectMessagesSection({
    super.key,
    required this.directMessageThreads,
    required this.onOpenChat,
    required this.onToggleMute,
    required this.onBlock,
    required this.onDelete,
    required this.directChatUserCandidates,
    required this.onStartChatWithCandidate,
    required this.formatTimestamp,
  });

  final List<DirectMessageThread> directMessageThreads;
  final ValueChanged<DirectMessageThread> onOpenChat;
  final List<DirectChatUserCandidate> directChatUserCandidates;
  final ValueChanged<String> onToggleMute;
  final Future<void> Function(String id, String participant) onBlock;
  final Future<void> Function(String id, String participant) onDelete;
  final Future<void> Function(DirectChatUserCandidate candidate) onStartChatWithCandidate;
  final String Function(DateTime timestamp) formatTimestamp;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('mensajes'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileDirectMessagesCard(
          threads: directMessageThreads,
          onOpenChat: onOpenChat,
          candidates: directChatUserCandidates,
          onToggleMute: onToggleMute,
          onBlock: onBlock,
          onDelete: onDelete,
          onStartChatWithCandidate: onStartChatWithCandidate,
          formatTimestamp: formatTimestamp,
        ),
      ],
    );
  }
}
