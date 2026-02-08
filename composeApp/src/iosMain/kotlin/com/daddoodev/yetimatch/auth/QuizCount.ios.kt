package com.daddoodev.yetimatch.auth

import kotlinx.cinterop.ExperimentalForeignApi
import platform.Foundation.NSHomeDirectory
import platform.Foundation.NSString
import platform.Foundation.NSUTF8StringEncoding
import platform.Foundation.stringWithContentsOfFile
import platform.Foundation.writeToFile

private const val FILENAME = "yetimatch_quiz_count.txt"

private fun quizCountPath(): String {
    val home = NSHomeDirectory()
    return "$home/Documents/$FILENAME"
}

@OptIn(ExperimentalForeignApi::class)
actual fun getQuizzesTakenCount(): Int {
    val path = quizCountPath()
    val content = NSString.stringWithContentsOfFile(path, NSUTF8StringEncoding, null) as? String ?: return 0
    return content.trim().toIntOrNull() ?: 0
}

@OptIn(ExperimentalForeignApi::class)
actual fun setQuizzesTakenCount(count: Int) {
    val path = quizCountPath()
    (count.toString() as NSString).writeToFile(path, atomically = true, encoding = NSUTF8StringEncoding.toULong(), error = null)
}
