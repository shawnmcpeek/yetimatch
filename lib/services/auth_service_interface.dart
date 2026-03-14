/// Contract for auth (Firebase Auth on mobile, REST on desktop).
abstract class IAuthService {
  String? get currentUserEmail;
  String? get currentUserId;
  Future<void> signOut();
  Future<String?> getIdToken();
  Future<({String? error})> signInWithEmail(String email, String password);
  Future<({String? error})> signUpWithEmail(String email, String password);
  Future<({String? error})> sendPasswordResetEmail(String email);
  Future<({String? error})> deleteAccount();
}
