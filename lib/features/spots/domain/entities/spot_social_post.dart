enum SpotSocialAttachmentType { image, video }

class SpotSocialAttachment {
  SpotSocialAttachment({
    required this.id,
    required this.type,
    required this.url,
    required this.storagePath,
    required this.fileName,
    this.mimeType,
    this.sizeBytes,
    this.thumbnailUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final SpotSocialAttachmentType type;
  final String url;
  final String storagePath;
  final String fileName;
  final String? mimeType;
  final int? sizeBytes;
  final String? thumbnailUrl;
  final DateTime createdAt;

  SpotSocialAttachment copyWith({
    SpotSocialAttachmentType? type,
    String? url,
    String? storagePath,
    String? fileName,
    String? mimeType,
    int? sizeBytes,
    String? thumbnailUrl,
    DateTime? createdAt,
  }) {
    return SpotSocialAttachment(
      id: id,
      type: type ?? this.type,
      url: url ?? this.url,
      storagePath: storagePath ?? this.storagePath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

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
    List<SpotSocialAttachment>? attachments,
    List<SpotSocialReply>? replies,
    this.authorAvatarPath,
  }) : attachments = List<SpotSocialAttachment>.from(attachments ?? const []),
       replies = List<SpotSocialReply>.from(replies ?? const []);

  final String id;
  final String spotName;
  final String spotArea;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarPath;
  final String message;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isMine;
  final List<SpotSocialAttachment> attachments;
  final List<SpotSocialReply> replies;

  SpotSocialPost copyWith({
    String? message,
    DateTime? updatedAt,
    bool? isMine,
    List<SpotSocialAttachment>? attachments,
    List<SpotSocialReply>? replies,
    String? authorAvatarPath,
  }) {
    return SpotSocialPost(
      id: id,
      spotName: spotName,
      spotArea: spotArea,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      authorAvatarPath: authorAvatarPath ?? this.authorAvatarPath,
      message: message ?? this.message,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isMine: isMine ?? this.isMine,
      attachments: attachments ?? this.attachments,
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
    List<SpotSocialAttachment>? attachments,
    List<SpotSocialReply>? replies,
    this.authorAvatarPath,
  }) : attachments = List<SpotSocialAttachment>.from(attachments ?? const []),
       replies = List<SpotSocialReply>.from(replies ?? const []);

  final String id;
  final String postId;
  final String? parentReplyId;
  final String authorUsername;
  final String authorDisplayName;
  final String? authorAvatarPath;
  final String message;
  final DateTime createdAt;
  final bool isMine;
  final List<SpotSocialAttachment> attachments;
  final List<SpotSocialReply> replies;

  SpotSocialReply copyWith({
    String? message,
    String? parentReplyId,
    bool? isMine,
    List<SpotSocialAttachment>? attachments,
    List<SpotSocialReply>? replies,
    String? authorAvatarPath,
  }) {
    return SpotSocialReply(
      id: id,
      postId: postId,
      parentReplyId: parentReplyId ?? this.parentReplyId,
      authorUsername: authorUsername,
      authorDisplayName: authorDisplayName,
      authorAvatarPath: authorAvatarPath ?? this.authorAvatarPath,
      message: message ?? this.message,
      createdAt: createdAt,
      isMine: isMine ?? this.isMine,
      attachments: attachments ?? this.attachments,
      replies: replies ?? this.replies,
    );
  }
}
