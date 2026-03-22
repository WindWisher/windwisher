import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/application/use_cases/profile_use_cases.dart';

class ProfileController {
  ProfileController({
    required GetProfileUseCase getProfile,
    required SaveProfileUseCase saveProfile,
  }) : _getProfile = getProfile,
       _saveProfile = saveProfile;

  final GetProfileUseCase _getProfile;
  final SaveProfileUseCase _saveProfile;

  UserProfileData get profile => _getProfile();

  Future<UserProfileData> loadProfile() {
    return _getProfile.load();
  }

  Future<void> updateProfile(UserProfileData value) {
    return _saveProfile(value);
  }
}
