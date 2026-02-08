package com.daddoodev.yetimatch.subscription

import com.revenuecat.purchases.kmp.Purchases
import com.revenuecat.purchases.kmp.models.CustomerInfo
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Manages subscription state via RevenueCat.
 * Single source of truth for whether the user has purchased.
 */
object SubscriptionManager {
    private val _isUnlimited = MutableStateFlow(false)
    val isUnlimited: StateFlow<Boolean> = _isUnlimited.asStateFlow()

    private val _customerInfo = MutableStateFlow<CustomerInfo?>(null)
    val customerInfo: StateFlow<CustomerInfo?> = _customerInfo.asStateFlow()

    /**
     * Check current entitlement status from RevenueCat.
     */
    fun refreshCustomerInfo() {
        Purchases.sharedInstance.getCustomerInfo(
            onError = { error ->
                println("RevenueCat error: ${error.message}")
            },
            onSuccess = { info ->
                _customerInfo.value = info
                _isUnlimited.value = info.entitlements.active[ENTITLEMENT_UNLIMITED] != null
            }
        )
    }

    /**
     * Quick check if user has the unlimited entitlement.
     */
    fun hasUnlimitedAccess(): Boolean = _isUnlimited.value

    /**
     * Login a RevenueCat user (call after Firebase sign-in).
     * Links purchases to the user's account across devices.
     */
    fun loginUser(userId: String) {
        Purchases.sharedInstance.logIn(
            newAppUserID = userId,
            onError = { error ->
                println("RevenueCat login error: ${error.message}")
            },
            onSuccess = { info, _ ->
                _customerInfo.value = info
                _isUnlimited.value = info.entitlements.active[ENTITLEMENT_UNLIMITED] != null
            }
        )
    }

    /**
     * Logout from RevenueCat (call after Firebase sign-out).
     */
    fun logoutUser() {
        Purchases.sharedInstance.logOut(
            onError = { error ->
                println("RevenueCat logout error: ${error.message}")
            },
            onSuccess = { info ->
                _customerInfo.value = info
                _isUnlimited.value = false
            }
        )
    }
}
