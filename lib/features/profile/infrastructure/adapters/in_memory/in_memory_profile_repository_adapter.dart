import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_repository_port.dart';

class InMemoryProfileRepositoryAdapter implements ProfileRepositoryPort {
  UserProfileData _profile = UserProfileData.initial();

  @override
  UserProfileData getProfile() {
    return _profile;
  }

  @override
  Future<UserProfileData> loadProfile() async {
    return _profile;
  }

  @override
  Future<void> saveProfile(UserProfileData value) async {
    _profile = value;
  }
}
