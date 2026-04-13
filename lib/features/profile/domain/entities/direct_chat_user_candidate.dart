class DirectChatUserCandidate {
  const DirectChatUserCandidate({
    required this.id,
    required this.displayName,
    required this.handle,
    this.avatarPath,
  });

  final String id;
  final String displayName;
  final String handle;
  final String? avatarPath;
}
