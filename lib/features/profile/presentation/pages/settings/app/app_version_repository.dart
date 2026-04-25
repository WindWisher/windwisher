import 'package:package_info_plus/package_info_plus.dart';

class AppVersionRepository {
  const AppVersionRepository._();

  static Future<String> loadVersionLabel() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = packageInfo.version.trim();
    final buildNumber = packageInfo.buildNumber.trim();

    if (version.isEmpty) {
      return 'Version no disponible';
    }

    if (buildNumber.isEmpty) {
      return version;
    }

    return '$version ($buildNumber)';
  }
}
