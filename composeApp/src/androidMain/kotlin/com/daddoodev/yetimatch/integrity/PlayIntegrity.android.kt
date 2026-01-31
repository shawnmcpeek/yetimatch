package com.daddoodev.yetimatch.integrity

import com.daddoodev.yetimatch.QuizResourceHelper
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

actual suspend fun requestIntegrityToken(nonce: String): Result<String> = suspendCoroutine { cont ->
    val context = QuizResourceHelper.context
    if (context == null) {
        cont.resume(Result.failure(IllegalStateException("Context not available")))
        return@suspendCoroutine
    }
    val integrityManager = IntegrityManagerFactory.create(context)
    val request = IntegrityTokenRequest.builder()
        .setNonce(nonce)
        .build()
    integrityManager.requestIntegrityToken(request)
        .addOnSuccessListener { response ->
            cont.resume(Result.success(response.token()))
        }
        .addOnFailureListener { e ->
            cont.resume(Result.failure(e))
        }
}
