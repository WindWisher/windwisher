abstract class RecentAuthAccountsPort {
  Future<List<String>> getRecentEmails();

  Future<void> add(String email);

  Future<void> remove(String email);
}
