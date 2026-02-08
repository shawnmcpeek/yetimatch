buildscript {
    dependencies {
        // AGP 9 defaults to KGP 2.2.10; use project Kotlin 2.3.0
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:2.3.0")
    }
}

plugins {
    // this is necessary to avoid the plugins to be loaded multiple times
    // in each subproject's classloader
    alias(libs.plugins.androidApplication) apply false
    alias(libs.plugins.androidLibrary) apply false
    alias(libs.plugins.androidMultiplatformLibrary) apply false
    alias(libs.plugins.composeMultiplatform) apply false
    alias(libs.plugins.composeCompiler) apply false
    alias(libs.plugins.kotlinMultiplatform) apply false
    alias(libs.plugins.kotlinSerialization) apply false
    alias(libs.plugins.googleServices) apply false
}

tasks.register("syncVersionToIos") {
    description = "Syncs app version from gradle.properties into iOS Config.xcconfig"
    val versionCode = providers.gradleProperty("app.versionCode")
    val versionName = providers.gradleProperty("app.versionName")
    val xcconfig = layout.projectDirectory.file("iosApp/Configuration/Config.xcconfig")
    doLast {
        val code = versionCode.get()
        val name = versionName.get()
        val file = xcconfig.asFile
        val content = file.readText()
            .replace(Regex("CURRENT_PROJECT_VERSION=.*"), "CURRENT_PROJECT_VERSION=$code")
            .replace(Regex("MARKETING_VERSION=.*"), "MARKETING_VERSION=$name")
        file.writeText(content)
        println("iOS version synced: CURRENT_PROJECT_VERSION=$code, MARKETING_VERSION=$name")
    }
}