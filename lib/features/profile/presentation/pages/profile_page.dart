import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/core/theme/app_spacing.dart';
import 'package:windwisher/core/ui/app_scroll_behavior.dart';
import 'package:windwisher/features/profile/domain/entities/app_message_index_entry.dart';
import 'package:windwisher/features/community/di/community_module.dart';
import 'package:windwisher/features/community/domain/entities/community_user_summary.dart';
import 'package:windwisher/features/community/domain/entities/following_session.dart';
import 'package:windwisher/features/community/domain/entities/session_comment.dart';
import 'package:windwisher/features/community/domain/entities/session_like_state.dart';
import 'package:windwisher/features/profile/domain/entities/direct_message_thread.dart';
import 'package:windwisher/features/profile/domain/entities/profile_gear_entities.dart';
import 'package:windwisher/features/profile/application/profile_community_stats_aggregator.dart';
import 'package:windwisher/features/profile/application/profile_kpi_aggregator.dart';
import 'package:windwisher/features/profile/application/profile_session_stats_aggregator.dart';
import 'package:windwisher/features/profile/domain/entities/profile_community_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/profile_kpi_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/profile_session_stats_snapshot.dart';
import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/di/profile_module.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_alarms_section.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_gear_section.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_gear_management_builder.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_gear_dialogs_coordinator.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_gear_actions_handler.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_messages_index_pages.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_messages_section.dart';
import 'package:windwisher/features/profile/presentation/pages/profile_overview_section.dart';
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
  int _selectedTabIndex = 0;

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
  final TextEditingController _boardBrandController = TextEditingController();
  final TextEditingController _boardModelController = TextEditingController();
  final TextEditingController _boardSizeController = TextEditingController();
  final TextEditingController _boardYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _harnessBrandController = TextEditingController();
  final TextEditingController _harnessModelController = TextEditingController();
  final TextEditingController _harnessSizeController = TextEditingController(
    text: 'M',
  );
  final TextEditingController _harnessYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
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
  final TextEditingController _helmetBrandController = TextEditingController();
  final TextEditingController _helmetModelController = TextEditingController();
  final TextEditingController _helmetYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  final TextEditingController _vestBrandController = TextEditingController();
  final TextEditingController _vestModelController = TextEditingController();
  final TextEditingController _vestSizeController = TextEditingController(
    text: 'M',
  );
  final TextEditingController _vestYearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );

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
    final users = await _communityModule.getCommunityUsers.load();
    final sessions = await _communityModule.getFollowingSessions.load();
    final followingUsernames =
        await _communityModule.getFollowingUsernames.load() ?? const <String>{};
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
            .from('profiles')
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
      _sessionLikeStatesBySessionId = Map<String, SessionLikeState>.fromEntries(
        likeEntries,
      );
    });
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

  ProfileKpiSnapshot get _profileKpis => ProfileKpiAggregator.build(
    _profileData,
    _profileSessionStats,
    _profileCommunityStats,
  );

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
      barBrandController: _barBrandController,
      barModelController: _barModelController,
      barLineLengthController: _barLineLengthController,
      barWidthController: _barWidthController,
      barYearController: _barYearController,
      boardBrandController: _boardBrandController,
      boardModelController: _boardModelController,
      boardSizeController: _boardSizeController,
      boardYearController: _boardYearController,
      harnessBrandController: _harnessBrandController,
      harnessModelController: _harnessModelController,
      harnessSizeController: _harnessSizeController,
      harnessYearController: _harnessYearController,
      wetsuitBrandController: _wetsuitBrandController,
      wetsuitModelController: _wetsuitModelController,
      wetsuitThicknessController: _wetsuitThicknessController,
      wetsuitSizeController: _wetsuitSizeController,
      wetsuitYearController: _wetsuitYearController,
      helmetBrandController: _helmetBrandController,
      helmetModelController: _helmetModelController,
      helmetYearController: _helmetYearController,
      vestBrandController: _vestBrandController,
      vestModelController: _vestModelController,
      vestSizeController: _vestSizeController,
      vestYearController: _vestYearController,
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
      gearSetupNameController: _gearSetupNameController,
      kiteBrandController: _kiteBrandController,
      kiteModelController: _kiteModelController,
      kiteSizeController: _kiteSizeController,
      kiteYearController: _kiteYearController,
      barBrandController: _barBrandController,
      barModelController: _barModelController,
      barLineLengthController: _barLineLengthController,
      barWidthController: _barWidthController,
      barYearController: _barYearController,
      boardBrandController: _boardBrandController,
      boardModelController: _boardModelController,
      boardSizeController: _boardSizeController,
      boardYearController: _boardYearController,
      harnessBrandController: _harnessBrandController,
      harnessModelController: _harnessModelController,
      harnessSizeController: _harnessSizeController,
      harnessYearController: _harnessYearController,
      wetsuitBrandController: _wetsuitBrandController,
      wetsuitModelController: _wetsuitModelController,
      wetsuitThicknessController: _wetsuitThicknessController,
      wetsuitSizeController: _wetsuitSizeController,
      wetsuitYearController: _wetsuitYearController,
      helmetBrandController: _helmetBrandController,
      helmetModelController: _helmetModelController,
      helmetYearController: _helmetYearController,
      vestBrandController: _vestBrandController,
      vestModelController: _vestModelController,
      vestSizeController: _vestSizeController,
      vestYearController: _vestYearController,
      savedKites: () => _savedKites,
      savedBars: () => _savedBars,
      savedBoards: () => _savedBoards,
      savedHarnesses: () => _savedHarnesses,
      savedWetsuits: () => _savedWetsuits,
      savedHelmets: () => _savedHelmets,
      savedVests: () => _savedVests,
      findKite: _findKite,
      findBar: _findBar,
      findBoard: _findBoard,
      findHarness: _findHarness,
      findWetsuit: _findWetsuit,
      findHelmet: _findHelmet,
      findVest: _findVest,
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
      setSelectedHelmetForSetupId: (value) => _selectedHelmetForSetupId = value,
      selectedVestForSetupId: () => _selectedVestForSetupId,
      setSelectedVestForSetupId: (value) => _selectedVestForSetupId = value,
      canSaveGearSetup: () => _canSaveGearSetup,
      saveGearSetup: _saveGearSetup,
      saveKite: _saveKite,
      saveBar: _saveBar,
      saveBoard: _saveBoard,
      saveHarness: _saveHarness,
      saveWetsuit: _saveWetsuit,
      saveHelmet: _saveHelmet,
      saveVest: _saveVest,
    );
  }

  Future<bool> _confirmDeleteItem(String itemLabel) {
    return _gearDialogs.confirmDeleteItem(itemLabel);
  }

  Future<void> _openGearSetupDetailsDialog(_GearSetup setup) {
    return _gearDialogs.openGearSetupDetailsDialog(setup);
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

  int get _selectedMessagesViewIndex {
    return _messagesController.selectedMessagesViewIndex;
  }

  String get _messageSearchQuery {
    return _messagesController.messageSearchQuery;
  }

  List<AppMessageIndexEntry> _filteredIndexedMessages() {
    return _messagesController.filteredIndexedMessages;
  }

  void _mutateState(VoidCallback callback) {
    setState(callback);
  }

  void _setSelectedGearConfigTabIndex(int index) {
    setState(() {
      _selectedGearConfigTabIndex = index;
    });
  }

  Future<void> _updateProfileData(_UserProfileData value) async {
    await _profileController.updateProfile(value);
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _setSelectedMessagesView(int index) {
    setState(() {
      _messagesController.setSelectedMessagesView(index);
    });
  }

  void _setMessageSearchQuery(String value) {
    setState(() {
      _messagesController.setMessageSearchQuery(value);
    });
  }

  void _toggleMuteDirectThread(String threadId) {
    setState(() {
      _messagesController.toggleMuteDirectThread(threadId);
    });
  }

  void _deleteDirectThread(String threadId) {
    setState(() {
      _messagesController.deleteDirectThread(threadId);
    });
  }

  void _blockDirectThread(String threadId, String participant) {
    final changed = _messagesController.blockDirectThread(threadId);
    if (!changed) {
      return;
    }
    setState(() {});
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$participant bloqueado.')));
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Bloquear usuario'),
          content: Text(
            'Se bloqueara a $participant. Podras desbloquearlo mas adelante.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Bloquear'),
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
            ProfileOverviewSection(
              profile: _profileData,
              kpis: _profileKpis,
              onProfileUpdated: _updateProfileData,
            ),
            const SizedBox(height: AppSpacing.md),
            ProfileGearSection(
              savedKites: _savedKites,
              savedBars: _savedBars,
              savedBoards: _savedBoards,
              savedHarnesses: _savedHarnesses,
              savedWetsuits: _savedWetsuits,
              savedHelmets: _savedHelmets,
              savedVests: _savedVests,
              savedGearSetups: _savedGearSetups,
              selectedGearConfigTabIndex: _selectedGearConfigTabIndex,
              onSelectGearConfigTab: _setSelectedGearConfigTabIndex,
              onOpenGearSetupDialog: _openGearSetupDialog,
              onOpenGearSetupDetailsDialog: _openGearSetupDetailsDialog,
              onConfirmDeleteItem: _confirmDeleteItem,
              onDeleteGearSetup: _deleteGearSetup,
              findKite: _findKite,
              findBar: _findBar,
              findBoard: _findBoard,
              findHarness: _findHarness,
              findWetsuit: _findWetsuit,
              findHelmet: _findHelmet,
              findVest: _findVest,
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
          ],
        );
      case 1:
        return const ProfileAlarmsSection();
      case 2:
        return ProfileMessagesSection(
          selectedMessagesViewIndex: _selectedMessagesViewIndex,
          onSelectMessagesView: _setSelectedMessagesView,
          directMessageThreads: _directMessageThreads,
          onToggleMute: _toggleMuteDirectThread,
          onBlock: _confirmAndBlockDirectThread,
          onDelete: _confirmAndDeleteDirectThread,
          messageSearchController: _messageSearchController,
          messageSearchQuery: _messageSearchQuery,
          onSearchChanged: _setMessageSearchQuery,
          indexedResults: _filteredIndexedMessages(),
          onOpenIndexedMessage: _openIndexedMessage,
          formatTimestamp: _formatTimestamp,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _openIndexedMessage(AppMessageIndexEntry entry) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => IndexedCommentDetailPage(
          entry: entry,
          onEntryUpdated: _updateIndexedMessage,
          onEntryDeleted: _deleteIndexedMessage,
        ),
      ),
    );
  }

  void _updateIndexedMessage(AppMessageIndexEntry updated) {
    setState(() {
      _messagesController.updateIndexedMessage(updated);
    });
  }

  void _deleteIndexedMessage(String id) {
    setState(() {
      _messagesController.deleteIndexedMessage(id);
    });
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
