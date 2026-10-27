/// A quiz final result persisted for the signed-in user (latest run per quiz).
class SavedQuizResult {
  const SavedQuizResult({
    required this.quizId,
    required this.quizTitle,
    required this.characterId,
    required this.characterName,
    required this.description,
    required this.traits,
    this.completedAt,
  });

  final String quizId;
  final String quizTitle;
  final String characterId;
  final String characterName;
  final String description;
  final List<String> traits;
  final DateTime? completedAt;
}
