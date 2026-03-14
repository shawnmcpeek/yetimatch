import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase config for desktop (Linux/Windows). Same project as mobile.
/// Values from google-services.json / GoogleService-Info.plist.
const FirebaseOptions desktopFirebaseOptions = FirebaseOptions(
  apiKey: 'AIzaSyC0yCFGqKfYSc-VyoqeN-DoNTOkIHWOhmI',
  appId: '1:72821816836:android:10d831dac02e8c6387ff51',
  messagingSenderId: '72821816836',
  projectId: 'yetimatch',
  authDomain: 'yetimatch.firebaseapp.com',
  storageBucket: 'yetimatch.firebasestorage.app',
);
