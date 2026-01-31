package com.daddoodev.yetimatch.platform

import android.content.Intent
import android.net.Uri
import com.daddoodev.yetimatch.QuizResourceHelper

actual fun openUrl(url: String) {
    val ctx = QuizResourceHelper.context ?: return
    val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
    ctx.startActivity(Intent.createChooser(intent, null))
}
