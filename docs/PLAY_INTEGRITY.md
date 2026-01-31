# Play Integrity API

YetiMatch includes the [Play Integrity API](https://developer.android.com/google/play/integrity) on Android to verify app and device integrity. Configuration and verdict options are documented in `notes.md`.

## What's in the app

- **Dependency:** `com.google.android.play:integrity` (see `gradle/libs.versions.toml` and `composeApp/build.gradle.kts`).
- **Client API:** `com.daddoodev.yetimatch.integrity.requestIntegrityToken(nonce: String): Result<String>` (expect/actual; Android requests a token, iOS returns failure). Use this when you need an integrity token (e.g. before a sensitive action); send the token to your backend for verification.

## Setup (per notes.md)

- **Google Cloud:** Project "YetiMatch"; Play Integrity API enabled.
- **Play Console:** Link the Cloud project under **Test and release > App integrity**.
- **Verdicts:** Device integrity (MEETS_DEVICE_INTEGRITY, MEETS_VIRTUAL_INTEGRITY), Application integrity (PLAY_RECOGNIZED, etc.), App licensing (LICENSED, etc.). Response encryption: managed by Google. Usage tier: Standard.

## Using the token

1. Call `requestIntegrityToken(nonce)` (ideally with a server-generated nonce).
2. On success, send the token to your backend.
3. Backend calls Google's API to decrypt/verify the verdict (see [Verify integrity token on the server](https://developer.android.com/google/play/integrity/verify)).

No token is requested automatically; wire `requestIntegrityToken` where you want to gate (e.g. sign-in, high-value action).
