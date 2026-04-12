class UserProfileData {
  const UserProfileData({
    required this.displayName,
    required this.handle,
    required this.publicTagline,
    required this.totalSessions,
    required this.waterHours,
    required this.jumps,
    required this.topJump,
    required this.maxHangtime,
    this.avatarLocalPath,
    this.bannerLocalPath,
  });

  final String displayName;
  final String handle;
  final String publicTagline;
  final String totalSessions;
  final String waterHours;
  final String jumps;
  final String topJump;
  final String maxHangtime;
  final String? avatarLocalPath;
  final String? bannerLocalPath;

  UserProfileData copyWith({
    String? displayName,
    String? handle,
    String? publicTagline,
    String? totalSessions,
    String? waterHours,
    String? jumps,
    String? topJump,
    String? maxHangtime,
    String? avatarLocalPath,
    String? bannerLocalPath,
  }) {
    return UserProfileData(
      displayName: displayName ?? this.displayName,
      handle: handle ?? this.handle,
      publicTagline: publicTagline ?? this.publicTagline,
      totalSessions: totalSessions ?? this.totalSessions,
      waterHours: waterHours ?? this.waterHours,
      jumps: jumps ?? this.jumps,
      topJump: topJump ?? this.topJump,
      maxHangtime: maxHangtime ?? this.maxHangtime,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      bannerLocalPath: bannerLocalPath ?? this.bannerLocalPath,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'displayName': displayName,
      'handle': handle,
      'publicTagline': publicTagline,
      'totalSessions': totalSessions,
      'waterHours': waterHours,
      'jumps': jumps,
      'topJump': topJump,
      'maxHangtime': maxHangtime,
      'avatarLocalPath': avatarLocalPath,
      'bannerLocalPath': bannerLocalPath,
    };
  }

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      displayName: json['displayName'] as String,
      handle: json['handle'] as String,
      publicTagline: json['publicTagline'] as String? ?? '',
      totalSessions:
          (json['totalSessions'] ?? json['sessions']) as String? ?? '0',
      waterHours: json['waterHours'] as String? ?? '0h',
      jumps: json['jumps'] as String? ?? '0',
      topJump: json['topJump'] as String? ?? '0.0m',
      maxHangtime: json['maxHangtime'] as String? ?? '--',
      avatarLocalPath: json['avatarLocalPath'] as String?,
      bannerLocalPath: json['bannerLocalPath'] as String?,
    );
  }

  factory UserProfileData.initial() {
    return const UserProfileData(
      displayName: 'Rider Kitesurf',
      handle: '@rider_ks',
      publicTagline: 'Perfil publico visible para toda la comunidad.',
      totalSessions: '42',
      waterHours: '126h',
      jumps: '312',
      topJump: '12.5m',
      maxHangtime: '--',
      avatarLocalPath: null,
      bannerLocalPath: null,
    );
  }
}
