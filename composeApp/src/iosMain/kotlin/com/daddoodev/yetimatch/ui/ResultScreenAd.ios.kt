package com.daddoodev.yetimatch.ui

import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.compose.ui.interop.UIKitView
import com.daddoodev.yetimatch.generateIOSBanner

@Composable
actual fun ResultScreenAd(modifier: Modifier) {
    UIKitView(
        factory = { generateIOSBanner().view },
        modifier = modifier
            .fillMaxWidth()
            .defaultMinSize(minHeight = 50.dp)
            .height(50.dp),
        update = { }
    )
}
