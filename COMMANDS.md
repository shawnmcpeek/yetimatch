# YetiMatch – Commands

Run from the project root (`yetimatch`). Use `.\gradlew` on Windows, `./gradlew` on macOS/Linux.

## Android

| Command | What it does |
|--------|----------------|
| `.\gradlew composeApp:assembleDebug` | Build debug APK |
| `.\gradlew clean composeApp:assembleDebug` | Clean, then build debug APK |
| `.\gradlew composeApp:installDebug` | Build and install debug on device/emulator |
| `.\gradlew composeApp:bundleRelease` | Build release AAB (for Play Store) |

## iOS (macOS only)

| Command | What it does |
|--------|----------------|
| `cd iosApp && pod install` | Install CocoaPods (Google Mobile Ads, etc.). Do once or after Podfile changes. |
| `.\gradlew composeApp:linkReleaseFrameworkIosSimulatorArm64` | Build iOS framework for simulator (from project root). |

Then open **iosApp/iosApp.xcworkspace** in Xcode and build/run.

## Gradle

| Command | What it does |
|--------|----------------|
| `.\gradlew --version` | Show Gradle and JVM version |
| `.\gradlew tasks` | List available tasks |
