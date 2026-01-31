package com.daddoodev.yetimatch.firestore

import com.daddoodev.yetimatch.models.QuizResult

actual suspend fun ensureUserOnSignIn(): Result<Unit> =
    Result.failure(UnsupportedOperationException("Firestore on iOS: add Firebase Firestore iOS SDK and implement"))

actual suspend fun saveQuizResult(quizId: String, quizTitle: String, result: QuizResult): Result<Unit> =
    Result.failure(UnsupportedOperationException("Firestore on iOS: add Firebase Firestore iOS SDK and implement"))

actual suspend fun setUserAgeVerified(verified: Boolean): Result<Unit> =
    Result.failure(UnsupportedOperationException("Firestore on iOS: add Firebase Firestore iOS SDK and implement"))
