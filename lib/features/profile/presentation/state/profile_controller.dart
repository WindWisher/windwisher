import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/application/use_cases/profile_use_cases.dart';

class ProfileController {
  ProfileController({
    required GetProfileUseCase getProfile,
    required SaveProfileUseCase saveProfile,
    required CheckProfileHandleAvailabilityUseCase checkHandleAvailability,
  }) : _getProfile = getProfile,
       _saveProfile = saveProfile,
       _checkHandleAvailability = checkHandleAvailability;

  final GetProfileUseCase _getProfile;
  final SaveProfileUseCase _saveProfile;
  final CheckProfileHandleAvailabilityUseCase _checkHandleAvailability;

  UserProfileData get profile => _getProfile();

  Future<UserProfileData> loadProfile() {
    return _getProfile.load();
  }

  Future<void> updateProfile(UserProfileData value) {
    return _saveProfile(value);
  }

  Future<bool> isHandleAvailable(String handle) {
    return _checkHandleAvailability(handle);
  }
}
