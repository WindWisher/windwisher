import 'package:windwisher/features/auth/domain/ports/out/recent_auth_accounts_port.dart';

class GetRecentAuthEmailsUseCase {
  const GetRecentAuthEmailsUseCase(this._port);

  final RecentAuthAccountsPort _port;

  Future<List<String>> call() {
    return _port.getRecentEmails();
  }
}

class AddRecentAuthEmailUseCase {
  const AddRecentAuthEmailUseCase(this._port);

  final RecentAuthAccountsPort _port;

  Future<void> call(String email) {
    return _port.add(email);
  }
}

class RemoveRecentAuthEmailUseCase {
  const RemoveRecentAuthEmailUseCase(this._port);

  final RecentAuthAccountsPort _port;

  Future<void> call(String email) {
    return _port.remove(email);
  }
}
