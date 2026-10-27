import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service_interface.dart';

const _baseAuthUrl = 'https://identitytoolkit.googleapis.com/v1/accounts';
const _secureTokenUrl = 'https://securetoken.googleapis.com/v1/token';

/// Firebase Auth via REST API for desktop (Linux/Windows).
class AuthRestService implements IAuthService {
  AuthRestService({required this.apiKey});

  final String apiKey;

  String? _idToken;
  String? _refreshToken;
  DateTime? _expiresAt;
  String? _localId;
  String? _email;
  bool _isAnonymous = false;

  @override
  String? get currentUserEmail => _email;

  @override
  String? get currentUserId => _localId;

  @override
  bool get isAnonymous => _localId != null && _isAnonymous;

  @override
  bool get hasEmailAccount =>
      _localId != null && !_isAnonymous && _email != null && _email!.isNotEmpty;

  @override
  Future<String?> getIdToken() async {
    if (_idToken == null) return null;
    if (_expiresAt != null &&
        DateTime.now()
            .isBefore(_expiresAt!.subtract(const Duration(minutes: 5)))) {
      return _idToken;
    }
    if (_refreshToken != null) {
      final refreshed = await _refreshIdToken();
      if (refreshed) return _idToken;
    }
    return null;
  }

  Future<bool> _refreshIdToken() async {
    if (_refreshToken == null) return false;
    try {
      final response = await http.post(
        Uri.parse('$_secureTokenUrl?key=$apiKey'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: 'grant_type=refresh_token&refresh_token=$_refreshToken',
      );
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _idToken = data['id_token'] as String?;
      _refreshToken = data['refresh_token'] as String? ?? _refreshToken;
      final expiresIn =
          int.tryParse(data['expires_in']?.toString() ?? '3600') ?? 3600;
      _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
      return _idToken != null;
    } catch (_) {
      return false;
    }
  }

  void _setFromResponse(Map<String, dynamic> data, {required bool anonymous}) {
    _idToken = data['idToken'] as String?;
    _refreshToken = data['refreshToken'] as String?;
    _email = data['email'] as String?;
    _localId = data['localId'] as String?;
    final expiresIn =
        int.tryParse(data['expiresIn']?.toString() ?? '3600') ?? 3600;
    _expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    _isAnonymous = anonymous;
  }

  String? _errorFromResponse(int statusCode, String body) {
    if (statusCode == 200) return null;
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final err = data['error'] as Map<String, dynamic>?;
      return err?['message'] as String? ?? 'Request failed';
    } catch (_) {
      return 'Request failed';
    }
  }

  @override
  Future<({String? error})> ensureAnonymousUser() async {
    if (_localId != null) return (error: null);
    try {
      final response = await http.post(
        Uri.parse('$_baseAuthUrl:signUp?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'returnSecureToken': true}),
      );
      final err = _errorFromResponse(response.statusCode, response.body);
      if (err != null) return (error: err);
      _setFromResponse(
        jsonDecode(response.body) as Map<String, dynamic>,
        anonymous: true,
      );
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }

  @override
  Future<({String? error})> signInWithEmail(String email, String password) async {
    try {
      if (_isAnonymous) {
        await signOut();
      }
      final response = await http.post(
        Uri.parse('$_baseAuthUrl:signInWithPassword?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final err = _errorFromResponse(response.statusCode, response.body);
      if (err != null) return (error: err);
      _setFromResponse(
        jsonDecode(response.body) as Map<String, dynamic>,
        anonymous: false,
      );
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }

  @override
  Future<({String? error})> signUpWithEmail(String email, String password) async {
    try {
      if (_isAnonymous && _idToken != null) {
        final token = await getIdToken();
        if (token == null) return (error: 'No user signed in');
        final response = await http.post(
          Uri.parse('$_baseAuthUrl:update?key=$apiKey'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'idToken': token,
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }),
        );
        final err = _errorFromResponse(response.statusCode, response.body);
        if (err != null) return (error: err);
        _setFromResponse(
          jsonDecode(response.body) as Map<String, dynamic>,
          anonymous: false,
        );
        return (error: null);
      }

      final response = await http.post(
        Uri.parse('$_baseAuthUrl:signUp?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      final err = _errorFromResponse(response.statusCode, response.body);
      if (err != null) return (error: err);
      _setFromResponse(
        jsonDecode(response.body) as Map<String, dynamic>,
        anonymous: false,
      );
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }

  @override
  Future<({String? error})> sendPasswordResetEmail(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseAuthUrl:sendOobCode?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestType': 'PASSWORD_RESET',
          'email': email,
        }),
      );
      final err = _errorFromResponse(response.statusCode, response.body);
      return (error: err);
    } catch (e) {
      return (error: e.toString());
    }
  }

  @override
  Future<({String? error})> deleteAccount() async {
    final token = await getIdToken();
    if (token == null) return (error: 'No user signed in');
    try {
      final response = await http.post(
        Uri.parse('$_baseAuthUrl:delete?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': token}),
      );
      final err = _errorFromResponse(response.statusCode, response.body);
      if (err != null) return (error: err);
      await signOut();
      return (error: null);
    } catch (e) {
      return (error: e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    _idToken = null;
    _refreshToken = null;
    _expiresAt = null;
    _localId = null;
    _email = null;
    _isAnonymous = false;
  }
}
