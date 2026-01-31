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
    alias(libs.plugins.composeMultiplatform) apply false
    alias(libs.plugins.composeCompiler) apply false
    alias(libs.plugins.kotlinMultiplatform) apply false
    alias(libs.plugins.kotlinSerialization) apply false
    alias(libs.plugins.googleServices) apply false
}