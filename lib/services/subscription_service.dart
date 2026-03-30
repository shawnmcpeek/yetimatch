import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';

const String entitlementUnlimited = 'YetiMatch Unlimited';

class SubscriptionService {
  static bool _configured = false;

  static Future<void> configure() async {
    if (_configured) return;
    if (!Platform.isIOS && !Platform.isAndroid) {
      return;
    }
    var apiKey = Platform.isIOS
        ? AppConfig.revenueCatIosKey
        : AppConfig.revenueCatAndroidKey;
    if (apiKey.isEmpty) {
      apiKey = AppConfig.revenueCatFallbackKey;
    }
    if (apiKey.isEmpty) {
      debugPrint(
        'RevenueCat: no key for this platform (set REVENUECAT_IOS_KEY / '
        'REVENUECAT_ANDROID_KEY or REVENUECAT_FALLBACK_KEY). Subscriptions disabled.',
      );
      return;
    }
    try {
      await Purchases.setLogLevel(LogLevel.error);
      await Purchases.configure(
        PurchasesConfiguration(apiKey),
      );
      _configured = true;
    } catch (e, st) {
      debugPrint('RevenueCat configure failed: $e');
      if (kDebugMode) debugPrint('$st');
    }
  }

  static Future<CustomerInfo?> getCustomerInfo() async {
    if (!_configured) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      debugPrint('RevenueCat getCustomerInfo error: $e');
      return null;
    }
  }

  static Future<bool> hasUnlimitedAccess() async {
    final info = await getCustomerInfo();
    if (info == null) return false;
    return info.entitlements.active[entitlementUnlimited] != null;
  }

  static Future<void> loginUser(String userId) async {
    if (!_configured) return;
    try {
      final result = await Purchases.logIn(userId);
      debugPrint(
          'RevenueCat login ok: ${result.customerInfo.entitlements.active.containsKey(entitlementUnlimited)}');
    } catch (e) {
      debugPrint('RevenueCat login error: $e');
    }
  }

  static Future<void> logout() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('RevenueCat logout error: $e');
    }
  }
}
