package com.daddoodev.yetimatch

expect fun loadManifestJson(): String
expect fun loadQuizJson(path: String): String

/** Loads a resource file (e.g. image) from the app bundle as raw bytes. Path is relative to resources root, e.g. "quizzes/images/summit_steve.png". */
expect fun loadResourceBytes(path: String): ByteArray?
