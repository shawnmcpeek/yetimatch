import 'dart:convert';

import '../models/manifest.dart';
import '../models/quiz.dart';

class QuizService {
  QuizManifest loadManifestFromJson(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return QuizManifest.fromJson(map);
  }

  Quiz loadQuizFromJson(String jsonString) {
    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return Quiz.fromJson(map);
  }

  QuizResult calculateResult(Quiz quiz, Map<String, String> selectedAnswers) {
    final characterVotes = <String, int>{};
    for (final e in selectedAnswers.entries) {
      final qList = quiz.questions.where((q) => q.id == e.key).toList();
      final question = qList.isEmpty ? null : qList.first;
      final aList = question?.answers.where((a) => a.id == e.value).toList();
      final answer = (aList == null || aList.isEmpty) ? null : aList.first;
      if (answer != null) {
        characterVotes[answer.characterId] =
            (characterVotes[answer.characterId] ?? 0) + 1;
      }
    }
    if (characterVotes.isEmpty) {
      return quiz.results.first;
    }
    final winningId = characterVotes.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
    return quiz.results.firstWhere(
      (r) => r.characterId == winningId,
      orElse: () => quiz.results.first,
    );
  }
}
