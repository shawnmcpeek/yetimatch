package com.daddoodev.yetimatch.auth

import com.daddoodev.yetimatch.QuizResourceHelper

private const val PREFS_NAME = "yetimatch_prefs"
private const val KEY_QUIZ_COUNT = "quizzes_taken_count"

actual fun getQuizzesTakenCount(): Int {
    val ctx = QuizResourceHelper.context ?: return 0
    return ctx.getSharedPreferences(PREFS_NAME, android.content.Context.MODE_PRIVATE)
        .getInt(KEY_QUIZ_COUNT, 0)
}

actual fun setQuizzesTakenCount(count: Int) {
    QuizResourceHelper.context?.getSharedPreferences(PREFS_NAME, android.content.Context.MODE_PRIVATE)
        ?.edit()
        ?.putInt(KEY_QUIZ_COUNT, count)
        ?.apply()
}
