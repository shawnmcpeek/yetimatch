# KMP Development Guidelines

## File Organization
```
composeApp/
├── src/
│   ├── commonMain/        # Shared code (works on all platforms)
│   ├── androidMain/       # Android-specific code
│   ├── iosMain/          # iOS-specific code
│   └── commonTest/       # Shared tests
```

## When to use expect/actual
Use expect/actual for:
- File system access
- Platform-specific UI components
- Native API calls
- Platform capabilities

Example:
```kotlin
// commonMain
expect fun getPlatformName(): String

// androidMain
actual fun getPlatformName(): String = "Android"

// iosMain  
actual fun getPlatformName(): String = "iOS"
```

## UI: Material 3 and Theming
- Use Material 3 (Compose Material3) for all UI: MaterialTheme, Scaffold, TopAppBar, Button, Card, etc.
- Theme in `commonMain/.../ui/Theme.kt`: `YetiMatchTheme(themeMode)`, `YetiMatchLightColors`, `YetiMatchDarkColors`.
- Support light/dark: `ThemeMode` (Light, Dark, System); expose `ThemeModeToggle` in the app bar.
- Use `MaterialTheme.colorScheme` and `MaterialTheme.typography` in composables; avoid hard-coded colors.

## Resource Loading
Resources must be in commonMain/resources and accessed via:
```kotlin
// Wrong - won't work in KMP
val stream = File("quiz.json").inputStream()

// Correct - use expect/actual for KMP (e.g. loadQuizJson()); classLoader is JVM-only
```

## 3. **Custom Cursor Composer Instructions**

In Cursor Settings → Composer, add custom instructions:
```
When working with Kotlin Multiplatform projects:
- Always place shared code in commonMain
- Use expect/actual for platform-specific code
- Prefer kotlinx libraries over platform-specific ones
- Use Compose Multiplatform for UI
- Remind me when I'm using platform-specific APIs in shared code