package com.daddoodev.yetimatch.auth

import com.google.firebase.auth.FirebaseAuth
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

private val auth: FirebaseAuth get() = FirebaseAuth.getInstance()

actual suspend fun signInWithEmail(email: String, password: String): Result<Unit> = suspendCoroutine { cont ->
    auth.signInWithEmailAndPassword(email, password)
        .addOnSuccessListener { cont.resume(Result.success(Unit)) }
        .addOnFailureListener { cont.resume(Result.failure(it)) }
}

actual suspend fun signUpWithEmail(email: String, password: String): Result<Unit> = suspendCoroutine { cont ->
    auth.createUserWithEmailAndPassword(email, password)
        .addOnSuccessListener { cont.resume(Result.success(Unit)) }
        .addOnFailureListener { cont.resume(Result.failure(it)) }
}

actual suspend fun sendPasswordResetEmail(email: String): Result<Unit> = suspendCoroutine { cont ->
    auth.sendPasswordResetEmail(email)
        .addOnSuccessListener { cont.resume(Result.success(Unit)) }
        .addOnFailureListener { cont.resume(Result.failure(it)) }
}

actual fun signOut() {
    auth.signOut()
}

actual fun getCurrentUserEmail(): String? = auth.currentUser?.email

actual fun getCurrentUserId(): String? = auth.currentUser?.uid

actual suspend fun deleteAccount(): Result<Unit> = suspendCoroutine { cont ->
    val user = auth.currentUser
    if (user == null) {
        cont.resume(Result.failure(IllegalStateException("No user signed in")))
        return@suspendCoroutine
    }
    user.delete()
        .addOnSuccessListener { cont.resume(Result.success(Unit)) }
        .addOnFailureListener { cont.resume(Result.failure(it)) }
}
