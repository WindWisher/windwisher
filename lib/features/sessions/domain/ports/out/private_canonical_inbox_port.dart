import 'dart:typed_data';

import 'package:windwisher/features/sessions/domain/services/private_canonical_validator.dart';

abstract interface class PrivateCanonicalInboxPort {
  Future<List<PrivateCanonicalSession>> list();

  Future<PrivateCanonicalSession> validateBytes(Uint8List bytes);

  Future<bool> importBytes(Uint8List bytes);
}
