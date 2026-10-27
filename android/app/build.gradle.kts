import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    // Kotlin comes from AGP built-in Kotlin or Flutter's legacy KGP path
    // (android.builtInKotlin=false). Do not apply kotlin-android here.
    id("dev.flutter.flutter-gradle-plugin")
}

apply(plugin = "com.google.gms.google-services")

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasReleaseKeystore = keystorePropertiesFile.exists()
if (hasReleaseKeystore) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

gradle.taskGraph.whenReady {
    val wantsReleaseArtifact = allTasks.any { task ->
        val n = task.name.lowercase()
        (n.contains("bundle") && n.contains("release")) ||
            (n.contains("assemble") && n.contains("release"))
    }
    if (wantsReleaseArtifact && !hasReleaseKeystore) {
        throw GradleException(
            "Release AAB/APK requires android/key.properties (upload keystore). " +
                "Codemagic generates this when android_signing is configured. " +
                "See https://docs.flutter.dev/deployment/android#sign-the-app",
        )
    }
}

android {
    namespace = "com.daddoodev.yetimatch"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                // Paths in key.properties are relative to android/ (same dir as key.properties), not android/app/
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    defaultConfig {
        applicationId = "com.daddoodev.yetimatch"
        // Firebase Android BoM 35 / FlutterFire 5.x require minSdk 24.
        // RevenueCat 10.x requires minSdk 23.
        minSdk = maxOf(flutter.minSdkVersion, 24)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            if (hasReleaseKeystore) {
                signingConfig = signingConfigs.getByName("release")
            }
            ndk {
                debugSymbolLevel = "SYMBOL_TABLE"
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
