import 'package:flutter_test/flutter_test.dart';
import 'package:yetimatch/models/manifest.dart';

void main() {
  group('QuizManifest', () {
    test('fromJson parses empty manifest', () {
      final m = QuizManifest.fromJson({'categories': [], 'quizzes': []});
      expect(m.categories, isEmpty);
      expect(m.quizzes, isEmpty);
    });

    test('fromJson parses categories and quizzes', () {
      final m = QuizManifest.fromJson({
        'categories': [
          {
            'id': 'cat1',
            'name': 'Category One',
            'description': 'First category',
          },
        ],
        'quizzes': [
          {
            'id': 'quiz1',
            'title': 'Quiz One',
            'description': 'First quiz',
            'categoryId': 'cat1',
            'resourcePath': 'quizzes/one.json',
          },
        ],
      });
      expect(m.categories.length, 1);
      expect(m.categories.first.id, 'cat1');
      expect(m.categories.first.name, 'Category One');
      expect(m.quizzes.length, 1);
      expect(m.quizzes.first.id, 'quiz1');
      expect(m.quizzes.first.title, 'Quiz One');
      expect(m.quizzes.first.resourcePath, 'quizzes/one.json');
    });

    test('fromJson handles null/missing fields with defaults', () {
      final m = QuizManifest.fromJson({});
      expect(m.categories, isEmpty);
      expect(m.quizzes, isEmpty);
    });
  });

  group('Category', () {
    test('fromJson parses full object', () {
      final c = Category.fromJson({
        'id': 'who-am-i',
        'name': 'Who Am I?',
        'description': 'Match to characters',
      });
      expect(c.id, 'who-am-i');
      expect(c.name, 'Who Am I?');
      expect(c.description, 'Match to characters');
    });

    test('fromJson defaults missing fields to empty string', () {
      final c = Category.fromJson({});
      expect(c.id, '');
      expect(c.name, '');
      expect(c.description, '');
    });
  });

  group('QuizMeta', () {
    test('fromJson parses full object', () {
      final q = QuizMeta.fromJson({
        'id': 'coffee-quiz',
        'title': 'Coffee Quiz',
        'description': 'Which coffee are you?',
        'categoryId': 'fun',
        'resourcePath': 'quizzes/coffee.json',
      });
      expect(q.id, 'coffee-quiz');
      expect(q.title, 'Coffee Quiz');
      expect(q.description, 'Which coffee are you?');
      expect(q.categoryId, 'fun');
      expect(q.resourcePath, 'quizzes/coffee.json');
    });

    test('fromJson defaults resourcePath to empty string', () {
      final q = QuizMeta.fromJson({
        'id': 'x',
        'title': 'T',
        'description': 'D',
        'categoryId': 'c',
      });
      expect(q.resourcePath, '');
    });
  });
}
