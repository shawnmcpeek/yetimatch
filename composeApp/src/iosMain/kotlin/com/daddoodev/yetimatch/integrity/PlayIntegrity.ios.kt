package com.daddoodev.yetimatch.integrity

actual suspend fun requestIntegrityToken(nonce: String): Result<String> =
    Result.failure(UnsupportedOperationException("Play Integrity API is Android only"))
