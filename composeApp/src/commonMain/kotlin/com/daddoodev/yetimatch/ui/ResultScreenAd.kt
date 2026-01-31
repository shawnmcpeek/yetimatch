package com.daddoodev.yetimatch.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier

/**
 * Platform-specific ad slot shown after quiz results (e.g. banner on Android).
 * No-op on iOS until AdMob is integrated there.
 */
@Composable
expect fun ResultScreenAd(modifier: Modifier = Modifier)
