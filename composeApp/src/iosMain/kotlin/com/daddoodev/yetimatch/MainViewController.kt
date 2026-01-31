package com.daddoodev.yetimatch

import androidx.compose.ui.window.ComposeUIViewController
import platform.UIKit.UIViewController

var IOSBanner: () -> UIViewController = { error("IOSBanner not set by iOS app") }

fun generateIOSBanner(): UIViewController = IOSBanner()

fun MainViewController() = ComposeUIViewController(
    configure = { enforceStrictPlistSanityCheck = false }
) { App() }