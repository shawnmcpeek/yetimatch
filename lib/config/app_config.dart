import 'dart:io' show File, Platform;

/// App URLs and API key.
///
/// Quiz API (`ym/v2`) uses [ymV2QuizApiKey] — hardcoded client key (same as Cloud Run `YM_API_KEY`).
/// [setApiKeyForTesting] can override for unit tests only.
///
/// RevenueCat public SDK keys (not dashboard app ids): REVENUECAT_IOS_KEY (`appl_…`),
/// REVENUECAT_ANDROID_KEY (`goog_…`). Optional REVENUECAT_FALLBACK_KEY: single shared key
/// (e.g. RevenueCat test/public key in `.env`) used when the platform-specific key is unset—same
/// idea as the pre–1.1.x single embedded test key, without hardcoding secrets in source.
///
/// Call [init] from main() before runApp.
class AppConfig {
  /// Client key for `GET /ym/v2/quizzes` (matches Firebase secret for `ymApi`).
  static const String ymV2QuizApiKey =
      'ymTJKwohI4otH8wUdFYzlaJUrGtmm5dut9';

  static const String privacyPolicyUrl = 'https://daddoodev.pro/privacy';
  static const String supportUrl =
      'mailto:support@daddoodev.pro?subject=YetiMatch%20Support';

  static String? _quizApiKeyTestOverride;
  static String? _revenueCatIosKey;
  static String? _revenueCatAndroidKey;
  static String? _revenueCatFallbackKey;

  static String get apiKey {
    final o = _quizApiKeyTestOverride;
    if (o != null && o.isNotEmpty) return o;
    return ymV2QuizApiKey;
  }

  /// Public RevenueCat SDK key for Apple (`appl_…` from RevenueCat → API keys).
  static String get revenueCatIosKey =>
      _revenueCatIosKey ??
      const String.fromEnvironment('REVENUECAT_IOS_KEY', defaultValue: '');

  /// Public RevenueCat SDK key for Google Play (`goog_…` from RevenueCat → API keys).
  static String get revenueCatAndroidKey =>
      _revenueCatAndroidKey ??
      const String.fromEnvironment('REVENUECAT_ANDROID_KEY', defaultValue: '');

  /// Optional single key (often test mode) used when [revenueCatIosKey] / [revenueCatAndroidKey] is empty.
  static String get revenueCatFallbackKey =>
      _revenueCatFallbackKey ??
      const String.fromEnvironment('REVENUECAT_FALLBACK_KEY', defaultValue: '');

  static void setApiKeyForTesting(String key) {
    _quizApiKeyTestOverride = key.trim().isEmpty ? null : key.trim();
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
    final dartIos =
        const String.fromEnvironment('REVENUECAT_IOS_KEY', defaultValue: '');
    _revenueCatIosKey = dartIos.isNotEmpty ? dartIos : null;
    if (_revenueCatIosKey == null || _revenueCatIosKey!.isEmpty) {
      _revenueCatIosKey = Platform.environment['REVENUECAT_IOS_KEY']?.trim();
    }
    if (_revenueCatIosKey != null && _revenueCatIosKey!.isEmpty) {
      _revenueCatIosKey = null;
    }

    final dartAndroid =
        const String.fromEnvironment('REVENUECAT_ANDROID_KEY', defaultValue: '');
    _revenueCatAndroidKey = dartAndroid.isNotEmpty ? dartAndroid : null;
    if (_revenueCatAndroidKey == null || _revenueCatAndroidKey!.isEmpty) {
      _revenueCatAndroidKey =
          Platform.environment['REVENUECAT_ANDROID_KEY']?.trim();
    }
    if (_revenueCatAndroidKey != null && _revenueCatAndroidKey!.isEmpty) {
      _revenueCatAndroidKey = null;
    }

    final dartFb =
        const String.fromEnvironment('REVENUECAT_FALLBACK_KEY', defaultValue: '');
    _revenueCatFallbackKey = dartFb.isNotEmpty ? dartFb : null;
    if (_revenueCatFallbackKey == null || _revenueCatFallbackKey!.isEmpty) {
      _revenueCatFallbackKey =
          Platform.environment['REVENUECAT_FALLBACK_KEY']?.trim();
    }
    if (_revenueCatFallbackKey != null && _revenueCatFallbackKey!.isEmpty) {
      _revenueCatFallbackKey = null;
    }

    try {
      final candidates = envPath != null
          ? [File(envPath)]
          : ['.env', '../.env', '../../.env'].map((p) => File(p)).where((f) => f.existsSync());
      for (final f in candidates) {
        if (!f.existsSync()) continue;
        for (final line in f.readAsLinesSync()) {
          final ri = _parseValue(line, 'REVENUECAT_IOS_KEY');
          if (ri != null) _revenueCatIosKey = ri;
          final ra = _parseValue(line, 'REVENUECAT_ANDROID_KEY');
          if (ra != null) _revenueCatAndroidKey = ra;
          final rf = _parseValue(line, 'REVENUECAT_FALLBACK_KEY');
          if (rf != null) _revenueCatFallbackKey = rf;
        }
      }
    } catch (_) {}
  }
}
