import 'dart:convert';

/// Read the weather site's configuration, never an unrelated advertising key.
String? extractWundergroundApiKey(String dashboard) {
  final configKeys = <String>{};
  final configs = RegExp(
    r'\b(?:const|let|var)\s+data\s*=\s*(\{.*?\})\s*;',
    dotAll: true,
  );
  for (final match in configs.allMatches(dashboard)) {
    try {
      final config = jsonDecode(match[1]!);
      if (config is! Map ||
          !const {
            'https://api.weather.com',
            'https://api.weather.com/',
          }.contains(config['API_URL'])) {
        continue;
      }
      final key = config['API_KEY'];
      if (key is String && RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(key)) {
        configKeys.add(key);
      }
    } on FormatException {
      // JavaScript expressions are not configuration JSON; never evaluate them.
    }
  }
  if (configKeys.isNotEmpty) {
    return configKeys.length == 1 ? configKeys.single : null;
  }

  // Older dashboards embedded weather URLs. Require the PWS endpoint and host.
  final legacyKeys = <String>{};
  final normalized = dashboard.replaceAll(r'\/', '/').replaceAll('&amp;', '&');
  for (final match in RegExp(
    r'''https://[^\s"'<>]+''',
  ).allMatches(normalized)) {
    final uri = Uri.tryParse(match[0]!);
    if (uri == null ||
        uri.host != 'api.weather.com' ||
        uri.userInfo.isNotEmpty ||
        uri.port != 443 ||
        !uri.path.startsWith('/v2/pws/observations/')) {
      continue;
    }
    final keys = uri.queryParametersAll['apiKey'];
    if (keys?.length == 1 &&
        RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(keys!.single)) {
      legacyKeys.add(keys.single);
    }
  }
  return legacyKeys.length == 1 ? legacyKeys.single : null;
}
