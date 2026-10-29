import 'dart:io' show Platform;

/// App URLs and API / SDK keys.
class AppConfig {
  static const bool subscriptionsEnabled = true;

  static const String ymV2QuizApiKey =
      'ymTJKwohI4otH8wUdFYzlaJUrGtmm5dut9';

  static const String revenueCatIosKey =
      'appl_enfdkSYFweszCzKBjtkglOtJjmb';

  static const String revenueCatAndroidKey =
      'goog_CnBiVmTEXQLboqmoFxlYpAmqVdX';

  static const String revenueCatFallbackKey = '';

  static const String privacyPolicyUrl = 'https://daddoodev.pro/privacy';
  static const String supportUrl =
      'mailto:support@daddoodev.pro?subject=YetiMatch%20Support';

  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.daddoodev.yetimatch';

  static const String appStoreUrl =
      'https://apps.apple.com/us/app/yetimatch/id6758521672';

  static String get storeListingUrl {
    if (Platform.isIOS && appStoreUrl.isNotEmpty) return appStoreUrl;
    return playStoreUrl;
  }

  static String? _quizApiKeyTestOverride;

  static String get apiKey {
    final o = _quizApiKeyTestOverride;
    if (o != null && o.isNotEmpty) return o;
    return ymV2QuizApiKey;
  }

  static void setApiKeyForTesting(String key) {
    _quizApiKeyTestOverride = key.trim().isEmpty ? null : key.trim();
  }

  static void init({String? envPath}) {}
}
