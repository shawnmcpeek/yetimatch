import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service_interface.dart';

class AuthService implements IAuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  String? get currentUserEmail => _auth.currentUser?.email;

  @override
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  @override
  bool get hasEmailAccount {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    return user.email != null && user.email!.isNotEmpty;
  }

  @override
  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken(true);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<({String? error})> ensureAnonymousUser() async {
    if (_auth.currentUser != null) return (error: null);
    try {
      await _auth.signInAnonymously();
      return (error: null);
    } on FirebaseAuthException catch (e) {
      return (error: e.message ?? 'Anonymous sign-in failed');
    }
  }

  @override
  Future<({String? error})> signInWithEmail(String email, String password) async {
    try {
      // Cannot link an existing email account onto anonymous; switch sessions.
      if (_auth.currentUser?.isAnonymous == true) {
        await _auth.signOut();
      }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return (error: null);
    } on FirebaseAuthException catch (e) {
      return (error: e.message ?? 'Sign in failed');
    }
  }

  @override
  Future<({String? error})> signUpWithEmail(String email, String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        await user.linkWithCredential(credential);
        return (error: null);
      }
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return (error: null);
    } on FirebaseAuthException catch (e) {
      return (error: e.message ?? 'Sign up failed');
    }
  }

  @override
  Future<({String? error})> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return (error: null);
    } on FirebaseAuthException catch (e) {
      return (error: e.message ?? 'Failed to send reset email');
    }
  }

  @override
  Future<({String? error})> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return (error: 'No user signed in');
    try {
      await user.delete();
      return (error: null);
    } on FirebaseAuthException catch (e) {
      return (error: e.message ?? 'Could not delete account');
    }
  }
}
