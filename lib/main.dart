import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/yeti_match_app.dart';
import 'config/app_config.dart';
import 'services/auth_rest_service.dart';
import 'services/auth_service.dart';
import 'services/auth_service_interface.dart';
import 'services/firestore_rest_service.dart';
import 'services/firestore_service.dart';
import 'services/firestore_service_interface.dart';
import 'services/prefs_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.init();

  final isDesktop = Platform.isLinux || Platform.isWindows;

  if (!isDesktop) {
    await Firebase.initializeApp();
  }
  // Desktop uses Auth REST + Firestore REST only; no Firebase SDK init
  //
  // RevenueCat must NOT run in main() before runApp: Purchases.configure can
  // block for a long time (network / Store), which leaves the native splash
  // up forever on Android and a blank screen on iOS.

  final prefs = await PrefsService.init();
  final IAuthService auth = isDesktop
      ? AuthRestService(apiKey: AppConfig.apiKey)
      : AuthService();

  final IFirestoreService firestore = isDesktop
      ? FirestoreRestService(projectId: 'yetimatch', auth: auth)
      : FirestoreService(auth: auth);

  runApp(YetiMatchApp(
    prefs: prefs,
    auth: auth,
    firestore: firestore,
  ));
}
