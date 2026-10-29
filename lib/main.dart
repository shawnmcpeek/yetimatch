import 'dart:async';
import 'dart:io' show Platform;

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/yeti_match_app.dart';
import 'config/app_config.dart';
import 'firebase_options.dart';
import 'services/auth_rest_service.dart';
import 'services/auth_service.dart';
import 'services/auth_service_interface.dart';
import 'services/error_reporting.dart';
import 'services/error_reporting_crashlytics.dart';
import 'services/firestore_rest_service.dart';
import 'services/firestore_service.dart';
import 'services/firestore_service_interface.dart';
import 'services/prefs_service.dart';
import 'services/quiz_api.dart';

Future<void> main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    AppConfig.init();

    final isDesktop = Platform.isLinux || Platform.isWindows;
    ErrorReporting errorReporting = NoOpErrorReporting();
    QuizApi quizApi = QuizApi();

    if (!isDesktop) {
      await Firebase.initializeApp();

      await FirebaseAppCheck.instance.activate(
        providerAndroid: kDebugMode
            ? const AndroidDebugProvider()
            : const AndroidPlayIntegrityProvider(),
        providerApple: kDebugMode
            ? const AppleDebugProvider()
            : const AppleAppAttestWithDeviceCheckFallbackProvider(),
      );

      // Enables Crashlytics breadcrumb logs when Analytics is on in the project.
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);

      errorReporting = CrashlyticsErrorReporting();
      FlutterError.onError = (details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      quizApi = QuizApi(
        getAppCheckToken: () => FirebaseAppCheck.instance.getToken(),
      );
    } else {
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        errorReporting.recordError(
          details.exception,
          details.stack,
          fatal: true,
          reason: 'FlutterError',
        );
      };
    }

    final prefs = await PrefsService.init();
    // Desktop Auth REST must use the Firebase Web API key, not the quiz API key.
    final IAuthService auth = isDesktop
        ? AuthRestService(apiKey: desktopFirebaseOptions.apiKey)
        : AuthService();

    final IFirestoreService firestore = isDesktop
        ? FirestoreRestService(projectId: 'yetimatch', auth: auth)
        : FirestoreService(auth: auth);

    // RevenueCat must NOT run in main() before runApp: Purchases.configure can
    // block for a long time (network / Store), which leaves the native splash
    // up forever on Android and a blank screen on iOS.

    runApp(YetiMatchApp(
      prefs: prefs,
      auth: auth,
      firestore: firestore,
      errorReporting: errorReporting,
      quizApi: quizApi,
    ));
  }, (error, stack) async {
    debugPrint('Uncaught zone error: $error');
    try {
      if (!Platform.isLinux && !Platform.isWindows) {
        await FirebaseCrashlytics.instance
            .recordError(error, stack, fatal: true);
      }
    } catch (_) {}
  });
}
