package com.daddoodev.yetimatch

import platform.Foundation.NSBundle
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.NSString

actual fun loadQuizJson(): String {
    val path = NSBundle.mainBundle.pathForResource("sample_quiz", "json", "quizzes")
        ?: error("sample_quiz.json not found in bundle (quizzes/sample_quiz.json)")
    return NSString.stringWithContentsOfFile(path, NSUTF8StringEncoding, null) as String
}
