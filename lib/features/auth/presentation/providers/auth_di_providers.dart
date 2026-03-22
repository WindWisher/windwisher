import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:windwisher/features/auth/di/auth_module.dart';

final authModuleProvider = Provider<AuthModule>((ref) {
  return AuthModule.auto();
});
