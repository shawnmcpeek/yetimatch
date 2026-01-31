package com.daddoodev.yetimatch.preferences

/**
 * Returns whether the user has passed the age gate (18+) for adult content.
 * Global flag: once set, no re-prompt in any category.
 */
expect fun getAgeVerified(): Boolean

/**
 * Persists that the user has passed the age gate.
 */
expect fun setAgeVerified(verified: Boolean)
