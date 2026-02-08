package com.daddoodev.yetimatch.ui.screens

import androidx.compose.runtime.Composable
import com.revenuecat.purchases.kmp.ui.revenuecatui.Paywall
import com.revenuecat.purchases.kmp.ui.revenuecatui.PaywallOptions

/**
 * Displays the RevenueCat paywall for purchasing Basic or Premium.
 *
 * @param onDismiss Called when user dismisses the paywall (back/cancel).
 * @param onPurchaseCompleted Called after a successful purchase.
 * @param onRestoreCompleted Called after a successful restore.
 */
@Composable
fun PaywallScreen(
    onDismiss: () -> Unit,
    onPurchaseCompleted: () -> Unit,
    onRestoreCompleted: () -> Unit
) {
    Paywall(
        options = PaywallOptions(
            dismissRequest = onDismiss
        ) {
            shouldDisplayDismissButton = true
            listener = object : com.revenuecat.purchases.kmp.ui.revenuecatui.PaywallListener {
                override fun onPurchaseCompleted(
                    customerInfo: com.revenuecat.purchases.kmp.models.CustomerInfo,
                    storeTransaction: com.revenuecat.purchases.kmp.models.StoreTransaction
                ) {
                    onPurchaseCompleted()
                }

                override fun onRestoreCompleted(
                    customerInfo: com.revenuecat.purchases.kmp.models.CustomerInfo
                ) {
                    onRestoreCompleted()
                }

                override fun onPurchaseError(error: com.revenuecat.purchases.kmp.models.PurchasesError) {
                    println("Purchase error: ${error.message}")
                }

                override fun onPurchaseCancelled() {
                    // User cancelled, do nothing — paywall stays visible
                }

                override fun onRestoreError(error: com.revenuecat.purchases.kmp.models.PurchasesError) {
                    println("Restore error: ${error.message}")
                }

                override fun onRestoreStarted() {}
                override fun onPurchaseStarted(rcPackage: com.revenuecat.purchases.kmp.models.Package) {}
            }
        }
    )
}
