import 'package:flutter/foundation.dart';

/// Thin wrapper so mobile can use Crashlytics and desktop/tests stay no-op.
abstract class ErrorReporting {
  Future<void> setUserId(String? userId);
  Future<void> log(String message);
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  });
}

class NoOpErrorReporting implements ErrorReporting {
  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> log(String message) async {
    debugPrint(message);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
    String? reason,
  }) async {
    debugPrint('ErrorReporting: $reason $error');
    if (stack != null) debugPrint('$stack');
  }
}
