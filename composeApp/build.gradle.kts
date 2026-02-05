import org.jetbrains.compose.desktop.application.dsl.TargetFormat
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.io.File
import java.util.Properties

plugins {
    alias(libs.plugins.kotlinMultiplatform)
    alias(libs.plugins.androidApplication)
    alias(libs.plugins.composeMultiplatform)
    alias(libs.plugins.composeCompiler)
    alias(libs.plugins.kotlinSerialization)
    alias(libs.plugins.googleServices)
}

compose.resources {
    publicResClass = true
}

val generateApiKey = tasks.register("generateApiKey") {
    val outDir = layout.buildDirectory.dir("generated/apiConfig")
    val rootDir = layout.projectDirectory.dir("..").asFile
    outputs.dir(outDir)
    doLast {
        val envFile = File(rootDir, ".env")
        val envKey = System.getenv("YETIMATCH_API_KEY")
            ?: envFile.takeIf { f -> f.exists() }?.readLines()?.firstOrNull { line: String -> line.startsWith("YETIMATCH_API_KEY=") }?.substringAfter("=")?.trim()?.trim('"')
            ?: ""
        val pkgDir = outDir.get().asFile.resolve("com/daddoodev/yetimatch/api")
        pkgDir.mkdirs()
        pkgDir.resolve("ApiConfig.kt").writeText("""
package com.daddoodev.yetimatch.api

internal object ApiConfig {
    const val API_KEY = "$envKey"
}
""".trimIndent())
    }
}

kotlin {
    androidTarget {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_11)
        }
    }
    
    listOf(
        iosArm64(),
        iosSimulatorArm64()
    ).forEach { iosTarget ->
        iosTarget.binaries.framework {
            baseName = "ComposeApp"
            isStatic = true
        }
    }
    
    sourceSets {
        commonMain.get().kotlin.srcDir(generateApiKey.map { layout.buildDirectory.dir("generated/apiConfig") })
        androidMain.dependencies {
            implementation(libs.ktor.client.okhttp)
            implementation(libs.compose.uiToolingPreview)
            implementation(libs.androidx.activity.compose)
            implementation(project.dependencies.platform("com.google.firebase:firebase-bom:34.8.0"))
            implementation("com.google.firebase:firebase-analytics")
            implementation("com.google.firebase:firebase-auth")
            implementation("com.google.firebase:firebase-firestore")
            implementation(libs.kotlinx.coroutines.play.services)
            implementation("com.google.android.gms:play-services-ads:23.6.0")
            implementation(libs.play.integrity)
        }
        commonMain.dependencies {
            implementation(libs.ktor.client.core)
            implementation(libs.ktor.client.content.negotiation)
            implementation(libs.ktor.serialization.kotlinx.json)
            implementation(libs.compose.runtime)
            implementation(libs.compose.foundation)
            implementation(libs.compose.material3)
            implementation(libs.compose.ui)
            implementation(libs.compose.components.resources)
            implementation(libs.compose.uiToolingPreview)
            implementation(libs.androidx.lifecycle.viewmodelCompose)
            implementation(libs.androidx.lifecycle.runtimeCompose)
            implementation(libs.kotlinx.serialization.json)
            implementation(libs.kotlinx.coroutines.core)
        }
        iosMain.dependencies {
            implementation(libs.ktor.client.darwin)
        }
        commonTest.dependencies {
            implementation(libs.kotlin.test)
        }
    }
}

android {
    namespace = "com.daddoodev.yetimatch"
    compileSdk = libs.versions.android.compileSdk.get().toInt()

    sourceSets.getByName("main").assets.srcDirs("src/commonMain/resources")

    val keystorePropertiesFile = rootProject.file("keystore.properties")
    val useCodemagicSigning = System.getenv("CM_KEYSTORE_PATH") != null
    if (keystorePropertiesFile.exists() || useCodemagicSigning) {
        signingConfigs {
            create("release") {
                if (useCodemagicSigning) {
                    storeFile = file(System.getenv("CM_KEYSTORE_PATH")!!)
                    storePassword = System.getenv("CM_KEYSTORE_PASSWORD")
                    keyAlias = System.getenv("CM_KEY_ALIAS")
                    keyPassword = System.getenv("CM_KEY_PASSWORD")
                } else {
                    val keystoreProperties = Properties()
                    keystoreProperties.load(keystorePropertiesFile.inputStream())
                    keyAlias = keystoreProperties["keyAlias"] as String
                    keyPassword = keystoreProperties["keyPassword"] as String
                    storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                    storePassword = keystoreProperties["storePassword"] as String
                }
            }
        }
    }

    defaultConfig {
        applicationId = "com.daddoodev.yetimatch"
        minSdk = libs.versions.android.minSdk.get().toInt()
        targetSdk = libs.versions.android.targetSdk.get().toInt()
        versionCode = 1
        versionName = "1.0"
    }
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
    buildTypes {
        getByName("release") {
            isMinifyEnabled = false
            if (keystorePropertiesFile.exists() || useCodemagicSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    debugImplementation(libs.compose.uiTooling)
}

