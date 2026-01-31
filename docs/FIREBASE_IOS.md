# Firebase iOS Setup

The Android app is wired to Firebase via the Google services plugin and `composeApp/google-services.json`. For iOS you configure Firebase in Xcode.

## 1. Add Firebase iOS SDK (Swift Package Manager)

1. Open the iOS app in **Xcode** (e.g. `iosApp/iosApp.xcodeproj`).
2. **File → Add Package Dependencies…**
3. Enter: `https://github.com/firebase/firebase-ios-sdk`
4. Use the default (latest) version.
5. Add at least:
   - **FirebaseAnalytics** (or **FirebaseAnalyticsWithoutAdId** if you don’t need IDFA).
   - **FirebaseAuth** (for email/password sign-in).
6. Click **Add Package** and assign the libraries to your **app** target (not the Compose framework target).

## 2. Add GoogleService-Info.plist

1. In Firebase Console: **Project settings → Your apps → Add app → iOS**.
2. Use your app’s **bundle ID** (e.g. from the Xcode project).
3. Download **GoogleService-Info.plist**.
4. In Xcode, drag it into the **app target** (e.g. under the `iosApp` group) and ensure **Copy items if needed** and the app target are checked.

## 3. Initialize Firebase in the app

In your iOS app’s entry point (e.g. `@main` or `AppDelegate`), call Firebase’s configure **before** running the rest of the app:

```swift
import FirebaseCore

// e.g. in @main struct or application(_:didFinishLaunchingWithOptions:)
FirebaseApp.configure()
```

After this, the shared KMP code can use Firebase Auth via expect/actual once that layer is added.
