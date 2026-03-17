import 'dart:io' show File, Platform;

/// App URLs and API key.
///
/// YETIMATCH_API_KEY from .env (or --dart-define / env var). Used for quiz API and desktop Firebase.
/// Call [init] from main() before runApp.
class AppConfig {
  static const String privacyPolicyUrl = 'https://daddoodev.pro/privacy';
  static const String supportUrl =
      'mailto:support@daddoodev.pro?subject=YetiMatch%20Support';

  static String? _runtimeKey;

  static String get apiKey =>
      _runtimeKey ??
      const String.fromEnvironment('YETIMATCH_API_KEY', defaultValue: '');

  static void setApiKeyForTesting(String key) {
    _runtimeKey = key.trim().isEmpty ? null : key.trim();
  }

  static String? _parseValue(String line, String key) {
    if (!line.trim().startsWith('$key=')) return null;
    var value = line.trim().substring('$key='.length).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }
    return value.isEmpty ? null : value;
  }

  static void init({String? envPath}) {
    final dartKey = const String.fromEnvironment('YETIMATCH_API_KEY', defaultValue: '');
    _runtimeKey = dartKey.isNotEmpty ? dartKey : null;
    if (_runtimeKey == null || _runtimeKey!.isEmpty) {
      _runtimeKey = Platform.environment['YETIMATCH_API_KEY']?.trim();
    }
    if (_runtimeKey != null && _runtimeKey!.isEmpty) _runtimeKey = null;

    try {
      final candidates = envPath != null
          ? [File(envPath)]
          : ['.env', '../.env', '../../.env'].map((p) => File(p)).where((f) => f.existsSync());
      for (final f in candidates) {
        if (!f.existsSync()) continue;
        for (final line in f.readAsLinesSync()) {
          final v = _parseValue(line, 'YETIMATCH_API_KEY');
          if (v != null) _runtimeKey = v;
        }
      }
    } catch (_) {}
  }
}
