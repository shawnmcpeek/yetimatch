package com.daddoodev.yetimatch.firestore

import com.daddoodev.yetimatch.models.QuizResult

/**
 * Ensures a user document exists in Firestore (users/{uid}) with email and createdAt.
 * Call after sign-in or sign-up so the user exists for quiz progress.
 */
expect suspend fun ensureUserOnSignIn(): Result<Unit>

/**
 * Saves one quiz completion to the authenticated user's quizResults subcollection.
 * Data is stored for all signed-in users; visibility (e.g. history UI) can be gated by paid tier later.
 */
expect suspend fun saveQuizResult(quizId: String, quizTitle: String, result: QuizResult): Result<Unit>

/**
 * Updates the signed-in user's age-verified flag (passed 18+ gate for adult content).
 * No-op if not signed in. Used to persist "passed age test" to user data.
 */
expect suspend fun setUserAgeVerified(verified: Boolean): Result<Unit>
