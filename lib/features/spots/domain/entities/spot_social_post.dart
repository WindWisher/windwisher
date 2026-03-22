class SpotSocialPost {
  SpotSocialPost({
    required this.id,
    required this.spotName,
    required this.spotArea,
    required this.authorUsername,
    required this.authorDisplayName,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.isMine,
    List<SpotSocialReply>? replies,
  }) : replies = List<SpotSocialReply>.from(replies ?? const []);

  final String id;
  final String spotName;
  final String spotArea;
  final String authorUsername;
  final String authorDisplayName;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isMine;
  final List<SpotSocialReply> replies;

  SpotSocialPost copyWith({
    String? message,
    DateTime? updatedAt,
    bool? isMine,
    List<SpotSocialReply>? replies,
  }) {
    return SpotSocialPost(
      id: id,
      spotName: spotName,
      spotArea: spotArea,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      message: message ?? this.message,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isMine: isMine ?? this.isMine,
      replies: replies ?? this.replies,
    );
  }
}

class SpotSocialReply {
  SpotSocialReply({
    required this.id,
    required this.postId,
    required this.authorUsername,
    required this.authorDisplayName,
    required this.message,
    required this.createdAt,
    required this.isMine,
    this.parentReplyId,
    List<SpotSocialReply>? replies,
  }) : replies = List<SpotSocialReply>.from(replies ?? const []);

  final String id;
  final String postId;
  final String? parentReplyId;
  final String authorUsername;
  final String authorDisplayName;
  final String message;
  final DateTime createdAt;
  final bool isMine;
  final List<SpotSocialReply> replies;

  SpotSocialReply copyWith({
    String? message,
    String? parentReplyId,
    bool? isMine,
    List<SpotSocialReply>? replies,
  }) {
    return SpotSocialReply(
      id: id,
      postId: postId,
      parentReplyId: parentReplyId ?? this.parentReplyId,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      message: message ?? this.message,
      createdAt: createdAt,
      isMine: isMine ?? this.isMine,
      replies: replies ?? this.replies,
    );
  }
}
