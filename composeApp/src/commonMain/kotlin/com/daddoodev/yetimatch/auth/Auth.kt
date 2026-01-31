package com.daddoodev.yetimatch.auth

expect suspend fun signInWithEmail(email: String, password: String): Result<Unit>
expect suspend fun signUpWithEmail(email: String, password: String): Result<Unit>
expect fun signOut()
expect fun getCurrentUserEmail(): String?
/** Deletes the current user's account and all server-side data. Required for App Store (account deletion). */
expect suspend fun deleteAccount(): Result<Unit>
