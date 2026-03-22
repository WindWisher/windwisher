import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';

abstract class ProfileRepositoryPort {
  UserProfileData getProfile();

  Future<UserProfileData> loadProfile();

  Future<void> saveProfile(UserProfileData value);
}
