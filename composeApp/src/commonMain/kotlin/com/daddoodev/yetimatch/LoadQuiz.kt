package com.daddoodev.yetimatch

import org.jetbrains.compose.resources.ExperimentalResourceApi
import yetimatch.composeapp.generated.resources.Res

@OptIn(ExperimentalResourceApi::class)
suspend fun loadManifestJson(): String {
    return Res.readBytes("files/manifest.json").decodeToString()
}

@OptIn(ExperimentalResourceApi::class)
suspend fun loadQuizJson(path: String): String {
    // path comes as "quizzes/xyz.json", we need "files/quizzes/xyz.json"
    val resourcePath = if (path.startsWith("files/")) path else "files/$path"
    return Res.readBytes(resourcePath).decodeToString()
}

@OptIn(ExperimentalResourceApi::class)
suspend fun loadThemesJson(): String {
    return Res.readBytes("files/themes.json").decodeToString()
}

@OptIn(ExperimentalResourceApi::class)
suspend fun loadResourceBytes(path: String): ByteArray? {
    return try {
        val resourcePath = if (path.startsWith("files/")) path else "files/$path"
        Res.readBytes(resourcePath)
    } catch (_: Exception) {
        null
    }
}
