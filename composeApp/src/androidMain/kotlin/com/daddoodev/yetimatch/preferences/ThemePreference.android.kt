package com.daddoodev.yetimatch.preferences

import com.daddoodev.yetimatch.QuizResourceHelper
import com.daddoodev.yetimatch.ui.ThemeMode

private const val PREFS_NAME = "yetimatch_prefs"
private const val KEY_THEME_MODE = "theme_mode"

actual fun getThemeMode(): ThemeMode {
    val ctx = QuizResourceHelper.context ?: return ThemeMode.System
    val value = ctx.getSharedPreferences(PREFS_NAME, android.content.Context.MODE_PRIVATE)
        .getString(KEY_THEME_MODE, null) ?: return ThemeMode.System
    return when (value) {
        "Light" -> ThemeMode.Light
        "Dark" -> ThemeMode.Dark
        "System" -> ThemeMode.System
        else -> ThemeMode.System
    }
}

actual fun setThemeMode(mode: ThemeMode) {
    QuizResourceHelper.context?.getSharedPreferences(PREFS_NAME, android.content.Context.MODE_PRIVATE)
        ?.edit()
        ?.putString(KEY_THEME_MODE, mode.name)
        ?.apply()
}
