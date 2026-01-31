package com.daddoodev.yetimatch.firestore

import android.util.Log
import com.daddoodev.yetimatch.auth.getCurrentUserEmail
import com.daddoodev.yetimatch.auth.getCurrentUserId
import com.daddoodev.yetimatch.models.QuizResult
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.SetOptions
import kotlinx.coroutines.tasks.await

private const val USERS = "users"
private const val QUIZ_RESULTS = "quizResults"
private const val EMAIL = "email"
private const val CREATED_AT = "createdAt"
private const val QUIZ_ID = "quizId"
private const val QUIZ_TITLE = "quizTitle"
private const val CHARACTER_ID = "characterId"
private const val CHARACTER_NAME = "characterName"
private const val DESCRIPTION = "description"
private const val TRAITS = "traits"
private const val COMPLETED_AT = "completedAt"
private const val AGE_VERIFIED = "ageVerified"

private const val TAG = "YetiMatch/Firestore"
private val firestore: FirebaseFirestore get() = FirebaseFirestore.getInstance()

actual suspend fun ensureUserOnSignIn(): Result<Unit> = runCatching {
    val uid = getCurrentUserId()
    if (uid == null) {
        Log.w(TAG, "ensureUserOnSignIn: no uid (not signed in?)")
        return@runCatching
    }
    val email = getCurrentUserEmail() ?: ""
    val userRef = firestore.collection(USERS).document(uid)
    val data = mapOf(
        EMAIL to email,
        CREATED_AT to com.google.firebase.Timestamp.now()
    )
    userRef.set(data, SetOptions.merge()).await()
    Log.d(TAG, "ensureUserOnSignIn: wrote users/$uid")
}.onFailure { e -> Log.e(TAG, "ensureUserOnSignIn failed", e) }

actual suspend fun saveQuizResult(quizId: String, quizTitle: String, result: QuizResult): Result<Unit> = runCatching {
    val uid = getCurrentUserId()
    if (uid == null) {
        Log.w(TAG, "saveQuizResult: no uid")
        return@runCatching
    }
    val col = firestore.collection(USERS).document(uid).collection(QUIZ_RESULTS)
    val data = mapOf(
        QUIZ_ID to quizId,
        QUIZ_TITLE to quizTitle,
        CHARACTER_ID to result.characterId,
        CHARACTER_NAME to result.characterName,
        DESCRIPTION to result.description,
        TRAITS to result.traits,
        COMPLETED_AT to com.google.firebase.Timestamp.now()
    )
    col.document(quizId).set(data).await()
    Log.d(TAG, "saveQuizResult: wrote quiz $quizId for users/$uid")
}.onFailure { e -> Log.e(TAG, "saveQuizResult failed", e) }

actual suspend fun setUserAgeVerified(verified: Boolean): Result<Unit> = runCatching {
    val uid = getCurrentUserId()
    if (uid == null) return@runCatching
    firestore.collection(USERS).document(uid).set(mapOf(AGE_VERIFIED to verified), SetOptions.merge()).await()
    Log.d(TAG, "setUserAgeVerified: users/$uid ageVerified=$verified")
}.onFailure { e -> Log.e(TAG, "setUserAgeVerified failed", e) }
