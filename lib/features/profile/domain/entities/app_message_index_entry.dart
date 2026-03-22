class AppMessageIndexEntry {
  const AppMessageIndexEntry({
    required this.id,
    required this.channel,
    required this.contextLabel,
    required this.message,
    required this.createdAt,
    this.isEdited = false,
  });

  final String id;
  final String channel;
  final String contextLabel;
  final String message;
  final DateTime createdAt;
  final bool isEdited;

  AppMessageIndexEntry copyWith({String? message, bool? isEdited}) {
    return AppMessageIndexEntry(
      id: id,
      channel: channel,
      contextLabel: contextLabel,
      message: message ?? this.message,
      createdAt: createdAt,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
