package com.daddoodev.yetimatch.auth

// iOS: Wire Firebase Auth via Swift bridge or use firebase-kotlin-sdk when ready.
// Until then, auth is unavailable on iOS (gate will require sign-in; use Android to test).
actual suspend fun signInWithEmail(email: String, password: String): Result<Unit> =
    Result.failure(UnsupportedOperationException("Firebase Auth on iOS: add FirebaseAuth iOS SDK and bridge from Swift/Kotlin"))

actual suspend fun signUpWithEmail(email: String, password: String): Result<Unit> =
    Result.failure(UnsupportedOperationException("Firebase Auth on iOS: add FirebaseAuth iOS SDK and bridge from Swift/Kotlin"))

actual fun signOut() {}

actual fun getCurrentUserEmail(): String? = null

actual suspend fun deleteAccount(): Result<Unit> =
    Result.failure(UnsupportedOperationException("Firebase Auth on iOS: implement when Firebase Auth iOS is wired"))
