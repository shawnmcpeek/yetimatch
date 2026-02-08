package com.daddoodev.yetimatch

import android.app.Application
import com.daddoodev.yetimatch.subscription.configureRevenueCat

class YetiMatchApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        configureRevenueCat()
    }
}
