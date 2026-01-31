package com.daddoodev.yetimatch.preferences

import com.daddoodev.yetimatch.QuizResourceHelper

private const val PREFS_NAME = "yetimatch_prefs"
private const val KEY_AGE_VERIFIED = "age_verified"

actual fun getAgeVerified(): Boolean {
    val ctx = QuizResourceHelper.context ?: return false
    return ctx.getSharedPreferences(PREFS_NAME, android.content.Context.MODE_PRIVATE)
        .getBoolean(KEY_AGE_VERIFIED, false)
}

actual fun setAgeVerified(verified: Boolean) {
    QuizResourceHelper.context?.getSharedPreferences(PREFS_NAME, android.content.Context.MODE_PRIVATE)
        ?.edit()
        ?.putBoolean(KEY_AGE_VERIFIED, verified)
        ?.apply()
}
