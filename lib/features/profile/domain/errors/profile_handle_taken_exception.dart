class ProfileHandleTakenException implements Exception {
  const ProfileHandleTakenException([this.handle]);

  final String? handle;

  @override
  String toString() {
    if (handle == null || handle!.trim().isEmpty) {
      return 'Este nombre de usuario ya esta ocupado.';
    }
    return 'Este nombre de usuario ya esta ocupado.';
  }
}
