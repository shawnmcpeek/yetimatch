package com.daddoodev.yetimatch.ui

import androidx.compose.material3.ColorScheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.ui.graphics.Color
import kotlinx.datetime.Clock
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.todayIn
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class ThemesConfig(
    val themes: List<SeasonalThemeDefinition>
)

@Serializable
data class SeasonalThemeDefinition(
    val id: String,
    val name: String,
    val priority: Int,
    val dateRanges: List<DateRange>,
    val light: ThemeColors,
    val dark: ThemeColors
)

@Serializable
data class DateRange(
    val start: String, // MM-dd format
    val end: String    // MM-dd format
)

@Serializable
data class ThemeColors(
    val primary: String,
    val onPrimary: String,
    val primaryContainer: String,
    val onPrimaryContainer: String,
    val secondary: String,
    val onSecondary: String,
    val secondaryContainer: String,
    val onSecondaryContainer: String,
    val background: String,
    val onBackground: String,
    val surface: String,
    val onSurface: String,
    val error: String,
    val onError: String
)

object SeasonalThemeManager {
    private val json = Json { ignoreUnknownKeys = true }
    private var themesConfig: ThemesConfig? = null
    
    fun initialize(themesJson: String) {
        themesConfig = json.decodeFromString<ThemesConfig>(themesJson)
    }
    
    fun resolveTheme(
        date: LocalDate = Clock.System.todayIn(TimeZone.currentSystemDefault()),
        isDarkMode: Boolean
    ): ColorScheme {
        val config = themesConfig ?: return if (isDarkMode) defaultDarkScheme else defaultLightScheme
        
        // Find the highest priority theme that is active today
        val activeTheme = config.themes
            .filter { it.isActiveOn(date) }
            .maxByOrNull { it.priority }
            ?: config.themes.find { it.id == "default" }
            ?: return if (isDarkMode) defaultDarkScheme else defaultLightScheme
        
        val colors = if (isDarkMode) activeTheme.dark else activeTheme.light
        return colors.toColorScheme(isDarkMode)
    }
    
    fun getCurrentThemeName(
        date: LocalDate = Clock.System.todayIn(TimeZone.currentSystemDefault())
    ): String {
        val config = themesConfig ?: return "Default"
        
        return config.themes
            .filter { it.isActiveOn(date) }
            .maxByOrNull { it.priority }
            ?.name ?: "Default"
    }
    
    private val defaultLightScheme = lightColorScheme(
        primary = Color(0xFF006684),
        onPrimary = Color(0xFFFFFFFF),
        primaryContainer = Color(0xFFB6EAFF),
        onPrimaryContainer = Color(0xFF001F29),
        secondary = Color(0xFF4D616C),
        onSecondary = Color(0xFFFFFFFF),
        secondaryContainer = Color(0xFFD0E6F2),
        onSecondaryContainer = Color(0xFF091E27),
        background = Color(0xFFF5FAFC),
        onBackground = Color(0xFF191C1E),
        surface = Color(0xFFF5FAFC),
        onSurface = Color(0xFF191C1E),
        error = Color(0xFFBA1A1A),
        onError = Color(0xFFFFFFFF)
    )
    
    private val defaultDarkScheme = darkColorScheme(
        primary = Color(0xFF7DD3FC),
        onPrimary = Color(0xFF003547),
        primaryContainer = Color(0xFF004D64),
        onPrimaryContainer = Color(0xFFB6EAFF),
        secondary = Color(0xFFB1C8D4),
        onSecondary = Color(0xFF1C333B),
        secondaryContainer = Color(0xFF334952),
        onSecondaryContainer = Color(0xFFCDE4F0),
        background = Color(0xFF191C1E),
        onBackground = Color(0xFFE1E3E5),
        surface = Color(0xFF191C1E),
        onSurface = Color(0xFFE1E3E5),
        error = Color(0xFFFFB4AB),
        onError = Color(0xFF690005)
    )
}

private fun SeasonalThemeDefinition.isActiveOn(date: LocalDate): Boolean {
    if (dateRanges.isEmpty()) return true // Default theme is always active
    
    val monthDay = "%02d-%02d".format(date.monthNumber, date.dayOfMonth)
    
    return dateRanges.any { range ->
        if (range.start <= range.end) {
            // Normal range (e.g., 03-01 to 03-17)
            monthDay >= range.start && monthDay <= range.end
        } else {
            // Wrapping range (e.g., 12-25 to 01-12)
            monthDay >= range.start || monthDay <= range.end
        }
    }
}

private fun ThemeColors.toColorScheme(isDark: Boolean): ColorScheme {
    return if (isDark) {
        darkColorScheme(
            primary = parseColor(primary),
            onPrimary = parseColor(onPrimary),
            primaryContainer = parseColor(primaryContainer),
            onPrimaryContainer = parseColor(onPrimaryContainer),
            secondary = parseColor(secondary),
            onSecondary = parseColor(onSecondary),
            secondaryContainer = parseColor(secondaryContainer),
            onSecondaryContainer = parseColor(onSecondaryContainer),
            background = parseColor(background),
            onBackground = parseColor(onBackground),
            surface = parseColor(surface),
            onSurface = parseColor(onSurface),
            error = parseColor(error),
            onError = parseColor(onError)
        )
    } else {
        lightColorScheme(
            primary = parseColor(primary),
            onPrimary = parseColor(onPrimary),
            primaryContainer = parseColor(primaryContainer),
            onPrimaryContainer = parseColor(onPrimaryContainer),
            secondary = parseColor(secondary),
            onSecondary = parseColor(onSecondary),
            secondaryContainer = parseColor(secondaryContainer),
            onSecondaryContainer = parseColor(onSecondaryContainer),
            background = parseColor(background),
            onBackground = parseColor(onBackground),
            surface = parseColor(surface),
            onSurface = parseColor(onSurface),
            error = parseColor(error),
            onError = parseColor(onError)
        )
    }
}

private fun parseColor(hex: String): Color {
    val cleanHex = hex.removePrefix("#")
    return Color(("FF$cleanHex").toLong(16))
}
