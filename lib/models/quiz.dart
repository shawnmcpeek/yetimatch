class Quiz {
  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.results,
  });

  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final List<QuizResult> results;

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      results: (json['results'] as List<dynamic>?)
              ?.map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Question {
  const Question({
    required this.id,
    required this.text,
    required this.answers,
  });

  final String id;
  final String text;
  final List<Answer> answers;

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      answers: (json['answers'] as List<dynamic>?)
              ?.map((e) => Answer.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Answer {
  const Answer({
    required this.id,
    required this.text,
    required this.characterId,
  });

  final String id;
  final String text;
  final String characterId;

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      characterId: json['characterId'] as String? ?? '',
    );
  }
}

class QuizResult {
  const QuizResult({
    required this.characterId,
    required this.characterName,
    required this.description,
    required this.traits,
    this.visualDescription,
    this.imageUrl,
  });

  final String characterId;
  final String characterName;
  final String description;
  final List<String> traits;
  final String? visualDescription;
  final String? imageUrl;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      characterId: json['characterId'] as String? ?? '',
      characterName: json['characterName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      traits: (json['traits'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      visualDescription: json['visualDescription'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
