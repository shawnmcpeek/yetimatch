import 'package:flutter_test/flutter_test.dart';
import 'package:yetimatch/models/quiz.dart';

void main() {
  group('Quiz', () {
    test('fromJson parses minimal quiz', () {
      final q = Quiz.fromJson({
        'id': 'quiz1',
        'title': 'Test Quiz',
        'description': 'A test',
        'questions': [],
        'results': [
          {
            'characterId': 'r1',
            'characterName': 'Result 1',
            'description': 'You are R1',
            'traits': ['t1'],
          },
        ],
      });
      expect(q.id, 'quiz1');
      expect(q.title, 'Test Quiz');
      expect(q.questions, isEmpty);
      expect(q.results.length, 1);
      expect(q.results.first.characterId, 'r1');
    });

    test('fromJson parses questions and answers', () {
      final q = Quiz.fromJson({
        'id': 'q',
        'title': 'T',
        'description': 'D',
        'questions': [
          {
            'id': 'q1',
            'text': 'Question 1?',
            'answers': [
              {'id': 'a1', 'text': 'Answer 1', 'characterId': 'c1'},
            ],
          },
        ],
        'results': [
          {'characterId': 'c1', 'characterName': 'C1', 'description': 'D1', 'traits': []},
        ],
      });
      expect(q.questions.length, 1);
      expect(q.questions.first.id, 'q1');
      expect(q.questions.first.text, 'Question 1?');
      expect(q.questions.first.answers.length, 1);
      expect(q.questions.first.answers.first.characterId, 'c1');
    });
  });

  group('Question', () {
    test('fromJson defaults missing fields', () {
      final q = Question.fromJson({});
      expect(q.id, '');
      expect(q.text, '');
      expect(q.answers, isEmpty);
    });
  });

  group('Answer', () {
    test('fromJson parses full object', () {
      final a = Answer.fromJson({
        'id': 'a1',
        'text': 'Option A',
        'characterId': 'espresso',
      });
      expect(a.id, 'a1');
      expect(a.text, 'Option A');
      expect(a.characterId, 'espresso');
    });
  });

  group('QuizResult', () {
    test('fromJson parses with optional visualDescription and imageUrl', () {
      final r = QuizResult.fromJson({
        'characterId': 'latte',
        'characterName': 'Latte',
        'description': 'You are smooth.',
        'traits': ['calm', 'sweet'],
        'visualDescription': 'Cup of latte',
        'imageUrl': 'https://example.com/latte.png',
      });
      expect(r.characterId, 'latte');
      expect(r.characterName, 'Latte');
      expect(r.traits, ['calm', 'sweet']);
      expect(r.visualDescription, 'Cup of latte');
      expect(r.imageUrl, 'https://example.com/latte.png');
    });

    test('fromJson defaults optional fields to null', () {
      final r = QuizResult.fromJson({
        'characterId': 'x',
        'characterName': 'X',
        'description': 'D',
        'traits': [],
      });
      expect(r.visualDescription, isNull);
      expect(r.imageUrl, isNull);
    });
  });
}
