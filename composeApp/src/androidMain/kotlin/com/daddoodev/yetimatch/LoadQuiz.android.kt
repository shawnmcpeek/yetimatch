package com.daddoodev.yetimatch

actual fun loadQuizJson(): String {
    val ctx = QuizResourceHelper.context
        ?: error("QuizResourceHelper.context not set. Call QuizResourceHelper.context = applicationContext in MainActivity.onCreate.")
    return ctx.assets.open("quizzes/sample_quiz.json")
        .bufferedReader()
        .use { it.readText() }
}
