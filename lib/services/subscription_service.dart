import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

const String entitlementUnlimited = 'YetiMatch Unlimited';

/// RevenueCat API key (public, safe to embed).
const String _revenueCatApiKey = 'test_KqSuiFjkPcIGGSClwLTnpDPpbFw';

class SubscriptionService {
  static bool _configured = false;

  static Future<void> configure() async {
    if (_configured) return;
    await Purchases.setLogLevel(LogLevel.error);
    await Purchases.configure(
      PurchasesConfiguration(_revenueCatApiKey),
    );
    _configured = true;
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
