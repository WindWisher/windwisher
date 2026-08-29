import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/notifications/push_notification_subscription_service.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/notifications/local_notifications_service.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/community/di/community_module.dart';
import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/entities/session_comment.dart';
import 'package:windwisher/features/community/domain/entities/session_like_state.dart';
import 'package:windwisher/features/profile/domain/entities/direct_chat_user_candidate.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/application/profile_community_stats_aggregator.dart';
import 'package:windwisher/features/profile/application/profile_kpi_aggregator.dart';
import 'package:windwisher/features/profile/application/profile_session_stats_aggregator.dart';
import 'package:windwisher/features/profile/domain/entities/profile_community_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/profile_session_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/domain/errors/profile_handle_taken_exception.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/presentation/pages/alarms/profile_alarms_section.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/profile_gear_section.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/widgets/profile_gear_section_data.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/management/profile_gear_management_builder.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/dialogs/profile_gear_dialogs_coordinator.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/dialogs/profile_gear_dialogs_dependencies.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/gear/management/profile_gear_actions_handler.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/direct_chat_dialog.dart';
import 'package:windwisher/features/profile/presentation/pages/messages/profile_direct_messages_section.dart';
import 'package:windwisher/features/profile/presentation/pages/profile/user/widgets/profile_overview_section.dart';
import 'package:windwisher/features/profile/presentation/state/profile_controller.dart';
import 'package:windwisher/features/profile/presentation/state/profile_gear_controller.dart';
import 'package:windwisher/features/profile/presentation/state/profile_gear_setup_catalog.dart';
import 'package:windwisher/features/profile/presentation/state/profile_messages_controller.dart';
import 'package:windwisher/features/sessions/di/sessions_module.dart';
import 'package:windwisher/features/sessions/domain/entities/recorded_session.dart';
import 'package:windwisher/features/sessions/presentation/models/session_detail_models.dart';

