import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_user_candidate.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/direct_message_manager_tile.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/widgets/profile_direct_messages_empty_state.dart';

class ProfileDirectMessagesCard extends StatefulWidget {
  const ProfileDirectMessagesCard({
    super.key,
    required this.threads,
    required this.candidates,
    required this.onOpenChat,
    required this.onStartChatWithCandidate,
    required this.onToggleMute,
    required this.onBlock,
    required this.onDelete,
    required this.formatTimestamp,
  });

  final List<DirectMessageThread> threads;
  final List<DirectChatUserCandidate> candidates;
  final ValueChanged<DirectMessageThread> onOpenChat;
  final Future<void> Function(DirectChatUserCandidate candidate)
  onStartChatWithCandidate;
  final ValueChanged<String> onToggleMute;
  final Future<void> Function(String id, String participant) onBlock;
  final Future<void> Function(String id, String participant) onDelete;
  final String Function(DateTime timestamp) formatTimestamp;

  @override
  State<ProfileDirectMessagesCard> createState() =>
      _ProfileDirectMessagesCardState();
}

class _ProfileDirectMessagesCardState extends State<ProfileDirectMessagesCard> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DirectMessageThread> get _filteredThreads {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.threads;
    }
    final filtered = widget.threads.where((thread) {
      return thread.participant.toLowerCase().contains(query) ||
          thread.preview.toLowerCase().contains(query) ||
          thread.lastLocation.toLowerCase().contains(query);
    }).toList(growable: false);
    filtered.sort((a, b) {
      final aStarts = a.participant.toLowerCase().startsWith(query);
      final bStarts = b.participant.toLowerCase().startsWith(query);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return b.lastActivity.compareTo(a.lastActivity);
    });
    return filtered;
  }

  List<DirectChatUserCandidate> get _filteredCandidates {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return const [];
    }
    final threadNames = widget.threads
        .map((thread) => thread.participant.trim().toLowerCase())
        .toSet();
    final filtered = widget.candidates.where((candidate) {
      final matches = candidate.displayName.toLowerCase().contains(query) ||
          candidate.handle.toLowerCase().contains(query);
      final alreadyVisible = threadNames.contains(
        candidate.displayName.trim().toLowerCase(),
      );
      return matches && !alreadyVisible;
    }).toList(growable: false);
    filtered.sort((a, b) {
      final aStarts = a.displayName.toLowerCase().startsWith(query) ||
          a.handle.toLowerCase().startsWith(query);
      final bStarts = b.displayName.toLowerCase().startsWith(query) ||
          b.handle.toLowerCase().startsWith(query);
      if (aStarts != bStarts) {
        return aStarts ? -1 : 1;
      }
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final filteredThreads = _filteredThreads;
    final filteredCandidates = _filteredCandidates;
    final hasQuery = _query.trim().isNotEmpty;
    final mixedResults = <_DirectSearchItem>[
      ...filteredThreads.map(_DirectSearchItem.thread),
      ...filteredCandidates.map(_DirectSearchItem.candidate),
    ];

    return Card(
      margin: EdgeInsets.zero,
      color: colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          hasQuery ? AppSpacing.xs : AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  isDense: true,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  hintText: 'Buscar',
                  hintStyle: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 14,
                  ),
                  suffixIcon: _query.trim().isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpiar búsqueda',
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                            });
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
              ),
            ),
            SizedBox(height: hasQuery ? AppSpacing.xs : AppSpacing.sm),
            if (!hasQuery && filteredThreads.isEmpty)
              const ProfileDirectMessagesEmptyState()
            else if (hasQuery && mixedResults.isEmpty)
              const _DirectSearchEmptyState()
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(hasQuery ? 16 : 18),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: hasQuery ? mixedResults.length : filteredThreads.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 68,
                    endIndent: AppSpacing.sm,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.22),
                  ),
                  itemBuilder: (context, index) {
                    if (!hasQuery) {
                      return DirectMessageManagerTile(
                        thread: filteredThreads[index],
                        textTheme: textTheme,
                        onOpenChat: widget.onOpenChat,
                        onToggleMute: widget.onToggleMute,
                        onBlock: widget.onBlock,
                        onDelete: widget.onDelete,
                        formatTimestamp: widget.formatTimestamp,
                      );
                    }

                    final item = mixedResults[index];
                    if (item.thread case final thread?) {
                      return DirectMessageManagerTile(
                        thread: thread,
                        textTheme: textTheme,
                        onOpenChat: widget.onOpenChat,
                        onToggleMute: widget.onToggleMute,
                        onBlock: widget.onBlock,
                        onDelete: widget.onDelete,
                        formatTimestamp: widget.formatTimestamp,
                      );
                    }

                    return _DirectChatCandidateRow(
                      candidate: item.candidate!,
                      onTap: () => widget.onStartChatWithCandidate(item.candidate!),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DirectSearchItem {
  const _DirectSearchItem._({this.thread, this.candidate});

  const _DirectSearchItem.thread(DirectMessageThread thread)
    : this._(thread: thread);

  const _DirectSearchItem.candidate(DirectChatUserCandidate candidate)
    : this._(candidate: candidate);

  final DirectMessageThread? thread;
  final DirectChatUserCandidate? candidate;
}

class _DirectChatCandidateRow extends StatelessWidget {
  const _DirectChatCandidateRow({
    required this.candidate,
    required this.onTap,
  });

  final DirectChatUserCandidate candidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final avatarImage = _avatarImageProvider(candidate.avatarPath);
    final initials = candidate.displayName.trim().isEmpty
        ? 'U'
        : candidate.displayName.characters.first.toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 10,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
                backgroundImage: avatarImage,
                child: avatarImage == null
                    ? Text(
                        initials,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      candidate.handle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Nuevo',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider<Object>? _avatarImageProvider(String? path) {
    if (path == null || path.trim().isEmpty) {
      return null;
    }
    final trimmedPath = path.trim();
    final uri = Uri.tryParse(trimmedPath);
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      return NetworkImage(trimmedPath);
    }
    if (!kIsWeb) {
      return FileImage(File(trimmedPath));
    }
    return null;
  }
}

class _DirectSearchEmptyState extends StatelessWidget {
  const _DirectSearchEmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        'Sin resultados.',
        style: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
