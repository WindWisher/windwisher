import 'package:windwisher/features/profile/domain/entities/user_profile_data.dart';
import 'package:windwisher/features/profile/domain/ports/out/profile_repository_port.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepositoryPort _repository;

  UserProfileData call() {
    return _repository.getProfile();
  }

  Future<UserProfileData> load() {
    return _repository.loadProfile();
  }
}

class SaveProfileUseCase {
  const SaveProfileUseCase(this._repository);

  final ProfileRepositoryPort _repository;

  Future<void> call(UserProfileData value) {
    return _repository.saveProfile(value);
  }
}
