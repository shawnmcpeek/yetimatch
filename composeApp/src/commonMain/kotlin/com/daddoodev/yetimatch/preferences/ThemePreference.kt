package com.daddoodev.yetimatch.preferences

import com.daddoodev.yetimatch.ui.ThemeMode

/**
 * Returns the persisted theme mode, or [ThemeMode.System] if none saved (app follows device).
 */
expect fun getThemeMode(): ThemeMode

/**
 * Persists the theme mode so it is used on next app launch.
 */
expect fun setThemeMode(mode: ThemeMode)
