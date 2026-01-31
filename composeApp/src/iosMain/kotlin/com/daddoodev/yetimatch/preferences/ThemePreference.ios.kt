package com.daddoodev.yetimatch.preferences

import com.daddoodev.yetimatch.ui.ThemeMode
import platform.Foundation.NSHomeDirectory
import platform.Foundation.NSString
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.stringWithContentsOfFile
import platform.Foundation.writeToFile

private const val FILENAME = "yetimatch_theme_mode.txt"

private fun themeModePath(): String {
    val home = NSHomeDirectory()
    return "$home/Documents/$FILENAME"
}

actual fun getThemeMode(): ThemeMode {
    val path = themeModePath()
    val content = NSString.stringWithContentsOfFile(path, NSUTF8StringEncoding, null) as? String ?: return ThemeMode.System
    return when (content.trim()) {
        "Light" -> ThemeMode.Light
        "Dark" -> ThemeMode.Dark
        "System" -> ThemeMode.System
        else -> ThemeMode.System
    }
}

actual fun setThemeMode(mode: ThemeMode) {
    val path = themeModePath()
    (mode.name as NSString).writeToFile(path, atomically = true, encoding = NSUTF8StringEncoding.toLong(), error = null)
}