typedef _KiteItem = KiteItem;
typedef _BarItem = BarItem;
typedef _BoardItem = BoardItem;
typedef _HarnessItem = HarnessItem;
typedef _WetsuitItem = WetsuitItem;
typedef _HelmetItem = HelmetItem;
typedef _VestItem = VestItem;
typedef _CommunityUser = CommunityUserSummary;
typedef _FollowingSession = FollowingSession;
typedef _GearSetup = GearSetup;
typedef _UserProfileData = UserProfileData;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  late final ProfileController _profileController;
  late final ProfileMessagesController _messagesController;
  late final ProfileGearController _gearController;
  late final SessionsModule _sessionsModule;
  late final CommunityModule _communityModule;
  List<RecordedSession> _recordedSessions = const <RecordedSession>[];
  List<_CommunityUser> _communityUsers = const <_CommunityUser>[];
  List<_FollowingSession> _communitySessions = const <_FollowingSession>[];
  Set<String> _followingUsernames = const <String>{};
  List<String>? _followerUsernames;
  Map<String, List<SessionComment>> _sessionCommentsBySessionId =
      const <String, List<SessionComment>>{};
  Map<String, SessionLikeState> _sessionLikeStatesBySessionId =
      const <String, SessionLikeState>{};

  static const List<String> _tabs = ['Perfil', 'Alarmas', 'Mensajes'];
  static const List<String> _profileSections = ['Usuario', 'Equipo'];
  int _selectedTabIndex = 0;
  int _selectedProfileSectionIndex = 0;
  Timer? _messagesAutoRefreshTimer;
  StreamSubscription<void>? _messagesRealtimeSubscription;
  String? _activeDirectChatThreadId;
  bool _hasHydratedMessagesOnce = false;

  final TextEditingController _messageSearchController =
      TextEditingController();
  final TextEditingController _gearSetupNameController =
      TextEditingController();
  final TextEditingController _kiteBrandController = TextEditingController();
  final TextEditingController _kiteModelController = TextEditingController();
  final TextEditingController _kiteSizeController = TextEditingController(
    text: '12',
  );
  final TextEditingController _kiteYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _kitePriceController = TextEditingController();
  final TextEditingController _barBrandController = TextEditingController();
  final TextEditingController _barModelController = TextEditingController();
  final TextEditingController _barLineLengthController = TextEditingController(
    text: '22',
  );
  final TextEditingController _barWidthController = TextEditingController(
    text: '50',
  );
  final TextEditingController _barYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _barPriceController = TextEditingController();
  final TextEditingController _boardBrandController = TextEditingController();
  final TextEditingController _boardModelController = TextEditingController();
  final TextEditingController _boardSizeController = TextEditingController();
  final TextEditingController _boardYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _boardPriceController = TextEditingController();
  final TextEditingController _harnessBrandController = TextEditingController();
  final TextEditingController _harnessModelController = TextEditingController();
  final TextEditingController _harnessSizeController = TextEditingController(
    text: 'M',
  );
  final TextEditingController _harnessYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _harnessPriceController = TextEditingController();
  final TextEditingController _wetsuitBrandController = TextEditingController();
  final TextEditingController _wetsuitModelController = TextEditingController();
  final TextEditingController _wetsuitThicknessController =
      TextEditingController(text: '4/3');
  final TextEditingController _wetsuitSizeController = TextEditingController(
    text: 'M',
  );
  final TextEditingController _wetsuitYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _wetsuitPriceController = TextEditingController();
  final TextEditingController _helmetBrandController = TextEditingController();
  final TextEditingController _helmetModelController = TextEditingController();
  final TextEditingController _helmetYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _helmetPriceController = TextEditingController();
  final TextEditingController _vestBrandController = TextEditingController();
  final TextEditingController _vestModelController = TextEditingController();
  final TextEditingController _vestSizeController = TextEditingController(
    text: 'M',
  );
  final TextEditingController _vestYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _vestPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final module = EnvConfig.profileLocalPersistenceEnabled
        ? ProfileModule.auto()
        : ProfileModule.inMemory();
    _profileController = module.profileController;
    _messagesController = module.messagesController;
    _gearController = module.gearController;
    _sessionsModule = SessionsModule.auto(
      encodeInsights: _encodeRecordedSessionInsights,
      decodeInsights: _decodeRecordedSessionInsights,
    );
    _communityModule = EnvConfig.communityLocalPersistenceEnabled
        ? CommunityModule.auto()
        : CommunityModule.inMemory();
    _publishGearSetupsForSessions();
    _hydrateProfile();
    _hydrateMessages();
    _hydrateGear();
    _hydrateRecordedSessions();
    _hydrateCommunityStats();
    _startMessagesRealtime();
    _startMessagesAutoRefresh();
  }

  Future<void> _hydrateProfile() async {
    await _profileController.loadProfile();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _hydrateMessages() async {
    await _messagesController.hydrate();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _startMessagesRealtime() {
    _messagesRealtimeSubscription?.cancel();
    _messagesRealtimeSubscription = _messagesController
        .watchDirectThreads()
        .listen((_) {
          if (!mounted) {
            return;
          }
          unawaited(_refreshMessagesSilently());
        });
  }

  void _startMessagesAutoRefresh() {
    _messagesAutoRefreshTimer?.cancel();
    _messagesAutoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (
      _,
    ) {
      if (!mounted || _selectedTabIndex != 2) {
        return;
      }
      unawaited(_refreshMessagesSilently());
    });
  }

  Future<void> _refreshMessagesSilently() async {
    final previousThreads = List<DirectMessageThread>.from(
      _directMessageThreads,
    );
    await _messagesController.hydrate();
    if (!mounted) {
      return;
    }
    if (_hasHydratedMessagesOnce) {
      unawaited(_notifyForegroundDirectMessagesIfNeeded(previousThreads));
    } else {
      _hasHydratedMessagesOnce = true;
    }
    setState(() {});
  }

  Future<void> _notifyForegroundDirectMessagesIfNeeded(
    List<DirectMessageThread> previousThreads,
  ) async {
    await PushNotificationSubscriptionService.instance.initialize();
    if (!PushNotificationSubscriptionService.instance.enabled ||
        !PushNotificationSubscriptionService.instance.directMessagesEnabled) {
      return;
    }
    if (_selectedTabIndex == 2 && _activeDirectChatThreadId != null) {
      return;
    }
    final previousById = <String, DirectMessageThread>{
      for (final thread in previousThreads) thread.id: thread,
    };
    for (final thread in _directMessageThreads) {
      if (thread.id == _activeDirectChatThreadId) {
        continue;
      }
      final previous = previousById[thread.id];
      final previousUnread = previous?.unreadCount ?? 0;
      if (thread.unreadCount <= previousUnread) {
        continue;
      }
      await LocalNotificationsService.instance.showDirectMessage(
        threadId: thread.id,
        messageId:
            'foreground-${thread.id}-${thread.lastActivity.millisecondsSinceEpoch}',
        senderName: thread.participant,
        body: thread.preview,
      );
    }
  }

  Future<void> _hydrateGear() async {
    await _gearController.hydrate();
    if (!mounted) {
      return;
    }
    _publishGearSetupsForSessions();
    setState(() {});
  }

  Future<void> _hydrateRecordedSessions() async {
    final sessions = await _sessionsModule.getRecordedSessions.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _recordedSessions = sessions;
    });
  }

  Future<void> _hydrateCommunityStats() async {
    try {
      final users = await _communityModule.getCommunityUsers.load();
      final sessions = await _communityModule.getFollowingSessions.load();
      final followingUsernames =
          await _communityModule.getFollowingUsernames.load() ??
          const <String>{};
      final client = Supabase.instance.client;
      final currentUser = client.auth.currentUser;

      List<String>? followerUsernames;
      if (currentUser != null) {
        final followerRows = await client
            .from('user_follows')
            .select('follower_user_id')
            .eq('followed_user_id', currentUser.id);
        final followerIds = (followerRows as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map((row) => row['follower_user_id'] as String?)
            .whereType<String>()
            .toList(growable: false);
        if (followerIds.isEmpty) {
          followerUsernames = const <String>[];
        } else {
          final profileRows = await client
              .from('public_profiles')
              .select('id, handle')
              .inFilter('id', followerIds);
          followerUsernames = (profileRows as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map((row) => (row['handle'] as String? ?? '').trim())
              .where((handle) => handle.isNotEmpty)
              .toList(growable: false);
        }
      }

      final commentsEntries = await Future.wait(
        sessions.map((session) async {
          final comments = await _communityModule.getSessionComments.load(
            sessionId: session.id,
          );
          return MapEntry(session.id, comments);
        }),
      );
      final likeEntries = await Future.wait(
        sessions.map((session) async {
          final likeState = await _communityModule.getSessionLikeState.load(
            sessionId: session.id,
            username: _normalizedUsername(_profileData.handle),
          );
          return MapEntry(session.id, likeState);
        }),
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _communityUsers = users;
        _communitySessions = sessions;
        _followingUsernames = followingUsernames;
        _followerUsernames = followerUsernames;
        _sessionCommentsBySessionId =
            Map<String, List<SessionComment>>.fromEntries(commentsEntries);
        _sessionLikeStatesBySessionId =
            Map<String, SessionLikeState>.fromEntries(likeEntries);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _communityUsers = const <_CommunityUser>[];
        _communitySessions = const <_FollowingSession>[];
        _followingUsernames = const <String>{};
        _followerUsernames = const <String>[];
        _sessionCommentsBySessionId = const <String, List<SessionComment>>{};
        _sessionLikeStatesBySessionId = const <String, SessionLikeState>{};
      });
    }
  }

  String _normalizedUsername(String handle) {
    final cleaned = handle.replaceFirst('@', '').trim();
    return cleaned.isEmpty ? 'you_rider' : cleaned.toLowerCase();
  }

  Object? _encodeRecordedSessionInsights(Object value) {
    if (value is SessionInsightData) {
      return value.toJson();
    }
    return value;
  }

  Object _decodeRecordedSessionInsights(Object? value) {
    if (value is Map<String, dynamic>) {
      return SessionInsightData.fromJson(value);
    }
    return value ?? SessionInsightData.empty(deviceKind: 'Dispositivo Android');
  }

  _UserProfileData get _profileData => _profileController.profile;

  ProfileSessionStatsSnapshot get _profileSessionStats =>
      ProfileSessionStatsAggregator.build(_recordedSessions);

  ProfileCommunityStatsSnapshot get _profileCommunityStats =>
      ProfileCommunityStatsAggregator.build(
        profile: _profileData,
        communityUsers: _communityUsers,
        followingUsernames: _followingUsernames,
        followerUsernames: _followerUsernames,
        visibleSessions: _communitySessions,
        commentsBySessionId: _sessionCommentsBySessionId,
        likeStatesBySessionId: _sessionLikeStatesBySessionId,
      );

  ProfileKpiSnapshot get _profileKpis =>
      ProfileKpiAggregator.build(_profileSessionStats, _profileCommunityStats);

  void _publishGearSetupsForSessions() {
    ProfileGearSetupCatalog.instance.replaceAll(
      _savedGearSetups
          .map(
            (setup) => ProfileGearSetupOption(id: setup.id, name: setup.name),
          )
          .toList(growable: false),
    );
  }

  List<_KiteItem> get _savedKites => _gearController.savedKites;

  List<_BarItem> get _savedBars => _gearController.savedBars;

  List<_BoardItem> get _savedBoards => _gearController.savedBoards;

  List<_HarnessItem> get _savedHarnesses => _gearController.savedHarnesses;

  List<_WetsuitItem> get _savedWetsuits => _gearController.savedWetsuits;

  List<_HelmetItem> get _savedHelmets => _gearController.savedHelmets;

  List<_VestItem> get _savedVests => _gearController.savedVests;

  List<_GearSetup> get _savedGearSetups => _gearController.savedGearSetups;

  String get _selectedBoardType => _gearController.selectedBoardType;

  set _selectedBoardType(String value) {
    _gearController.selectedBoardType = value;
  }

  int get _selectedGearConfigTabIndex =>
      _gearController.selectedGearConfigTabIndex;

  set _selectedGearConfigTabIndex(int value) {
    _gearController.selectedGearConfigTabIndex = value;
  }

  String? get _selectedKiteManageId => _gearController.selectedKiteManageId;

  set _selectedKiteManageId(String? value) {
    _gearController.selectedKiteManageId = value;
  }

  String? get _selectedBarManageId => _gearController.selectedBarManageId;

  set _selectedBarManageId(String? value) {
    _gearController.selectedBarManageId = value;
  }

  String? get _selectedBoardManageId => _gearController.selectedBoardManageId;

  set _selectedBoardManageId(String? value) {
    _gearController.selectedBoardManageId = value;
  }

  String? get _selectedHarnessManageId =>
      _gearController.selectedHarnessManageId;

  set _selectedHarnessManageId(String? value) {
    _gearController.selectedHarnessManageId = value;
  }

  String? get _selectedWetsuitManageId =>
      _gearController.selectedWetsuitManageId;

  set _selectedWetsuitManageId(String? value) {
    _gearController.selectedWetsuitManageId = value;
  }

  String? get _selectedHelmetManageId => _gearController.selectedHelmetManageId;

  set _selectedHelmetManageId(String? value) {
    _gearController.selectedHelmetManageId = value;
  }

  String? get _selectedVestManageId => _gearController.selectedVestManageId;

  set _selectedVestManageId(String? value) {
    _gearController.selectedVestManageId = value;
  }

  String? get _selectedKiteForSetupId => _gearController.selectedKiteForSetupId;

  set _selectedKiteForSetupId(String? value) {
    _gearController.selectedKiteForSetupId = value;
  }

  String? get _selectedBarForSetupId => _gearController.selectedBarForSetupId;

  set _selectedBarForSetupId(String? value) {
    _gearController.selectedBarForSetupId = value;
  }

  String? get _selectedBoardForSetupId =>
      _gearController.selectedBoardForSetupId;

  set _selectedBoardForSetupId(String? value) {
    _gearController.selectedBoardForSetupId = value;
  }

  String? get _selectedHarnessForSetupId =>
      _gearController.selectedHarnessForSetupId;

  set _selectedHarnessForSetupId(String? value) {
    _gearController.selectedHarnessForSetupId = value;
  }

  String? get _selectedWetsuitForSetupId =>
      _gearController.selectedWetsuitForSetupId;

  set _selectedWetsuitForSetupId(String? value) {
    _gearController.selectedWetsuitForSetupId = value;
  }

  String? get _selectedHelmetForSetupId =>
      _gearController.selectedHelmetForSetupId;

  set _selectedHelmetForSetupId(String? value) {
    _gearController.selectedHelmetForSetupId = value;
  }

  String? get _selectedVestForSetupId => _gearController.selectedVestForSetupId;

  set _selectedVestForSetupId(String? value) {
    _gearController.selectedVestForSetupId = value;
  }

  ProfileGearActionsHandler get _gearActions {
    return ProfileGearActionsHandler(
      context: context,
      mutateState: _mutateState,
      gearController: _gearController,
      publishGearSetupsForSessions: _publishGearSetupsForSessions,
      gearSetupNameController: _gearSetupNameController,
      kiteBrandController: _kiteBrandController,
      kiteModelController: _kiteModelController,
      kiteSizeController: _kiteSizeController,
      kiteYearController: _kiteYearController,
      kitePriceController: _kitePriceController,
      barBrandController: _barBrandController,
      barModelController: _barModelController,
      barLineLengthController: _barLineLengthController,
      barWidthController: _barWidthController,
      barYearController: _barYearController,
      barPriceController: _barPriceController,
      boardBrandController: _boardBrandController,
      boardModelController: _boardModelController,
      boardSizeController: _boardSizeController,
      boardYearController: _boardYearController,
      boardPriceController: _boardPriceController,
      harnessBrandController: _harnessBrandController,
      harnessModelController: _harnessModelController,
      harnessSizeController: _harnessSizeController,
      harnessYearController: _harnessYearController,
      harnessPriceController: _harnessPriceController,
      wetsuitBrandController: _wetsuitBrandController,
      wetsuitModelController: _wetsuitModelController,
      wetsuitThicknessController: _wetsuitThicknessController,
      wetsuitSizeController: _wetsuitSizeController,
      wetsuitYearController: _wetsuitYearController,
      wetsuitPriceController: _wetsuitPriceController,
      helmetBrandController: _helmetBrandController,
      helmetModelController: _helmetModelController,
      helmetYearController: _helmetYearController,
      helmetPriceController: _helmetPriceController,
      vestBrandController: _vestBrandController,
      vestModelController: _vestModelController,
      vestSizeController: _vestSizeController,
      vestYearController: _vestYearController,
      vestPriceController: _vestPriceController,
      selectedBoardType: () => _selectedBoardType,
      setSelectedBoardType: (value) => _selectedBoardType = value,
      selectedKiteForSetupId: () => _selectedKiteForSetupId,
      selectedBarForSetupId: () => _selectedBarForSetupId,
      selectedBoardForSetupId: () => _selectedBoardForSetupId,
      selectedHarnessForSetupId: () => _selectedHarnessForSetupId,
      selectedWetsuitForSetupId: () => _selectedWetsuitForSetupId,
      selectedHelmetForSetupId: () => _selectedHelmetForSetupId,
      selectedVestForSetupId: () => _selectedVestForSetupId,
    );
  }

  bool get _canSaveGearSetup => _gearActions.canSaveGearSetup;

  void _saveKite({String? editingId}) =>
      _gearActions.saveKite(editingId: editingId);

  void _saveBar({String? editingId}) =>
      _gearActions.saveBar(editingId: editingId);

  void _saveBoard({String? editingId}) =>
      _gearActions.saveBoard(editingId: editingId);

  void _saveHarness({String? editingId}) =>
      _gearActions.saveHarness(editingId: editingId);

  void _saveWetsuit({String? editingId}) =>
      _gearActions.saveWetsuit(editingId: editingId);

  void _saveHelmet({String? editingId}) =>
      _gearActions.saveHelmet(editingId: editingId);

  void _saveVest({String? editingId}) =>
      _gearActions.saveVest(editingId: editingId);

  void _saveGearSetup({String? editingId}) =>
      _gearActions.saveGearSetup(editingId: editingId);

  void _deleteKite(String kiteId) => _gearActions.deleteKite(kiteId);

  void _deleteBar(String barId) => _gearActions.deleteBar(barId);

  void _deleteBoard(String boardId) => _gearActions.deleteBoard(boardId);

  void _deleteHarness(String harnessId) =>
      _gearActions.deleteHarness(harnessId);

  void _deleteWetsuit(String wetsuitId) =>
      _gearActions.deleteWetsuit(wetsuitId);

  void _deleteHelmet(String helmetId) => _gearActions.deleteHelmet(helmetId);

  void _deleteVest(String vestId) => _gearActions.deleteVest(vestId);

  void _deleteGearSetup(String setupId) =>
      _gearActions.deleteGearSetup(setupId);

  _KiteItem? _findKite(String id) => _gearController.findKite(id);

  _BarItem? _findBar(String id) => _gearController.findBar(id);

  _BoardItem? _findBoard(String id) => _gearController.findBoard(id);

  _HarnessItem? _findHarness(String id) => _gearController.findHarness(id);

  _WetsuitItem? _findWetsuit(String id) => _gearController.findWetsuit(id);

  _HelmetItem? _findHelmet(String id) => _gearController.findHelmet(id);

  _VestItem? _findVest(String id) => _gearController.findVest(id);

  ProfileGearManagementBuilder get _gearManagement {
    return ProfileGearManagementBuilder(
      mutateState: _mutateState,
      savedKites: () => _savedKites,
      savedBars: () => _savedBars,
      savedBoards: () => _savedBoards,
      savedHarnesses: () => _savedHarnesses,
      savedWetsuits: () => _savedWetsuits,
      savedHelmets: () => _savedHelmets,
      savedVests: () => _savedVests,
      selectedKiteManageId: () => _selectedKiteManageId,
      setSelectedKiteManageId: (value) => _selectedKiteManageId = value,
      selectedBarManageId: () => _selectedBarManageId,
      setSelectedBarManageId: (value) => _selectedBarManageId = value,
      selectedBoardManageId: () => _selectedBoardManageId,
      setSelectedBoardManageId: (value) => _selectedBoardManageId = value,
      selectedHarnessManageId: () => _selectedHarnessManageId,
      setSelectedHarnessManageId: (value) => _selectedHarnessManageId = value,
      selectedWetsuitManageId: () => _selectedWetsuitManageId,
      setSelectedWetsuitManageId: (value) => _selectedWetsuitManageId = value,
      selectedHelmetManageId: () => _selectedHelmetManageId,
      setSelectedHelmetManageId: (value) => _selectedHelmetManageId = value,
      selectedVestManageId: () => _selectedVestManageId,
      setSelectedVestManageId: (value) => _selectedVestManageId = value,
      findKite: _findKite,
      findBar: _findBar,
      findBoard: _findBoard,
      findHarness: _findHarness,
      findWetsuit: _findWetsuit,
      findHelmet: _findHelmet,
      findVest: _findVest,
      openKiteDialog: _openKiteDialog,
      openBarDialog: _openBarDialog,
      openBoardDialog: _openBoardDialog,
      openHarnessDialog: _openHarnessDialog,
      openWetsuitDialog: _openWetsuitDialog,
      openHelmetDialog: _openHelmetDialog,
      openVestDialog: _openVestDialog,
      deleteKite: _deleteKite,
      deleteBar: _deleteBar,
      deleteBoard: _deleteBoard,
      deleteHarness: _deleteHarness,
      deleteWetsuit: _deleteWetsuit,
      deleteHelmet: _deleteHelmet,
      deleteVest: _deleteVest,
      confirmDeleteItem: _confirmDeleteItem,
    );
  }

  Widget _buildKiteManagement() => _gearManagement.buildKiteManagement();

  Widget _buildBarManagement() => _gearManagement.buildBarManagement();

  Widget _buildBoardManagement() => _gearManagement.buildBoardManagement();

  Widget _buildHarnessManagement() => _gearManagement.buildHarnessManagement();

  Widget _buildWetsuitManagement() => _gearManagement.buildWetsuitManagement();

  Widget _buildHelmetManagement() => _gearManagement.buildHelmetManagement();

  Widget _buildVestManagement() => _gearManagement.buildVestManagement();

  ProfileGearDialogsCoordinator get _gearDialogs {
    return ProfileGearDialogsCoordinator(
      context: context,
      mutateState: _mutateState,
      controllers: ProfileGearDialogControllers(
        gearSetupNameController: _gearSetupNameController,
        kiteBrandController: _kiteBrandController,
        kiteModelController: _kiteModelController,
        kiteSizeController: _kiteSizeController,
        kiteYearController: _kiteYearController,
        kitePriceController: _kitePriceController,
        barBrandController: _barBrandController,
        barModelController: _barModelController,
        barLineLengthController: _barLineLengthController,
        barWidthController: _barWidthController,
        barYearController: _barYearController,
        barPriceController: _barPriceController,
        boardBrandController: _boardBrandController,
        boardModelController: _boardModelController,
        boardSizeController: _boardSizeController,
        boardYearController: _boardYearController,
        boardPriceController: _boardPriceController,
        harnessBrandController: _harnessBrandController,
        harnessModelController: _harnessModelController,
        harnessSizeController: _harnessSizeController,
        harnessYearController: _harnessYearController,
        harnessPriceController: _harnessPriceController,
        wetsuitBrandController: _wetsuitBrandController,
        wetsuitModelController: _wetsuitModelController,
        wetsuitThicknessController: _wetsuitThicknessController,
        wetsuitSizeController: _wetsuitSizeController,
        wetsuitYearController: _wetsuitYearController,
        wetsuitPriceController: _wetsuitPriceController,
        helmetBrandController: _helmetBrandController,
        helmetModelController: _helmetModelController,
        helmetYearController: _helmetYearController,
        helmetPriceController: _helmetPriceController,
        vestBrandController: _vestBrandController,
        vestModelController: _vestModelController,
        vestSizeController: _vestSizeController,
        vestYearController: _vestYearController,
        vestPriceController: _vestPriceController,
      ),
      inventory: ProfileGearDialogInventory(
        savedKites: () => _savedKites,
        savedBars: () => _savedBars,
        savedBoards: () => _savedBoards,
        savedHarnesses: () => _savedHarnesses,
        savedWetsuits: () => _savedWetsuits,
        savedHelmets: () => _savedHelmets,
        savedVests: () => _savedVests,
      ),
      resolvers: ProfileGearDialogResolvers(
        findKite: _findKite,
        findBar: _findBar,
        findBoard: _findBoard,
        findHarness: _findHarness,
        findWetsuit: _findWetsuit,
        findHelmet: _findHelmet,
        findVest: _findVest,
      ),
      selection: ProfileGearDialogSelection(
        selectedBoardType: () => _selectedBoardType,
        setSelectedBoardType: (value) => _selectedBoardType = value,
        selectedKiteForSetupId: () => _selectedKiteForSetupId,
        setSelectedKiteForSetupId: (value) => _selectedKiteForSetupId = value,
        selectedBarForSetupId: () => _selectedBarForSetupId,
        setSelectedBarForSetupId: (value) => _selectedBarForSetupId = value,
        selectedBoardForSetupId: () => _selectedBoardForSetupId,
        setSelectedBoardForSetupId: (value) => _selectedBoardForSetupId = value,
        selectedHarnessForSetupId: () => _selectedHarnessForSetupId,
        setSelectedHarnessForSetupId: (value) =>
            _selectedHarnessForSetupId = value,
        selectedWetsuitForSetupId: () => _selectedWetsuitForSetupId,
        setSelectedWetsuitForSetupId: (value) =>
            _selectedWetsuitForSetupId = value,
        selectedHelmetForSetupId: () => _selectedHelmetForSetupId,
        setSelectedHelmetForSetupId: (value) =>
            _selectedHelmetForSetupId = value,
        selectedVestForSetupId: () => _selectedVestForSetupId,
        setSelectedVestForSetupId: (value) => _selectedVestForSetupId = value,
      ),
      actions: ProfileGearDialogSaveActions(
        canSaveGearSetup: () => _canSaveGearSetup,
        saveGearSetup: _saveGearSetup,
        saveKite: _saveKite,
        saveBar: _saveBar,
        saveBoard: _saveBoard,
        saveHarness: _saveHarness,
        saveWetsuit: _saveWetsuit,
        saveHelmet: _saveHelmet,
        saveVest: _saveVest,
      ),
    );
  }

  Future<bool> _confirmDeleteItem(String itemLabel) {
    return _gearDialogs.confirmDeleteItem(itemLabel);
  }

  Future<void> _openGearSetupDialog({_GearSetup? existing}) {
    return _gearDialogs.openGearSetupDialog(existing: existing);
  }

  Future<void> _openKiteDialog({_KiteItem? existing}) {
    return _gearDialogs.openKiteDialog(existing: existing);
  }

  Future<void> _openBarDialog({_BarItem? existing}) {
    return _gearDialogs.openBarDialog(existing: existing);
  }

  Future<void> _openBoardDialog({_BoardItem? existing}) {
    return _gearDialogs.openBoardDialog(existing: existing);
  }

  Future<void> _openHarnessDialog({_HarnessItem? existing}) {
    return _gearDialogs.openHarnessDialog(existing: existing);
  }

  Future<void> _openWetsuitDialog({_WetsuitItem? existing}) {
    return _gearDialogs.openWetsuitDialog(existing: existing);
  }

  Future<void> _openHelmetDialog({_HelmetItem? existing}) {
    return _gearDialogs.openHelmetDialog(existing: existing);
  }

  Future<void> _openVestDialog({_VestItem? existing}) {
    return _gearDialogs.openVestDialog(existing: existing);
  }

  List<DirectMessageThread> get _directMessageThreads {
    return _messagesController.directThreads;
  }

  void _mutateState(VoidCallback callback) {
    setState(callback);
  }

  void _setSelectedGearConfigTabIndex(int index) {
    setState(() {
      _selectedGearConfigTabIndex = index;
    });
  }

  Future<bool> _updateProfileData(_UserProfileData value) async {
    try {
      await _profileController.updateProfile(value);
      await _profileController.loadProfile();
      if (!mounted) {
        return false;
      }
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
      return true;
    } on ProfileHandleTakenException catch (_) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este nombre de usuario ya esta ocupado.'),
        ),
      );
      return false;
    } catch (error) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar el perfil: $error')),
      );
      return false;
    }
  }

  Future<bool> _isProfileHandleAvailable(String handle) {
    return _profileController.isHandleAvailable(handle);
  }

  void _toggleMuteDirectThread(String threadId) {
    setState(() {
      _messagesController.toggleMuteDirectThread(threadId);
    });
  }

  Future<void> openDirectChatFromNotification(String threadId) async {
    if (_selectedTabIndex != 2) {
      setState(() {
        _selectedTabIndex = 2;
      });
    }
    await _messagesController.hydrate();
    if (!mounted) {
      return;
    }
    setState(() {});
    final thread = _directMessageThreads
        .cast<DirectMessageThread?>()
        .firstWhere((item) => item?.id == threadId, orElse: () => null);
    if (thread == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el chat desde la notificacion.'),
        ),
      );
      return;
    }
    await _openDirectChat(thread);
  }

  void openAlarmsFromNotification() {
    if (_selectedTabIndex == 1) {
      return;
    }
    setState(() {
      _selectedTabIndex = 1;
    });
  }

  Future<void> reloadProfileAfterExternalChange() async {
    await _profileController.loadProfile();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _startNewDirectChat(DirectChatUserCandidate candidate) async {
    final thread = await _messagesController.createOrOpenDirectChat(
      candidate.id,
    );
    if (!mounted) {
      return;
    }
    if (thread == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el chat seleccionado.')),
      );
      return;
    }

    setState(() {});
    await _openDirectChat(thread);
  }

  Future<void> _openDirectChat(DirectMessageThread thread) async {
    await _messagesController.markDirectThreadAsRead(thread.id);
    if (!mounted) {
      return;
    }
    _activeDirectChatThreadId = thread.id;
    setState(() {});
    await showDialog<void>(
      context: context,
      builder: (_) => DirectChatDialog(
        threadId: thread.id,
        participant: thread.participant,
        participantAvatarPath: thread.participantAvatarPath,
        loadMessages: _messagesController.loadDirectChatMessages,
        sendMessage: _messagesController.sendDirectChatMessage,
        watchMessages: _messagesController.watchDirectChatMessages,
        watchTyping: _messagesController.watchDirectChatTyping,
        sendTypingState: _messagesController.sendDirectChatTypingState,
        sendMediaMessage: _messagesController.sendDirectChatMediaMessage,
        updateMessage: _messagesController.updateDirectChatMessage,
        deleteMessages: _messagesController.deleteDirectChatMessages,
        onThreadChanged: _refreshMessagesSilently,
      ),
    );
    _activeDirectChatThreadId = null;
    if (!mounted) {
      return;
    }
    await _messagesController.hydrate();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _deleteDirectThread(String threadId) {
    setState(() {
      _messagesController.deleteDirectThread(threadId);
    });
  }

  void _blockDirectThread(String threadId, String participant) {
    final blocked = _messagesController.toggleBlockDirectThread(threadId);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          blocked ? '$participant bloqueado.' : '$participant desbloqueado.',
        ),
      ),
    );
  }

  Future<void> _confirmAndDeleteDirectThread(
    String threadId,
    String participant,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar chat'),
          content: Text(
            'Se eliminara el chat con $participant. Esta accion no se puede deshacer.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }
    _deleteDirectThread(threadId);
  }

  Future<void> _confirmAndBlockDirectThread(
    String threadId,
    String participant,
  ) async {
    final thread = _directMessageThreads
        .cast<DirectMessageThread?>()
        .firstWhere((item) => item?.id == threadId, orElse: () => null);
    final isBlocked = thread?.isBlocked ?? false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isBlocked ? 'Desbloquear usuario' : 'Bloquear usuario'),
          content: Text(
            isBlocked
                ? 'Se desbloqueara a $participant y podras volver a interactuar con este chat.'
                : 'Se bloqueara a $participant. Podras desbloquearlo mas adelante.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(isBlocked ? 'Desbloquear' : 'Bloquear'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }
    _blockDirectThread(threadId, participant);
  }

  @override
  void dispose() {
    _messagesAutoRefreshTimer?.cancel();
    _messagesRealtimeSubscription?.cancel();
    _messagesController.dispose();
    _messageSearchController.dispose();
    _gearSetupNameController.dispose();
    _kiteBrandController.dispose();
    _kiteModelController.dispose();
    _kiteSizeController.dispose();
    _kiteYearController.dispose();
    _barBrandController.dispose();
    _barModelController.dispose();
    _barLineLengthController.dispose();
    _barWidthController.dispose();
    _barYearController.dispose();
    _boardBrandController.dispose();
    _boardModelController.dispose();
    _boardSizeController.dispose();
    _boardYearController.dispose();
    _harnessBrandController.dispose();
    _harnessModelController.dispose();
    _harnessSizeController.dispose();
    _harnessYearController.dispose();
    _wetsuitBrandController.dispose();
    _wetsuitModelController.dispose();
    _wetsuitThicknessController.dispose();
    _wetsuitSizeController.dispose();
    _wetsuitYearController.dispose();
    _helmetBrandController.dispose();
    _helmetModelController.dispose();
    _helmetYearController.dispose();
    _vestBrandController.dispose();
    _vestModelController.dispose();
    _vestSizeController.dispose();
    _vestYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      physics: kAppBouncingScrollPhysics,
      children: [
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: _tabs
              .map(
                (tab) => ButtonSegment<int>(
                  value: _tabs.indexOf(tab),
                  label: Text(tab),
                ),
              )
              .toList(),
          selected: {_selectedTabIndex},
          onSelectionChanged: (selection) {
            setState(() {
              _selectedTabIndex = selection.first;
            });
          },
        ),
        const SizedBox(height: AppSpacing.md),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _buildTabContent(textTheme),
        ),
      ],
    );
  }

  Widget _buildTabContent(TextTheme textTheme) {
    switch (_selectedTabIndex) {
      case 0:
        return Column(
          key: const ValueKey('perfil_tab'),
          children: [
            Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_profileSections.length, (index) {
                      final isSelected = _selectedProfileSectionIndex == index;
                      final colorScheme = Theme.of(context).colorScheme;
                      final textTheme = Theme.of(context).textTheme;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == _profileSections.length - 1 ? 0 : 4,
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedProfileSectionIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? colorScheme.surface
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: colorScheme.shadow.withValues(
                                          alpha: 0.08,
                                        ),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              _profileSections[index],
                              style: textTheme.titleSmall?.copyWith(
                                color: isSelected
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _selectedProfileSectionIndex == 0
                  ? ProfileOverviewSection(
                      key: const ValueKey('perfil_usuario_section'),
                      profile: _profileData,
                      kpis: _profileKpis,
                      onProfileUpdated: _updateProfileData,
                      isHandleAvailable: _isProfileHandleAvailable,
                      savedGearSetups: _savedGearSetups,
                      findKite: _findKite,
                      findBar: _findBar,
                      findBoard: _findBoard,
                      findHarness: _findHarness,
                      findWetsuit: _findWetsuit,
                      findHelmet: _findHelmet,
                      findVest: _findVest,
                    )
                  : ProfileGearSection(
                      key: const ValueKey('perfil_equipo_section'),
                      material: ProfileGearMaterialCardData(
                        selectedGearConfigTabIndex: _selectedGearConfigTabIndex,
                        onSelectGearConfigTab: _setSelectedGearConfigTabIndex,
                        savedKitesCount: _savedKites.length,
                        savedBoardsCount: _savedBoards.length,
                        savedBarsCount: _savedBars.length,
                        savedHarnessesCount: _savedHarnesses.length,
                        savedWetsuitsCount: _savedWetsuits.length,
                        savedHelmetsCount: _savedHelmets.length,
                        savedVestsCount: _savedVests.length,
                        kiteManagement: _buildKiteManagement(),
                        boardManagement: _buildBoardManagement(),
                        barManagement: _buildBarManagement(),
                        harnessManagement: _buildHarnessManagement(),
                        wetsuitManagement: _buildWetsuitManagement(),
                        helmetManagement: _buildHelmetManagement(),
                        vestManagement: _buildVestManagement(),
                        onOpenKiteDialog: _openKiteDialog,
                        onOpenBoardDialog: _openBoardDialog,
                        onOpenBarDialog: _openBarDialog,
                        onOpenHarnessDialog: _openHarnessDialog,
                        onOpenWetsuitDialog: _openWetsuitDialog,
                        onOpenHelmetDialog: _openHelmetDialog,
                        onOpenVestDialog: _openVestDialog,
                      ),
                      setups: ProfileGearSetupsCardData(
                        savedGearSetups: _savedGearSetups,
                        findKite: _findKite,
                        findBar: _findBar,
                        findBoard: _findBoard,
                        findHarness: _findHarness,
                        findWetsuit: _findWetsuit,
                        findHelmet: _findHelmet,
                        findVest: _findVest,
                        onOpenGearSetupDialog: _openGearSetupDialog,
                        onConfirmDeleteItem: _confirmDeleteItem,
                        onDeleteGearSetup: _deleteGearSetup,
                      ),
                      usage: ProfileGearUsageStatsCardData(
                        savedGearSetups: _savedGearSetups,
                        savedKites: _savedKites,
                        savedBoards: _savedBoards,
                        savedBars: _savedBars,
                        savedHarnesses: _savedHarnesses,
                        savedWetsuits: _savedWetsuits,
                        savedHelmets: _savedHelmets,
                        savedVests: _savedVests,
                        recordedSessions: _recordedSessions,
                      ),
                    ),
            ),
          ],
        );
      case 1:
        return const ProfileAlarmsSection();
      case 2:
        return ProfileDirectMessagesSection(
          directMessageThreads: _directMessageThreads,
          directChatUserCandidates:
              _messagesController.directChatUserCandidates,
          onOpenChat: _openDirectChat,
          onToggleMute: _toggleMuteDirectThread,
          onBlock: _confirmAndBlockDirectThread,
          onDelete: _confirmAndDeleteDirectThread,
          onStartChatWithCandidate: _startNewDirectChat,
          formatTimestamp: _formatTimestamp,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }
}
