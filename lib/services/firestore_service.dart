import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quiz.dart';
import '../models/saved_quiz_result.dart';
import 'auth_service.dart';
import 'auth_service_interface.dart';
import 'firestore_service_interface.dart';

class FirestoreService implements IFirestoreService {
  FirestoreService({
    FirebaseFirestore? firestore,
    IAuthService? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? AuthService();

  final FirebaseFirestore _firestore;
  final IAuthService _auth;

  static const _users = 'users';
  static const _quizResults = 'quizResults';

  @override
  Future<void> ensureUserOnSignIn() async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    final email = _auth.currentUserEmail ?? '';
    await _firestore.collection(_users).doc(uid).set(
      {
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> saveQuizResult(
    String quizId,
    String quizTitle,
    QuizResult result,
  ) async {
    final uid = _auth.currentUserId;
    if (uid == null) return;
    await _firestore
        .collection(_users)
        .doc(uid)
        .collection(_quizResults)
        .doc(quizId)
        .set({
      'quizId': quizId,
      'quizTitle': quizTitle,
      'characterId': result.characterId,
      'characterName': result.characterName,
      'description': result.description,
      'traits': result.traits,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<SavedQuizResult>> listQuizResults() async {
    final uid = _auth.currentUserId;
    if (uid == null) return [];
    final snap = await _firestore
        .collection(_users)
        .doc(uid)
        .collection(_quizResults)
        .orderBy('completedAt', descending: true)
        .get();
    return snap.docs.map((doc) {
      final data = doc.data();
      final completed = data['completedAt'];
      DateTime? completedAt;
      if (completed is Timestamp) {
        completedAt = completed.toDate();
      }
      return SavedQuizResult(
        quizId: data['quizId'] as String? ?? doc.id,
        quizTitle: data['quizTitle'] as String? ?? '',
        characterId: data['characterId'] as String? ?? '',
        characterName: data['characterName'] as String? ?? '',
        description: data['description'] as String? ?? '',
        traits: (data['traits'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        completedAt: completedAt,
      );
    }).toList();
  }
}
