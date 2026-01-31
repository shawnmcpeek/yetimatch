package com.daddoodev.yetimatch.platform

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.util.Log
import com.daddoodev.yetimatch.QuizResourceHelper

private const val TAG = "YetiMatch/OpenUrl"

actual fun openUrl(url: String) {
    Log.d(TAG, "openUrl: $url")
    val ctx = QuizResourceHelper.context
    if (ctx == null) {
        Log.w(TAG, "openUrl: context is null")
        return
    }
    if (url.isBlank()) {
        Log.w(TAG, "openUrl: blank url")
        return
    }
    try {
        val uri = Uri.parse(url)
        val viewIntent = Intent(Intent.ACTION_VIEW, uri)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        val chooserIntent = Intent.createChooser(viewIntent, null)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        ctx.startActivity(chooserIntent)
        Log.d(TAG, "openUrl: started activity")
    } catch (e: ActivityNotFoundException) {
        Log.w(TAG, "openUrl: no app can handle url", e)
    } catch (e: SecurityException) {
        Log.w(TAG, "openUrl: security", e)
    } catch (e: Throwable) {
        Log.e(TAG, "openUrl: failed", e)
    }
}
