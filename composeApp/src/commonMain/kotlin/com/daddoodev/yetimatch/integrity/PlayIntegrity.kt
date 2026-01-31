package com.daddoodev.yetimatch.integrity

/**
 * Requests a Play Integrity API token (Android only).
 * The token should be sent to your backend for verification; Google recommends
 * using a server-generated nonce for the request.
 * Returns the token string on success, or a failure Result.
 * iOS: not supported; returns Result.failure.
 */
expect suspend fun requestIntegrityToken(nonce: String): Result<String>
