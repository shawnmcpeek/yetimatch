/// Contract for auth (Firebase Auth on mobile, REST on desktop).
abstract class IAuthService {
  String? get currentUserEmail;
  String? get currentUserId;

  /// True when signed in via anonymous auth (no email linked yet).
  bool get isAnonymous;

  /// True when signed in with an email identity (not anonymous).
  bool get hasEmailAccount;

  Future<void> signOut();
  Future<String?> getIdToken();

  /// Creates an anonymous Firebase user. No-op if already signed in.
  Future<({String? error})> ensureAnonymousUser();

  Future<({String? error})> signInWithEmail(String email, String password);

  /// Creates an email account, or links email/password onto the current
  /// anonymous user (same uid) when [isAnonymous] is true.
  Future<({String? error})> signUpWithEmail(String email, String password);

  Future<({String? error})> sendPasswordResetEmail(String email);
  Future<({String? error})> deleteAccount();
}
