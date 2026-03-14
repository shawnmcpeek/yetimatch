import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/quiz.dart';
import 'auth_service_interface.dart';
import 'firestore_service_interface.dart';

/// Firestore via REST API for desktop (Linux/Windows) where cloud_firestore has no implementation.
/// Uses Firebase ID token from Auth and Firestore REST v1.
class FirestoreRestService implements IFirestoreService {
  FirestoreRestService({
    required this.projectId,
    required IAuthService auth,
  }) : _auth = auth;

  final String projectId;
  final IAuthService _auth;

  static const _databaseId = '(default)';
  static const _users = 'users';
  static const _quizResults = 'quizResults';

  String get _baseUrl =>
      'https://firestore.googleapis.com/v1/projects/$projectId/databases/$_databaseId/documents';

  Future<String?> _getIdToken() async {
    return _auth.getIdToken();
  }

  @override
  Future<void> ensureUserOnSignIn() async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    final token = await _getIdToken();
    if (token == null) return;
    final email = _auth.currentUserEmail ?? '';
    final docName = 'projects/$projectId/databases/$_databaseId/documents/$_users/$uid';
    final path = '$_baseUrl/$_users/$uid';
    final now = DateTime.now().toUtc().toIso8601String();
    final body = {
      'name': docName,
      'fields': {
        'email': {'stringValue': email},
        'createdAt': {'timestampValue': now},
      },
    };
    final response = await http.patch(
      Uri.parse(path),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 409) {
      throw Exception('Firestore REST ensureUser: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Future<void> saveQuizResult(
    String quizId,
    String quizTitle,
    QuizResult result,
  ) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    final token = await _getIdToken();
    if (token == null) return;
    final docPath = '$_users/$uid/$_quizResults/$quizId';
    final path = '$_baseUrl/$docPath';
    final now = DateTime.now().toUtc().toIso8601String();
    final body = {
      'name': 'projects/$projectId/databases/$_databaseId/documents/$docPath',
      'fields': {
        'quizId': {'stringValue': quizId},
        'quizTitle': {'stringValue': quizTitle},
        'characterId': {'stringValue': result.characterId},
        'characterName': {'stringValue': result.characterName},
        'description': {'stringValue': result.description},
        'traits': {'arrayValue': {'values': result.traits.map((t) => {'stringValue': t}).toList()}},
        'completedAt': {'timestampValue': now},
      },
    };
    final response = await http.patch(
      Uri.parse(path),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 409) {
      throw Exception('Firestore REST saveQuizResult: ${response.statusCode} ${response.body}');
    }
  }
}
