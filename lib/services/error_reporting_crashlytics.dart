import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'error_reporting.dart';

class CrashlyticsErrorReporting implements ErrorReporting {
  CrashlyticsErrorReporting({FirebaseCrashlytics? crashlytics})
      : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance;

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> setUserId(String? userId) async {
    await _crashlytics.setUserIdentifier(userId ?? '');
  }

  @override
  Future<void> log(String message) async {
    await _crashlytics.log(message);
    debugPrint(message);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) async {
    await _crashlytics.recordError(
      error,
      stack,
      fatal: fatal,
      reason: reason,
    );
  }
}
