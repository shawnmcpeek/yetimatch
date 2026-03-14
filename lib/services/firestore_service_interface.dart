import '../models/quiz.dart';

/// Contract for persisting user and quiz result data (Firestore on mobile, REST on desktop).
abstract class IFirestoreService {
  Future<void> ensureUserOnSignIn();
  Future<void> saveQuizResult(
    String quizId,
    String quizTitle,
    QuizResult result,
  );
}
