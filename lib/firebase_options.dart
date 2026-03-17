import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

import 'config/app_config.dart';

/// Firebase config for desktop (Linux/Windows). Uses YETIMATCH_API_KEY from .env.
FirebaseOptions get desktopFirebaseOptions => FirebaseOptions(
      apiKey: AppConfig.apiKey,
      appId: '1:72821816836:android:10d831dac02e8c6387ff51',
      messagingSenderId: '72821816836',
      projectId: 'yetimatch',
      authDomain: 'yetimatch.firebaseapp.com',
      storageBucket: 'yetimatch.firebasestorage.app',
    );
