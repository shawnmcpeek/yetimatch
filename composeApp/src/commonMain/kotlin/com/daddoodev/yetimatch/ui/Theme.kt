package com.daddoodev.yetimatch.ui

import androidx.compose.foundation.Image
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Switch
import androidx.compose.material3.SwitchDefaults
import androidx.compose.material3.Text
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.compositionLocalOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import org.jetbrains.compose.resources.painterResource
import yetimatch.composeapp.generated.resources.logoDark
import yetimatch.composeapp.generated.resources.logoLight

val LocalUseDarkLogo = compositionLocalOf { false }
val LocalSeasonalThemeName = compositionLocalOf { "Default" }

enum class ThemeMode { Light, Dark, System }

// Fallback colors if seasonal themes aren't loaded
private val YetiMatchDarkColors = darkColorScheme(
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

private val YetiMatchLightColors = lightColorScheme(
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

@Composable
fun YetiMatchTheme(
    themeMode: ThemeMode = ThemeMode.System,
    seasonalThemesEnabled: Boolean = true,
    content: @Composable () -> Unit
) {
    val darkTheme = when (themeMode) {
        ThemeMode.Light -> false
        ThemeMode.Dark -> true
        ThemeMode.System -> isSystemInDarkTheme()
    }
    
    val colorScheme = if (seasonalThemesEnabled) {
        SeasonalThemeManager.resolveTheme(isDarkMode = darkTheme)
    } else {
        if (darkTheme) YetiMatchDarkColors else YetiMatchLightColors
    }
    
    val themeName = if (seasonalThemesEnabled) {
        SeasonalThemeManager.getCurrentThemeName()
    } else {
        "Default"
    }
    
    CompositionLocalProvider(
        LocalUseDarkLogo provides darkTheme,
        LocalSeasonalThemeName provides themeName
    ) {
        MaterialTheme(
            colorScheme = colorScheme,
            typography = MaterialTheme.typography,
            content = content
        )
    }
}

@Composable
fun YetiMatchLogo(
    modifier: Modifier = Modifier,
    size: Dp = 48.dp,
    contentDescription: String? = "YetiMatch logo"
) {
    val useDark = LocalUseDarkLogo.current
    Image(
        painter = painterResource(if (useDark) logoDark else logoLight),
        contentDescription = contentDescription,
        modifier = modifier.size(size),
        contentScale = ContentScale.Fit
    )
}

@Composable
fun ThemeModeToggle(
    themeMode: ThemeMode,
    onThemeModeChange: (ThemeMode) -> Unit,
    modifier: Modifier = Modifier
) {
    val darkTheme = when (themeMode) {
        ThemeMode.Light -> false
        ThemeMode.Dark -> true
        ThemeMode.System -> isSystemInDarkTheme()
    }
    val onSurface = MaterialTheme.colorScheme.onSurface
    val primary = MaterialTheme.colorScheme.primary
    Row(
        modifier = modifier.padding(horizontal = 4.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = "☀",
            fontSize = 20.sp,
            color = if (!darkTheme) primary else onSurface.copy(alpha = 0.6f)
        )
        Switch(
            checked = darkTheme,
            onCheckedChange = { onThemeModeChange(if (it) ThemeMode.Dark else ThemeMode.Light) },
            modifier = Modifier.padding(horizontal = 4.dp),
            colors = SwitchDefaults.colors(
                checkedThumbColor = primary,
                checkedTrackColor = MaterialTheme.colorScheme.primaryContainer,
                uncheckedThumbColor = MaterialTheme.colorScheme.outline,
                uncheckedTrackColor = MaterialTheme.colorScheme.surfaceVariant
            )
        )
        Text(
            text = "🌙",
            fontSize = 18.sp,
            color = if (darkTheme) primary else onSurface.copy(alpha = 0.6f)
        )
    }
}
