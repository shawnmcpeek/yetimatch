import '../models/quiz.dart';
import '../models/saved_quiz_result.dart';

/// Contract for persisting user and quiz result data (Firestore on mobile, REST on desktop).
abstract class IFirestoreService {
  Future<void> ensureUserOnSignIn();
  Future<void> saveQuizResult(
    String quizId,
    String quizTitle,
    QuizResult result,
  );
  Future<List<SavedQuizResult>> listQuizResults();

  /// Deletes the signed-in user's profile and quizResults. Auth user is deleted separately.
  Future<void> deleteUserData();
}
