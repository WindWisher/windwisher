import 'package:windwisher/core/config/env/env_config.dart';
import 'package:windwisher/features/profile/application/use_cases/profile_gear_use_cases.dart';
import 'package:windwisher/features/profile/application/use_cases/profile_messages_use_cases.dart';
import 'package:windwisher/features/profile/application/use_cases/profile_use_cases.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/in_memory/in_memory_profile_gear_repository_adapter.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/in_memory/in_memory_profile_messages_repository_adapter.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/in_memory/in_memory_profile_repository_adapter.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/local/local_file_profile_repository_adapter.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/supabase/supabase_profile_gear_repository_adapter.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/supabase/supabase_profile_messages_repository_adapter.dart';
import 'package:windwisher/features/profile/infrastructure/adapters/supabase/supabase_profile_repository_adapter.dart';
import 'package:windwisher/features/profile/presentation/state/profile_controller.dart';
import 'package:windwisher/features/profile/presentation/state/profile_gear_controller.dart';
import 'package:windwisher/features/profile/presentation/state/profile_messages_controller.dart';

class ProfileModule {
  const ProfileModule({
    required this.profileController,
    required this.messagesController,
    required this.gearController,
  });

  final ProfileController profileController;
  final ProfileMessagesController messagesController;
  final ProfileGearController gearController;

  static final InMemoryProfileRepositoryAdapter _inMemoryProfileRepository =
      InMemoryProfileRepositoryAdapter();
  static final LocalFileProfileRepositoryAdapter _localFileProfileRepository =
      LocalFileProfileRepositoryAdapter();
  static final InMemoryProfileMessagesRepositoryAdapter _messagesRepository =
      InMemoryProfileMessagesRepositoryAdapter();
  static final SupabaseProfileMessagesRepositoryAdapter
  _supabaseMessagesRepository = SupabaseProfileMessagesRepositoryAdapter();
  static final InMemoryProfileGearRepositoryAdapter _gearRepository =
      InMemoryProfileGearRepositoryAdapter();
  static final SupabaseProfileGearRepositoryAdapter _supabaseGearRepository =
      SupabaseProfileGearRepositoryAdapter();
  static final SupabaseProfileRepositoryAdapter _supabaseProfileRepository =
      SupabaseProfileRepositoryAdapter();

  factory ProfileModule.inMemory() {
    return ProfileModule(
      profileController: ProfileController(
        getProfile: GetProfileUseCase(_inMemoryProfileRepository),
        saveProfile: SaveProfileUseCase(_inMemoryProfileRepository),
      ),
      messagesController: ProfileMessagesController(
        getDirectThreads: GetDirectMessageThreadsUseCase(_messagesRepository),
        getIndexedMessages: GetIndexedMessagesUseCase(_messagesRepository),
        toggleMuteDirectThread: ToggleMuteDirectThreadUseCase(
          _messagesRepository,
        ),
        blockDirectThread: BlockDirectThreadUseCase(_messagesRepository),
        deleteDirectThread: DeleteDirectThreadUseCase(_messagesRepository),
        updateIndexedMessage: UpdateIndexedMessageUseCase(_messagesRepository),
        deleteIndexedMessage: DeleteIndexedMessageUseCase(_messagesRepository),
      ),
      gearController: ProfileGearController(
        useCases: ProfileGearUseCases(_gearRepository),
      ),
    );
  }

  factory ProfileModule.localFile() {
    return ProfileModule(
      profileController: ProfileController(
        getProfile: GetProfileUseCase(_localFileProfileRepository),
        saveProfile: SaveProfileUseCase(_localFileProfileRepository),
      ),
      messagesController: ProfileMessagesController(
        getDirectThreads: GetDirectMessageThreadsUseCase(_messagesRepository),
        getIndexedMessages: GetIndexedMessagesUseCase(_messagesRepository),
        toggleMuteDirectThread: ToggleMuteDirectThreadUseCase(
          _messagesRepository,
        ),
        blockDirectThread: BlockDirectThreadUseCase(_messagesRepository),
        deleteDirectThread: DeleteDirectThreadUseCase(_messagesRepository),
        updateIndexedMessage: UpdateIndexedMessageUseCase(_messagesRepository),
        deleteIndexedMessage: DeleteIndexedMessageUseCase(_messagesRepository),
      ),
      gearController: ProfileGearController(
        useCases: ProfileGearUseCases(_gearRepository),
      ),
    );
  }

  factory ProfileModule.auto() {
    final hasSupabase =
        EnvConfig.supabaseUrl.trim().isNotEmpty &&
        EnvConfig.supabaseAnonKey.trim().isNotEmpty;
    final profileRepository = hasSupabase
        ? _supabaseProfileRepository
        : _localFileProfileRepository;
    final messagesRepository = hasSupabase
        ? _supabaseMessagesRepository
        : _messagesRepository;
    final gearRepository = hasSupabase
        ? _supabaseGearRepository
        : _gearRepository;

    return ProfileModule(
      profileController: ProfileController(
        getProfile: GetProfileUseCase(profileRepository),
        saveProfile: SaveProfileUseCase(profileRepository),
      ),
      messagesController: ProfileMessagesController(
        getDirectThreads: GetDirectMessageThreadsUseCase(messagesRepository),
        getIndexedMessages: GetIndexedMessagesUseCase(messagesRepository),
        toggleMuteDirectThread: ToggleMuteDirectThreadUseCase(
          messagesRepository,
        ),
        blockDirectThread: BlockDirectThreadUseCase(messagesRepository),
        deleteDirectThread: DeleteDirectThreadUseCase(messagesRepository),
        updateIndexedMessage: UpdateIndexedMessageUseCase(messagesRepository),
        deleteIndexedMessage: DeleteIndexedMessageUseCase(messagesRepository),
      ),
      gearController: ProfileGearController(
        useCases: ProfileGearUseCases(gearRepository),
      ),
    );
  }
}
