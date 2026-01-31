package com.daddoodev.yetimatch

actual fun loadManifestJson(): String {
    val ctx = QuizResourceHelper.context
        ?: error("QuizResourceHelper.context not set. Call QuizResourceHelper.context = applicationContext in MainActivity.onCreate.")
    return ctx.assets.open("manifest.json")
        .bufferedReader()
        .use { it.readText() }
}

actual fun loadQuizJson(path: String): String {
    val ctx = QuizResourceHelper.context
        ?: error("QuizResourceHelper.context not set. Call QuizResourceHelper.context = applicationContext in MainActivity.onCreate.")
    return ctx.assets.open(path)
        .bufferedReader()
        .use { it.readText() }
}
