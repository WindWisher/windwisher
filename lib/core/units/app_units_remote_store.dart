abstract interface class AppUnitsRemoteStore {
  Future<Map<String, String>?> load(String userId);

  Future<void> save(String userId, Map<String, String> values);
}
