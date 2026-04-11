class UserProfileData {
  const UserProfileData({
    required this.displayName,
    required this.handle,
    required this.publicTagline,
    required this.bio,
    required this.userRole,
    required this.sessions,
    required this.followers,
    required this.following,
    required this.ranking,
    required this.baseSpot,
    required this.totalSessions,
    required this.waterHours,
    required this.jumps,
    required this.topJump,
    required this.maxHangtime,
    required this.bestSpot,
    required this.latestSession,
    required this.latestComment,
    required this.featuredThread,
    this.avatarLocalPath,
    this.bannerLocalPath,
  });

  final String displayName;
  final String handle;
  final String publicTagline;
  final String bio;
  final String userRole;
  final String sessions;
  final String followers;
  final String following;
  final String ranking;
  final String baseSpot;
  final String totalSessions;
  final String waterHours;
  final String jumps;
  final String topJump;
  final String maxHangtime;
  final String bestSpot;
  final String latestSession;
  final String latestComment;
  final String featuredThread;
  final String? avatarLocalPath;
  final String? bannerLocalPath;

  UserProfileData copyWith({
    String? displayName,
    String? handle,
    String? publicTagline,
    String? bio,
    String? userRole,
    String? sessions,
    String? followers,
    String? following,
    String? ranking,
    String? baseSpot,
    String? totalSessions,
    String? waterHours,
    String? jumps,
    String? topJump,
    String? maxHangtime,
    String? bestSpot,
    String? latestSession,
    String? latestComment,
    String? featuredThread,
    String? avatarLocalPath,
    String? bannerLocalPath,
  }) {
    return UserProfileData(
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      publicTagline: publicTagline ?? this.publicTagline,
      bio: bio ?? this.bio,
      userRole: userRole ?? this.userRole,
      sessions: sessions ?? this.sessions,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      ranking: ranking ?? this.ranking,
      baseSpot: baseSpot ?? this.baseSpot,
      totalSessions: totalSessions ?? this.totalSessions,
      waterHours: waterHours ?? this.waterHours,
      jumps: jumps ?? this.jumps,
      topJump: topJump ?? this.topJump,
      maxHangtime: maxHangtime ?? this.maxHangtime,
      bestSpot: bestSpot ?? this.bestSpot,
      latestSession: latestSession ?? this.latestSession,
      latestComment: latestComment ?? this.latestComment,
      featuredThread: featuredThread ?? this.featuredThread,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      bannerLocalPath: bannerLocalPath ?? this.bannerLocalPath,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'displayName': displayName,
      'handle': handle,
      'publicTagline': publicTagline,
      'bio': bio,
      'userRole': userRole,
      'user_role': userRole,
      'level': userRole,
      'sessions': sessions,
      'followers': followers,
      'following': following,
      'ranking': ranking,
      'baseSpot': baseSpot,
      'totalSessions': totalSessions,
      'waterHours': waterHours,
      'jumps': jumps,
      'topJump': topJump,
      'maxHangtime': maxHangtime,
      'bestSpot': bestSpot,
      'latestSession': latestSession,
      'latestComment': latestComment,
      'featuredThread': featuredThread,
      'avatarLocalPath': avatarLocalPath,
      'bannerLocalPath': bannerLocalPath,
    };
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      displayName: json['displayName'] as String,
      handle: json['handle'] as String,
      publicTagline: json['publicTagline'] as String,
      bio: json['bio'] as String,
      userRole:
          (json['userRole'] ?? json['user_role'] ?? json['level']) as String,
      sessions: json['sessions'] as String,
      followers: json['followers'] as String? ?? '0',
      following: json['following'] as String? ?? '0',
      ranking: json['ranking'] as String,
      baseSpot: json['baseSpot'] as String,
      totalSessions: json['totalSessions'] as String,
      waterHours: json['waterHours'] as String,
      jumps: json['jumps'] as String,
      topJump: json['topJump'] as String,
      maxHangtime: json['maxHangtime'] as String? ?? '0.0s',
      bestSpot: json['bestSpot'] as String,
      latestSession: json['latestSession'] as String,
      latestComment: json['latestComment'] as String,
      featuredThread: json['featuredThread'] as String,
      avatarLocalPath: json['avatarLocalPath'] as String?,
      bannerLocalPath: json['bannerLocalPath'] as String?,
    );
  }

  factory UserProfileData.initial() {
    return const UserProfileData(
      displayName: 'Rider Kitesurf',
      handle: '@rider_ks',
      publicTagline: 'Perfil publico visible para toda la comunidad.',
      bio:
          'Rider de costa mediterranea. Enfocado en freeride, seguridad y progresion continua en viento fuerte.',
      userRole: 'Freeride',
      sessions: '42',
      followers: '248',
      following: '132',
      ranking: '#8 Valencia',
      baseSpot: 'Oliva Norte',
      totalSessions: '42',
      waterHours: '126h',
      jumps: '312',
      topJump: '12.5m',
      maxHangtime: '4.8s',
      bestSpot: 'Tarifa',
      latestSession: 'Hoy · Oliva Norte',
      latestComment: 'Hace 3h · Comunidad',
      featuredThread: 'Big Air Seguridad',
      avatarLocalPath: null,
      bannerLocalPath: null,
    );
  }
}
