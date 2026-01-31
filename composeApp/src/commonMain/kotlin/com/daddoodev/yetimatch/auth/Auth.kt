package com.daddoodev.yetimatch.auth

expect suspend fun signInWithEmail(email: String, password: String): Result<Unit>
expect suspend fun signUpWithEmail(email: String, password: String): Result<Unit>
/** Sends a password-reset email to the given address. */
expect suspend fun sendPasswordResetEmail(email: String): Result<Unit>
expect fun signOut()
expect fun getCurrentUserEmail(): String?
/** Firebase Auth UID for the current user; null if signed out. Used for Firestore user doc and quiz results. */
expect fun getCurrentUserId(): String?
/** Deletes the current user's account and all server-side data. Required for App Store (account deletion). */
expect suspend fun deleteAccount(): Result<Unit>
