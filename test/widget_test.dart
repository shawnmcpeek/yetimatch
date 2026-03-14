import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yetimatch/app/yeti_match_app.dart';
import 'package:yetimatch/models/quiz.dart';
import 'package:yetimatch/services/auth_service_interface.dart';
import 'package:yetimatch/services/firestore_service_interface.dart';
import 'package:yetimatch/services/prefs_service.dart';

void main() {
  group('YetiMatchApp', () {
    testWidgets('pumps without throwing', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await PrefsService.init();
      final auth = _FakeAuthService();
      final firestore = _FakeFirestoreService();

      await tester.pumpWidget(
        YetiMatchApp(
          prefs: prefs,
          auth: auth,
          firestore: firestore,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}

class _FakeAuthService implements IAuthService {
  @override
  String? get currentUserEmail => null;

  @override
  String? get currentUserId => null;

  @override
  Future<({String? error})> deleteAccount() async => (error: null);

  @override
  Future<String?> getIdToken() async => null;

  @override
  Future<({String? error})> sendPasswordResetEmail(String email) async =>
      (error: null);

  @override
  Future<({String? error})> signInWithEmail(String email, String password) async =>
      (error: null);

  @override
  Future<({String? error})> signUpWithEmail(String email, String password) async =>
      (error: null);

  @override
  Future<void> signOut() async {}
}

class _FakeFirestoreService implements IFirestoreService {
  @override
  Future<void> ensureUserOnSignIn() async {}

  @override
  Future<void> saveQuizResult(
    String quizId,
    String quizTitle,
    QuizResult result,
  ) async {}
}
