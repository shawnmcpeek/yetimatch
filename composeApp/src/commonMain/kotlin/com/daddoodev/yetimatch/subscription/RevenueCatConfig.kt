package com.daddoodev.yetimatch.subscription

import com.revenuecat.purchases.kmp.Purchases
import com.revenuecat.purchases.kmp.configure

/**
 * RevenueCat API key. This is a public key safe to embed in the app.
 * Uses the same key for both platforms via KMP SDK.
 */
private const val REVENUECAT_API_KEY = "test_KqSuiFjkPcIGGSClwLTnpDPpbFw"

/**
 * Entitlement identifier configured in RevenueCat dashboard.
 */
const val ENTITLEMENT_UNLIMITED = "YetiMatch Unlimited"

/**
 * Initialize RevenueCat SDK. Call once at app startup.
 */
fun configureRevenueCat() {
    Purchases.configure(apiKey = REVENUECAT_API_KEY)
}
