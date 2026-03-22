import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/ports/out/community_following_feed_port.dart';

class InMemoryCommunityFollowingFeedAdapter
    implements CommunityFollowingFeedPort {
  final List<FollowingSession> _sessions = [
    FollowingSession(
      id: 'sess-air-lucas-20260223-1840',
      username: 'air_lucas',
      title: 'Sesion sunset en Tarifa',
      spot: 'Tarifa',
      dateLabel: '23/02 18:40',
      endedAt: DateTime(2026, 2, 23, 18, 40),
      bigAirScore: 987,
      highestJumpMeters: 22.4,
      distanceKm: 34.7,
      durationLabel: '01:12:00',
      equipmentLabel: 'Core XR8 + Jaime SLS (fase 2)',
      likesCount: 184,
      hasSessionPhoto: true,
    ),
    FollowingSession(
      id: 'sess-mara-bigair-20260223-1620',
      username: 'mara_bigair',
      title: 'Training Big Air',
      spot: 'Fuerteventura',
      dateLabel: '23/02 16:20',
      endedAt: DateTime(2026, 2, 23, 16, 20),
      bigAirScore: 972,
      highestJumpMeters: 21.7,
      distanceKm: 29.4,
      durationLabel: '00:58:00',
      equipmentLabel: 'Dice + Atmos (fase 2)',
      likesCount: 132,
      hasSessionPhoto: false,
    ),
    FollowingSession(
      id: 'sess-nico-loop-20260222-1405',
      username: 'nico_loop',
      title: 'Viento racheado pero bueno',
      spot: 'Tarifa',
      dateLabel: '22/02 14:05',
      endedAt: DateTime(2026, 2, 22, 14, 5),
      bigAirScore: 948,
      highestJumpMeters: 20.9,
      distanceKm: 41.2,
      durationLabel: '01:26:00',
      equipmentLabel: 'Orbit + Spectrum (fase 2)',
      likesCount: 96,
      hasSessionPhoto: false,
    ),
  ];

  @override
  List<FollowingSession> getFollowingSessions() {
    return List<FollowingSession>.unmodifiable(_sessions);
  }

  @override
  Future<List<FollowingSession>> loadFollowingSessions() async {
    return getFollowingSessions();
  }
}
