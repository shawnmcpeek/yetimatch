import 'dart:io' show File, Platform;

/// App URLs and API key.
///
/// Quiz API key is chosen in this order:
/// 1. --dart-define=YETIMATCH_API_KEY=xxx at build
/// 2. Environment variable YETIMATCH_API_KEY (e.g. export before flutter run)
/// 3. Project root .env file with line: YETIMATCH_API_KEY=your_key
///
/// Call [init] from main() before runApp.
class AppConfig {
  static const String privacyPolicyUrl = 'https://daddoodev.pro/privacy';
  static const String supportUrl =
      'mailto:support@daddoodev.pro?subject=YetiMatch%20Support';

  static String? _runtimeKey;

  /// Quiz API key. [init] must be called first for env/.env to apply.
  static String get apiKey =>
      _runtimeKey ??
      const String.fromEnvironment('YETIMATCH_API_KEY', defaultValue: '');

  /// For tests only: set key from e.g. test/.api_key (gitignored).
  static void setApiKeyForTesting(String key) {
    _runtimeKey = key.trim().isEmpty ? null : key.trim();
  }

  /// Load key from env var and optionally .env.
  /// [envPath] if set (e.g. from test) use this .env file; else try .env in CWD and parent dirs.
  static void init({String? envPath}) {
    const dartDefine =
        String.fromEnvironment('YETIMATCH_API_KEY', defaultValue: '');
    if (dartDefine.isNotEmpty) return;

    final fromEnv = Platform.environment['YETIMATCH_API_KEY'];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      _runtimeKey = fromEnv.trim();
      return;
    }

    try {
      final candidates = envPath != null
          ? [File(envPath)]
          : ['.env', '../.env', '../../.env']
              .map((p) => File(p))
              .where((f) => f.existsSync());
      for (final envFile in candidates) {
        if (!envFile.existsSync()) continue;
        for (final line in envFile.readAsLinesSync()) {
          final trimmed = line.trim();
          if (trimmed.startsWith('YETIMATCH_API_KEY=')) {
            var value = trimmed.substring('YETIMATCH_API_KEY='.length).trim();
            if (value.length >= 2 &&
                ((value.startsWith('"') && value.endsWith('"')) ||
                    (value.startsWith("'") && value.endsWith("'")))) {
              value = value.substring(1, value.length - 1);
            }
            if (value.isNotEmpty) {
              _runtimeKey = value;
              return;
            }
          }
        }
      }
    } catch (_) {
      // Ignore: .env optional
    }
  }
}
