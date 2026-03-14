import 'package:flutter_test/flutter_test.dart';
import 'package:yetimatch/models/quiz.dart';
import 'package:yetimatch/services/quiz_service.dart';

void main() {
  late QuizService quizService;

  setUp(() {
    quizService = QuizService();
  });

  group('loadManifestFromJson', () {
    test('parses valid manifest JSON', () {
      const json = '''
      {
        "categories": [{"id": "c1", "name": "Cat1", "description": "Desc1"}],
        "quizzes": [{"id": "q1", "title": "Q1", "description": "D1", "categoryId": "c1"}]
      }
      ''';
      final manifest = quizService.loadManifestFromJson(json);
      expect(manifest.categories.length, 1);
      expect(manifest.quizzes.length, 1);
      expect(manifest.quizzes.first.id, 'q1');
    });

    test('throws on invalid JSON', () {
      expect(
        () => quizService.loadManifestFromJson('not json'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('loadQuizFromJson', () {
    test('parses valid quiz JSON', () {
      const json = '''
      {
        "id": "test-quiz",
        "title": "Test",
        "description": "Desc",
        "questions": [
          {"id": "q1", "text": "Q?", "answers": [{"id": "a1", "text": "A", "characterId": "c1"}]}
        ],
        "results": [
          {"characterId": "c1", "characterName": "C1", "description": "D1", "traits": []}
        ]
      }
      ''';
      final quiz = quizService.loadQuizFromJson(json);
      expect(quiz.id, 'test-quiz');
      expect(quiz.questions.length, 1);
      expect(quiz.results.length, 1);
    });
  });

  group('calculateResult', () {
    test('returns first result when no answers selected', () {
      final quiz = Quiz(
        id: 'q',
        title: 'Q',
        description: 'D',
        questions: [],
        results: [
          const QuizResult(
            characterId: 'default',
            characterName: 'Default',
            description: 'Default result',
            traits: [],
          ),
        ],
      );
      final result = quizService.calculateResult(quiz, {});
      expect(result.characterId, 'default');
    });

    test('returns winning character by vote count', () {
      final quiz = Quiz(
        id: 'q',
        title: 'Q',
        description: 'D',
        questions: [
          Question(
            id: 'q1',
            text: 'Q1?',
            answers: [
              const Answer(id: 'a1', text: 'A1', characterId: 'espresso'),
              const Answer(id: 'a2', text: 'A2', characterId: 'latte'),
            ],
          ),
          Question(
            id: 'q2',
            text: 'Q2?',
            answers: [
              const Answer(id: 'a1', text: 'A1', characterId: 'espresso'),
              const Answer(id: 'a2', text: 'A2', characterId: 'latte'),
            ],
          ),
        ],
        results: [
          const QuizResult(
            characterId: 'espresso',
            characterName: 'Espresso',
            description: 'Strong',
            traits: [],
          ),
          const QuizResult(
            characterId: 'latte',
            characterName: 'Latte',
            description: 'Smooth',
            traits: [],
          ),
        ],
      );
      // Two votes for espresso, one for latte
      final selected = {'q1': 'a1', 'q2': 'a1'};
      final result = quizService.calculateResult(quiz, selected);
      expect(result.characterId, 'espresso');
    });

    test('returns first result when tie (reduce picks first)', () {
      final quiz = Quiz(
        id: 'q',
        title: 'Q',
        description: 'D',
        questions: [
          Question(
            id: 'q1',
            text: 'Q1?',
            answers: [
              const Answer(id: 'a1', text: 'A1', characterId: 'A'),
              const Answer(id: 'a2', text: 'A2', characterId: 'B'),
            ],
          ),
        ],
        results: [
          const QuizResult(
            characterId: 'A',
            characterName: 'A',
            description: 'A',
            traits: [],
          ),
          const QuizResult(
            characterId: 'B',
            characterName: 'B',
            description: 'B',
            traits: [],
          ),
        ],
      );
      final result = quizService.calculateResult(quiz, {'q1': 'a1'});
      expect(result.characterId, 'A');
    });
  });
}
